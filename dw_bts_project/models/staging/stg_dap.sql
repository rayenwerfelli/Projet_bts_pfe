with source as (
    select * from ods."DAP"
),

cleaned as (
    select
        "SUDAP"                                    as sudap,
        {{ parse_mixed_date('"DMJDAP"') }}         as dmjdap,
        "TIMDAP"                                   as timdap,
        "EMPDAP"                                   as empdap,
        {{ clean_text('"COPDAP"') }}               as copdap,

        -- ── Identifiants ────────────────────────────────────────────
        "REFAUTDAP"                                as refautdap,
        "ORDDAP"                                   as orddap,
        "CODENADAP"                                as codenadap,

        -- ── Compte débiteur (16 lignes NULL → nullable) ─────────────
        "NATCPTDAP"                                as natcptdap,
        "ORDCPTDAP"                                as ordcptdap,
        "KLECPTDAP"                                as klecptdap,

        -- ── Conditions financières ───────────────────────────────────
        "MNTDAP"                                   as mntdap,

        -- PDPDAP : 92 NULL (8,64 %) → valeur par défaut 1 (Mensuelle)
        -- avec conservation de la source brute pour audit
        "PDPDAP"                                   as pdpdap_src,
        coalesce("PDPDAP", 1)                      as pdpdap,

        -- TAUDAP : 100 % NULL → colonne vide conservée telle quelle
        "TAUDAP"                                   as taudap,

        -- DBKDAP : 100 % NULL → colonne vide conservée telle quelle
        {{ parse_mixed_date('"DBKDAP"') }}         as dbkdap,

        -- RMBDAP : 80,09 % NULL → nullable
        "RMBDAP"                                   as rmbdap,

        -- FRZDAP : 0,56 % NULL → nullable
        "FRZDAP"                                   as frzdap,

        "DURDAP"                                   as durdap,

        -- CDFDAP : 100 % NULL → colonne vide conservée telle quelle
        "CDFDAP"                                   as cdfdap,

        -- ── Tranches (toutes à 0 NULL → not null) ───────────────────
        "MNTTR1DAP"                                as mnttr1dap,
        "MNTR2DAP"                                 as mntr2dap,
        "MNTR3DAP"                                 as mntr3dap,
        "MNTR4DAP"                                 as mntr4dap,
        "MNTR5DAP"                                 as mntr5dap,

        -- ── Etat & pool ─────────────────────────────────────────────
        "MDFDAP"                                   as mdfdap,

        -- POLDAP : texte brut (VARCHAR2(1)) → normalisation technique
        {{ clean_text('"POLDAP"') }}               as poldap_src,
        case
            when {{ clean_text('"POLDAP"') }} = '1' then 1
            when {{ clean_text('"POLDAP"') }} = '0' then 0
            else 0
        end::smallint                              as poldap,

        -- BQFDAP : 0 NULL mais souvent placeholder '0' ou vide
        {{ clean_text_or_na('"BQFDAP"') }}         as bqfdap,

        -- TOTDAP : 25 NULL (2,35 %) → nullable
        "TOTDAP"                                   as totdap,

        -- PBQDAP : 100 % NULL → colonne vide conservée telle quelle
        "PBQDAP"                                   as pbqdap,

        -- ── Compte interne de règlement (90,8 % NULL) ───────────────
        "NATCPFDAP"                                as natcpfdap,
        "ORDCPFDAP"                                as ordcpfdap,
        "KLECPFDAP"                                as klecpfdap,

        -- ── Indicateurs islamiques / consolidation ───────────────────
        -- IISDAP : 89,3 % NULL → nullable, pas de défaut imposé
        "IISDAP"                                   as iisdap,

        -- CODENGDAP : 99,81 % NULL → nullable
        "CODENGDAP"                                as codengdap,

        -- CODLFNDAP : 100 % NULL → colonne vide conservée telle quelle
        "CODLFNDAP"                                as codlfndap,

        -- ICSLDAP : 100 % NULL → colonne vide conservée telle quelle
        "ICSLDAP"                                  as icsldap,

        -- NUMCSLDAP : 98,69 % NULL → nullable
        "NUMCSLDAP"                                as numcsldap,

        -- NUMADXDAP : 100 % NULL → colonne vide conservée telle quelle
        "NUMADXDAP"                                as numadxdap,

        -- CODTADDAP : 100 % NULL → colonne vide conservée telle quelle
        {{ clean_text('"CODTADDAP"') }}            as codtaddap,

        current_timestamp                          as _load_timestamp

    from source
)

select * from cleaned