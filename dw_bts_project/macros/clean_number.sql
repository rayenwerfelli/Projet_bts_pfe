{% macro clean_number(col, precision=15, scale=3) %}
case
    when {{ col }} is null then null
    when btrim(cast({{ col }} as text)) in ('', 'NULL', '[NULL]', 'NAN', 'N/A', 'NA', 'VIDE') then null
    when btrim(cast({{ col }} as text)) ~ '^[+-]?[0-9]+([.,][0-9]+)?$'
        then cast(replace(btrim(cast({{ col }} as text)), ',', '.') as numeric({{ precision }}, {{ scale }}))
    else null
end
{% endmacro %}