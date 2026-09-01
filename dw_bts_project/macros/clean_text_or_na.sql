{% macro clean_text_or_na(col) %}
    coalesce({{ clean_text(col) }}, 'N/A')
{% endmacro %}