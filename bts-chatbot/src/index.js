import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import keycloak from "./keycloak";

const root = ReactDOM.createRoot(document.getElementById("root"));

keycloak.init({ onLoad: "login-required", checkLoginIframe: false, pkceMethod: "S256" })
  .then((authenticated) => {
    if (!authenticated) { window.location.reload(); return; }
    const groups = keycloak.tokenParsed?.groups ?? [];
    if (!groups.includes("/DirecteurGeneral")) {
      root.render(
        React.createElement("div", { style: { display:"flex", alignItems:"center", justifyContent:"center", height:"100vh", fontFamily:"sans-serif", background:"#f8fafc" } },
          React.createElement("div", { style: { background:"#fff", padding:"2rem", borderRadius:"12px", boxShadow:"0 2px 16px rgba(0,0,0,.1)", textAlign:"center" } },
            React.createElement("div", { style: { fontSize:"3rem" } }, "🔒"),
            React.createElement("h2", { style: { color:"#C8102E" } }, "Accès refusé"),
            React.createElement("p", { style: { color:"#6b7280" } }, "Réservé au Directeur Général"),
            React.createElement("button", { onClick: () => keycloak.logout(), style: { background:"#C8102E", color:"#fff", border:"none", padding:"0.6rem 1.5rem", borderRadius:"8px", cursor:"pointer", marginTop:"1rem" } }, "Se déconnecter")
          )
        )
      );
      return;
    }
    setInterval(() => keycloak.updateToken(60).catch(() => keycloak.logout()), 4 * 60 * 1000);
    window.keycloak = keycloak;
    root.render(React.createElement(React.StrictMode, null, React.createElement(App, null)));
  })
  .catch((err) => {
    console.error("Keycloak init error:", err);
    root.render(React.createElement("div", { style: { padding:"2rem", textAlign:"center" } }, React.createElement("h2", null, "Erreur Keycloak : " + (err?.message || "vérifiez la configuration"))));
  });
