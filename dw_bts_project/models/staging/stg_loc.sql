{{ config(materialized='table') }}

with source as (

    select *
    from {{ source('ods', 'LOC') }}

),

cleaned as (

    select
        {{ clean_int('"SULOC"') }} as suloc,
        {{ parse_mixed_date('"DMJLOC"') }} as dmjloc,
        {{ clean_bigint('"TIMLOC"') }} as timloc,
        {{ clean_int('"EMPLOC"') }} as emploc,
        {{ clean_legacy_text('"COPLOC"', 4) }} as coploc,

        {{ clean_int('"CODGOVLOC"') }} as codgovloc,
        {{ clean_int('"CODDLGLOC"') }} as coddlgloc,
        {{ clean_int('"CODLOC"') }} as codloc,
        {{ clean_int('"CODPTTLOC"') }} as codpttloc,

        {{ clean_legacy_text('"LIBLOC"', 40) }} as libloc,
        {{ clean_legacy_text('"ALIBLOC"', 40) }} as alibloc,
        upper({{ clean_legacy_text('"ZBRLOC"', 1) }}) as zbrloc,

        current_timestamp as _load_timestamp

    from source

)

select *
from cleaned