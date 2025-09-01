!set variable_substitution=true;

-- Target context = SILVER/COMMON for the current ENV (DEV/QA/PROD)
USE DATABASE &{ENV}_SILVER;
USE SCHEMA COMMON;

CREATE OR REPLACE TABLE DIM_PRODUCT (
  PRODUCT_ID             NUMBER        PRIMARY KEY COMMENT 'Business key from STAGING.PRODUCTS',
  NAME                   STRING        COMMENT 'It stores the product name',
  BRAND                  STRING        COMMENT 'It stores the product brand',
  CATEGORY               STRING        COMMENT 'It stores the product category',
  DEPARTMENT             STRING        COMMENT 'It stores the product department',
  SKU                    STRING        COMMENT 'It stores the product SKU',
  RETAIL_PRICE           NUMBER(18,2)  COMMENT 'It stores the standard retail price',
  COST                   NUMBER(18,2)  COMMENT 'It stores the standard unit cost',
  DISTRIBUTION_CENTER_ID NUMBER        COMMENT 'FK TO DIM_DISTRIBUTION_CENTER'
)
COMMENT = 'PRODUCT DIMENSION (ONE ROW PER PRODUCT, ATTRIBUTES FOR ANALYTICS)';

INSERT INTO DIM_PRODUCT
SELECT
  PRODUCT_ID,
  NAME,
  BRAND,
  CATEGORY,
  DEPARTMENT,
  SKU,
  RETAIL_PRICE,
  COST,
  DISTRIBUTION_CENTER_ID
FROM &{ENV}_SILVER.STAGING.PRODUCTS;