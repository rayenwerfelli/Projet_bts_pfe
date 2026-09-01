{{ config(materialized='table') }}

with source as (
    select *
    from {{ source('ods', 'DMG') }}
),

cleaned as (
    select
        {{ clean_int('"SUDMG"') }} as sudmg,
        {{ parse_mixed_date('"DMJDMG"') }} as dmjdmg,
        {{ clean_int('"TIMDMG"') }} as timdmg,
        {{ clean_int('"EMPDMG"') }} as empdmg,
        {{ clean_legacy_text('"COPDMG"', 4) }} as copdmg,
        {{ clean_int('"NUMDMG"') }} as numdmg,
        {{ clean_int('"CODCLTDMG"') }} as codcltdmg,

        {{ parse_mixed_date('"DATDMG"') }} as datdmg,

        {{ clean_int('"ETADMG"') }} as etadmg,
        {{ clean_int('"DCDDMG"') }} as dcddmg,
        {{ parse_mixed_date('"DADDMG"') }} as daddmg,
        {{ clean_int('"DSDDMG"') }} as dsddmg,
        {{ clean_legacy_text('"CD1DMG"', 250) }} as cd1dmg,
        {{ clean_int('"RPCDMG"') }} as rpcdmg,
        {{ parse_mixed_date('"DRPDMG"') }} as drpdmg,
        {{ clean_legacy_text('"CC1DMG"', 250) }} as cc1dmg,
        {{ clean_int('"UNTIDMG"') }} as untidmg,
        {{ clean_int('"UNTDDMG"') }} as untddmg,
        {{ parse_mixed_date('"DNCDMG"') }} as dncdmg,

        {{ clean_int('"CODHMFDMG"') }} as codhmfdmg,
        {{ clean_number('"MNTDMG"', 15, 3) }} as mntdmg,
        {{ clean_int('"NBRDMG"') }} as nbrdmg,
        {{ clean_int('"CODUNDDMG"') }} as codunddmg,
        {{ clean_legacy_text('"RFDDMG"', 15) }} as rfddmg,
        {{ clean_int('"NTFDMG"') }} as ntfdmg,

        {{ parse_mixed_date('"DENRDMG"') }} as denrdmg,
        {{ parse_mixed_date('"DAVIDMG"') }} as davidmg,
        {{ parse_mixed_date('"DADCDMG"') }} as dadcdmg,
        {{ parse_mixed_date('"DAUTDMG"') }} as dautdmg,

        {{ clean_number('"TMNTDMG"', 15, 3) }} as tmntdmg,
        {{ clean_int('"TNBRDMG"') }} as tnbrdmg,
        {{ clean_legacy_text('"CODDVSDMG"', 3) }} as coddvsdmg,
        {{ clean_int('"CODCLT2DMG"') }} as codclt2dmg,
        {{ clean_number('"TECDMG"', 15, 3) }} as tecdmg,
        {{ clean_number('"TEPDMG"', 15, 3) }} as tepdmg,
        {{ clean_number('"TEADMG"', 15, 3) }} as teadmg,
        {{ clean_number('"TRCDMG"', 15, 3) }} as trcdmg,
        {{ clean_number('"TRPDMG"', 15, 3) }} as trpdmg,
        {{ clean_number('"TRADMG"', 15, 3) }} as tradmg,

        {{ parse_mixed_date('"DTRFDMG"') }} as dtrfdmg,

        {{ clean_int('"CODDMXDMG"') }} as coddmxdmg,
        {{ clean_int('"CODDMYDMG"') }} as coddmydmg,
        {{ clean_int('"CODMTFDMG"') }} as codmtfdmg,
        {{ clean_int('"CODMTFCDMG"') }} as codmtfcdmg,

        {{ parse_mixed_date('"DRCPDMG"') }} as drcpdmg,

        {{ clean_int('"NUMAUTDMG"') }} as numautdmg,
        {{ clean_int('"ORDCPTDMG"') }} as ordcptdmg,
        {{ clean_number('"CRDPDMG"', 15, 3) }} as crdpdmg,
        {{ clean_number('"CRDADMG"', 15, 3) }} as crdadmg,
        {{ clean_number('"COMDMG"', 15, 3) }} as comdmg,
        {{ clean_number('"TVADMG"', 15, 3) }} as tvadmg,
        {{ clean_int('"CHRDMG"') }} as chrdmg,
        {{ clean_int('"IISDMG"') }} as iisdmg,
        {{ clean_int('"ITMKDMG"') }} as itmkdmg,
        {{ clean_int('"NATCPFDMG"') }} as natcpfdmg,
        {{ clean_int('"ORDCPFDMG"') }} as ordcpfdmg,
        {{ clean_int('"KLECPFDMG"') }} as klecpfdmg,

        {{ parse_mixed_date('"DCMFDMG"') }} as dcmfdmg,
        {{ parse_mixed_date('"DFTMKDMG"') }} as dftmkdmg,
        {{ parse_mixed_date('"DVLDDMG"') }} as dvlddmg,

        {{ clean_int('"NUMATFDMG"') }} as numatfdmg,
        {{ clean_number('"MATFDMG"', 15, 3) }} as matfdmg,
        {{ clean_int('"IATFDMG"') }} as iatfdmg,
        {{ clean_int('"NUM2DMG"') }} as num2dmg,
        {{ clean_number('"MASSDMG"', 15, 3) }} as massdmg,
        {{ clean_int('"TYPDMG"') }} as typdmg,
        {{ clean_number('"MHTVDMG"', 15, 3) }} as mhtvdmg,
        {{ clean_number('"MTVADMG"', 15, 3) }} as mtvadmg,
        {{ clean_number('"MTTCDMG"', 15, 3) }} as mttcdmg,
        {{ clean_legacy_text('"IRMBDMG"', 1) }} as irmbdmg,
        {{ clean_legacy_text('"ETJDMG"', 2) }} as etjdmg,
        {{ clean_int('"IDCADMG"') }} as idcadmg,
        {{ clean_int('"NUMCSLDMG"') }} as numcsldmg,
        {{ clean_int('"NUMADXDMG"') }} as numadxdmg,
        {{ clean_legacy_text('"CODTADDMG"', 4) }} as codtaddmg,
        {{ clean_legacy_text('"CODHRFDMG"', 2) }} as codhrfdmg,
        {{ clean_legacy_text('"ITDSDMG"', 1) }} as itdsdmg,
        {{ clean_legacy_text('"ISBVDMG"', 1) }} as isbvdmg,

        current_timestamp as _load_timestamp
    from source
)

select *
from cleaned