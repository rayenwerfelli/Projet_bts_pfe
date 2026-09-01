"""
BTS BI Chatbot Backend — Groq LLM + SQLite conversation history.

Architecture
------------
- FastAPI application exposing chat, session, and Superset routes.
- Groq API for LLM generation (model: openai/gpt-oss-120b by default).
- SQLite (via aiosqlite) for session and message persistence.
- Apache Superset for executing generated SQL against the BI data marts.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import httpx
import os
import re
import uuid
import json
import logging
from datetime import datetime

import aiosqlite
from groq import Groq

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("bts-chatbot")

app = FastAPI(title="BTS BI Chatbot API", version="3.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─────────────────────────────────────────────────────────────
# CONFIGURATION
# ─────────────────────────────────────────────────────────────
GROQ_API_KEY      = os.getenv("GROQ_API_KEY", "")
GROQ_MODEL        = os.getenv("GROQ_MODEL", "openai/gpt-oss-120b")
SUPERSET_URL      = os.getenv("SUPERSET_URL", "http://superset:8088")
SUPERSET_USER     = os.getenv("SUPERSET_USERNAME", "admin")
SUPERSET_PASSWORD = os.getenv("SUPERSET_PASSWORD", "admin")
DB_PATH           = os.getenv("HISTORY_DB_PATH", "/app/data/history.db")

# Token guardrails: cap the output and the number of history messages so the
# input never crowds out the completion budget (a common cause of empty
# responses). gpt-oss models have a 131k context and 65k max completion.
MAX_OUTPUT_TOKENS = int(os.getenv("GROQ_MAX_TOKENS", "1500"))
MAX_HISTORY_MSGS  = int(os.getenv("MAX_HISTORY_MSGS", "8"))

_groq_client: Optional[Groq] = None
_superset_token: Optional[str] = None


def get_groq_client() -> Groq:
    """Return a lazily-initialized, cached Groq client."""
    global _groq_client
    if _groq_client is None:
        if not GROQ_API_KEY:
            raise HTTPException(400, "GROQ_API_KEY is not configured")
        _groq_client = Groq(api_key=GROQ_API_KEY)
    return _groq_client


# ─────────────────────────────────────────────────────────────
# DATABASE — CONVERSATION HISTORY
# ─────────────────────────────────────────────────────────────

async def init_db():
    """Create the sessions and messages tables if they do not exist."""
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    async with aiosqlite.connect(DB_PATH) as db:
        await db.executescript("""
            CREATE TABLE IF NOT EXISTS sessions (
                id          TEXT PRIMARY KEY,
                title       TEXT NOT NULL DEFAULT 'New conversation',
                dashboard   TEXT,
                created_at  TEXT NOT NULL,
                updated_at  TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS messages (
                id              TEXT PRIMARY KEY,
                session_id      TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
                role            TEXT NOT NULL CHECK(role IN ('user','assistant')),
                content         TEXT NOT NULL,
                sql_query       TEXT,
                sql_data        TEXT,
                sql_error       TEXT,
                created_at      TEXT NOT NULL
            );

            CREATE INDEX IF NOT EXISTS idx_messages_session
                ON messages(session_id, created_at);
        """)
        await db.commit()


@app.on_event("startup")
async def startup():
    """Initialize the database schema when the application starts."""
    await init_db()


# ── Database helpers ─────────────────────────────────────────

async def db_create_session(title: str, dashboard: Optional[str]) -> dict:
    """Insert a new session and return it as a dictionary."""
    session_id = str(uuid.uuid4())
    now = datetime.utcnow().isoformat()
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            "INSERT INTO sessions (id, title, dashboard, created_at, updated_at) VALUES (?,?,?,?,?)",
            (session_id, title, dashboard, now, now),
        )
        await db.commit()
    return {"id": session_id, "title": title, "dashboard": dashboard,
            "created_at": now, "updated_at": now}


async def db_get_session(session_id: str) -> Optional[dict]:
    """Return a single session by id, or None if it does not exist."""
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        async with db.execute(
            "SELECT * FROM sessions WHERE id = ?", (session_id,)
        ) as cursor:
            row = await cursor.fetchone()
            return dict(row) if row else None


async def db_list_sessions(limit: int = 50) -> List[dict]:
    """Return the most recently updated sessions, newest first."""
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        async with db.execute(
            "SELECT * FROM sessions ORDER BY updated_at DESC LIMIT ?", (limit,)
        ) as cursor:
            rows = await cursor.fetchall()
            return [dict(row) for row in rows]


async def db_update_session_title(session_id: str, title: str):
    """Update a session's title and refresh its updated_at timestamp."""
    now = datetime.utcnow().isoformat()
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            "UPDATE sessions SET title=?, updated_at=? WHERE id=?",
            (title, now, session_id),
        )
        await db.commit()


async def db_delete_session(session_id: str):
    """Delete a session (cascades to its messages)."""
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("DELETE FROM sessions WHERE id=?", (session_id,))
        await db.commit()


async def db_save_message(
    session_id: str,
    role: str,
    content: str,
    sql_query: Optional[str] = None,
    sql_data: Optional[dict] = None,
    sql_error: Optional[str] = None,
) -> dict:
    """Persist a single message and bump the parent session's updated_at."""
    message_id = str(uuid.uuid4())
    now = datetime.utcnow().isoformat()
    sql_data_str = json.dumps(sql_data, ensure_ascii=False) if sql_data else None
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            """INSERT INTO messages
               (id, session_id, role, content, sql_query, sql_data, sql_error, created_at)
               VALUES (?,?,?,?,?,?,?,?)""",
            (message_id, session_id, role, content, sql_query, sql_data_str, sql_error, now),
        )
        await db.execute(
            "UPDATE sessions SET updated_at=? WHERE id=?", (now, session_id)
        )
        await db.commit()
    return {
        "id": message_id, "session_id": session_id, "role": role, "content": content,
        "sql_query": sql_query, "sql_data": sql_data, "sql_error": sql_error,
        "created_at": now,
    }


async def db_get_messages(session_id: str) -> List[dict]:
    """Return all messages for a session in chronological order.

    The sql_data column is stored as a JSON string and deserialized here.
    """
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        async with db.execute(
            "SELECT * FROM messages WHERE session_id=? ORDER BY created_at ASC",
            (session_id,),
        ) as cursor:
            rows = await cursor.fetchall()
            messages = []
            for row in rows:
                message = dict(row)
                if message["sql_data"]:
                    try:
                        message["sql_data"] = json.loads(message["sql_data"])
                    except json.JSONDecodeError:
                        pass  # Leave the raw string if it is not valid JSON.
                messages.append(message)
            return messages


async def db_delete_messages(session_id: str):
    """Delete all messages belonging to a session."""
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("DELETE FROM messages WHERE session_id=?", (session_id,))
        await db.commit()


def derive_title(text: str, max_len: int = 60) -> str:
    """Build a readable session title from the first user message."""
    clean = re.sub(r"\s+", " ", text).strip()
    return clean[:max_len] + ("…" if len(clean) > max_len else "")


# ─────────────────────────────────────────────────────────────
# SUPERSET INTEGRATION
# ─────────────────────────────────────────────────────────────

async def get_superset_token() -> str:
    """Authenticate against Superset and return an access token."""
    global _superset_token
    async with httpx.AsyncClient(verify=False, timeout=15.0) as client:
        response = await client.post(
            f"{SUPERSET_URL}/api/v1/security/login",
            json={"username": SUPERSET_USER, "password": SUPERSET_PASSWORD,
                  "provider": "db", "refresh": True},
        )
        if response.status_code != 200:
            raise HTTPException(502, f"Superset authentication failed: {response.text}")
        _superset_token = response.json()["access_token"]
        return _superset_token


async def superset_sql_query(sql: str, database_id: int = 1) -> dict:
    """Execute a SQL query synchronously through the Superset SQL Lab API."""
    token = await get_superset_token()
    async with httpx.AsyncClient(verify=False, timeout=30.0) as client:
        response = await client.post(
            f"{SUPERSET_URL}/api/v1/sqllab/execute/",
            headers={"Authorization": f"Bearer {token}"},
            json={"database_id": database_id, "sql": sql,
                  "runAsync": False, "queryLimit": 500},
        )
        if response.status_code not in (200, 202):
            raise HTTPException(502, f"Superset SQL error: {response.text}")
        return response.json()


