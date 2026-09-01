import React, { useState } from 'react';

export default function SqlResultTable({ columns, data, sql }) {
  const [showSql, setShowSql] = useState(false);

  if (!columns || columns.length === 0) return null;

  return (
    <div style={styles.wrapper}>
      {/* SQL toggle */}
      {sql && (
        <button
          style={styles.sqlToggle}
          onClick={() => setShowSql((v) => !v)}
        >
          {showSql ? '▾ Masquer SQL' : '▸ Voir SQL généré'}
        </button>
      )}
      {showSql && sql && (
        <pre style={styles.sqlBlock}>{sql}</pre>
      )}

      {/* Table */}
      <div style={styles.tableWrapper}>
        <table style={styles.table}>
          <thead>
            <tr>
              {columns.map((col) => (
                <th key={col} style={styles.th}>{col}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.slice(0, 50).map((row, i) => (
              <tr key={i} style={i % 2 === 0 ? styles.trEven : styles.trOdd}>
                {(Array.isArray(row)
                  ? row
                  : columns.map((c) => row[c])
                ).map((cell, j) => (
                  <td key={j} style={styles.td}>
                    {cell === null || cell === undefined ? (
                      <span style={styles.null}>—</span>
                    ) : String(cell)}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div style={styles.footer}>
        {data.length} ligne{data.length > 1 ? 's' : ''}
        {data.length > 50 && ' (50 affichées)'}
      </div>
    </div>
  );
}

const styles = {
  wrapper: {
    marginTop: '10px',
    border: '1px solid #F1F3F5',
    borderRadius: '10px',
    overflow: 'hidden',
    fontSize: '12px',
    background: '#fff',
  },
  sqlToggle: {
    display: 'block',
    width: '100%',
    padding: '6px 12px',
    background: '#F8F9FA',
    border: 'none',
    borderBottom: '1px solid #F1F3F5',
    textAlign: 'left',
    cursor: 'pointer',
    fontSize: '11px',
    color: '#C0392B',
    fontFamily: 'Inter, sans-serif',
    fontWeight: 500,
  },
  sqlBlock: {
    padding: '10px 14px',
    background: '#1E1E2E',
    color: '#CDD6F4',
    fontSize: '11px',
    fontFamily: 'monospace',
    overflowX: 'auto',
    borderBottom: '1px solid #F1F3F5',
    lineHeight: 1.6,
    margin: 0,
    whiteSpace: 'pre-wrap',
  },
  tableWrapper: {
    overflowX: 'auto',
    maxHeight: '260px',
    overflowY: 'auto',
  },
  table: {
    width: '100%',
    borderCollapse: 'collapse',
  },
  th: {
    padding: '7px 12px',
    background: '#FEF9F9',
    color: '#C0392B',
    fontWeight: 600,
    textAlign: 'left',
    borderBottom: '1px solid #FADBD8',
    whiteSpace: 'nowrap',
    position: 'sticky',
    top: 0,
  },
  trEven: { background: '#fff' },
  trOdd:  { background: '#FEF9F9' },
  td: {
    padding: '6px 12px',
    color: '#343A40',
    borderBottom: '1px solid #F8F9FA',
    whiteSpace: 'nowrap',
    maxWidth: '200px',
    overflow: 'hidden',
    textOverflow: 'ellipsis',
  },
  null: { color: '#ADB5BD', fontStyle: 'italic' },
  footer: {
    padding: '5px 12px',
    color: '#ADB5BD',
    fontSize: '11px',
    borderTop: '1px solid #F1F3F5',
    background: '#F8F9FA',
  },
};