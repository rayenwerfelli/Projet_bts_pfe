{{ config(materialized='table') }}

with dmp as (
    select *
    from {{ ref('hist_dmp') }}
    where is_current = true
      and sudmp = 0
),

prj as (
    select *
    from {{ ref('hist_prj') }}
    where is_current = true
      and suprj = 0
),

zac as (
    select * from {{ ref('hist_zac') }}
    where is_current = true
),

gov as (
    select * from {{ ref('hist_gov') }}
    where is_current = true
),

dlg as (
    select * from {{ ref('hist_dlg') }}
    where is_current = true
),

loc as (
    select * from {{ ref('hist_loc') }}
    where is_current = true
),

dmgprj as (
    select
        numdmgdmp,
        codprjdmp                                            as codprjn,
        count(*) over (partition by numdmgdmp)              as nbrprj,
        row_number() over (
            partition by numdmgdmp
            order by codprjdmp desc
        )                                                    as rn
    from dmp
),

-- ✅ On filtre ici : un seul projet principal par demande
dmgprj_principal as (
    select *
    from dmgprj
    where rn = 1
)

select
    dmgprj_principal.numdmgdmp,
    dmgprj_principal.nbrprj,

    dmp.natdmp,
    dmp.nepdmp,

    prj.codprj,
    prj.codzacprj,
    prj.codgovprj,
    prj.coddlgprj,
    prj.codlocprj,
    prj.codpttprj                                            as codptt,

    zac.libzac,
    zac.seczac,
    gov.libgov,
    dlg.libdlg,
    loc.libloc

from dmgprj_principal

left join dmp
    on  dmgprj_principal.numdmgdmp = dmp.numdmgdmp
    and dmgprj_principal.codprjn   = dmp.codprjdmp

left join prj
    on prj.codprj = dmgprj_principal.codprjn

left join zac
    on prj.codzacprj = zac.codzac

left join gov
    on prj.codgovprj = gov.codgov

left join dlg
    on  prj.codgovprj = dlg.codgovdlg
    and prj.coddlgprj = dlg.coddlg

left join loc
    on  prj.codgovprj  = loc.codgovloc
    and prj.coddlgprj  = loc.coddlgloc
    and prj.codlocprj  = loc.codloc