async def get_superset_dashboards() -> list:
    """Return the list of available Superset dashboards."""
    token = await get_superset_token()
    async with httpx.AsyncClient(verify=False, timeout=15.0) as client:
        response = await client.get(
            f"{SUPERSET_URL}/api/v1/dashboard/",
            headers={"Authorization": f"Bearer {token}"},
            params={"page_size": 50},
        )
        return response.json().get("result", []) if response.status_code == 200 else []


async def get_superset_charts(dashboard_id: int) -> list:
    """Return the charts belonging to a given dashboard."""
    token = await get_superset_token()
    async with httpx.AsyncClient(verify=False, timeout=15.0) as client:
        response = await client.get(
            f"{SUPERSET_URL}/api/v1/dashboard/{dashboard_id}/charts",
            headers={"Authorization": f"Bearer {token}"},
        )
        return response.json().get("result", []) if response.status_code == 200 else []


# ─────────────────────────────────────────────────────────────
# BUSINESS SCHEMAS & SYSTEM PROMPT
# ─────────────────────────────────────────────────────────────

MART_SCHEMAS = {
    "microprojects": {
        "tables": ["mart_demande_financement"],
        "description": "Microproject financing requests (CIC/DIS)",
        "columns": """
mart_demande_financement:
- numdmg: request number
- codclt, nomclt, prnclt: client code / last name / first name
- lib_etat: status (Enregistré/En Etude/Accord/Rejet/Décision Prise)
- lib_decision: decision (Acceptée/Rejetée/Ajournée/Acceptée sous Réserve)
- datdmg: submission date, date_decision: decision date
- lib_secteur: Agriculture/Service/Industrie/Artisanat/Petits Métiers
- lib_unite, cod_unite: handling branch
- nature_projet: Création/Extension
- mnt_total_prop: total proposed amount (TND)
- cout_total_acc: total granted amount (TND)
- txfdr, txamg, txequip: working-capital / fit-out / equipment rates
- age: client age, lib_sexe: Masculin/Féminin
- dsa: branch processing time (days), dss: head-office processing time (days)
- codgov: governorate code
- lib_niveau_instruction: education level
- lib_stfclt: family situation
- mntechu, mntechuimpay, tx_impaye_clt: repayment indicators
- activsection, activdiv, activgroup: activity classification
""",
    },
    "collections": {
        "tables": ["mart_recouvrement", "mart_echeances"],
        "description": "Collections portfolio and recovery effort",
        "columns": """
mart_recouvrement / mart_echeances:
- codclt, nomclt: client
- agence (libunt): branch
- date_echeance, date_reglement: dates
- lib_type_effet: À Échoir/Impayé/Réglé Partiel/Réglé Total/Annulé
- lib_nature_effet: Principal/Intérêts
- mnt_engagement, mnt_echu, mnt_impaye, mnt_regle: amounts
- taux_recouvrement: mnt_regle/mnt_echu*100
- poids_impaye: mnt_impaye/mnt_engagement*100
- nb_jours_impaye: overdue age
- tranche_anciennete_impaye: 0-30d/31-60d/61-90d/91-180d/181-365d/+365d
- ligne_financement, type_engagement: product
- lib_secteur, gouvernorat, localite: geography
- annee_mois_ech, annee_mois_regl: temporal aggregation
""",
    },
    "commercial": {
        "tables": ["mart_req4_ouverture_comptes", "fact_compte_gele"],
        "description": "Active account openings and frozen-account monitoring",
        "columns": """
mart_req4_ouverture_comptes:
- ord_cpt, cod_client, nom_client, prenom_client
- agence_libelle, cod_agence
- nature_libelle, nature_type, nature_categorie
- situation_libelle, date_ouverture, date_cloture, annee_mois_ouverture
- solde_courant, solde_comptable, solde_moyen (TND)
- mvt_credit_mois, mvt_debit_mois
- tranche_solde: Débiteur/Nul/0-10K/10K-100K/100K-1M/>1M
- lib_sexe, lib_situation_familiale, lib_niveau_instruction
- ind_bloque, ind_gele, est_actif

fact_compte_gele:
- ord_cpt, cod_client, lib_unt (branch)
- ind_gele, ind_bloque, ind_bloque_credit, situation_libelle
- mnt_solde_debiteur, mnt_eff_encours, mnt_imp, mnt_dap
- mnt_trh_debloq, mnt_exposition_totale
""",
    },
}

