with source as (
    select *
    from ods."AUT"
),

cleaned as (
    select
        -- placeholder 100% -> null
        {{ clean_int('"SUAUT"') }} as suaut,

        {{ parse_mixed_date('"DMJAUT"') }} as dmjaut,
        {{ clean_bigint('"TIMAUT"') }} as timaut,
        {{ clean_bigint('"EMPAUT"') }} as empaut,

        {{ clean_text('"COPAUT"') }} as copaut,
        {{ clean_bigint('"REFAUT"') }} as refaut,
        {{ clean_bigint('"CODCLTAUT"') }} as codcltaut,
        {{ clean_number('"MNTAUT"', 18, 3) }} as mntaut,
        {{ parse_mixed_date('"DATAUT"') }} as dataut,

        -- colonnes totalement vides -> null
        cast(null as date) as echaut,
        cast(null as date) as cndaut,

        case
            when {{ clean_text('"POLAUT"') }} in ('0', '0.0') then null
            else {{ clean_text('"POLAUT"') }}
        end as polaut,

        cast(null as text) as bqfaut,

        {{ clean_text('"DSCAUT"') }} as dscaut,
        {{ clean_bigint('"NUMDMGAUT"') }} as numdmgaut,
        {{ parse_mixed_date('"DBVAUT"') }} as dbvaut,
        {{ parse_mixed_date('"FNVAUT"') }} as fnvaut,

        {{ clean_int('"VLBAUT"') }} as vlbaut,
        {{ clean_int('"VLCAUT"') }} as vlcaut,
        {{ clean_int('"CLOAUT"') }} as cloaut,

        {{ parse_mixed_date('"DSNAUT"') }} as dsnaut,
        {{ parse_mixed_date('"DEGAUT"') }} as degaut,
        {{ parse_mixed_date('"DNCAUT"') }} as dncaut,
        {{ clean_int('"CODUNDAUT"') }} as codundaut,

        {{ clean_number('"TOTAUT"', 18, 3) }} as totaut,

        -- colonne totalement vide -> null
        cast(null as bigint) as codclt2aut,

        {{ clean_text('"CODDVSAUT"') }} as coddvsaut,
        {{ parse_mixed_date('"DCCAUT"') }} as dccaut,
        {{ clean_int('"TYPAUT"') }} as typaut,

        {{ clean_int('"CODRCFAUT"') }} as codrcfaut,
        {{ clean_int('"NENRAUT"') }} as nenraut,
        {{ clean_int('"NQTCAUT"') }} as nqtcaut,

        -- colonnes totalement vides -> null
        cast(null as bigint) as codprjaut,
        cast(null as numeric(18, 3)) as pplaut,
        cast(null as numeric(18, 3)) as intcaut,
        cast(null as numeric(18, 3)) as intraut,
        cast(null as numeric(18, 3)) as intnaut,
        cast(null as numeric(18, 3)) as pvzaut,

        {{ clean_int('"NATCPTAUT"') }} as natcptaut,
        {{ clean_bigint('"ORDCPFAUT"') }} as ordcpfaut,
        {{ clean_int('"KLECPFAUT"') }} as klecpfaut,
        {{ clean_int('"NATCPFAUT"') }} as natcpfaut,
        {{ clean_int('"KLECPTAUT"') }} as klecptaut,
        {{ clean_bigint('"ORDCPTAUT"') }} as ordcptaut,
        {{ clean_int('"IISAUT"') }} as iisaut,

        {{ parse_mixed_date('"DSPRAUT"') }} as dspraut,
        {{ parse_mixed_date('"DRPRAUT"') }} as drpraut,
        {{ parse_mixed_date('"DACCAUT"') }} as daccaut,
        {{ parse_mixed_date('"DRPVAUT"') }} as drpvaut,
        {{ parse_mixed_date('"DSPVAUT"') }} as dspvaut,
        {{ parse_mixed_date('"DEPRAUT"') }} as depraut,

        {{ parse_mixed_date('"DETLAUT"') }} as detlaut,
        {{ parse_mixed_date('"DETCRAUT"') }} as detcraut,
        {{ parse_mixed_date('"DECFAUT"') }} as decfaut,
        {{ parse_mixed_date('"DRCFAUT"') }} as drcfaut,
        {{ parse_mixed_date('"DACFAUT"') }} as dacfaut,
        {{ parse_mixed_date('"DSCFAUT"') }} as dscfaut,

        -- colonne totalement vide -> null
        cast(null as date) as drfcfaut,

        {{ parse_mixed_date('"DEPVAUT"') }} as depvaut,
        {{ clean_bigint('"NUMCSLAUT"') }} as numcslaut,

        -- colonnes totalement vides -> null
        cast(null as text) as numadxaut,
        cast(null as bigint) as codtadaut,

        {{ clean_int('"CODHRFAUT"') }} as codhrfaut,
        {{ clean_int('"ISBVAUT"') }} as isbvaut,
        {{ clean_int('"ITDSAUT"') }} as itdsaut,
        {{ parse_mixed_date('"DHPAUT"') }} as dhpaut,
        {{ clean_text('"NUMHPAUT"') }} as numhpaut,

        -- colonnes totalement vides -> null
        cast(null as date) as ddstaut,
        cast(null as bigint) as idstaut,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned