!set variable_substitution=true;

-- Target context = SILVER/COMMON for the current ENV (DEV/QA/PROD)
USE DATABASE &{ENV}_SILVER;
USE SCHEMA COMMON;

CREATE OR REPLACE TABLE DIM_CUSTOMER (
  CUSTOMER_ID        NUMBER        PRIMARY KEY COMMENT 'It stores business key from STAGING.CUSTOMERS',
  FIRST_NAME         STRING        COMMENT 'It stores First name of customer',
  LAST_NAME          STRING        COMMENT 'It stores Last name of customer',
  EMAIL              STRING        COMMENT 'It stores email of customer',
  AGE                NUMBER        COMMENT 'It stores age of customer in years',
  GENDER             STRING        COMMENT 'It stores gender of customer',
  STATE              STRING        COMMENT 'It stores state / region of customer',
  COUNTRY            STRING        COMMENT 'It stores country of customer',
  CITY               STRING        COMMENT 'It stores city of cusomer',
  POSTAL_CODE        STRING        COMMENT 'It stores ZIP/POSTAL CODE of customer',
  LATITUDE           FLOAT         COMMENT 'It stores GEO LATITUDE of customer',
  LONGITUDE          FLOAT         COMMENT 'It stores GEO LONGITUDE of customer',
  TRAFFIC_SOURCE     STRING        COMMENT 'It stores original acquisition source',
  CREATED_AT         TIMESTAMP_NTZ COMMENT 'It stores when customer was created in the source'
)
COMMENT = 'It stores all the customer attributes here providing a single source of truth for customer data';

INSERT INTO DIM_CUSTOMER
SELECT
  CUSTOMER_ID,
  FIRST_NAME,
  LAST_NAME,
  EMAIL,
  AGE,
  GENDER,
  STATE,
  COUNTRY,
  CITY,
  POSTAL_CODE,
  LATITUDE,
  LONGITUDE,
  TRAFFIC_SOURCE,
  CREATED_AT
FROM &{ENV}_SILVER.STAGING.CUSTOMERS;