SYSTEM_PROMPT = """
You are VousBI, an AI assistant for the BTS (Banque Tunisienne de Solidarité).

## Execution context (IMPORTANT)
Any SQL query you place in a ```sql code block is AUTOMATICALLY executed against
the bank's data warehouse, and the resulting table is shown to the user directly
below your message. Therefore:
- NEVER say you cannot run SQL or execute queries. You effectively can: just
  output the SQL and it runs.
- When the user asks to "run it", "execute", or "show the results", simply
  provide the SQL query in a ```sql block. Do not apologize or refuse.
- Do not invent or fabricate result values; the real results come from execution.

## SQL rules — ClickHouse dialect (CRITICAL, obey exactly)
The database is ClickHouse, NOT PostgreSQL. Use ONLY the real table and column
names given in the Schemas section below. Do NOT invent table names such as
"mart_demandes" or columns such as "statut" — they do not exist.

Hard requirements:
- ASCII-ONLY aliases. NEVER put accented letters in a column alias.
  Write "AS nb_demandes_acceptees", never "AS nb_demandes_acceptées".
  (Accented aliases cause a ClickHouse syntax error and the query fails.)
- Accents ARE allowed inside string values being compared, e.g.
  WHERE lib_decision = 'Acceptée' is correct (the value is accented in the data).
- Conditional counts: use countIf(cond) / sumIf(expr, cond).
  NEVER "COUNT(*) FILTER (WHERE ...)" (PostgreSQL only, will fail).
- Current date: today() — NOT CURRENT_DATE / CURRENT_DATE().
- Start of month: toStartOfMonth(col) — NOT DATE_TRUNC('month', col).
- Month arithmetic: addMonths(d, 1) — NOT "d + INTERVAL '1 month'".
- Current-month filter example:
  WHERE toStartOfMonth(date_decision) = toStartOfMonth(today())
- Rounding: round(val, 2).
- Always ORDER BY for rankings, LIMIT 20 for lists.
- Amounts are in Tunisian Dinars (TND).

For "accepted requests this month" on microprojects the correct query is:
```sql
SELECT count() AS nb_demandes_acceptees
FROM mart_demande_financement
WHERE lib_decision = 'Acceptée'
  AND toStartOfMonth(date_decision) = toStartOfMonth(today())
```

## Required response format
1. Short explanation (1-2 sentences)
2. SQL block: ```sql ... ```
3. Business interpretation
4. 2-3 follow-up questions

CRITICAL RULE: If the user explicitly asks for SQL code, queries, or technical
implementation details, skip the standard business explanation format and provide
the clean SQL query directly inside a code block.

## BTS context
- Sectors: A=Agriculture, S=Service, I=Industry, B=Handicraft, M=Small Trades
- Request statuses: 0=Registered, 1=Under Review, 3=Approved, 4=Rejected, 6=Decided
- 24 Tunisian governorates

Always respond in French."""


# ─────────────────────────────────────────────────────────────
# REQUEST / RESPONSE MODELS
# ─────────────────────────────────────────────────────────────

class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    messages: List[ChatMessage]
    dashboard_context: Optional[str] = None
    execute_sql: Optional[bool] = False
    database_id: Optional[int] = 1
    session_id: Optional[str] = None
    save_history: Optional[bool] = True


class SQLExecuteRequest(BaseModel):
    sql: str
    database_id: Optional[int] = 1


