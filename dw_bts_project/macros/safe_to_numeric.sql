{% macro safe_numeric(col) %}
    case
        when trim({{ col }}::text) ~ '^-?[0-9]+(\.[0-9]+)?$'
        then trim({{ col }}::text)::double precision
        else null
    end
{% endmacro %}