{{ config(
    materialized = 'table',
    tags         = ['dimension', 'dap']
) }}

with src as (
    select *
    from {{ ref('stg_dap') }}
    where sudap = '0'
)

select

    -- ============================================================
    -- SURROGATE KEY
    -- ============================================================
    md5(cast(orddap as text))                       as dap_key,

    -- ============================================================
    -- CLÉS MÉTIER
    -- ============================================================
    orddap                                          as ord_dap,
    refautdap                                       as ref_autorisation,
    ordcptdap                                       as ord_compte,
    codenadap                                       as cod_ena,

    -- ============================================================
    -- CONDITIONS FINANCIÈRES
    -- ============================================================
    mntdap                                          as mnt_dap,
    taudap                                          as taux_dap,
    durdap                                          as duree_dap,
    pdpdap                                          as periodicite_dap,
    rmbdap                                          as remboursement_dap,
    frzdap                                          as frz_dap,
    totdap                                          as total_dap,

    -- Tranches
    mnttr1dap                                       as mnt_tranche_1,
    mntr2dap                                        as mnt_tranche_2,
    mntr3dap                                        as mnt_tranche_3,
    mntr4dap                                        as mnt_tranche_4,
    mntr5dap                                        as mnt_tranche_5,

    -- ============================================================
    -- ÉTAT & INDICATEURS
    -- ============================================================
    mdfdap                                          as mode_financement,
    poldap                                          as ind_pool,
    iisdap                                          as ind_islamique,
    bqfdap                                          as bqf_dap,

    -- ============================================================
    -- CODES DIVERS
    -- ============================================================
    copdap                                          as cop_dap,
    natcptdap                                       as nat_compte_dap,
    klecptdap                                       as cle_compte_dap,
    natcpfdap                                       as nat_cpf_dap,
    ordcpfdap                                       as ord_cpf_dap,
    klecpfdap                                       as cle_cpf_dap,
    codengdap                                       as cod_engagement,
    codtaddap                                       as cod_tad,
    empdap                                          as emp_dap,
    timdap                                          as tim_dap,

    -- ============================================================
    -- DATES
    -- ============================================================
    dmjdap                                          as date_maj,
    dbkdap                                          as date_blocage,

    -- ============================================================
    -- AUDIT
    -- ============================================================
    current_timestamp                               as dbt_loaded_at

from src