class SessionCreateRequest(BaseModel):
    title: Optional[str] = "New conversation"
    dashboard: Optional[str] = None


class SessionUpdateRequest(BaseModel):
    title: str


# ─────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────

def build_system_prompt(dashboard_context: Optional[str]) -> str:
    """Assemble the system prompt, scoping the schema to the active dashboard.

    When a dashboard maps to a known business domain, only that domain's schema
    is injected, and the active dashboard is named so the model understands
    references like "dashboard 7". Otherwise every schema is included.
    """
    domain_map = {
        "dash1": "microprojects", "dash8": "microprojects",
        "dash7": "collections",   "dash10": "collections",
        "dash4": "commercial",    "dash5": "commercial",
    }
    domain = domain_map.get(dashboard_context) if dashboard_context else None

    # Human-readable dashboard label so the model can resolve "dashboard N".
    dash_number = dashboard_context.replace("dash", "") if dashboard_context else None

    schema_section = ""
    if domain and domain in MART_SCHEMAS:
        schema = MART_SCHEMAS[domain]
        header = f"## Active dashboard: Dashboard {dash_number} — {schema['description']}\n"
        header += (
            f"The user is currently viewing Dashboard {dash_number}. "
            f"When they mention 'dashboard {dash_number}' or 'this dashboard', "
            f"they mean the tables below.\n"
        )
        schema_section = f"\n{header}\n## Tables\n{schema['columns']}\n"
    else:
        for schema in MART_SCHEMAS.values():
            schema_section += f"\n### {schema['description']}\n{schema['columns']}\n"

    return SYSTEM_PROMPT + "\n## Schemas\n" + schema_section


def extract_sql(text: str) -> Optional[str]:
    """Extract the first ```sql ... ``` code block from an LLM response."""
    match = re.search(r"```sql\n?(.*?)```", text, re.DOTALL | re.IGNORECASE)
    return match.group(1).strip() if match else None


def sanitize_sql_for_clickhouse(sql: str) -> str:
    """Make generated SQL safe for ClickHouse execution.

    ClickHouse rejects non-ASCII characters in identifiers (e.g. an accented
    alias like nb_demandes_acceptées raises a syntax error, code 62). We strip
    accents so column aliases are always valid ASCII. String *literals* between
    quotes are preserved so values like 'Acceptée' still match the data.
    """
    import unicodedata

    def strip_accents(s: str) -> str:
        return "".join(
            c for c in unicodedata.normalize("NFKD", s)
            if not unicodedata.combining(c)
        )

    # Split on single-quoted string literals; de-accent only the code parts,
    # leave the literals (odd indices) untouched.
    parts = re.split(r"('(?:[^']|'')*')", sql)
    for i in range(0, len(parts), 2):
        parts[i] = strip_accents(parts[i])
    return "".join(parts)


def sanitize_messages(messages: List[dict]) -> List[dict]:
    """Keep only valid, non-empty user/assistant turns in Groq message format.

    Guards against malformed history rows (missing role, None or blank content,
    unexpected keys) that would otherwise cause Groq to return an empty response.
    """
    clean = []
    for message in messages:
        role = message.get("role")
        content = message.get("content")
        if role in ("user", "assistant") and content and str(content).strip():
            clean.append({"role": role, "content": str(content)})
    return clean


