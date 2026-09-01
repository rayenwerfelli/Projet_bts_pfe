{{ config(materialized='table') }}

with hsf as (

    select *
    from {{ ref('hist_hsf') }}
    where is_current = true
      and suhsf = 0

)

select
    numdmghsf as numdmg,

    sum(case when typhsf = 1 then mnahsf else 0 end) as cout_projet_acc,

    sum(case when codhrfhsf = 1 then mnahsf else 0 end) as equifrs_acc,
    sum(case when codhrfhsf = 2 then mnahsf else 0 end) as equiclt_acc,
    sum(case when codhrfhsf = 3 then mnahsf else 0 end) as amngfrs_acc,
    sum(case when codhrfhsf = 4 then mnahsf else 0 end) as amngclt_acc,
    sum(case when codhrfhsf = 5 then mnahsf else 0 end) as mattranspfrs_acc,
    sum(case when codhrfhsf = 6 then mnahsf else 0 end) as mattranspclt_acc,
    sum(case when codhrfhsf = 7 then mnahsf else 0 end) as cheptfrs_acc,
    sum(case when codhrfhsf = 8 then mnahsf else 0 end) as cheptclt_acc,
    sum(case when codhrfhsf = 9 then mnahsf else 0 end) as fdrclt_acc,
    sum(case when codhrfhsf = 10 then mnahsf else 0 end) as approvfrs_acc,
    sum(case when codhrfhsf = 11 then mnahsf else 0 end) as assurancefrs_acc,
    sum(case when codhrfhsf = 12 then mnahsf else 0 end) as assuranceclt_acc,
    sum(case when codhrfhsf = 13 then mnahsf else 0 end) as fraisetd_acc,
    sum(case when codhrfhsf = 14 then mnahsf else 0 end) as fraisfng_acc,
    sum(case when codhrfhsf = 15 then mnahsf else 0 end) as fad_acc,
    sum(case when codhrfhsf = 20 then mnahsf else 0 end) as matroulant_acc,

    sum(case when codhrfhsf = 50 then mnahsf else 0 end) as mntacc_ap,
    sum(case when codhrfhsf = 51 then mnahsf else 0 end) as mntacc_autfrais,
    sum(case when codhrfhsf = 52 then mnahsf else 0 end) as mntacc_subv,
    sum(case when codhrfhsf = 53 then mnahsf else 0 end) as mntacc_cmt,
    sum(case when codhrfhsf = 54 then mnahsf else 0 end) as mntacc_dot,
    sum(case when codhrfhsf = 57 then mnahsf else 0 end) as mntacc_credct,
    sum(case when codhrfhsf = 58 then mnahsf else 0 end) as mntacc_dotqff,
    sum(case when codhrfhsf = 59 then mnahsf else 0 end) as mntacc_dotes,
    sum(case when codhrfhsf = 60 then mnahsf else 0 end) as mntacc_mourabmt,
    sum(case when codhrfhsf = 61 then mnahsf else 0 end) as mntacc_mourabct,
    sum(case when codhrfhsf = 62 then mnahsf else 0 end) as mntacc_dotmpjfem,
    sum(case when codhrfhsf = 63 then mnahsf else 0 end) as mntacc_pretparlfc,
    sum(case when codhrfhsf = 64 then mnahsf else 0 end) as mntacc_pretparfem,
    sum(case when codhrfhsf = 65 then mnahsf else 0 end) as mntacc_pretparfem2,
    sum(case when codhrfhsf = 66 then mnahsf else 0 end) as mntacc_pretparcpg,
    sum(case when codhrfhsf = 67 then mnahsf else 0 end) as mntacc_donpnud,
    sum(case when codhrfhsf = 68 then mnahsf else 0 end) as mntacc_pretparpnud,
    sum(case when codhrfhsf = 69 then mnahsf else 0 end) as mntacc_cct_avsubv,
    sum(case when codhrfhsf = 70 then mnahsf else 0 end) as mntacc_don_proagro,
    sum(case when codhrfhsf = 71 then mnahsf else 0 end) as mntacc_don_tun_jobs,
    sum(case when codhrfhsf = 72 then mnahsf else 0 end) as mntacc_dot_agripr3,
    sum(case when codhrfhsf = 73 then mnahsf else 0 end) as mntacc_gen_civil_frs,
    sum(case when codhrfhsf = 74 then mnahsf else 0 end) as mntacc_gen_civil_clt,
    sum(case when codhrfhsf = 75 then mnahsf else 0 end) as mntacc_plantation_frs,
    sum(case when codhrfhsf = 76 then mnahsf else 0 end) as mntacc_plantation_clt,
    sum(case when codhrfhsf = 77 then mnahsf else 0 end) as mntacc_puit_forage_frs,
    sum(case when codhrfhsf = 78 then mnahsf else 0 end) as mntacc_puit_forage_clt,
    sum(case when codhrfhsf = 79 then mnahsf else 0 end) as mntacc_subvpremloy,
    sum(case when codhrfhsf = 80 then mnahsf else 0 end) as mntacc_autofpremloy,
    sum(case when codhrfhsf = 81 then mnahsf else 0 end) as mntacc_finijara,
    sum(case when codhrfhsf = 82 then mnahsf else 0 end) as mntacc_dot_etap,
    sum(case when codhrfhsf = 83 then mnahsf else 0 end) as mntacc_pret_participatif,
    sum(case when codhrfhsf = 84 then mnahsf else 0 end) as mntacc_cred_ess_lf2022,
    sum(case when codhrfhsf = 85 then mnahsf else 0 end) as mntacc_don_giz_agricole,
    sum(case when codhrfhsf = 86 then mnahsf else 0 end) as mntacc_don_giz_non_agricole,
    sum(case when codhrfhsf = 87 then mnahsf else 0 end) as mntacc_cred_art29_lf2023,
    sum(case when codhrfhsf = 88 then mnahsf else 0 end) as mntacc_cred_af_tunithon,
    sum(case when codhrfhsf = 89 then mnahsf else 0 end) as mntacc_don_bit_prog_jeun_ess,
    sum(case when codhrfhsf = 91 then mnahsf else 0 end) as mntacc_entp_com_art32lf2024,
    sum(case when codhrfhsf = 92 then mnahsf else 0 end) as mntacc_dot_ct_avance_subv_agr,
    sum(case when codhrfhsf = 93 then mnahsf else 0 end) as mntacc_pret_honneur_cap_emploi,
    sum(case when codhrfhsf = 94 then mnahsf else 0 end) as mntacc_don_fad_we_fi

from hsf
group by numdmghsf