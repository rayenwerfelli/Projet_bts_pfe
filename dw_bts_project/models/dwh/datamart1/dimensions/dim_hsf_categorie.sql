{{ config(materialized='table') }}

with mapping as (

    select 1 as codhrfhsf, 'equipement' as hsf_categorie, 'Equipement' as libelle_categorie, 'nature_depense' as axe_categorie union all
    select 2, 'cession_projet', 'Cession projet', 'nature_depense' union all
    select 3, 'amenagement', 'Aménagement', 'nature_depense' union all
    select 4, 'amenagement', 'Aménagement', 'nature_depense' union all
    select 5, 'materiel_transport', 'Matériel transport', 'nature_depense' union all
    select 6, 'materiel_transport', 'Matériel transport', 'nature_depense' union all
    select 7, 'cheptel', 'Cheptel', 'nature_depense' union all
    select 8, 'cheptel', 'Cheptel', 'nature_depense' union all
    select 9, 'fdr', 'Fonds de roulement', 'nature_depense' union all
    select 10, 'fdr', 'Fonds de roulement', 'nature_depense' union all
    select 11, 'assurance', 'Assurance', 'nature_depense' union all
    select 12, 'assurance', 'Assurance', 'nature_depense' union all
    select 15, 'frais_approche_divers', 'Frais d approche et divers', 'nature_depense' union all
    select 20, 'materiel_transport', 'Matériel transport', 'nature_depense' union all
    select 50, 'autofinancement', 'Autofinancement', 'mode_financement' union all
    select 53, 'credit', 'Crédit', 'mode_financement' union all
    select 54, 'dotation', 'Dotation', 'mode_financement' union all
    select 56, 'terrain', 'Terrain', 'nature_depense' union all
    select 60, 'mourabaha', 'Mourabaha', 'mode_financement' union all
    select 62, 'dotation_femme', 'Dotation Femme', 'mode_financement' union all
    select 65, 'pret_femme', 'Prêt Femme', 'mode_financement' union all
    select 69, 'cct', 'CCT', 'nature_depense' union all
    select 71, 'don_tunjobs', 'DON TunJobs', 'nature_depense' union all
    select 80, 'autofinancement', 'Autofinancement', 'mode_financement' union all
    select 81, 'credit', 'Crédit', 'mode_financement'

)

select
    md5(cast(codhrfhsf as text)) as hsf_categorie_key,
    codhrfhsf,
    hsf_categorie,
    libelle_categorie,
    axe_categorie,
    current_timestamp as _load_timestamp
from mapping