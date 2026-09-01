{{ config(materialized='table') }}

with dmg as (

    select *
    from {{ ref('hist_dmg') }}
    where valid_to = date '9999-12-31'
      and sudmg = 0

),

dmy as (

    select *
    from {{ ref('hist_dmy') }}
    where valid_to = date '9999-12-31'

),

dmx as (

    select *
    from {{ ref('hist_dmx') }}
    where valid_to = date '9999-12-31'

),

clt as (

    select *
    from (
        select
            c.*,
            row_number() over (
                partition by c.codclt
                order by
                    case when c.valid_to = date '9999-12-31' then 0 else 1 end,
                    c.valid_to desc,
                    c.valid_from desc
            ) as rn
        from {{ ref('hist_clt') }} c
    ) x
    where rn = 1

),

unt as (

    select *
    from {{ ref('hist_unt') }}
    where valid_to = date '9999-12-31'

),

hmf as (

    select *
    from {{ ref('hist_hmf') }}
    where valid_to = date '9999-12-31'

),

nis as (

    select *
    from {{ ref('hist_nis') }}
    where valid_to = date '9999-12-31'

),

emp as (

    select *
    from {{ ref('hist_emp') }}
    where valid_to = date '9999-12-31'

),

eng as (

    select *
    from {{ ref('hist_eng') }}
    where valid_to = date '9999-12-31'

),

hsf as (

    select *
    from {{ ref('hist_hsf') }}
    where valid_to = date '9999-12-31'
      and suhsf = 0

),

dmc as (

    select *
    from {{ ref('hist_dmc') }}
    where valid_to = date '9999-12-31'
      and sudmc = 0

),

hsf_agg as (

    select
        numdmghsf as numdmg,
        coalesce(sum(case when codhrfhsf in (1, 2) then mnphsf else 0 end), 0) as mntpropequip,
        coalesce(sum(case when codhrfhsf in (3, 4) then mnphsf else 0 end), 0) as mntpropamnag,
        coalesce(sum(case when codhrfhsf in (5, 6) then mnphsf else 0 end), 0) as mntpropmatertransp,
        coalesce(sum(case when codhrfhsf in (7, 8) then mnphsf else 0 end), 0) as mntpropchept,
        coalesce(sum(case when codhrfhsf in (9, 10) then mnphsf else 0 end), 0) as mntpropfdr,
        coalesce(sum(case when codhrfhsf in (11, 12) then mnphsf else 0 end), 0) as mntpropass,
        coalesce(sum(case when codhrfhsf = 69 then mnphsf else 0 end), 0) as mntpropcct,
        coalesce(sum(case when codhrfhsf = 71 then mnphsf else 0 end), 0) as mntpropdon_tunjobs
    from hsf
    group by numdmghsf

),

dmc_agg as (

    select
        numdmgdmc as numdmg,
        count(*) as nbrcrdpropaccor,
        min(codenadmc) as codenadmc1,
        max(codenadmc) as codenadmc2
    from dmc
    group by numdmgdmc

)

select
    dmg.numdmg as id_demande,

    unt.codunt,
    unt.libunt,
    unt.alibunt,

    dmg.numdmg,
    dmg.datdmg,
    dmg.etadmg,

    case dmg.etadmg
        when 0 then 'Enregistré'
        when 1 then 'En Etude'
        when 2 then 'Transfert pour decision'
        when 3 then 'Accord'
        when 4 then 'Rejet'
        when 5 then 'Réexaminer'
        when 6 then 'DecisionPrise'
        when 7 then 'ClientNotifie'
        when 8 then 'TraitementTermine'
        when 9 then 'Annule'
    end as libetat,

    dmg.dsddmg,
    case dmg.dsddmg
        when 1 then 'Acceptée'
        when 2 then 'Acceptée sous Réserve'
        when 3 then 'Ajournée'
        when 4 then 'Rejetée'
    end as libdecision,

    dmg.idcadmg,
    case dmg.idcadmg
        when 1 then 'Acceptée'
        when 2 then 'Rejetée'
    end as libdecisionag,

    dmg.dcddmg as matdecideur,
    concat_ws(' ', emp.prnemp, emp.nomemp) as nomdecideur,

    dmg.daddmg,
    dmg.cd1dmg,
    dmg.dtrfdmg,

    dmg.coddmydmg,
    dmy.libdmy as libtypdde,

    dmg.coddmxdmg,
    dmx.libdmx as liborigindde,

    clt.codclt,
    clt.nomclt,
    clt.prnclt,
    clt.anomclt,
    clt.aprnclt,
    clt.crpclt,
    clt.ndcclt,
    clt.codnisclt,
    dmg.tepdmg,
    clt.dnaclt,
    dmg.numautdmg,

    dmg.codhmfdmg as codmodelesf,
    hmf.libhmf as libmodelesf,

    case
        when clt.sexclt = 'M' then 'Masculin'
        when clt.sexclt = 'F' then 'Féminin'
        else null
    end as sex,

    nis.libnis as niveau,

    hsf_agg.mntpropequip,
    hsf_agg.mntpropamnag,
    hsf_agg.mntpropmatertransp,
    hsf_agg.mntpropchept,
    hsf_agg.mntpropfdr,
    hsf_agg.mntpropass,
    hsf_agg.mntpropcct,
    hsf_agg.mntpropdon_tunjobs,

    dmg.drpdmg,
    dmg.dncdmg,
    dmg.denrdmg,
    dmg.davidmg,
    dmg.dadcdmg,
    dmg.dautdmg,
    dmg.drcpdmg,

    dmc_agg.nbrcrdpropaccor,
    dmc_agg.codenadmc1,
    dmc_agg.codenadmc2,

    eng.libeng as libeng1,
    eng1.libeng as libeng2,

    clt.mfsclt,
    clt.tidnclt,
    case clt.tidnclt
        when 1 then 'Identifiant National'
        when 2 then 'CIN'
        when 3 then 'Passeport'
        when 4 then 'CS'
        when 5 then 'Visa'
        when 6 then 'Code Ministère'
        when 7 then 'Identifiant BCT'
        when 8 then 'Code Localité'
        when 9 then 'RC'
        when 13 then 'Identifiant Fiscal Unique'
    end as lib_tidnclt,
    clt.idnclt,

    current_timestamp as dwh_load_ts

from dmg
left join dmy
    on dmg.coddmydmg = dmy.coddmy
left join dmx
    on dmg.coddmxdmg = dmx.coddmx
left join clt
    on dmg.codcltdmg = clt.codclt
left join unt
    on dmg.untidmg = unt.codunt
left join hmf
    on dmg.codhmfdmg = hmf.codhmf
left join nis
    on clt.codnisclt = nis.codnis
left join emp
    on dmg.dcddmg = emp.matemp
left join hsf_agg
    on hsf_agg.numdmg = dmg.numdmg
left join dmc_agg
    on dmc_agg.numdmg = dmg.numdmg
left join eng
    on dmc_agg.codenadmc1 = eng.codeng
left join eng eng1
    on dmc_agg.codenadmc2 = eng1.codeng