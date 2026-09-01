{{ config(materialized='table') }}

with prj as (

    select *
    from {{ ref('hist_prj') }}
    where is_current = true
      and suprj = 0

),

zac as (

    select *
    from {{ ref('hist_zac') }}
    where is_current = true

),

gov as (

    select *
    from {{ ref('hist_gov') }}
    where is_current = true

),

dlg as (

    select *
    from {{ ref('hist_dlg') }}
    where is_current = true

),

loc as (

    select *
    from {{ ref('hist_loc') }}
    where is_current = true

),

cltprj as (

    select
        codcltprj,
        max(codprj) as codprjn,
        count(*) as nbrprj
    from prj
    group by codcltprj

)

select
    cltprj.codcltprj,
    cltprj.nbrprj,
    prj.codprj,
    prj.codzacprj,
    prj.codgovprj,
    prj.coddlgprj,
    prj.codlocprj,
    zac.libzac,
    zac.seczac,
    gov.libgov,
    dlg.libdlg,
    loc.libloc
from cltprj
left join prj
    on prj.codcltprj = cltprj.codcltprj
   and prj.codprj = cltprj.codprjn
left join zac
    on prj.codzacprj = zac.codzac
left join gov
    on prj.codgovprj = gov.codgov
left join dlg
    on prj.codgovprj = dlg.codgovdlg
   and prj.coddlgprj = dlg.coddlg
left join loc
    on prj.codgovprj = loc.codgovloc
   and prj.coddlgprj = loc.coddlgloc
   and prj.codlocprj = loc.codloc