def call_groq(messages: List[dict], system: str) -> str:
    """Call the Groq chat completion endpoint and return the answer text.

    Handles reasoning models such as openai/gpt-oss-120b, which separate their
    chain-of-thought from the final answer. Without this handling the visible
    answer can arrive empty (all tokens spent in the reasoning channel) or
    wrapped in <think>...</think> tags, producing a blank chat bubble.
    """
    client = get_groq_client()

    payload = [{"role": "system", "content": system}] + messages
    if len(payload) == 1:
        raise HTTPException(400, "No valid user message to send to the model")

    try:
        response = client.chat.completions.create(
            model=GROQ_MODEL,
            messages=payload,
            temperature=0.3,
            max_tokens=MAX_OUTPUT_TOKENS,
        )
    except Exception as error:
        logger.error("Groq call failed: %s: %s", type(error).__name__, error)
        raise HTTPException(502, f"Groq error: {error}")

    choice = response.choices[0]
    message = choice.message

    # Primary answer field.
    content = (message.content or "").strip()

    # Fallback: some reasoning models leave content empty and place text in
    # a separate `reasoning` attribute.
    if not content:
        content = (getattr(message, "reasoning", None) or "").strip()

    # Strip any <think>...</think> block, keeping only the final answer.
    content = re.sub(r"<think>.*?</think>", "", content, flags=re.DOTALL).strip()

    logger.info(
        "Groq model=%s finish_reason=%s content_len=%d usage=%s",
        GROQ_MODEL, choice.finish_reason, len(content), getattr(response, "usage", None),
    )

    if not content:
        if choice.finish_reason == "length":
            raise HTTPException(
                502,
                "The model produced no output because the context window is full. "
                "Reduce the history length or increase MAX_OUTPUT_TOKENS.",
            )
        raise HTTPException(
            502, f"Empty response from the model (finish_reason={choice.finish_reason})"
        )

    return content


def history_to_groq_messages(history: List[dict]) -> List[dict]:
    """Convert stored DB messages to Groq format, keeping the most recent turns.

    Trimming to the last MAX_HISTORY_MSGS entries prevents token-limit overflow
    (HTTP 413) on long conversations.
    """
    recent = history[-MAX_HISTORY_MSGS:] if len(history) > MAX_HISTORY_MSGS else history
    return sanitize_messages(recent)


# ─────────────────────────────────────────────────────────────
# ROUTES — SESSIONS
# ─────────────────────────────────────────────────────────────

@app.post("/sessions", status_code=201)
async def create_session(req: SessionCreateRequest):
    """Create a new conversation session."""
    return await db_create_session(req.title, req.dashboard)


@app.get("/sessions")
async def list_sessions(limit: int = 50):
    """List recent sessions, most recently updated first."""
    sessions = await db_list_sessions(limit)
    return {"sessions": sessions, "total": len(sessions)}


@app.get("/sessions/{session_id}")
async def get_session(session_id: str):
    """Return a session together with all of its messages."""
    session = await db_get_session(session_id)
    if not session:
        raise HTTPException(404, f"Session '{session_id}' not found")
    messages = await db_get_messages(session_id)
    return {**session, "messages": messages}


@app.patch("/sessions/{session_id}")
async def update_session(session_id: str, req: SessionUpdateRequest):
    """Rename a session."""
    session = await db_get_session(session_id)
    if not session:
        raise HTTPException(404, f"Session '{session_id}' not found")
    await db_update_session_title(session_id, req.title)
    return {"id": session_id, "title": req.title, "updated": True}


@app.delete("/sessions/{session_id}", status_code=204)
async def delete_session(session_id: str):
    """Delete a session and its messages."""
    session = await db_get_session(session_id)
    if not session:
        raise HTTPException(404, f"Session '{session_id}' not found")
    await db_delete_session(session_id)


@app.delete("/sessions/{session_id}/messages", status_code=204)
async def clear_session_messages(session_id: str):
    """Delete all messages in a session while keeping the session itself."""
    session = await db_get_session(session_id)
    if not session:
        raise HTTPException(404, f"Session '{session_id}' not found")
    await db_delete_messages(session_id)


@app.get("/sessions/{session_id}/messages")
async def get_session_messages(session_id: str):
    """Return only the messages for a session."""
    session = await db_get_session(session_id)
    if not session:
        raise HTTPException(404, f"Session '{session_id}' not found")
    messages = await db_get_messages(session_id)
    return {"session_id": session_id, "messages": messages, "count": len(messages)}


# ─────────────────────────────────────────────────────────────
# ROUTES — CHAT
# ─────────────────────────────────────────────────────────────

