import { useState, useEffect, useRef, useCallback } from "react";
import btsLogoSrc from "./assets/bts-logo.png";

// ─── Constants ───────────────────────────────────────────────
const API_BASE = process.env.REACT_APP_API_URL || "http://localhost:8000";

// 🖼️ LOGO: Le fichier logo est dans src/assets/bts-logo.png
// Il est importé directement via: import btsLogoSrc from "./assets/bts-logo.png"

const LogoWithFallback = ({ size = 40 }) => {
  const [imgFailed, setImgFailed] = useState(false);
  if (imgFailed) {
    return (
      <svg width={size} height={size} viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <rect width="100" height="100" rx="14" fill="#C8102E" />
        <g fill="white" transform="translate(18, 15)">
          <rect x="4" y="0" width="56" height="10" rx="3" />
          <rect x="4" y="14" width="44" height="8" rx="3" />
          <rect x="4" y="26" width="32" height="8" rx="3" />
          <rect x="16" y="40" width="44" height="8" rx="3" />
          <rect x="16" y="52" width="44" height="8" rx="3" />
          <rect x="4" y="64" width="56" height="8" rx="3" />
        </g>
      </svg>
    );
  }
  return (
    <img
      src={btsLogoSrc}
      width={size}
      height={size}
      alt="BTS Bank"
      style={{ objectFit: "contain", display: "block" }}
      onError={() => setImgFailed(true)}
    />
  );
};

const DASHBOARDS = {
  MICROPROJETS: [
    { id: "dash1", label: "Dashboard 1 — Suivi Demande CIC", sub: "mart_demande_financement", color: "#3B82F6" },
    { id: "dash8", label: "Dashboard 8 — Travail Statistique", sub: "mart_demande_financement", color: "#8B5CF6" },
  ],
  "RECOUVREMENT / FINANCE": [
    { id: "dash7", label: "Dashboard 7 — Suivi Portefeuille RCV", sub: "mart_recouvrement", color: "#F59E0B" },
    { id: "dash10", label: "Dashboard 10 — Effort de recouvrement", sub: "mart_recouvrement", color: "#EF4444" },
  ],
  "COMMERCIAL / AGENCES": [
    { id: "dash4", label: "Dashboard 4 — Ouverture Comptes", sub: "mart_req4_ouverture_comptes", color: "#10B981" },
    { id: "dash5", label: "Dashboard 5 — Comptes Gelés", sub: "fact_compte_gele", color: "#06B6D4" },
  ],
};

const QUICK_PROMPTS = [
  { icon: "📊", text: "Taux de recouvrement par agence ce mois" },
  { icon: "💼", text: "Demandes de financement accordées vs rejetées" },
  { icon: "🔒", text: "Comptes gelés avec exposition totale > 10 000" },
  { icon: "📋", text: "Évolution ouverture de comptes par secteur" },
  { icon: "⚠️", text: "Clients avec impayés > 90 jours" },
  { icon: "🌍", text: "Top 5 gouvernorats par volume de crédit accordé" },
];

const formatTime = (iso) => {
  if (!iso) return "";
  return new Date(iso).toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" });
};

const formatDate = (iso) => {
  if (!iso) return "";
  const d = new Date(iso);
  const today = new Date();
  if (d.toDateString() === today.toDateString()) return "Aujourd'hui";
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  if (d.toDateString() === yesterday.toDateString()) return "Hier";
  return d.toLocaleDateString("fr-FR", { day: "numeric", month: "short" });
};

