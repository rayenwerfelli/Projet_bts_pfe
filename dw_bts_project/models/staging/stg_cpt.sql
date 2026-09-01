with source as (
    select *
    from ods."CPT"
),

cleaned as (
    select
        "SUCPT" as sucpt,
        {{ parse_mixed_date('"DMJCPT"') }} as dmjcpt,
        "TIMCPT" as timcpt,
        "EMPCPT" as empcpt,
        nullif(trim(cast("COPCPT" as text)), '') as copcpt,

        "ORDCPT" as ordcpt,
        "CODNATCPT" as codnatcpt,
        "KLECPT" as klecpt,
        "CODCLTCPT" as codcltcpt,
        "CODDVSCPT" as coddvscpt,

        coalesce(nullif(trim(cast("CODPTTCPT" as text)), ''), 'N/A') as codpttcpt,
        coalesce(nullif(trim(cast("CODPAYACPT" as text)), ''), 'N/A') as codpayacpt,
        coalesce(nullif(trim(cast("CODPAYNCPT" as text)), ''), 'N/A') as codpayncpt,
        coalesce(nullif(trim(cast("CODPAYCPT" as text)), ''), 'N/A') as codpaycpt,

        "NCVCPT" as ncvcpt,
        {{ parse_mixed_date('"OUVCPT"') }} as ouvcpt,

        coalesce(nullif(trim(cast("RZDCPT" as text)), ''), 'N/A') as rzdcpt,
        "TYPCPT" as typcpt,
        "CATCPT" as catcpt,
        "PPMCPT" as ppmcpt,

        upper(nullif(trim(cast("NOMCPT" as text)), '')) as nomcpt,
        initcap(lower(nullif(trim(cast("PRNCPT" as text)), ''))) as prncpt,

        {{ parse_mixed_date('"DNACPT"') }} as dnacpt,
        coalesce(nullif(trim(cast("VNACPT" as text)), ''), 'NON RENSEIGNE') as vnacpt,
        coalesce(nullif(trim(cast("ADR1CPT" as text)), ''), 'NON RENSEIGNE') as adr1cpt,

        case
            when nullif(trim(regexp_replace(cast("ANOMCPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')), '') is null
            then 'NON RENSEIGNE'
            else upper(trim(regexp_replace(cast("ANOMCPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')))
        end as anomcpt,

        case
            when nullif(trim(regexp_replace(cast("APRNCPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')), '') is null
            then 'NON RENSEIGNE'
            else initcap(lower(trim(regexp_replace(cast("APRNCPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g'))))
        end as aprncpt,

        case
            when nullif(trim(regexp_replace(cast("AADR1CPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')), '') is null
            then 'NON RENSEIGNE'
            else upper(trim(regexp_replace(cast("AADR1CPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')))
        end as aadr1cpt,

        coalesce(nullif(trim(cast("LNGCPT" as text)), ''), 'N/A') as lngcpt,

        nullif(trim(cast("IBANCPT" as text)), '') as ibancpt,
        nullif(trim(cast("RIBBCPT" as text)), '') as ribbcpt,
        nullif(trim(cast("RIBACPT" as text)), '') as ribacpt,
        nullif(trim(cast("RIBCCPT" as text)), '') as ribccpt,
        nullif(trim(cast("RIBKCPT" as text)), '') as ribkcpt,

        coalesce(nullif(trim(cast("RZVCPT" as text)), ''), 'N/A') as rzvcpt,
        "CMNCPT" as cmncpt,
        coalesce("TADCPT", 0) as tadcpt,
        "OSGCPT" as osgcpt,
        "JNTCPT" as jntcpt,

        coalesce(nullif(trim(cast("OPDCPT" as text)), ''), 'N/A') as opdcpt,
        coalesce(nullif(trim(cast("OPCCPT" as text)), ''), 'N/A') as opccpt,
        coalesce(nullif(trim(cast("OPPCPT" as text)), ''), 'N/A') as oppcpt,

        coalesce({{ parse_mixed_date('"DCECPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dcecpt,
        coalesce(nullif(trim(cast("LNRCPT" as text)), ''), 'N/A') as lnrcpt,
        "CLOCPT" as clocpt,

        coalesce({{ parse_mixed_date('"DCLOCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dclocpt,

        "MCLOCPT" as mclocpt,
        nullif(trim(cast("TDCCPT" as text)), '') as tdccpt,
        coalesce(nullif(trim(cast("NDCCPT" as text)), ''), 'NON_RAPPORTE') as ndccpt,

        coalesce(nullif(trim(cast("TSPCPT" as text)), ''), 'N') as tspcpt,
        coalesce(nullif(trim(cast("RSPCPT" as text)), ''), 'N') as rspcpt,
        coalesce(nullif(trim(cast("CAZCPT" as text)), ''), 'N/A') as cazcpt,
        coalesce(nullif(trim(cast("RCQCPT" as text)), ''), 'N') as rcqcpt,

        "CRCCPT" as crccpt,
        coalesce({{ parse_mixed_date('"DCRCCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dcrccpt,
        coalesce({{ parse_mixed_date('"ECRCCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as ecrccpt,

        coalesce(nullif(trim(cast("AVSCPT" as text)), ''), 'N') as avscpt,

        coalesce("SLCCPT", 0) as slccpt,
        coalesce("SLDCPT", 0) as sldcpt,
        coalesce({{ parse_mixed_date('"DSLDCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dsldcpt,
        coalesce("SMNCPT", 0) as smncpt,
        coalesce({{ parse_mixed_date('"DSMNCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dsmncpt,
        coalesce("SMXCPT", 0) as smxcpt,
        coalesce({{ parse_mixed_date('"DSMXCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dsmxcpt,
        coalesce("SMMCPT", 0) as smmcpt,
        coalesce("MCMCPT", 0) as mcmcpt,
        coalesce("MDMCPT", 0) as mdmcpt,
        coalesce("MMMCPT", 0) as mmmcpt,

        coalesce(nullif(trim(cast("UMCCCPT" as text)), ''), 'N/A') as umcccpt,
        coalesce({{ parse_mixed_date('"DPDCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dpdcpt,
        coalesce({{ parse_mixed_date('"DPCCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dpccpt,

        coalesce(nullif(trim(cast("BLKCPT" as text)), ''), 'N') as blkcpt,
        coalesce(nullif(trim(cast("BLCCPT" as text)), ''), 'N') as blccpt,

        "BURCPT" as burcpt,
        coalesce(nullif(trim(cast("RTMCPT" as text)), ''), 'N/A') as rtmcpt,
        "CTPCPT" as ctpcpt,
        coalesce(nullif(trim(cast("RGECPT" as text)), ''), 'N/A') as rgecpt,
        coalesce(nullif(trim(cast("CODCLT2CPT" as text)), ''), 'N/A') as codclt2cpt,
        coalesce(nullif(trim(cast("ECHCPT" as text)), ''), 'N/A') as echcpt,
        coalesce("PRLCPT", 0) as prlcpt,
        coalesce("TAUCPT", 0) as taucpt,

        coalesce(nullif(trim(cast("ISRCPT" as text)), ''), 'N') as isrcpt,
        coalesce(nullif(trim(cast("IASCPT" as text)), ''), 'N') as iascpt,
        coalesce(nullif(trim(cast("IANCPT" as text)), ''), 'N') as iancpt,

        coalesce({{ parse_mixed_date('"DINCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dincpt,
        coalesce(nullif(trim(cast("EAVCPT" as text)), ''), 'N/A') as eavcpt,
        coalesce({{ parse_mixed_date('"DAVCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as davcpt,
        coalesce("MRSCPT", 0) as mrscpt,
        coalesce(nullif(trim(cast("TRSCPT" as text)), ''), 'N') as trscpt,
        coalesce(nullif(trim(cast("NETCPT" as text)), ''), 'N') as netcpt,
        coalesce(nullif(trim(cast("TIDCPT" as text)), ''), 'N/A') as tidcpt,
        coalesce("MRLCPT", 0) as mrlcpt,
        coalesce(nullif(trim(cast("NDTCPT" as text)), ''), 'N/A') as ndtcpt,

        "CPSCPT" as cpscpt,
        coalesce("SARCPT", 0) as sarcpt,
        "CNPCPT" as cnpcpt,
        "EFFCPT" as effcpt,
        "PRVCPT" as prvcpt,
        coalesce(nullif(trim(cast("PTECPT" as text)), ''), 'N/A') as ptecpt,
        coalesce(nullif(trim(cast("SCHCPT" as text)), ''), 'N/A') as schcpt,

        nullif(trim(cast("RIBCPT" as text)), '') as ribcpt,

        coalesce(nullif(trim(cast("GCRCPT" as text)), ''), 'N/A') as gcrcpt,
        coalesce(nullif(trim(cast("GDBCPT" as text)), ''), 'N/A') as gdbcpt,
        coalesce(nullif(trim(cast("AGCCPT" as text)), ''), 'N/A') as agccpt,
        coalesce(nullif(trim(cast("CEFCPT" as text)), ''), 'N/A') as cefcpt,

        coalesce(nullif(trim(cast("NBRCPT" as text)), ''), 'N/A') as nbrcpt,
        coalesce(nullif(trim(cast("RBCBCPT" as text)), ''), 'N/A') as rbcbcpt,
        coalesce(nullif(trim(cast("RBCACPT" as text)), ''), 'N/A') as rbcacpt,
        coalesce(nullif(trim(cast("RBCCCPT" as text)), ''), 'N/A') as rbcccpt,
        coalesce(nullif(trim(cast("RBCKCPT" as text)), ''), 'N/A') as rbckcpt,

        coalesce(nullif(trim(cast("AGECPT" as text)), ''), 'N/A') as agecpt,
        coalesce(nullif(trim(cast("BCTCPT" as text)), ''), 'N') as bctcpt,
        coalesce(nullif(trim(cast("RBCTCPT" as text)), ''), 'N/A') as rbctcpt,
        coalesce(nullif(trim(cast("ETRCPT" as text)), ''), 'N/A') as etrcpt,
        coalesce(nullif(trim(cast("IVALCPT" as text)), ''), 'N') as ivalcpt,

        coalesce(nullif(trim(cast("CODBAQCPT" as text)), ''), 'N/A') as codbaqcpt,
        coalesce(nullif(trim(cast("CODBQECPT" as text)), ''), 'N/A') as codbqecpt,

        coalesce(nullif(trim(cast("FINCPT" as text)), ''), 'N/A') as fincpt,
        coalesce(nullif(trim(cast("FINXCPT" as text)), ''), 'N/A') as finxcpt,

        coalesce({{ parse_mixed_date('"DSLCCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dslccpt,
        coalesce(nullif(trim(cast("GELCPT" as text)), ''), 'N') as gelcpt,
        coalesce({{ parse_mixed_date('"DDMVCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as ddmvcpt,

        coalesce(nullif(trim(cast("CODCPDCPT" as text)), ''), 'N/A') as codcpdcpt,
        coalesce(nullif(trim(cast("CRLCPT" as text)), ''), 'N/A') as crlcpt,

        case
            when nullif(trim(regexp_replace(cast("AADR2CPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')), '') is null
            then 'NON RENSEIGNE'
            else upper(trim(regexp_replace(cast("AADR2CPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')))
        end as aadr2cpt,

        case
            when nullif(trim(regexp_replace(cast("AADR3CPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')), '') is null
            then 'NON RENSEIGNE'
            else upper(trim(regexp_replace(cast("AADR3CPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')))
        end as aadr3cpt,

        coalesce(nullif(trim(cast("REACPT" as text)), ''), 'N/A') as reacpt,
        coalesce(nullif(trim(cast("NATXCPT" as text)), ''), 'N/A') as natxcpt,
        coalesce(nullif(trim(cast("CNLCPT" as text)), ''), 'N/A') as cnlcpt,
        coalesce(nullif(trim(cast("TMMCPT" as text)), ''), 'N/A') as tmmcpt,
        coalesce(nullif(trim(cast("EPZCPT" as text)), ''), 'N/A') as epzcpt,
        coalesce(nullif(trim(cast("ORDCPTCPT" as text)), ''), 'N/A') as ordcptcpt,
        coalesce(nullif(trim(cast("CODGCPT" as text)), ''), 'N/A') as codgcpt,
        coalesce(nullif(trim(cast("RPTCPT" as text)), ''), 'N/A') as rptcpt,
        coalesce(nullif(trim(cast("CSECPT" as text)), ''), 'N/A') as csecpt,
        coalesce(nullif(trim(cast("STOCPT" as text)), ''), 'N/A') as stocpt,
        coalesce(nullif(trim(cast("CAZMCPT" as text)), ''), 'N/A') as cazmcpt,
        coalesce(nullif(trim(cast("IVLCPT" as text)), ''), 'N/A') as ivlcpt,
        coalesce(nullif(trim(cast("PDICPT" as text)), ''), 'N/A') as pdicpt,
        coalesce(nullif(trim(cast("ORDGCPT" as text)), ''), 'N/A') as ordgcpt,
        coalesce(nullif(trim(cast("VFRCPT" as text)), ''), 'N/A') as vfrcpt,
        coalesce(nullif(trim(cast("MTSCPT" as text)), ''), 'N/A') as mtscpt,

        case
            when nullif(trim(regexp_replace(cast("AADR4CPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')), '') is null
            then 'NON RENSEIGNE'
            else upper(trim(regexp_replace(cast("AADR4CPT" as text), '[^A-Za-z0-9 éèàùâêîôûçÉÈÀÙÂÊÎÔÛÇ/-]', '', 'g')))
        end as aadr4cpt,

        coalesce(nullif(trim(cast("ADECPT" as text)), ''), 'N/A') as adecpt,
        coalesce(nullif(trim(cast("NDC2CPT" as text)), ''), 'N/A') as ndc2cpt,
        coalesce(nullif(trim(cast("KLEGCPT" as text)), ''), 'N/A') as klegcpt,
        coalesce(nullif(trim(cast("MAGOCPT" as text)), ''), 'N/A') as magocpt,
        coalesce(nullif(trim(cast("MTACPT" as text)), ''), 'N/A') as mtacpt,
        coalesce(nullif(trim(cast("NATCPTCPT" as text)), ''), 'N/A') as natcptcpt,
        coalesce(nullif(trim(cast("IACCPT" as text)), ''), 'N') as iaccpt,
        coalesce(nullif(trim(cast("IIECPT" as text)), ''), 'N') as iiecpt,
        coalesce(nullif(trim(cast("CODCLTSCPT" as text)), ''), 'N/A') as codcltscpt,
        coalesce(nullif(trim(cast("RIBGCPT" as text)), ''), 'N/A') as ribgcpt,
        coalesce(nullif(trim(cast("KLECPTCPT" as text)), ''), 'N/A') as klecptcpt,
        coalesce(nullif(trim(cast("TTOCPT" as text)), ''), 'N/A') as ttocpt,
        coalesce(nullif(trim(cast("DVLCPT" as text)), ''), 'N/A') as dvlcpt,
        coalesce({{ parse_mixed_date('"DARTCPT"') }}, to_date('2099-12-31','YYYY-MM-DD')) as dartcpt,
        coalesce(nullif(trim(cast("ORDCTXCPT" as text)), ''), 'N/A') as ordctxcpt,
        coalesce(nullif(trim(cast("MATEMPCPT" as text)), ''), 'N/A') as matempcpt,

        current_timestamp as _load_timestamp

    from source
)

select *
from cleaned