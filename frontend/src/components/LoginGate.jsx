import React, { useEffect, useState } from 'react';

const KEYCLOAK_AUTH_URL =
  'http://localhost:8080/realms/superset/protocol/openid-connect/auth' +
  '?response_type=code&client_id=superset' +
  '&redirect_uri=' + encodeURIComponent(window.location.origin + '/chatbot/') +
  '&scope=openid+profile+email';

const TOKEN_KEY = 'bts_chatbot_authed';

export default function LoginGate({ children }) {
  const [authed, setAuthed] = useState(false);
  const [checked, setChecked] = useState(false);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    if (params.get('code')) {
      // NOTE: this only confirms Keycloak redirected back with a code.
      // Real verification happens server-side in Phase 2.
      localStorage.setItem(TOKEN_KEY, '1');
      window.history.replaceState({}, '', window.location.pathname);
    }
    setAuthed(localStorage.getItem(TOKEN_KEY) === '1');
    setChecked(true);
  }, []);

  const logout = () => {
    localStorage.removeItem(TOKEN_KEY);
    setAuthed(false);
  };

  if (!checked) return null;

  if (!authed) {
    return (
      <div style={styles.wrap}>
        <div style={styles.card}>
          <div style={styles.icon}>BI</div>
          <div style={styles.title}>BTS BI Assistant</div>
          <div style={styles.sub}>Connexion requise — Direction Générale</div>
          <a href={KEYCLOAK_AUTH_URL} style={styles.btn}>
            Se connecter avec Keycloak
          </a>
        </div>
      </div>
    );
  }

  return children({ logout });
}

const styles = {
  wrap: {
    height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
    background: '#F8F9FA', fontFamily: 'Inter, sans-serif',
  },
  card: {
    background: '#fff', padding: '40px 36px', borderRadius: '16px',
    boxShadow: '0 4px 24px rgba(0,0,0,0.08)', textAlign: 'center', width: '320px',
  },
  icon: {
    width: '48px', height: '48px', borderRadius: '14px', margin: '0 auto 16px',
    background: 'linear-gradient(135deg, #C0392B, #E74C3C)', color: '#fff',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    fontWeight: 700, fontSize: '15px',
  },
  title: { fontWeight: 700, fontSize: '17px', color: '#212529', marginBottom: '6px' },
  sub: { fontSize: '13px', color: '#6C757D', marginBottom: '24px' },
  btn: {
    display: 'block', padding: '11px 0', borderRadius: '10px',
    background: '#C0392B', color: '#fff', textDecoration: 'none',
    fontWeight: 600, fontSize: '14px',
  },
};