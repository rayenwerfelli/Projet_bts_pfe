# BTS BI Assistant — Frontend React

Interface chatbot analytique pour la Banque Tunisienne de Solidarité.

## Démarrage rapide

```bash
# Copier la config
cp .env.example .env
# Éditer les URLs si besoin
nano .env

# Installer et lancer
npm install
npm start
```

## Variables d'environnement

| Variable | Défaut | Description |
|---|---|---|
| `REACT_APP_API_URL` | `http://localhost:8000` | URL du backend FastAPI |
| `REACT_APP_SUPERSET_URL` | `http://localhost:8088` | URL de Superset |

## Build production

```bash
npm run build
# Les fichiers sont dans /build, à servir avec nginx ou serve
```

## Docker

```dockerfile
FROM node:20-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
```

## Version standalone

Le fichier `bts-chatbot.html` est une version autonome sans dépendances de build,
ouvrable directement dans un navigateur (assurez-vous que CORS est activé sur le backend).
