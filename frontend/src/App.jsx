import React, { useState } from 'react';
import Sidebar from './components/Sidebar';
import TopBar from './components/TopBar';
import ChatWindow from './components/ChatWindow';

export default function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(true);
  const [activeDashboard, setActiveDashboard] = useState(null);
  const [activeLabel, setActiveLabel] = useState('Tous les dashboards');

  const handleSelectDashboard = (dash) => {
    setActiveDashboard(dash);
    setActiveLabel(dash.title || 'Dashboard analytique');
  };

  const handleNewConversation = () => {
    setActiveDashboard(null);
    setActiveLabel('Tous les dashboards');
  };

  if (!isAuthenticated) {
    return (
      <div style={{ display: 'flex', height: '100vh', justifyContent: 'center', alignItems: 'center', background: '#F8F9FA' }}>
        <button onClick={() => setIsAuthenticated(true)} style={{ padding: '12px 24px', background: '#1A1A2E', color: '#fff', borderRadius: '8px', border: 'none', cursor: 'pointer', fontWeight: 600 }}>
          Sign in (Mock Mode)
        </button>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', height: '100vh', width: '100vw', background: '#F8F9FA', fontFamily: 'Inter, sans-serif', overflow: 'hidden' }}>
      <Sidebar activeDashboardId={activeDashboard?.id} onSelectDashboard={handleSelectDashboard} onNewConversation={handleNewConversation} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', height: '100vh', overflow: 'hidden' }}>
        <TopBar activeLabel={activeLabel} onLogout={() => setIsAuthenticated(false)} onOpenSuperset={() => window.open('http://localhost:8088', '_blank')} />
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden', background: '#FFFFFF' }}>
          <ChatWindow initialDomain={activeDashboard ? activeDashboard.group : 'microprojets'} activeDashboardTitle={activeLabel} />
        </div>
      </div>
    </div>
  );
}