@app.post("/chat")
async def chat(req: ChatRequest):
    """Main chat endpoint: generate a response and optionally execute its SQL.

    Message flow (deterministic, avoids the empty-response bug):
      1. Sanitize the incoming user turn.
      2. Resolve or create the session.
      3. Load prior history from the DB (NOT including the current turn).
      4. Send history + current turn to Groq.
      5. Only after a successful generation, persist the user turn and the
         assistant reply. Persisting after generation guarantees the request
         sent to Groq always ends on the current user message.
    """
    system = build_system_prompt(req.dashboard_context)

    # 1. Sanitize the current user turn.
    incoming = sanitize_messages([{"role": m.role, "content": m.content} for m in req.messages])
    if not incoming:
        raise HTTPException(400, "No valid user message provided")

    # 2. Resolve or create the session.
    session_id = req.session_id
    if session_id:
        session = await db_get_session(session_id)
        if not session:
            raise HTTPException(404, f"Session '{session_id}' not found")
    elif req.save_history:
        first_user = next(
            (m["content"] for m in incoming if m["role"] == "user"), "New conversation"
        )
        session = await db_create_session(derive_title(first_user), req.dashboard_context)
        session_id = session["id"]

    # 3. Load prior history (excludes the current turn, saved only after generation).
    if session_id and req.save_history:
        history = await db_get_messages(session_id)
        groq_history = history_to_groq_messages(history)
    else:
        groq_history = []

    # 4. Build the request and generate.
    groq_messages = groq_history + incoming
    ai_text = call_groq(groq_messages, system)

    # 5a. Optionally execute the generated SQL against Superset.
    sql_query = None
    sql_data = None
    sql_error = None
    if req.execute_sql:
        sql_query = extract_sql(ai_text)
        if sql_query:
            safe_sql = sanitize_sql_for_clickhouse(sql_query)
            try:
                sql_data = await superset_sql_query(safe_sql, req.database_id)
            except Exception as error:
                sql_error = str(error)

    # 5b. Persist the exchange only after a successful generation.
    if session_id and req.save_history:
        for message in incoming:
            await db_save_message(session_id, message["role"], message["content"])
        await db_save_message(
            session_id, "assistant", ai_text,
            sql_query=sql_query,
            sql_data=sql_data,
            sql_error=sql_error,
        )

    return {
        "response":   ai_text,
        "sql":        sql_query,
        "data":       sql_data,
        "error":      sql_error,
        "session_id": session_id,
    }


# ─────────────────────────────────────────────────────────────
# ROUTES — DIRECT SQL
# ─────────────────────────────────────────────────────────────

@app.post("/execute-sql")
async def execute_sql_route(req: SQLExecuteRequest):
    """Execute a SQL query directly against Superset, bypassing the LLM."""
    try:
        return {"data": await superset_sql_query(req.sql, req.database_id), "error": None}
    except Exception as error:
        return {"data": None, "error": str(error)}


# ─────────────────────────────────────────────────────────────
# ROUTES — SUPERSET
# ─────────────────────────────────────────────────────────────

@app.get("/superset/dashboards")
async def list_dashboards():
    """Return the available Superset dashboards."""
    try:
        return {"dashboards": await get_superset_dashboards()}
    except Exception as error:
        return {"dashboards": [], "error": str(error)}


@app.get("/superset/dashboards/{dashboard_id}/charts")
async def list_charts(dashboard_id: int):
    """Return the charts for a given dashboard."""
    try:
        return {"charts": await get_superset_charts(dashboard_id)}
    except Exception as error:
        return {"charts": [], "error": str(error)}


@app.get("/superset/status")
async def superset_status():
    """Health check for the Superset connection."""
    try:
        await get_superset_token()
        dashboards = await get_superset_dashboards()
        return {"connected": True, "url": SUPERSET_URL,
                "dashboards_count": len(dashboards)}
    except Exception as error:
        return {"connected": False, "error": str(error)}


# ─────────────────────────────────────────────────────────────
# ROUTE — HEALTH
# ─────────────────────────────────────────────────────────────

@app.get("/health")
async def health():
    """Basic liveness and configuration report."""
    return {
        "status":       "ok",
        "provider":     "groq",
        "model":        GROQ_MODEL,
        "superset_url": SUPERSET_URL,
        "history_db":   DB_PATH,
        "version":      "3.1.0",
    }