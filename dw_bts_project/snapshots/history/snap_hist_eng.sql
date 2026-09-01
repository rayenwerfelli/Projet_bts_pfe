{% snapshot snap_hist_eng %}

{{
    config(
        unique_key='codeng',
        strategy='check',
        check_cols='all',
        hard_deletes='invalidate',
        dbt_valid_to_current="date '9999-12-31'",
        snapshot_meta_column_names={
            "dbt_valid_from": "valid_from",
            "dbt_valid_to": "valid_to",
            "dbt_updated_at": "snapshot_updated_at",
            "dbt_scd_id": "scd_id",
            "dbt_is_deleted": "is_deleted"
        }
    )
}}

select * from {{ ref('stg_eng') }}

{% endsnapshot %}