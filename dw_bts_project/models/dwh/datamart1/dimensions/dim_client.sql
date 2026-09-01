{{ config(materialized='table') }}

with src as (
    select * from {{ ref('hist_clt') }}
    where is_current = true
)

select
    md5(cast(codclt as text))       as client_key,

    codclt,
    nomclt,
    prnclt,
    njfclt,
    dnaclt,

    -- SEXE
    sexclt,
    case sexclt
        when 'M' then 'Masculin'
        when 'F' then 'Féminin'
        else 'F'
    end                             as lib_sexe,          -- ✅ ajouté

    -- SITUATION FAMILIALE
    stfclt,
    case stfclt
        when 'C' then 'Célibataire'
        when 'M' then 'Marié'
        when 'D' then 'Divorcé'
        when 'V' then 'Veuf'
        else 'Inconnu'
    end                             as lib_situation_familiale,  -- ✅ ajouté

    mfsclt,
    tidnclt,
    idnclt,
    codnisclt,
    crpclt,
    ndcclt,
    anomclt,
    aprnclt,
    adprclt,
    ageclt,
    codqlfclt,
    codstjclt,
    codtymclt,
    naeclt,
    napclt,
    rgmclt,
    rsdclt,
    nefclt,
    nslclt,
    incclt,
    tvaclt,
    lttclt,
    lgtclt,

    current_timestamp               as _load_timestamp

from src