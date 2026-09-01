{{ config(materialized='table') }}

select *,
       case
           when valid_to is null
           or valid_to = timestamp '9999-12-31 00:00:00'  
           then true
           else false
       end as is_current
from {{ ref('snap_hist_aut') }}