{% macro parse_legacy_date(col) %}
case
    when trim(cast({{ col }} as text)) in ('', '0', '00000000', '99999999', 'NULL', '[NULL]', 'NAN') then null
    when trim(cast({{ col }} as text)) ~ '^\d{8}(\.0+)?$'
        then to_date(split_part(trim(cast({{ col }} as text)), '.', 1), 'YYYYMMDD')
    when trim(cast({{ col }} as text)) ~ '^\d{4}-\d{2}-\d{2}$'
        then cast(trim(cast({{ col }} as text)) as date)
    else null
end
{% endmacro %}