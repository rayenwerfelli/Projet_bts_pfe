import React from 'react';

export default function TopBar({ activeLabel, onLogout, onOpenSuperset }) {
  return (
    <div style={{ height: '64px', background: '#FFFFFF', borderBottom: '1px solid #E5E7EB', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 24px', flexShrink: 0 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <button style={{ background: 'none', border: 'none', fontSize: '18px', cursor: 'pointer', color: '#6B7280' }}>✕</button>
        <span style={{ fontSize: '16px', fontWeight: 600, color: '#111827' }}>Assistant BI Analytique</span>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '6px 14px', background: '#F9FAFB', border: '1px solid #E5E7EB', borderRadius: '20px', fontSize: '13px', fontWeight: 500, color: '#374151' }}>
          <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#EF4444' }}></span>
          {activeLabel}
        </div>
        <button onClick={onOpenSuperset} style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '8px 16px', background: '#1F2937', color: '#FFFFFF', border: 'none', borderRadius: '8px', fontSize: '13px', fontWeight: 500, cursor: 'pointer' }}>
          <span>📊 Superset</span>
        </button>
        <button onClick={onLogout} style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '8px 16px', background: '#DC2626', color: '#FFFFFF', border: 'none', borderRadius: '8px', fontSize: '13px', fontWeight: '500', cursor: 'pointer' }}>
          <span>🚪 Déconnexion</span>
        </button>
      </div>
    </div>
  );
}
