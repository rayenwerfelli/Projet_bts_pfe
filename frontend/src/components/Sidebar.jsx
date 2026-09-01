import React from 'react';

const STATIC_DASHBOARDS = [
  { id: 'dash1', title: 'Dashboard 1 — Suivi Demande CIC', group: 'microprojets', subtitle: 'mart_demande_financement', color: '#3B82F6' },
  { id: 'dash8', title: 'Dashboard 8 — Travail Statistique', group: 'microprojets', subtitle: 'mart_demande_financement', color: '#8B5CF6' },
  { id: 'dash7', title: 'Dashboard 7 — Suivi Portefeuille RCV', group: 'recouvrement', subtitle: 'mart_recouvrement', color: '#F59E0B' },
  { id: 'dash10', title: 'Dashboard 10 — Effort de recouvrement', group: 'recouvrement', subtitle: 'mart_recouvrement', color: '#EF4444' },
  { id: 'dash4', title: 'Dashboard 4 — Ouverture Comptes', group: 'commercial', subtitle: 'mart_req_ouverture_comptes', color: '#10B981' },
  { id: 'dash5', title: 'Dashboard 5 — Comptes Gelés', group: 'commercial', subtitle: 'fact_compte_gele', color: '#06B6D4' },
];

export default function Sidebar({ activeDashboardId, onSelectDashboard, onNewConversation }) {
  return (
    <div style={{ width: '300px', background: '#0B0F19', color: '#FFFFFF', display: 'flex', flexDirection: 'column', height: '100vh', borderRight: '1px solid #1F2937', flexShrink: 0 }}>
      <div style={{ padding: '20px', borderBottom: '1px solid #1F2937' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ width: '32px', height: '32px', background: '#DC2626', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>BTS</div>
          <div>
            <div style={{ fontSize: '15px', fontWeight: 700 }}>BTS BI Assistant</div>
            <div style={{ fontSize: '11px', color: '#9CA3AF' }}>Banque Tunisienne de Solidarité</div>
          </div>
        </div>
      </div>
      <div style={{ padding: '16px' }}>
        <button onClick={onNewConversation} style={{ width: '100% ', padding: '10px 16px', background: 'linear-gradient(135deg, rgba(220, 38, 38, 0.2), rgba(153, 27, 27, 0.1))', border: '1px solid rgba(220, 38, 38, 0.3)', borderRadius: '8px', color: '#FFFFFF', fontSize: '13px', fontWeight: 600, cursor: 'pointer', textAlign: 'left' }}>
          + Nouvelle conversation
        </button>
      </div>
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 16px 16px' }}>
        <div style={{ fontSize: '11px', fontWeight: 700, color: '#6B7280', letterSpacing: '0.05em', marginBottom: '8px', marginTop: '8px' }}>MICROPROJETS</div>
        {STATIC_DASHBOARDS.filter(d => d.group === 'microprojets').map(dash => (
          <div key={dash.id} onClick={() => onSelectDashboard(dash)} style={{ padding: '10px 12px', borderRadius: '8px', cursor: 'pointer', background: activeDashboardId === dash.id ? 'rgba(255, 255, 255, 0.08)' : 'transparent', marginBottom: '4px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', fontWeight: 500, color: '#F3F4F6' }}>
              <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: dash.color }}></span>
              {dash.title}
            </div>
            <div style={{ fontSize: '11px', color: '#9CA3AF', paddingLeft: '16px', marginTop: '2px', fontFamily: 'monospace' }}>{dash.subtitle}</div>
          </div>
        ))}
        <div style={{ fontSize: '11px', fontWeight: 700, color: '#6B7280', letterSpacing: '0.05em', marginBottom: '8px', marginTop: '16px' }}>RECOUVREMENT / FINANCE</div>
        {STATIC_DASHBOARDS.filter(d => d.group === 'recouvrement').map(dash => (
          <div key={dash.id} onClick={() => onSelectDashboard(dash)} style={{ padding: '10px 12px', borderRadius: '8px', cursor: 'pointer', background: activeDashboardId === dash.id ? 'rgba(255, 255, 255, 0.08)' : 'transparent', marginBottom: '4px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', fontWeight: 500, color: '#F3F4F6' }}>
              <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: dash.color }}></span>
              {dash.title}
            </div>
            <div style={{ fontSize: '11px', color: '#9CA3AF', paddingLeft: '16px', marginTop: '2px', fontFamily: 'monospace' }}>{dash.subtitle}</div>
          </div>
        ))}
        <div style={{ fontSize: '11px', fontWeight: 700, color: '#6B7280', letterSpacing: '0.05em', marginBottom: '8px', marginTop: '16px' }}>COMMERCIAL / AGENCES</div>
        {STATIC_DASHBOARDS.filter(d => d.group === 'commercial').map(dash => (
          <div key={dash.id} onClick={() => onSelectDashboard(dash)} style={{ padding: '10px 12px', borderRadius: '8px', cursor: 'pointer', background: activeDashboardId === dash.id ? 'rgba(255, 255, 255, 0.08)' : 'transparent', marginBottom: '4px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', fontWeight: 500, color: '#F3F4F6' }}>
              <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: dash.color }}></span>
              {dash.title}
            </div>
            <div style={{ fontSize: '11px', color: '#9CA3AF', paddingLeft: '16px', marginTop: '2px', fontFamily: 'monospace' }}>{dash.subtitle}</div>
          </div>
        ))}
      </div>
      <div style={{ padding: '16px', borderTop: '1px solid #1F2937', fontSize: '12px', color: '#9CA3AF', display: 'flex', alignItems: 'center', gap: '8px' }}>
        <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#10B981' }}></span>
        Connecté - PostgreSQL DWH BTS
      </div>
    </div>
  );
}
