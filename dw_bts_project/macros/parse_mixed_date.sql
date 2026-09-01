{% macro parse_mixed_date(col) %}
case
    when {{ col }} is null then null
    when btrim(cast({{ col }} as text)) in ('', '0', '00000000', '99999999', 'NULL', '[NULL]', 'NAN') then null

    when btrim(cast({{ col }} as text)) ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?$'
        then cast(cast(btrim(cast({{ col }} as text)) as timestamp) as date)

    when btrim(cast({{ col }} as text)) ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        then cast(btrim(cast({{ col }} as text)) as date)

    when btrim(cast({{ col }} as text)) ~ '^[0-9]{8}(\.0+)?$'
        then to_date(split_part(btrim(cast({{ col }} as text)), '.', 1), 'YYYYMMDD')

    when btrim(cast({{ col }} as text)) ~ '^[0-9]{1,5}(\.0+)?$'
         and cast(split_part(btrim(cast({{ col }} as text)), '.', 1) as integer) between 1 and 60000
        then date '1899-12-30' + cast(split_part(btrim(cast({{ col }} as text)), '.', 1) as integer)

    else null
end
{% endmacro %}