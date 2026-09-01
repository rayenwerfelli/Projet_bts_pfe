{{ config(materialized='table') }}

with recouv as (

    select *
    from {{ ref('int_recap_recouv_par_clt') }}

),

client as (

    select *
    from {{ ref('dim_client') }}

)

select

    -- ✅ Surrogate keys
    client.client_key,

    -- ✅ Clé naturelle
    recouv.codclt,

    -- ✅ Mesures brutes Principal
    recouv.mntechupayprinc,
    recouv.mntechupayint,
    recouv.mntechupay,

    -- ✅ Mesures brutes Impayés
    recouv.mntechuimpayprinc,
    recouv.mntechuimpayint,
    recouv.mntechuimpay,

    -- ✅ Mesures brutes En attente
    recouv.mntechuenattreglprinc,
    recouv.mntechuenattreglint,
    recouv.mntechuenattregl,

    -- ✅ Mesures brutes Annulés
    recouv.mntannulprinc,
    recouv.mntannulint,
    recouv.mntannul,

    -- ✅ Mesures brutes A échoir
    recouv.mntaechoirprinc,
    recouv.mntaechoirint,
    recouv.mntaechoir,

    -- ✅ Dates
    recouv.datpremregl,
    recouv.datderregl,
    recouv.datpremech,
    recouv.datderech,
    recouv.premechimp,

    -- ✅ Compteurs
    recouv.nbrechimpprinc,
    recouv.nbrechimpint,

    current_timestamp  as _load_timestamp

from recouv

left join client
    on recouv.codclt = client.codclt