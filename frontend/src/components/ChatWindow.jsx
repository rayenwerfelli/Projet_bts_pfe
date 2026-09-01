import React, { useState, useRef, useEffect } from 'react';
import MessageBubble from './MessageBubble';
import DomainSelector from './DomainSelector';

const SAMPLE_QUESTIONS = {
  microprojets: [
    'Combien de demandes acceptées ce mois ?',
    'Montant total accordé par secteur ?',
    'Délai moyen DSA par agence ?',
  ],
  recouvrement: [
    'Taux de recouvrement global ?',
    'Clients avec impayés plus de 365 jours ?',
    'Répartition impayés par tranche ?',
  ],
  commercial: [
    'Comptes ouverts ce mois ?',
    'Nombre de comptes gelés par agence ?',
    'Répartition soldes par tranche ?',
  ],
};

const DOMAIN_TO_DASH = {
  microprojets: 'dash1',
  recouvrement: 'dash7',
  commercial: 'dash4',
};

// URL du backend : en prod via Nginx /api/, en dev direct :8000
const API_BASE = process.env.REACT_APP_API_URL || '/api';

function now() {
  return new Date().toLocaleTimeString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit',
  });
}

export default function ChatWindow({ hideHeader, initialDomain }) {
  const [domain, setDomain]     = useState(initialDomain || 'microprojets');
  const [messages, setMessages] = useState([]);
  const [input, setInput]       = useState('');
  const [loading, setLoading]   = useState(false);
  const [apiError, setApiError] = useState(null);
  const bottomRef               = useRef(null);
  const textareaRef             = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, loading]);

  useEffect(() => {
    setMessages([]);
    setApiError(null);
  }, [domain]);

  const sendMessage = async (text) => {
    const userText = (text || input).trim();
    if (!userText || loading) return;
    setInput('');
    setApiError(null);

    // Ajuster la hauteur du textarea
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
    }

    const userMsg = { role: 'user', content: userText, time: now() };
    const updatedMessages = [...messages, userMsg];
    setMessages(updatedMessages);
    setLoading(true);

    try {
      const history = updatedMessages.map((m) => ({
        role: m.role,
        content: m.content,
      }));

      const res = await fetch(`${API_BASE}/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messages: history,
          dashboard_context: DOMAIN_TO_DASH[domain],
          execute_sql: true,
          database_id: 2,
        }),
      });

      if (!res.ok) {
        const errText = await res.text();
        throw new Error(`Erreur serveur ${res.status} : ${errText}`);
      }

      const data = await res.json();

      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          content: data.response || data.answer || '(Pas de réponse)',
          sql: data.sql || null,
          sqlResult: data.data ? { columns: data.data.columns, data: data.data.data } : null,
          time: now(),
        },
      ]);
    } catch (err) {
      setApiError(err.message);
      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          content: `⚠️ Erreur de connexion : ${err.message}`,
          time: now(),
        },
      ]);
    } finally {
      setLoading(false);
    }
  };

  const handleKey = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const handleTextareaChange = (e) => {
    setInput(e.target.value);
    // Auto-resize
    e.target.style.height = 'auto';
    e.target.style.height = Math.min(e.target.scrollHeight, 120) + 'px';
  };

  const clearConversation = () => {
    setMessages([]);
    setApiError(null);
  };

  return (
    <div style={styles.shell}>
      {/* Header */}
      {!hideHeader && (
      <div style={styles.header}>
        <div style={styles.logoWrap}>
          <div style={styles.logoIcon}>BI</div>
          <div>
            <div style={styles.logoTitle}>Assistant BI — BTS</div>
            <div style={styles.logoSub}>Groq · llama-3.3-70b-versatile</div>
          </div>
        </div>
        <div style={styles.headerActions}>
          {messages.length > 0 && (
            <button style={styles.clearBtn} onClick={clearConversation} title="Nouvelle conversation">
              ↺ Nouveau
            </button>
          )}
          <div style={styles.statusDot} title="Connecté" />
        </div>
      </div>
      )}

      {/* Sélecteur de domaine */}
      <DomainSelector selected={domain} onChange={setDomain} />

      {/* Zone de messages */}
      <div style={styles.messages}>
        {messages.length === 0 && (
          <div style={styles.welcome}>
            <div style={styles.welcomeIcon}>💬</div>
            <div style={styles.welcomeTitle}>Comment puis-je vous aider ?</div>
            <div style={styles.welcomeSub}>
              Posez une question sur le domaine <strong>{domain}</strong>
            </div>
            <div style={styles.suggestions}>
              {(SAMPLE_QUESTIONS[domain] || []).map((q) => (
                <button
                  key={q}
                  style={styles.suggestion}
                  onClick={() => sendMessage(q)}
                >
                  {q}
                </button>
              ))}
            </div>
          </div>
        )}

        {messages.map((msg, i) => (
          <MessageBubble key={i} message={msg} />
        ))}

        {/* Indicateur de frappe */}
        {loading && (
          <div style={styles.typingRow} className="fade-in">
            <div style={styles.typingAvatar}>BI</div>
            <div style={styles.typingBubble}>
              <span style={{ ...styles.typingDot, animationDelay: '0s' }} />
              <span style={{ ...styles.typingDot, animationDelay: '0.2s' }} />
              <span style={{ ...styles.typingDot, animationDelay: '0.4s' }} />
            </div>
          </div>
        )}

        <div ref={bottomRef} />
      </div>

      {/* Bandeau d'erreur API */}
      {apiError && (
        <div style={styles.errorBanner}>
          ⚠️ {apiError}
          <button style={styles.errorClose} onClick={() => setApiError(null)}>✕</button>
        </div>
      )}

      {/* Zone de saisie */}
      <div style={styles.inputArea}>
        <textarea
          ref={textareaRef}
          style={styles.textarea}
          placeholder={`Question sur ${domain}… (Entrée pour envoyer)`}
          value={input}
          onChange={handleTextareaChange}
          onKeyDown={handleKey}
          rows={1}
          disabled={loading}
        />
        <button
          style={{
            ...styles.sendBtn,
            ...(loading || !input.trim() ? styles.sendBtnDisabled : {}),
          }}
          onClick={() => sendMessage()}
          disabled={loading || !input.trim()}
          title="Envoyer"
        >
          ➤
        </button>
      </div>
    </div>
  );
}

const styles = {
  shell: {
    display: 'flex',
    flexDirection: 'column',
    height: '100vh',
    background: '#F8F9FA',
    fontFamily: 'Inter, sans-serif',
  },
  header: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '14px 20px',
    background: '#fff',
    borderBottom: '1px solid #F1F3F5',
    boxShadow: '0 1px 4px rgba(0,0,0,0.06)',
  },
  logoWrap:  { display: 'flex', alignItems: 'center', gap: '12px' },
  logoIcon:  {
    width: '40px', height: '40px', borderRadius: '12px',
    background: 'linear-gradient(135deg, #C0392B, #E74C3C)',
    color: '#fff', display: 'flex', alignItems: 'center',
    justifyContent: 'center', fontWeight: 700, fontSize: '14px',
    boxShadow: '0 2px 8px rgba(192,57,43,0.35)',
  },
  logoTitle: { fontWeight: 700, fontSize: '16px', color: '#212529' },
  logoSub:   { fontSize: '11px', color: '#ADB5BD', marginTop: '1px' },
  headerActions: { display: 'flex', alignItems: 'center', gap: '12px' },
  clearBtn: {
    padding: '5px 10px', borderRadius: '8px', border: '1px solid #E9ECEF',
    background: '#F8F9FA', color: '#6C757D', fontSize: '12px',
    cursor: 'pointer', fontFamily: 'Inter, sans-serif',
  },
  statusDot: {
    width: '10px', height: '10px', borderRadius: '50%',
    background: '#27AE60', boxShadow: '0 0 0 3px rgba(39,174,96,0.2)',
  },
  messages: {
    flex: 1, overflowY: 'auto', padding: '24px 20px',
    display: 'flex', flexDirection: 'column',
  },
  welcome: {
    margin: 'auto', textAlign: 'center', maxWidth: '420px', paddingTop: '20px',
  },
  welcomeIcon:  { fontSize: '48px', marginBottom: '16px' },
  welcomeTitle: { fontSize: '20px', fontWeight: 700, color: '#212529', marginBottom: '8px' },
  welcomeSub:   { fontSize: '14px', color: '#6C757D', marginBottom: '24px' },
  suggestions:  { display: 'flex', flexDirection: 'column', gap: '8px' },
  suggestion:   {
    padding: '10px 16px', borderRadius: '10px',
    border: '1.5px solid #FADBD8', background: '#FEF9F9',
    color: '#C0392B', cursor: 'pointer', fontSize: '13px',
    fontFamily: 'Inter, sans-serif', fontWeight: 500, textAlign: 'left',
    transition: 'all 0.15s ease',
  },
  typingRow:    { display: 'flex', alignItems: 'flex-end', gap: '10px', marginBottom: '18px' },
  typingAvatar: {
    width: '34px', height: '34px', borderRadius: '50%',
    background: 'linear-gradient(135deg, #C0392B, #E74C3C)',
    color: '#fff', display: 'flex', alignItems: 'center',
    justifyContent: 'center', fontSize: '11px', fontWeight: 700, flexShrink: 0,
  },
  typingBubble: {
    background: '#fff', border: '1px solid #F1F3F5',
    borderRadius: '16px 16px 16px 4px',
    padding: '14px 18px', display: 'flex', gap: '5px', alignItems: 'center',
  },
  typingDot: {
    width: '7px', height: '7px', borderRadius: '50%',
    background: '#C0392B', display: 'inline-block',
    animation: 'pulse 1.2s ease infinite',
  },
  errorBanner: {
    display: 'flex', justifyContent: 'space-between', alignItems: 'center',
    padding: '8px 16px', background: '#FFF3F3',
    borderTop: '1px solid #FADBD8', color: '#C0392B', fontSize: '12px',
  },
  errorClose: {
    background: 'none', border: 'none', color: '#C0392B',
    cursor: 'pointer', fontSize: '14px', padding: '2px 6px',
  },
  inputArea: {
    display: 'flex', gap: '10px', padding: '14px 16px',
    background: '#fff', borderTop: '1px solid #F1F3F5', alignItems: 'flex-end',
  },
  textarea: {
    flex: 1, padding: '11px 14px', borderRadius: '12px',
    border: '1.5px solid #E9ECEF', fontFamily: 'Inter, sans-serif',
    fontSize: '14px', color: '#212529', background: '#F8F9FA',
    resize: 'none', outline: 'none', lineHeight: 1.5,
    maxHeight: '120px', overflowY: 'auto', transition: 'border-color 0.2s',
  },
  sendBtn: {
    width: '44px', height: '44px', borderRadius: '12px', border: 'none',
    background: 'linear-gradient(135deg, #C0392B, #E74C3C)',
    color: '#fff', fontSize: '16px', cursor: 'pointer',
    flexShrink: 0, display: 'flex', alignItems: 'center',
    justifyContent: 'center', boxShadow: '0 2px 8px rgba(192,57,43,0.3)',
  },
  sendBtnDisabled: {
    background: '#E9ECEF', color: '#ADB5BD',
    boxShadow: 'none', cursor: 'not-allowed',
  },
};