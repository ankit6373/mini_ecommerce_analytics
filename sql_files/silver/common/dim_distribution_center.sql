!set variable_substitution=true;

-- Target context = SILVER/COMMON for the current ENV (DEV/QA/PROD)
USE DATABASE &{ENV}_SILVER;
USE SCHEMA COMMON;

CREATE OR REPLACE TABLE DIM_DISTRIBUTION_CENTER (
  DC_ID          NUMBER        PRIMARY KEY COMMENT 'It stores Business key from STAGING.DISTRIBUTION_CENTERS',
  NAME           STRING        COMMENT 'It stores name of Distribution center',
  LATITUDE       FLOAT         COMMENT 'It stores latitude of Distribution center',
  LONGITUDE      FLOAT         COMMENT 'It stores longitude of Distribution center',
  GEO_ID         NUMBER        COMMENT 'FK TO DIM_GEOGRAPHY (optional linkage to geography dimension if available)'
)
COMMENT = 'It stores Distribution center dimension (LOGISTICS ENTITIES)';

-- LOAD data FROM STAGING
INSERT INTO DIM_DISTRIBUTION_CENTER
SELECT
  DC_ID,
  NAME,
  LATITUDE,
  LONGITUDE,
  NULL AS GEO_ID   -- OPTIONALLY MAP VIA DIM_GEOGRAPHY LATER
FROM &{ENV}_SILVER.STAGING.DISTRIBUTION_CENTERS;

