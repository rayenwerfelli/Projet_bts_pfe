{{ config(materialized='table') }}

with eff as (

    select *
    from {{ ref('hist_eff') }}
    where is_current = true

),

imp as (

    select *
    from {{ ref('hist_imp') }}
    where is_current = true

),

-- =========================
-- EFF
-- =========================
eff_part as (

    select
        sueff,
        codinseff,
        refeff,
        codengeff,
        ordcpxeff,
        ordcpyeff,

        ribbeff,
        ribaeff,
        ribceff,
        ribkeff,

        ppleff,
        echeff,
        drgleff,
        refauteff,
        orddapeff,
        numtrheff,

        case
            when typeff = 6 and coalesce(blceff, 0) > mnteff
                then blceff - mnteff
            else coalesce(blceff, 0)
        end as mnteff,

        coalesce(blceff, 0) as blceff,

        null::numeric as mttceff,
        null::numeric as minteff,
        null::numeric as mtvaeff,
        null::numeric as mtmbeff,

        case
            when typeff = 6 and coalesce(blceff, 0) > mnteff
                then 9
            else typeff
        end as typeff,

        coalesce(crpeff, 0) as crpeff,
        coalesce(ctxeff, 0) as ctxeff

    from eff

    where typeff != 6
       or (typeff = 6 and coalesce(blceff, 0) > mnteff)

),  -- ← virgule ici obligatoire

-- =========================
-- IMP normal
-- =========================
imp_part1 as (

    select
        suimp as sueff,
        codinsimp as codinseff,
        refimp as refeff,
        codengimp as codengeff,
        ordcpximp as ordcpxeff,
        ordcpyimp as ordcpyeff,

        ribbimp as ribbeff,
        ribaimp as ribaeff,
        ribcimp as ribceff,
        ribkimp as ribkeff,

        etaimp as ppleff,
        echimp as echeff,
        drglimp as drgleff,
        refautimp as refauteff,
        orddapimp as orddapeff,
        numtrhimp as numtrheff,

        case
            when typimp in (1, 2) then mntimp
            else blcimp
        end as mnteff,

        blcimp as blceff,

        null::numeric as mttceff,
        null::numeric as minteff,
        null::numeric as mtvaeff,
        null::numeric as mtmbeff,

        case
            when typimp in (1, 2) then 6
            else typimp
        end as typeff,

        coalesce(crpimp, 0) as crpeff,
        coalesce(ctximp, 0) as ctxeff

    from imp

),  -- ← virgule ici obligatoire

-- =========================
-- IMP partiel
-- =========================
imp_part2 as (

    select
        suimp as sueff,
        codinsimp as codinseff,
        refimp as refeff,
        codengimp as codengeff,
        ordcpximp as ordcpxeff,
        ordcpyimp as ordcpyeff,

        ribbimp as ribbeff,
        ribaimp as ribaeff,
        ribcimp as ribceff,
        ribkimp as ribkeff,

        etaimp as ppleff,
        echimp as echeff,
        drglimp as drgleff,
        refautimp as refauteff,
        orddapimp as orddapeff,
        numtrhimp as numtrheff,

        (blcimp - mntimp) as mnteff,
        blcimp as blceff,

        null::numeric as mttceff,
        null::numeric as minteff,
        null::numeric as mtvaeff,
        null::numeric as mtmbeff,

        9 as typeff,

        coalesce(crpimp, 0) as crpeff,
        coalesce(ctximp, 0) as ctxeff

    from imp
    where typimp in (1, 2)
      and coalesce(blcimp, 0) > mntimp

)  -- ← pas de virgule sur le dernier CTE

select * from eff_part
union all
select * from imp_part1
union all
select * from imp_part2