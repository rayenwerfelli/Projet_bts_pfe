{% macro clean_bigint(col) %}
case
    when {{ col }} is null then null
    when btrim(cast({{ col }} as text)) in (
        '', 'NULL', '[NULL]', 'NAN', 'N/A', 'NA', 'VIDE'
    ) then null
    when btrim(cast({{ col }} as text)) ~ '^-?[0-9]+(\.0+)?$'
        then cast(split_part(btrim(cast({{ col }} as text)), '.', 1) as bigint)
    else null
end
{% endmacro %}