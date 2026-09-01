{% macro format_date_fr(col) %}
    case
        when {{ col }} is null then null
        else to_char({{ col }}, 'DD/MM/YYYY')
    end
{% endmacro %}