-- ============================================================
-- 01_create_dimensions.sql
-- Dimensions + Facts + Marts ClickHouse
-- Moteur : PostgreSQL Engine (pointage direct vers PostgreSQL)
-- Base PG  : Projet_bts  |  Schéma PG : bts_datamart1 / bts_mart
-- Base CH  : bts_datamart1
-- ============================================================

USE bts_datamart1;

-- ============================================================
-- DIMENSIONS
-- ============================================================

-- ------------------------------------------------------------
-- DIM_CLIENT
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_client;
CREATE TABLE bts_datamart1.dim_client
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_client',
    'postgres', 'intissarBI!',
    'public_datamart1'
);
DROP TABLE IF EXISTS bts_datamart1.dim_autorisation;
CREATE TABLE bts_datamart1.dim_autorisation
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_client',
    'postgres', 'intissarBI!',
    'public_datamart1'
);
DROP TABLE IF EXISTS bts_datamart1.dim_classification_activite;
CREATE TABLE bts_datamart1.dim_classification_activite
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_client',
    'postgres', 'intissarBI!',
    'public_datamart1'
);
DROP TABLE IF EXISTS bts_datamart1.dim_ptt;
CREATE TABLE bts_datamart1.dim_ptt
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_client',
    'postgres', 'intissarBI!',
    'public_datamart1'
);


-- ------------------------------------------------------------
-- DIM_DEMANDE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_demande;
CREATE TABLE bts_datamart1.dim_demande
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_demande',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_UNITE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_unite;
CREATE TABLE bts_datamart1.dim_unite
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_unite',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_EMPLOYEE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_employee;
CREATE TABLE bts_datamart1.dim_employee
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_employee',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_PROJET
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_projet;
CREATE TABLE bts_datamart1.dim_projet
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_projet',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_ZAC
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_zac;
CREATE TABLE bts_datamart1.dim_zac
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_zac',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_GOUVERNORAT
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_gouvernorat;
CREATE TABLE bts_datamart1.dim_gouvernorat
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_gouvernorat',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_DELEGATION
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_delegation;
CREATE TABLE bts_datamart1.dim_delegation
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_delegation',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_LOCALITE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_localite;
CREATE TABLE bts_datamart1.dim_localite
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_localite',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_TYPE_DEMANDE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_type_demande;
CREATE TABLE bts_datamart1.dim_type_demande
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_type_demande',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_ORIGINE_DEMANDE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_origine_demande;
CREATE TABLE bts_datamart1.dim_origine_demande
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_origine_demande',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_MODELE_SF
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_modele_sf;
CREATE TABLE bts_datamart1.dim_modele_sf
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_modele_sf',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_NIVEAU_INSTRUCTION
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_niveau_instruction;
CREATE TABLE bts_datamart1.dim_niveau_instruction
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_niveau_instruction',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_ENGAGEMENT
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_engagement;
CREATE TABLE bts_datamart1.dim_engagement
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_engagement',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_AUTORISATION
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_autorisation;
CREATE TABLE bts_datamart1.dim_autorisation
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_autorisation',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_PTT
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_ptt;
CREATE TABLE bts_datamart1.dim_ptt
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_ptt',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_CLASSIFICATION_ACTIVITE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_classification_activite;
CREATE TABLE bts_datamart1.dim_classification_activite
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_classification_activite',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_DATE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_date;
CREATE TABLE bts_datamart1.dim_date
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_date',
    'postgres', 'intissarBI!',
    'public_datamart1'
);










-- ------------------------------------------------------------
-- DIM_ADRESSE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_adresse;
CREATE TABLE bts_datamart1.dim_adresse
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_adresse',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_HSF_CATEGORIE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_hsf_categorie;
CREATE TABLE bts_datamart1.dim_hsf_categorie
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_hsf_categorie',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_LFN
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_lfn;
CREATE TABLE bts_datamart1.dim_lfn
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_lfn',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_NATURE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_nature;
CREATE TABLE bts_datamart1.dim_nature
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_nature',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_TELEPHONE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_telephone;
CREATE TABLE bts_datamart1.dim_telephone
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_telephone',
    'postgres', 'intissarBI!',
    'public_datamart1'
);

-- ------------------------------------------------------------
-- DIM_TRH
-- ------------------------------------------------------------
DROP TABLE IF EXISTS bts_datamart1.dim_trh;
CREATE TABLE bts_datamart1.dim_trh
ENGINE = PostgreSQL(
    'host.docker.internal:5432',
    'Projet_bts', 'dim_trh',
    'postgres', 'intissarBI!',
    'public_datamart1'
);
