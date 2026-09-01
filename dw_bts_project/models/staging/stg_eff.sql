{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ods', 'EFF') }}

),

cleaned as (

    select
        {{ clean_int('"SUEFF"') }} as sueff,
        {{ parse_mixed_date('"DMJEFF"') }} as dmjeff,
        {{ clean_bigint('"TIMEFF"') }} as timeff,
        {{ clean_int('"EMPEFF"') }} as empeff,
        {{ clean_legacy_text('"COPEFF"', 4) }} as copeff,

        {{ clean_legacy_text('"CODINSEFF"', 8) }} as codinseff,
        {{ clean_legacy_text('"REFEFF"', 15) }} as refeff,
        {{ clean_legacy_text('"DVSEFF"', 3) }} as dvseff,
        {{ clean_number('"MNTEFF"', 15, 3) }} as mnteff,

        {{ clean_int('"CODENGEFF"') }} as codengeff,
        {{ clean_int('"NATCPXEFF"') }} as natcpxeff,
        {{ clean_bigint('"ORDCPXEFF"') }} as ordcpxeff,
        {{ clean_int('"KLECPXEFF"') }} as klecpxeff,
        {{ clean_int('"NATCPYEFF"') }} as natcpyeff,
        {{ clean_bigint('"ORDCPYEFF"') }} as ordcpyeff,
        {{ clean_int('"KLECPYEFF"') }} as klecpyeff,
        {{ clean_bigint('"CODPRDEFF"') }} as codprdeff,
        {{ clean_int('"CODUNTEEFF"') }} as codunteeff,
        {{ clean_int('"CODUNTREFF"') }} as coduntreff,

        {{ parse_mixed_date('"ECHEFF"') }} as echeff,
        {{ parse_mixed_date('"DDBEFF"') }} as ddbeff,
        {{ parse_mixed_date('"DFNEFF"') }} as dfneff,

        {{ clean_legacy_text('"CODBAQEFF"', 6) }} as codbaqeff,
        {{ clean_text('"INIEFF"') }} as inieff,
        {{ clean_text('"BNFEFF"') }} as bnfeff,
        {{ clean_text('"DSCEFF"') }} as dsceff,
        {{ clean_text('"RFTEFF"') }} as rfteff,

        {{ clean_number('"BLKEFF"', 15, 3) }} as blkeff,
        {{ clean_number('"BLCEFF"', 15, 3) }} as blceff,
        {{ clean_legacy_text('"CODOPMEFF"', 4) }} as codopmeff,

        {{ clean_int('"RIBBEFF"') }} as ribbeff,
        {{ clean_int('"RIBAEFF"') }} as ribaeff,
        {{ clean_bigint('"RIBCEFF"') }} as ribceff,
        {{ clean_int('"RIBKEFF"') }} as ribkeff,

        {{ clean_int('"PRTEFF"') }} as prteff,
        upper({{ clean_legacy_text('"ACPEFF"', 1) }}) as acpeff,
        {{ clean_int('"ENDEFF"') }} as endeff,
        {{ clean_int('"ODPEFF"') }} as odpeff,
        {{ clean_int('"MRJ1EFF"') }} as mrj1eff,
        {{ clean_int('"MRJ2EFF"') }} as mrj2eff,
        {{ clean_int('"MRJ3EFF"') }} as mrj3eff,
        {{ clean_int('"MRJ4EFF"') }} as mrj4eff,

        {{ clean_int('"CODUNTIEFF"') }} as coduntieff,
        {{ parse_mixed_date('"DTCEFF"') }} as dtceff,
        {{ parse_mixed_date('"DTSEFF"') }} as dtseff,
        {{ clean_text('"VILEFF"') }} as vileff,
        {{ parse_mixed_date('"AECHEFF"') }} as aecheff,

        {{ clean_int('"ETAEFF"') }} as etaeff,
        {{ clean_legacy_text('"TTAEFF"', 10) }} as ttaeff,
        {{ clean_number('"VTTAEFF"', 8, 6) }} as vttaeff,
        {{ clean_number('"TAUEFF"', 8, 6) }} as taueff,
        {{ clean_number('"CPCEFF"', 8, 6) }} as cpceff,
        {{ clean_number('"TCGEFF"', 8, 6) }} as tcgeff,
        {{ clean_int('"NBJEFF"') }} as nbjeff,
        {{ clean_number('"ASTEFF"', 15, 3) }} as asteff,

        {{ clean_int('"TYPEFF"') }} as typeff,
        {{ clean_int('"PPLEFF"') }} as ppleff,
        {{ clean_int('"LGNEFF"') }} as lgneff,
        {{ clean_bigint('"REFAUTEFF"') }} as refauteff,
        {{ clean_int('"ORDDAPEFF"') }} as orddapeff,
        {{ clean_int('"NUMTRHEFF"') }} as numtrheff,
        {{ clean_int('"CDFEFF"') }} as cdfeff,
        {{ clean_bigint('"NUM2EFF"') }} as num2eff,
        {{ clean_int('"CVVEFF"') }} as cvveff,

        {{ parse_mixed_date('"DRGLEFF"') }} as drgleff,
        {{ clean_int('"CTXEFF"') }} as ctxeff,
        {{ clean_int('"CRPEFF"') }} as crpeff,
        {{ parse_mixed_date('"DCTXEFF"') }} as dctxeff,

        {{ clean_number('"MNTIREFF"', 15, 3) }} as mntireff,
        {{ clean_number('"MNTIEFF"', 15, 3) }} as mntieff,
        {{ clean_number('"MNTPEFF"', 15, 3) }} as mntpeff,
        {{ clean_number('"IRIEEFF"', 15, 3) }} as irieeff,
        {{ clean_number('"IRIIEFF"', 15, 3) }} as iriieff,
        {{ clean_number('"IRPIEFF"', 15, 3) }} as irpieff,
        {{ clean_number('"IRPEEFF"', 15, 3) }} as irpeeff,
        {{ clean_number('"ICRUEFF"', 15, 3) }} as icrueff,
        {{ clean_number('"IECHEFF"', 15, 3) }} as iecheff,
        {{ clean_number('"IIMPEFF"', 15, 3) }} as iimpeff,
        {{ clean_number('"PNECEFF"', 15, 3) }} as pneceff,
        {{ clean_number('"PECHEFF"', 15, 3) }} as pecheff,
        {{ clean_number('"PIMPEFF"', 15, 3) }} as pimpeff,

        {{ clean_int('"ICSLEFF"') }} as icsleff,
        {{ clean_bigint('"NUMCSLEFF"') }} as numcsleff,
        {{ clean_number('"MINTEFF"', 15, 3) }} as minteff,
        {{ clean_number('"MTVAEFF"', 15, 3) }} as mtvaeff,
        {{ clean_number('"MTTCEFF"', 15, 3) }} as mttceff,
        {{ clean_number('"MTMBEFF"', 15, 3) }} as mtmbeff,
        {{ clean_number('"MASSEFF"', 15, 3) }} as masseff,
        {{ clean_bigint('"NUMRPTEFF"') }} as numrpteff,
        {{ clean_int('"IRPTEFF"') }} as irpteff,
        {{ clean_legacy_text('"REF2EFF"', 15) }} as ref2eff,
        upper({{ clean_legacy_text('"TRPTEFF"', 1) }}) as trpteff,
        {{ clean_bigint('"NUMRCHEFF"') }} as numrcheff,
        upper({{ clean_legacy_text('"IRCHEFF"', 1) }}) as ircheff,
        {{ clean_legacy_text('"CODQAQEFF"', 20) }} as codqaqeff,
        {{ clean_number('"MIRREFF"', 15, 3) }} as mirreff,
        {{ clean_number('"MTVAIEFF"', 15, 3) }} as mtvaieff,
        {{ clean_int('"IRGPEFF"') }} as irgpeff,
        {{ clean_legacy_text('"REF3EFF"', 15) }} as ref3eff,

        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned