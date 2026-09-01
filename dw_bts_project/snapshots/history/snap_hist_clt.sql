{% snapshot snap_hist_clt %}

{{
    config(
        unique_key='codclt',
        strategy='check',
        check_cols='all',
        hard_deletes='invalidate',
        snapshot_meta_column_names={
            "dbt_valid_from": "valid_from",
            "dbt_valid_to": "valid_to",
            "dbt_updated_at": "snapshot_updated_at",
            "dbt_scd_id": "scd_id",
            
        }
    )
}}

select *
from {{ ref('stg_clt') }}

{% endsnapshot %}