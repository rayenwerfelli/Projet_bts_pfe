import React from 'react';

const DOMAINS = [
  {
    key: 'microprojets',
    label: 'Microprojets',
    icon: '📋',
    desc: 'Demandes de financement · Dashboard 1 & 8',
    color: '#C0392B',
  },
  {
    key: 'recouvrement',
    label: 'Recouvrement',
    icon: '💰',
    desc: 'Portefeuille & échéances · Dashboard 7 & 10',
    color: '#922B21',
  },
  {
    key: 'commercial',
    label: 'Commercial',
    icon: '🏦',
    desc: 'Comptes actifs & gelés · Dashboard 4 & 5',
    color: '#E74C3C',
  },
];

export default function DomainSelector({ selected, onChange }) {
  return (
    <div style={styles.wrapper}>
      {DOMAINS.map((d) => (
        <button
          key={d.key}
          onClick={() => onChange(d.key)}
          style={{
            ...styles.card,
            ...(selected === d.key ? styles.cardActive : {}),
          }}
          title={d.desc}
        >
          <span style={styles.icon}>{d.icon}</span>
          <span style={styles.label}>{d.label}</span>
          {selected === d.key && <span style={styles.dot} />}
        </button>
      ))}
    </div>
  );
}

const styles = {
  wrapper: {
    display: 'flex',
    gap: '8px',
    padding: '10px 16px',
    background: '#fff',
    borderBottom: '1px solid #F1F3F5',
    flexWrap: 'wrap',
  },
  card: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    padding: '6px 14px',
    borderRadius: '99px',
    border: '1.5px solid #E9ECEF',
    background: '#F8F9FA',
    cursor: 'pointer',
    fontSize: '13px',
    fontFamily: 'Inter, sans-serif',
    fontWeight: 500,
    color: '#6C757D',
    transition: 'all 0.18s ease',
    position: 'relative',
  },
  cardActive: {
    background: '#FEF9F9',
    border: '1.5px solid #C0392B',
    color: '#C0392B',
  },
  icon: { fontSize: '14px' },
  label: {},
  dot: {
    width: '6px',
    height: '6px',
    borderRadius: '50%',
    background: '#C0392B',
    marginLeft: '2px',
  },
};