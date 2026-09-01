{{ config(materialized='table') }}

with dates_dmg as (

    select distinct datdmg   as date_jour from {{ ref('hist_dmg') }} where datdmg  is not null
    union
    select distinct daddmg               from {{ ref('hist_dmg') }} where daddmg  is not null
    union
    select distinct dtrfdmg              from {{ ref('hist_dmg') }} where dtrfdmg is not null
    union
    select distinct drpdmg               from {{ ref('hist_dmg') }} where drpdmg  is not null
    union
    select distinct dncdmg               from {{ ref('hist_dmg') }} where dncdmg  is not null
    union
    select distinct denrdmg              from {{ ref('hist_dmg') }} where denrdmg is not null
    union
    select distinct davidmg              from {{ ref('hist_dmg') }} where davidmg is not null
    union
    select distinct dadcdmg              from {{ ref('hist_dmg') }} where dadcdmg is not null
    union
    select distinct dautdmg              from {{ ref('hist_dmg') }} where dautdmg is not null
    union
    select distinct drcpdmg              from {{ ref('hist_dmg') }} where drcpdmg is not null

),

-- Plage complète pour couvrir EFF/IMP/LFN sans dépendre de leurs noms
dates_serie as (
    select generate_series(
        '2000-01-01'::date,
        '2040-12-31'::date,
        '1 day'::interval
    )::date as date_jour
),

-- Union des deux sources
all_dates as (
    select date_jour from dates_dmg
    union
    select date_jour from dates_serie
)

select
    to_char(date_jour, 'YYYYMMDD')::int              as date_key,
    date_jour,

    extract(year    from date_jour)::int             as annee,
    extract(month   from date_jour)::int             as mois,
    trim(to_char(date_jour, 'Month'))                as lib_mois,
    to_char(date_jour, 'Mon')                        as lib_mois_court,
    extract(quarter from date_jour)::int             as trimestre,
    concat('T', extract(quarter from date_jour)::int) as lib_trimestre,
    case
        when extract(month from date_jour) <= 6 then 1
        else 2
    end                                              as semestre,
    extract(day     from date_jour)::int             as jour,
    extract(isodow  from date_jour)::int             as jour_semaine,
    trim(to_char(date_jour, 'Day'))                  as lib_jour,
    extract(week    from date_jour)::int             as numero_semaine,
    case
        when extract(isodow from date_jour) in (6,7) then true
        else false
    end                                              as is_weekend,
    to_char(date_jour, 'YYYY-MM')                   as annee_mois,
    concat(extract(year from date_jour)::int,
           '-T',
           extract(quarter from date_jour)::int)     as annee_trimestre,
    date_trunc('month', date_jour)::date             as debut_mois,
    (date_trunc('month', date_jour)
        + interval '1 month - 1 day')::date         as fin_mois,
    date_trunc('year',  date_jour)::date             as debut_annee,
    (date_trunc('year',  date_jour)
        + interval '1 year - 1 day')::date          as fin_annee,
    case
        when extract(month from date_jour) in (1,2,3) then 'Q1'
        when extract(month from date_jour) in (4,5,6) then 'Q2'
        when extract(month from date_jour) in (7,8,9) then 'Q3'
        else                                               'Q4'
    end                                              as quarter_label,
    (current_date - date_jour)::int                  as nb_jours_depuis,
    case
        when (current_date - date_jour) <= 30  then '0-30j'
        when (current_date - date_jour) <= 60  then '31-60j'
        when (current_date - date_jour) <= 90  then '61-90j'
        when (current_date - date_jour) <= 180 then '91-180j'
        when (current_date - date_jour) <= 365 then '181-365j'
        else                                        '+365j'
    end                                              as tranche_anciennete,

    current_timestamp                                as _load_timestamp

from all_dates
where date_jour is not null