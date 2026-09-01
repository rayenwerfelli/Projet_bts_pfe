{% macro clean_legacy_text(col, max_len=None) %}
    {% if max_len is not none %}
        left({{ clean_text(col) }}, {{ max_len }})
    {% else %}
        {{ clean_text(col) }}
    {% endif %}
{% endmacro %}