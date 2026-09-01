{% macro clean_text(col) %}
    case
        when {{ col }} is null then null

        -- vide
        when btrim(cast({{ col }} as text)) = '' then null

        -- valeurs "fake"
        when upper(btrim(cast({{ col }} as text))) in
            ('N/A','NA','VIDE','NONE','NULL','[NULL]','NAN') then null

        -- caractères corrompus
        when btrim(cast({{ col }} as text)) ~ '^[¿\*\?XMY ]+$' then null

        -- contient beaucoup de caractères bizarres
        when btrim(cast({{ col }} as text)) like '%¿%' then null

        -- nettoyage espaces
        else regexp_replace(
                btrim(cast({{ col }} as text)),
                '\s+',
                ' ',
                'g'
             )
    end
{% endmacro %}