const api = {
  async getSessions() {
    const r = await fetch(`${API_BASE}/sessions?limit=50`);
    return r.json();
  },
  async createSession(title, dashboard) {
    const r = await fetch(`${API_BASE}/sessions`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title, dashboard }),
    });
    return r.json();
  },
  async deleteSession(id) {
    await fetch(`${API_BASE}/sessions/${id}`, { method: "DELETE" });
  },
  async getSessionMessages(id) {
    const r = await fetch(`${API_BASE}/sessions/${id}/messages`);
    return r.json();
  },
  async chat(messages, sessionId, dashboardContext) {
    const r = await fetch(`${API_BASE}/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        messages,
        session_id: sessionId,
        dashboard_context: dashboardContext,
        execute_sql: false,
        save_history: true,
      }),
    });
    return r.json();
  },
};

// ─── SQL Block ────────────────────────────────────────────────
const SqlBlock = ({ sql }) => {
  const [copied, setCopied] = useState(false);
  const copy = () => {
    navigator.clipboard.writeText(sql);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };
  return (
    <div className="sql-block">
      <div className="sql-header">
        <div className="sql-header-left">
          <span className="sql-dot" />
          <span className="sql-dot" style={{ background: "#fbbf24" }} />
          <span className="sql-dot" style={{ background: "#34d399" }} />
          <span className="sql-label">SQL</span>
        </div>
        <button onClick={copy} className={`copy-btn ${copied ? "copied" : ""}`}>
          {copied ? "✓ Copié !" : "Copier"}
        </button>
      </div>
      <pre className="sql-pre">{sql}</pre>
    </div>
  );
};

// ─── Message ──────────────────────────────────────────────────
const Message = ({ msg, isNew }) => {
  const isUser = msg.role === "user";
  const sqlMatch = msg.content?.match(/```sql\n?([\s\S]*?)```/i);
  const sql = sqlMatch ? sqlMatch[1].trim() : null;
  const textContent = msg.content?.replace(/```sql\n?[\s\S]*?```/gi, "").trim();

  const formatText = (text) => {
    if (!text) return null;
    return text.split("\n").map((line, i) => {
      if (line.startsWith("## ")) return <h3 key={i} className="msg-h3">{line.slice(3)}</h3>;
      if (line.startsWith("### ")) return <h4 key={i} className="msg-h4">{line.slice(4)}</h4>;
      if (line.startsWith("**") && line.endsWith("**"))
        return <p key={i} className="msg-p" style={{ fontWeight: 700 }}>{line.slice(2, -2)}</p>;
      if (line.startsWith("- ") || line.startsWith("• "))
        return <li key={i} className="msg-li">{line.slice(2)}</li>;
      if (line.startsWith("> "))
        return <blockquote key={i} className="msg-quote">{line.slice(2)}</blockquote>;
      if (line === "") return <br key={i} />;
      const parts = line.split(/(\*\*[^*]+\*\*)/g);
      return (
        <p key={i} className="msg-p">
          {parts.map((part, j) =>
            part.startsWith("**") && part.endsWith("**")
              ? <strong key={j}>{part.slice(2, -2)}</strong>
              : part
          )}
        </p>
      );
    });
  };

  return (
    <div className={`msg-wrapper ${isUser ? "user" : "bot"} ${isNew ? "msg-enter" : ""}`}>
      {!isUser && (
        <div className="avatar-bot">
          <LogoWithFallback size={22} />
        </div>
      )}
      <div className="msg-inner">
        <div className={`bubble ${isUser ? "bubble-user" : "bubble-bot"}`}>
          <div className="bubble-content">
            {formatText(textContent)}
          </div>
          {sql && <SqlBlock sql={sql} />}
        </div>
        <span className="msg-time">{formatTime(msg.created_at)}</span>
      </div>
      {isUser && (
        <div className="avatar-user">
          <span>U</span>
        </div>
      )}
    </div>
  );
};

// ─── Session Item ─────────────────────────────────────────────
const SessionItem = ({ session, isActive, onSelect, onDelete }) => (
  <div
    className={`session-item ${isActive ? "active" : ""}`}
    onClick={onSelect}
  >
    <div className="session-icon">💬</div>
    <div className="session-text">
      <div className="session-title">{session.title}</div>
      <div className="session-date">{formatDate(session.updated_at)}</div>
    </div>
    <button
      className="session-delete"
      onClick={(e) => { e.stopPropagation(); onDelete(session.id); }}
      title="Supprimer"
    >×</button>
  </div>
);

// ─── Main App ─────────────────────────────────────────────────
export default function BTSChatbot() {
  const [sessions, setSessions] = useState([]);
  const [activeSession, setActiveSession] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMsgIndex, setNewMsgIndex] = useState(-1);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [activeDashboard, setActiveDashboard] = useState(null);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [supersetUrl] = useState(process.env.REACT_APP_SUPERSET_URL || "http://localhost:8088");
  const messagesEndRef = useRef(null);
  const textareaRef = useRef(null);

  useEffect(() => { loadSessions(); }, []);
  useEffect(() => { messagesEndRef.current?.scrollIntoView({ behavior: "smooth" }); }, [messages]);

  const loadSessions = async () => {
    try {
      const data = await api.getSessions();
      setSessions(data.sessions || []);
    } catch { /* no-op */ }
  };

  const selectSession = async (session) => {
    setActiveSession(session);
    try {
      const data = await api.getSessionMessages(session.id);
      setMessages(data.messages || []);
      if (session.dashboard) setActiveDashboard(session.dashboard);
    } catch { setMessages([]); }
  };

  const newConversation = () => {
    setActiveSession(null);
    setMessages([]);
    setActiveDashboard(null);
  };

  const deleteSession = async (id) => {
    await api.deleteSession(id);
    if (activeSession?.id === id) newConversation();
    loadSessions();
  };

  const activeDashboardLabel = () => {
    if (!activeDashboard) return "Tous les dashboards";
    for (const group of Object.values(DASHBOARDS)) {
      const found = group.find((d) => d.id === activeDashboard);
      if (found) return found.label.replace(/^Dashboard \d+ — /, "");
    }
    return activeDashboard;
  };

  const sendMessage = useCallback(async (text) => {
    const userText = text || input.trim();
    if (!userText || loading) return;
    setInput("");

    const userMsg = { role: "user", content: userText, created_at: new Date().toISOString() };
    setMessages((prev) => { setNewMsgIndex(prev.length); return [...prev, userMsg]; });
    setLoading(true);

    try {
      const data = await api.chat(
        [{ role: "user", content: userText }],
        activeSession?.id || null,
        activeDashboard
      );

      if (data.session_id && !activeSession) {
        const newSess = { id: data.session_id, title: userText.slice(0, 60), updated_at: new Date().toISOString() };
        setActiveSession(newSess);
        loadSessions();
      }

      const botMsg = {
        role: "assistant",
        content: data.response,
        created_at: new Date().toISOString(),
      };
      setMessages((prev) => { setNewMsgIndex(prev.length); return [...prev, botMsg]; });
    } catch (e) {
      setMessages((prev) => [
        ...prev,
        { role: "assistant", content: `❌ Erreur de connexion: ${e.message}`, created_at: new Date().toISOString() },
      ]);
    } finally {
      setLoading(false);
    }
  }, [input, loading, activeSession, activeDashboard]);

  const handleKeyDown = (e) => {
    if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  };

  const isEmptyChat = messages.length === 0;

  return (
    <div className="root">
      <style>{CSS}</style>

      {/* Sidebar */}
      <aside className={`sidebar ${sidebarCollapsed ? "collapsed" : ""}`}>
        <div className="sidebar-header">
          <div className="sidebar-logo">
            <LogoWithFallback size={38} />
          </div>
          <div className="sidebar-brand">
            <div className="sidebar-title">BTS BI Assistant</div>
            <div className="sidebar-sub">Banque Tunisienne de Solidarité</div>
          </div>
        </div>

        <button className="new-chat-btn" onClick={newConversation}>
          <span className="new-chat-icon">＋</span>
          Nouvelle conversation
        </button>

        {Object.entries(DASHBOARDS).map(([group, dashboards]) => (
          <div key={group} className="sidebar-group">
            <div className="group-label">{group}</div>
            {dashboards.map((dash) => (
              <button
                key={dash.id}
                className={`dash-btn ${activeDashboard === dash.id ? "active" : ""}`}
                style={{ "--dash-color": dash.color }}
                onClick={() => setActiveDashboard(activeDashboard === dash.id ? null : dash.id)}
              >
                <span className="dash-dot" style={{ background: dash.color }} />
                <div>
                  <div className="dash-label">{dash.label}</div>
                  <div className="dash-sub">{dash.sub}</div>
                </div>
              </button>
            ))}
          </div>
        ))}

        {sessions.length > 0 && (
          <div className="sidebar-group">
            <div className="group-label">HISTORIQUE</div>
            {sessions.map((s) => (
              <SessionItem
                key={s.id}
                session={s}
                isActive={activeSession?.id === s.id}
                onSelect={() => selectSession(s)}
                onDelete={deleteSession}
              />
            ))}
          </div>
        )}

        <div className="sidebar-footer">
          <span className="status-dot" />
          <span className="status-text">Connecté · PostgreSQL DWH BTS</span>
        </div>
      </aside>

      {/* Main */}
      <main className="main">
        {/* Top bar */}
        <header className="topbar">
          <button className="collapse-btn" onClick={() => setSidebarCollapsed(v => !v)}>
            {sidebarCollapsed
              ? <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
              : <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            }
          </button>
          <span className="topbar-title">Assistant BI Analytique</span>
          <div className="topbar-right">
            <div className="context-badge">
              <span className="context-dot" />
              <span>{activeDashboardLabel()}</span>
            </div>
            <a href={supersetUrl} target="_blank" rel="noopener noreferrer" className="superset-btn">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{marginRight:5}}><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>
              Superset
            </a>
            <button
              onClick={() => window.keycloak?.logout()}
              style={{ background:"#C8102E", color:"#fff", border:"none", padding:"6px 14px", borderRadius:"8px", cursor:"pointer", fontSize:"13px", display:"flex", alignItems:"center", gap:"6px" }}
              title="Se déconnecter"
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
              Déconnexion
            </button>
          </div>
        </header>

        {/* Chat area */}
        <div className="chat-area">
          {isEmptyChat ? (
            <div className="welcome">
              <div className="welcome-logo-wrap">
                <LogoWithFallback size={72} />
                <div className="welcome-logo-ring" />
              </div>
              <h1 className="welcome-title">Bonjour, comment puis-je vous aider ?</h1>
              <p className="welcome-sub">
                Assistant BI connecté aux 6 dashboards de la BTS.<br />
                Posez vos questions en français — je génère le SQL et analyse vos données.
              </p>
              <div className="quick-grid">
                {QUICK_PROMPTS.map((q, i) => (
                  <button
                    key={i}
                    className="quick-btn"
                    style={{ animationDelay: `${i * 0.07}s` }}
                    onClick={() => sendMessage(q.text)}
                  >
                    <span className="quick-icon">{q.icon}</span>
                    <span className="quick-text">{q.text}</span>
                    <span className="quick-arrow">→</span>
                  </button>
                ))}
              </div>
            </div>
          ) : (
            <div className="msg-list">
              {messages.map((msg, i) => (
                <Message key={i} msg={msg} isNew={i === newMsgIndex} />
              ))}
              {loading && (
                <div className="msg-wrapper bot msg-enter">
                  <div className="avatar-bot"><LogoWithFallback size={22} /></div>
                  <div className="typing-bubble">
                    <span className="tdot" />
                    <span className="tdot" style={{ animationDelay: "0.18s" }} />
                    <span className="tdot" style={{ animationDelay: "0.36s" }} />
                  </div>
                </div>
              )}
              <div ref={messagesEndRef} />
            </div>
          )}
        </div>

        {/* Input bar */}
        <div className="input-bar">
          <div className={`input-wrapper ${input ? "focused" : ""}`}>
            <textarea
              ref={textareaRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Posez votre question analytique en français..."
              className="textarea"
              rows={1}
              disabled={loading}
            />
            <button
              className={`send-btn ${input.trim() && !loading ? "active" : ""}`}
              onClick={() => sendMessage()}
              disabled={!input.trim() || loading}
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <line x1="22" y1="2" x2="11" y2="13" />
                <polygon points="22 2 15 22 11 13 2 9 22 2" />
              </svg>
            </button>
          </div>
          <div className="input-hint">
            ↵ Envoyer · ⇧↵ Nouvelle ligne · Connecté à PostgreSQL DWH BTS
          </div>
        </div>
      </main>
    </div>
  );
}

// ─── CSS ──────────────────────────────────────────────────────
const CSS = `
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Fira+Code:wght@400;500&display=swap');

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Inter', -apple-system, sans-serif; }

  ::-webkit-scrollbar { width: 4px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: rgba(200,16,46,0.2); border-radius: 4px; }

  /* ── Root ── */
  .root {
    display: flex;
    height: 100vh;
    background: #0D0D1A;
    font-family: 'Inter', sans-serif;
    overflow: hidden;
  }

  /* ── Sidebar ── */
  .sidebar {
    width: 272px;
    min-width: 0;
    background: linear-gradient(180deg, #12122A 0%, #0D0D1A 100%);
    border-right: 1px solid rgba(200,16,46,0.15);
    display: flex;
    flex-direction: column;
    transition: width 0.3s cubic-bezier(0.4,0,0.2,1), opacity 0.3s ease;
    flex-shrink: 0;
    overflow-y: auto;
    overflow-x: hidden;
  }
  .sidebar.collapsed { width: 0; opacity: 0; pointer-events: none; }

  .sidebar-header {
    display: flex;
    align-items: center;
    padding: 22px 16px 18px;
    border-bottom: 1px solid rgba(255,255,255,0.05);
    gap: 12px;
  }
  .sidebar-logo {
    width: 44px;
    height: 44px;
    border-radius: 12px;
    background: white;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 3px;
    box-shadow: 0 4px 12px rgba(200,16,46,0.3);
    flex-shrink: 0;
    overflow: hidden;
  }
  .sidebar-title {
    color: #fff;
    font-weight: 700;
    font-size: 13.5px;
    letter-spacing: 0.2px;
  }
  .sidebar-sub {
    color: rgba(255,255,255,0.35);
    font-size: 10.5px;
    margin-top: 2px;
  }

  .new-chat-btn {
    margin: 14px 12px 6px;
    padding: 10px 14px;
    background: rgba(200,16,46,0.12);
    border: 1px solid rgba(200,16,46,0.3);
    border-radius: 10px;
    color: #ff8fa3;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s;
    width: calc(100% - 24px);
    font-family: 'Inter', sans-serif;
  }
  .new-chat-btn:hover {
    background: rgba(200,16,46,0.22);
    border-color: rgba(200,16,46,0.5);
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(200,16,46,0.15);
  }
  .new-chat-icon { font-size: 15px; }

  .sidebar-group { padding: 14px 0 4px; }
  .group-label {
    color: rgba(255,255,255,0.25);
    font-size: 9.5px;
    font-weight: 600;
    letter-spacing: 1.4px;
    padding: 0 16px 8px;
    text-transform: uppercase;
  }

  .dash-btn {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 9px 14px;
    background: transparent;
    border: none;
    border-left: 3px solid transparent;
    cursor: pointer;
    width: 100%;
    text-align: left;
    transition: all 0.18s;
    font-family: 'Inter', sans-serif;
  }
  .dash-btn:hover { background: rgba(255,255,255,0.04); }
  .dash-btn.active {
    background: rgba(200,16,46,0.1);
    border-left-color: var(--dash-color);
  }
  .dash-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    flex-shrink: 0;
    margin-top: 4px;
    transition: box-shadow 0.2s;
  }
  .dash-btn.active .dash-dot { box-shadow: 0 0 8px var(--dash-color); }
  .dash-label { color: rgba(255,255,255,0.78); font-size: 12px; font-weight: 500; line-height: 1.4; }
  .dash-sub { color: rgba(255,255,255,0.28); font-size: 10px; margin-top: 2px; font-family: 'Fira Code', monospace; }

  /* ── Session items ── */
  .session-item {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    cursor: pointer;
    border-left: 3px solid transparent;
    gap: 8px;
    transition: all 0.15s;
    border-radius: 0 8px 8px 0;
    margin: 1px 6px 1px 0;
  }
  .session-item:hover { background: rgba(255,255,255,0.05); }
  .session-item.active {
    background: rgba(200,16,46,0.1);
    border-left-color: #C8102E;
  }
  .session-icon { font-size: 12px; opacity: 0.4; flex-shrink: 0; }
  .session-text { flex: 1; min-width: 0; }
  .session-title { color: rgba(255,255,255,0.7); font-size: 12px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .session-date { color: rgba(255,255,255,0.28); font-size: 10px; margin-top: 1px; }
  .session-delete {
    background: none;
    border: none;
    color: rgba(255,255,255,0.3);
    cursor: pointer;
    font-size: 16px;
    line-height: 1;
    flex-shrink: 0;
    opacity: 0;
    transition: opacity 0.15s;
    padding: 0 2px;
  }
  .session-item:hover .session-delete { opacity: 1; }

  .sidebar-footer {
    margin-top: auto;
    padding: 14px 16px;
    border-top: 1px solid rgba(255,255,255,0.06);
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .status-dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #22c55e;
    box-shadow: 0 0 8px #22c55e, 0 0 16px rgba(34,197,94,0.4);
    animation: pulse-dot 2s ease-in-out infinite;
    flex-shrink: 0;
  }
  .status-text { color: rgba(255,255,255,0.3); font-size: 10px; }

  /* ── Main ── */
  .main {
    flex: 1;
    display: flex;
    flex-direction: column;
    background: #FFFFFF;
    overflow: hidden;
  }

  /* ── Topbar ── */
  .topbar {
    height: 60px;
    background: #fff;
    border-bottom: 1px solid #f0f0f0;
    display: flex;
    align-items: center;
    padding: 0 20px;
    gap: 14px;
    flex-shrink: 0;
    box-shadow: 0 1px 0 #f0f0f0, 0 2px 8px rgba(0,0,0,0.03);
  }
  .collapse-btn {
    background: none;
    border: none;
    cursor: pointer;
    color: #888;
    padding: 6px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    transition: all 0.15s;
  }
  .collapse-btn:hover { background: #f5f5f5; color: #333; }
  .topbar-title { font-weight: 600; font-size: 15px; color: #1a1a2e; flex: 1; }
  .topbar-right { display: flex; align-items: center; gap: 10px; }
  .context-badge {
    background: #f8f8f8;
    border: 1px solid #ebebeb;
    border-radius: 20px;
    padding: 5px 12px;
    font-size: 12px;
    color: #555;
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .context-dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #C8102E;
    box-shadow: 0 0 6px rgba(200,16,46,0.5);
    animation: pulse-dot 2s ease-in-out infinite;
  }
  .superset-btn {
    background: #1a1a2e;
    color: #fff;
    border: none;
    border-radius: 9px;
    padding: 7px 14px;
    font-size: 12px;
    font-weight: 500;
    cursor: pointer;
    text-decoration: none;
    display: flex;
    align-items: center;
    transition: all 0.2s;
  }
  .superset-btn:hover { background: #2d2d4e; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(26,26,46,0.25); }

  /* ── Chat area ── */
  .chat-area { flex: 1; overflow-y: auto; position: relative; }

  /* ── Welcome ── */
  .welcome {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 100%;
    padding: 48px 24px;
    text-align: center;
  }
  .welcome-logo-wrap {
    position: relative;
    margin-bottom: 24px;
    animation: float 3s ease-in-out infinite;
  }
  .welcome-logo-wrap > * { border-radius: 16px; overflow: hidden; background: white; padding: 6px; box-shadow: 0 8px 32px rgba(200,16,46,0.18); }
  .welcome-logo-ring {
    position: absolute;
    inset: -10px;
    border-radius: 50%;
    border: 2px solid rgba(200,16,46,0.2);
    animation: spin-ring 8s linear infinite;
    background: none !important;
    padding: 0 !important;
    box-shadow: none !important;
  }
  .welcome-title {
    font-size: 26px;
    font-weight: 700;
    color: #1a1a2e;
    margin-bottom: 12px;
    letter-spacing: -0.5px;
    animation: slide-up 0.5s ease both;
  }
  .welcome-sub {
    font-size: 14.5px;
    color: #888;
    line-height: 1.75;
    max-width: 500px;
    margin-bottom: 36px;
    animation: slide-up 0.5s 0.1s ease both;
  }
  .quick-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 10px;
    max-width: 600px;
    width: 100%;
  }
  .quick-btn {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 13px 15px;
    background: #fafafa;
    border: 1.5px solid #ededed;
    border-radius: 13px;
    cursor: pointer;
    text-align: left;
    transition: all 0.22s cubic-bezier(0.4,0,0.2,1);
    color: #333;
    font-family: 'Inter', sans-serif;
    animation: slide-up 0.4s ease both;
    position: relative;
    overflow: hidden;
  }
  .quick-btn::before {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(135deg, rgba(200,16,46,0.05), transparent);
    opacity: 0;
    transition: opacity 0.2s;
  }
  .quick-btn:hover {
    border-color: rgba(200,16,46,0.3);
    background: #fff;
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(200,16,46,0.1);
  }
  .quick-btn:hover::before { opacity: 1; }
  .quick-icon { font-size: 17px; flex-shrink: 0; }
  .quick-text { font-size: 12.5px; font-weight: 500; color: #2d2d2d; line-height: 1.35; flex: 1; }
  .quick-arrow { font-size: 12px; color: #ccc; transition: all 0.2s; flex-shrink: 0; }
  .quick-btn:hover .quick-arrow { color: #C8102E; transform: translateX(3px); }

  /* ── Messages ── */
  .msg-list { padding: 24px 28px; display: flex; flex-direction: column; gap: 18px; }

  .msg-wrapper {
    display: flex;
    gap: 10px;
    align-items: flex-start;
  }
  .msg-wrapper.user { flex-direction: row-reverse; }

  @keyframes msg-in-bot {
    from { opacity: 0; transform: translateX(-12px); }
    to { opacity: 1; transform: translateX(0); }
  }
  @keyframes msg-in-user {
    from { opacity: 0; transform: translateX(12px); }
    to { opacity: 1; transform: translateX(0); }
  }
  .msg-enter.bot { animation: msg-in-bot 0.3s cubic-bezier(0.4,0,0.2,1) both; }
  .msg-enter.user { animation: msg-in-user 0.3s cubic-bezier(0.4,0,0.2,1) both; }

  .avatar-bot {
    width: 34px;
    height: 34px;
    border-radius: 10px;
    background: #fff;
    border: 1.5px solid #f0e6e8;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    box-shadow: 0 2px 8px rgba(200,16,46,0.1);
    overflow: hidden;
    padding: 3px;
  }
  .avatar-user {
    width: 34px;
    height: 34px;
    border-radius: 10px;
    background: linear-gradient(135deg, #C8102E, #a00d24);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    box-shadow: 0 2px 8px rgba(200,16,46,0.3);
    color: white;
    font-weight: 700;
    font-size: 13px;
  }

  .msg-inner { max-width: 78%; display: flex; flex-direction: column; gap: 4px; }
  .msg-wrapper.user .msg-inner { align-items: flex-end; }

  .bubble { border-radius: 4px 16px 16px 16px; padding: 12px 15px; }
  .bubble-user {
    background: linear-gradient(135deg, #C8102E 0%, #a00d24 100%);
    border-radius: 16px 4px 16px 16px;
    padding: 12px 16px;
    box-shadow: 0 3px 12px rgba(200,16,46,0.25);
    color: #fff;
  }
  .bubble-bot {
    background: #f8f9fa;
    border: 1px solid #ebebeb;
    border-radius: 4px 16px 16px 16px;
    padding: 13px 16px;
    color: #2d2d2d;
    box-shadow: 0 1px 4px rgba(0,0,0,0.05);
  }
  .bubble-content { font-size: 14px; line-height: 1.65; }
  .msg-h3 { font-size: 14.5px; font-weight: 700; margin-bottom: 5px; margin-top: 10px; color: #C8102E; }
  .msg-h4 { font-size: 13px; font-weight: 600; margin-bottom: 4px; margin-top: 8px; color: #333; }
  .msg-p { margin-bottom: 3px; font-size: 14px; line-height: 1.65; }
  .msg-li { margin-left: 18px; margin-bottom: 3px; font-size: 14px; line-height: 1.55; }
  .msg-quote { border-left: 3px solid #C8102E; padding-left: 10px; color: #888; font-size: 13px; font-style: italic; margin: 6px 0; }
  .msg-time { font-size: 10px; color: #bbb; }

  /* ── SQL Block ── */
  .sql-block {
    background: #0d1117;
    border-radius: 10px;
    margin-top: 12px;
    overflow: hidden;
    border: 1px solid rgba(200,16,46,0.2);
    transition: border-color 0.2s;
  }
  .sql-block:hover { border-color: rgba(200,16,46,0.4); }
  .sql-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 7px 12px;
    background: rgba(255,255,255,0.03);
    border-bottom: 1px solid rgba(200,16,46,0.12);
  }
  .sql-header-left { display: flex; align-items: center; gap: 5px; }
  .sql-dot { width: 10px; height: 10px; border-radius: 50%; background: #ef4444; }
  .sql-label { color: rgba(255,255,255,0.3); font-size: 10.5px; font-weight: 600; letter-spacing: 1.5px; text-transform: uppercase; margin-left: 6px; font-family: 'Fira Code', monospace; }
  .copy-btn {
    background: rgba(200,16,46,0.15);
    border: 1px solid rgba(200,16,46,0.3);
    border-radius: 5px;
    color: #ff8fa3;
    font-size: 11px;
    padding: 3px 9px;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.15s;
    font-family: 'Inter', sans-serif;
  }
  .copy-btn:hover { background: rgba(200,16,46,0.25); }
  .copy-btn.copied { background: rgba(34,197,94,0.15); border-color: rgba(34,197,94,0.3); color: #4ade80; }
  .sql-pre {
    padding: 14px 16px;
    font-size: 12.5px;
    color: #e2e8f0;
    overflow-x: auto;
    line-height: 1.7;
    font-family: 'Fira Code', monospace;
    margin: 0;
    white-space: pre;
  }

  /* ── Typing bubble ── */
  .typing-bubble {
    background: #f8f9fa;
    border: 1px solid #ebebeb;
    border-radius: 4px 16px 16px 16px;
    padding: 14px 20px;
    display: flex;
    align-items: center;
    gap: 5px;
    height: 46px;
  }
  .tdot {
    display: inline-block;
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #C8102E;
    animation: bounce-dot 1s ease-in-out infinite;
  }

  /* ── Input bar ── */
  .input-bar {
    padding: 14px 22px 16px;
    border-top: 1px solid #f0f0f0;
    background: #fff;
    flex-shrink: 0;
  }
  .input-wrapper {
    display: flex;
    gap: 10px;
    background: #f8f8f8;
    border: 1.5px solid #e8e8e8;
    border-radius: 15px;
    padding: 7px 7px 7px 16px;
    align-items: flex-end;
    transition: all 0.2s;
  }
  .input-wrapper.focused { border-color: rgba(200,16,46,0.4); box-shadow: 0 0 0 3px rgba(200,16,46,0.07); background: #fff; }
  .textarea {
    flex: 1;
    background: transparent;
    border: none;
    outline: none;
    resize: none;
    font-size: 14px;
    color: #2d2d2d;
    line-height: 1.55;
    padding: 6px 0;
    font-family: 'Inter', sans-serif;
    min-height: 34px;
    max-height: 120px;
  }
  .textarea::placeholder { color: #bbb; }
  .send-btn {
    width: 38px;
    height: 38px;
    border-radius: 10px;
    border: none;
    background: #ddd;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    cursor: not-allowed;
    transition: all 0.2s;
  }
  .send-btn.active {
    background: linear-gradient(135deg, #C8102E, #a00d24);
    cursor: pointer;
    box-shadow: 0 3px 10px rgba(200,16,46,0.3);
  }
  .send-btn.active:hover { transform: scale(1.07); box-shadow: 0 5px 15px rgba(200,16,46,0.4); }
  .input-hint { text-align: center; color: #c8c8c8; font-size: 11px; margin-top: 9px; }

  /* ── Animations ── */
  @keyframes pulse-dot {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.4; transform: scale(0.8); }
  }
  @keyframes float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-6px); }
  }
  @keyframes spin-ring {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }
  @keyframes slide-up {
    from { opacity: 0; transform: translateY(16px); }
    to { opacity: 1; transform: translateY(0); }
  }
  @keyframes bounce-dot {
    0%, 80%, 100% { transform: translateY(0); opacity: 0.4; }
    40% { transform: translateY(-6px); opacity: 1; }
  }
`;

