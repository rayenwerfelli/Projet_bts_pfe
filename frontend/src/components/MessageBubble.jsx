import React from 'react';
import ReactMarkdown from 'react-markdown';
import SqlResultTable from './SqlResultTable';

export default function MessageBubble({ message }) {
  const isUser = message.role === 'user';

  // Extract columns and rows from the Superset response.
    const extractTableData = (sqlResult) => {
    if (!sqlResult) return { columns: null, data: null };
    // Support both shapes: { columns, data } (from ChatWindow) and a raw
    // Superset object that nests them under .data.
    const cols = sqlResult.columns || sqlResult.data?.columns;
    const rows = Array.isArray(sqlResult.data) ? sqlResult.data : sqlResult.data?.data;
    if (cols && rows) {
      return {
        columns: cols.map((c) => (typeof c === 'string' ? c : c.name || c.column_name)),
        data: rows,
      };
    }
    return { columns: null, data: null };
  };

  const { columns, data } = extractTableData(message.sqlResult);

  // Pull the SQL out of either the dedicated field or the ```sql fence in the text.
  const sqlFromText = (() => {
    const m = (message.content || '').match(/```sql\s*([\s\S]*?)```/i);
    return m ? m[1].trim() : null;
  })();
  const sqlCode = message.sql || sqlFromText;

  // Prose = the answer with the SQL fence removed (SQL is shown separately,
  // either as a result table or as a code block below).
  const displayText = (message.content || '')
    .replace(/```sql[\s\S]*?```/gi, '')
    .trim();

  // A message is "empty to show" if it has no prose, no table, and no SQL.
  const hasTable = columns && data && !message.sqlResult?.error;
  const nothingToShow = !displayText && !hasTable && !sqlCode && !message.sqlResult?.error;

  return (
    <div
      style={{ ...styles.row, justifyContent: isUser ? 'flex-end' : 'flex-start' }}
      className="fade-in"
    >
      {!isUser && <div style={styles.avatar}>BI</div>}

      <div style={{ maxWidth: '75%' }}>
        {/* Prose bubble */}
        {displayText && (
          <div style={isUser ? styles.bubbleUser : styles.bubbleBot}>
            <ReactMarkdown
              components={{
                code({ inline, children }) {
                  if (inline) return <code style={styles.inlineCode}>{children}</code>;
                  return (
                    <pre style={styles.codeBlock}>
                      <code>{children}</code>
                    </pre>
                  );
                },
                p({ children }) { return <p style={styles.para}>{children}</p>; },
                ul({ children }) { return <ul style={styles.list}>{children}</ul>; },
                li({ children }) { return <li style={styles.listItem}>{children}</li>; },
              }}
            >
              {displayText}
            </ReactMarkdown>
          </div>
        )}

        {/* SQL code block — always shown when SQL is present */}
        {sqlCode && (
          <div style={styles.sqlWrap}>
            <div style={styles.sqlLabel}>SQL</div>
            <pre style={styles.sqlBlock}><code>{sqlCode}</code></pre>
          </div>
        )}

        {/* SQL result table */}
        {hasTable && (
          <SqlResultTable columns={columns} data={data} sql={message.sql} />
        )}

        {/* SQL error */}
        {message.sqlResult?.error && (
          <div style={styles.sqlError}>
            ⚠ Erreur SQL : {message.sqlResult.error}
          </div>
        )}

        {/* Fallback so a bubble is never completely empty */}
        {!isUser && nothingToShow && (
          <div style={styles.bubbleBot}>
            <span style={styles.muted}>(Réponse vide)</span>
          </div>
        )}

        <div style={{ ...styles.time, textAlign: isUser ? 'right' : 'left' }}>
          {message.time}
        </div>
      </div>

      {isUser && <div style={styles.avatarUser}>Vous</div>}
    </div>
  );
}

const styles = {
  row: { display: 'flex', alignItems: 'flex-end', gap: '10px', marginBottom: '18px' },
  avatar: {
    width: '34px', height: '34px', borderRadius: '50%',
    background: 'linear-gradient(135deg, #C0392B, #E74C3C)', color: '#fff',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    fontSize: '11px', fontWeight: 700, flexShrink: 0,
    boxShadow: '0 2px 8px rgba(192,57,43,0.3)',
  },
  avatarUser: {
    width: '34px', height: '34px', borderRadius: '50%',
    background: '#343A40', color: '#fff', display: 'flex',
    alignItems: 'center', justifyContent: 'center',
    fontSize: '10px', fontWeight: 600, flexShrink: 0,
  },
  bubbleBot: {
    background: '#fff', border: '1px solid #F1F3F5',
    borderRadius: '16px 16px 16px 4px', padding: '12px 16px',
    color: '#212529', fontSize: '14px', lineHeight: 1.65,
    boxShadow: '0 1px 3px rgba(0,0,0,0.06)',
  },
  bubbleUser: {
    background: 'linear-gradient(135deg, #C0392B, #E74C3C)',
    borderRadius: '16px 16px 4px 16px', padding: '12px 16px',
    color: '#fff', fontSize: '14px', lineHeight: 1.65,
    boxShadow: '0 2px 8px rgba(192,57,43,0.25)',
  },
  inlineCode: {
    background: '#F8F9FA', color: '#C0392B', padding: '1px 5px',
    borderRadius: '4px', fontSize: '12px', fontFamily: 'monospace',
  },
  codeBlock: {
    background: '#F8F9FA', border: '1px solid #F1F3F5', borderRadius: '8px',
    padding: '10px 12px', overflowX: 'auto', fontSize: '12px',
    fontFamily: 'monospace', lineHeight: 1.5, margin: '6px 0',
  },
  sqlWrap: { marginTop: '8px' },
  sqlLabel: {
    fontSize: '10px', fontWeight: 700, color: '#6C757D',
    letterSpacing: '0.5px', marginBottom: '4px',
  },
  sqlBlock: {
    background: '#1E1E2E', color: '#E4E4E7', border: '1px solid #2D2D3A',
    borderRadius: '8px', padding: '12px 14px', overflowX: 'auto',
    fontSize: '12.5px', fontFamily: 'Consolas, Monaco, monospace',
    lineHeight: 1.55, margin: 0, whiteSpace: 'pre',
  },
  para: { marginBottom: '6px' },
  list: { paddingLeft: '18px', marginTop: '4px' },
  listItem: { marginBottom: '3px' },
  muted: { color: '#ADB5BD', fontStyle: 'italic', fontSize: '13px' },
  time: { fontSize: '11px', color: '#ADB5BD', marginTop: '4px', paddingInline: '4px' },
  sqlError: {
    marginTop: '8px', padding: '8px 12px', background: '#FFF3F3',
    border: '1px solid #FADBD8', borderRadius: '8px', color: '#C0392B', fontSize: '12px',
  },
};
