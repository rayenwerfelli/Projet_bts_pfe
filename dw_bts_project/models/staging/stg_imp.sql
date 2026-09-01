{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ods', 'IMP') }}

),

cleaned as (

    select
        {{ clean_int('"SUIMP"') }} as suimp,
        {{ parse_mixed_date('"DMJIMP"') }} as dmjimp,
        {{ clean_bigint('"TIMIMP"') }} as timimp,
        {{ clean_int('"EMPIMP"') }} as empimp,
        {{ clean_legacy_text('"COPIMP"', 4) }} as copimp,

        {{ clean_legacy_text('"CODINSIMP"', 8) }} as codinsimp,
        {{ clean_legacy_text('"REFIMP"', 15) }} as refimp,
        {{ clean_legacy_text('"DVSIMP"', 3) }} as dvsimp,
        {{ clean_number('"MNTIMP"', 15, 3) }} as mntimp,

        {{ clean_int('"CODENGIMP"') }} as codengimp,
        {{ clean_int('"NATCPXIMP"') }} as natcpximp,
        {{ clean_bigint('"ORDCPXIMP"') }} as ordcpximp,
        {{ clean_int('"KLECPXIMP"') }} as klecpximp,
        {{ clean_int('"NATCPYIMP"') }} as natcpyimp,
        {{ clean_bigint('"ORDCPYIMP"') }} as ordcpyimp,
        {{ clean_int('"KLECPYIMP"') }} as klecpyimp,
        {{ clean_bigint('"CODPRDIMP"') }} as codprdimp,
        {{ clean_int('"CODUNTEIMP"') }} as codunteimp,
        {{ clean_int('"CODUNTRIMP"') }} as coduntrimp,

        {{ parse_mixed_date('"ECHIMP"') }} as echimp,
        {{ parse_mixed_date('"DDBIMP"') }} as ddbimp,
        {{ parse_mixed_date('"DFNIMP"') }} as dfnimp,

        {{ clean_legacy_text('"CODBAQIMP"', 6) }} as codbaqimp,
        {{ clean_text('"INIIMP"') }} as iniimp,
        {{ clean_text('"BNFIMP"') }} as bnfimp,
        {{ clean_text('"DSCIMP"', ) }} as dscimp,
        {{ clean_text('"RFTIMP"') }} as rftimp,

        {{ clean_number('"BLKIMP"', 15, 3) }} as blkimp,
        {{ clean_number('"BLCIMP"', 15, 3) }} as blcimp,
        {{ clean_legacy_text('"CODOPMIMP"', 4) }} as codopmimp,

        {{ clean_int('"RIBBIMP"') }} as ribbimp,
        {{ clean_int('"RIBAIMP"') }} as ribaimp,
        {{ clean_bigint('"RIBCIMP"') }} as ribcimp,
        {{ clean_int('"RIBKIMP"') }} as ribkimp,

        {{ clean_int('"PRTIMP"') }} as prtimp,
        upper({{ clean_legacy_text('"ACPIMP"', 1) }}) as acpimp,
        {{ clean_int('"ENDIMP"') }} as endimp,
        {{ clean_int('"ODPIMP"') }} as odpimp,
        {{ clean_int('"MRJ1IMP"') }} as mrj1imp,
        {{ clean_int('"MRJ2IMP"') }} as mrj2imp,
        {{ clean_int('"MRJ3IMP"') }} as mrj3imp,
        {{ clean_int('"MRJ4IMP"') }} as mrj4imp,

        {{ clean_int('"CODUNTIIMP"') }} as coduntiimp,
        {{ parse_mixed_date('"DTCIMP"') }} as dtcimp,
        {{ parse_mixed_date('"DTSIMP"') }} as dtsimp,
        {{ clean_text('"VILIMP"') }} as vilimp,

        {{ clean_int('"ETAIMP"') }} as etaimp,
        {{ clean_legacy_text('"TTAIMP"', 10) }} as ttaimp,
        {{ clean_number('"VTTAIMP"', 8, 6) }} as vttaimp,
        {{ clean_number('"TAUIMP"', 8, 6) }} as tauimp,
        {{ clean_number('"CPCIMP"', 8, 6) }} as cpcimp,
        {{ clean_number('"TCGIMP"', 8, 6) }} as tcgimp,
        {{ clean_int('"NBJIMP"') }} as nbjimp,
        {{ clean_number('"ASTIMP"', 15, 3) }} as astimp,

        {{ clean_int('"TYPIMP"') }} as typimp,
        {{ clean_int('"NATCPHIMP"') }} as natcphimp,
        {{ clean_bigint('"ORDCPHIMP"') }} as ordcphimp,
        {{ clean_int('"KLECPHIMP"') }} as klecphimp,
        {{ clean_bigint('"REFAUTIMP"') }} as refautimp,
        {{ clean_int('"ORDDAPIMP"') }} as orddapimp,
        {{ clean_int('"NUMTRHIMP"') }} as numtrhimp,
        {{ clean_legacy_text('"CVVIMP"', 10) }} as cvvimp,

        {{ parse_mixed_date('"DRGLIMP"') }} as drglimp,
        {{ clean_int('"CTXIMP"') }} as ctximp,
        {{ clean_int('"CRPIMP"') }} as crpimp,
        {{ parse_mixed_date('"DCTXIMP"') }} as dctximp,

        {{ clean_number('"MNTIRIMP"', 15, 3) }} as mntirimp,
        {{ clean_number('"MNTIIMP"', 15, 3) }} as mntiimp,
        {{ clean_number('"MNTPIMP"', 15, 3) }} as mntpimp,
        {{ clean_number('"IRIEIMP"', 15, 3) }} as irieimp,
        {{ clean_number('"IRIIIMP"', 15, 3) }} as iriiimp,
        {{ clean_number('"IRPIIMP"', 15, 3) }} as irpiimp,
        {{ clean_number('"IRPEIMP"', 15, 3) }} as irpeimp,
        {{ clean_number('"ICRUIMP"', 15, 3) }} as icruimp,
        {{ clean_number('"IECHIMP"', 15, 3) }} as iechimp,
        {{ clean_number('"IIMPIMP"', 15, 3) }} as iimpimp,
        {{ clean_number('"PNECIMP"', 15, 3) }} as pnecimp,
        {{ clean_number('"PECHIMP"', 15, 3) }} as pechimp,
        {{ clean_number('"PIMPIMP"', 15, 3) }} as pimpimp,

        {{ clean_int('"ICSLIMP"') }} as icslimp,
        {{ clean_bigint('"NUMCSLIMP"') }} as numcslimp,
        {{ clean_bigint('"NUM2IMP"') }} as num2imp,
        {{ clean_number('"MINTIMP"', 15, 3) }} as mintimp,
        {{ clean_number('"MTVAIMP"', 15, 3) }} as mtvaimp,
        {{ clean_number('"MTTCIMP"', 15, 3) }} as mttcimp,
        {{ clean_number('"MTMBIMP"', 15, 3) }} as mtmbimp,
        {{ clean_number('"MASSIMP"', 15, 3) }} as massimp,
        {{ clean_bigint('"NUMRPTIMP"') }} as numrptimp,
        {{ clean_int('"IRPTIMP"') }} as irptimp,
        {{ clean_legacy_text('"REF2IMP"', 15) }} as ref2imp,
        upper({{ clean_legacy_text('"TRPTIMP"', 1) }}) as trptimp,
        {{ clean_bigint('"NUMRCHIMP"') }} as numrchimp,
        upper({{ clean_legacy_text('"IRCHIMP"', 1) }}) as irchimp,
        {{ clean_legacy_text('"CODQAQIMP"', 20) }} as codqaqimp,
        {{ clean_number('"MIRRIMP"', 15, 3) }} as mirrimp,
        {{ clean_number('"MTVAIIMP"', 15, 3) }} as mtvaiimp,
        {{ clean_int('"IRGPIMP"') }} as irgpimp,
        {{ clean_legacy_text('"REF3IMP"', 15) }} as ref3imp,

        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned