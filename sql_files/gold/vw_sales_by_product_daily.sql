!set variable_substitution=true;

-- Target context = GOLD/ANALYTICS for the current ENV (DEV/QA/PROD)
USE DATABASE &{ENV}_GOLD;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE VIEW VW_SALES_BY_PRODUCT_DAILY AS
SELECT
  OI.ORDER_DATE_ID                                             AS DATE_ID,
  D.FULL_DATE                                                  AS FULL_DATE,
  P.PRODUCT_ID                                                 AS PRODUCT_ID,
  P.NAME                                                       AS PRODUCT_NAME,
  P.BRAND                                                      AS BRAND,
  P.CATEGORY                                                   AS CATEGORY,
  P.DEPARTMENT                                                 AS DEPARTMENT,
  SUM(COALESCE(OI.QUANTITY, 1))                                AS UNITS,
  SUM(OI.SALES_PRICE)                                          AS GROSS_REVENUE,
  SUM(COALESCE(OI.UNIT_COST_AT_SALE, 0))                       AS EST_COGS,
  SUM(OI.SALES_PRICE) - SUM(COALESCE(OI.UNIT_COST_AT_SALE, 0)) AS GROSS_MARGIN,
  CASE WHEN COUNT(*) = 0 THEN NULL
       ELSE   SUM(OI.SALES_PRICE) / COUNT(*)
  END                                                          AS AVG_SELL_PRICE
FROM &{ENV}_SILVER.SALES.FACT_ORDER_ITEMS OI
JOIN &{ENV}_SILVER.COMMON.DIM_PRODUCT P
  ON P.PRODUCT_ID = OI.PRODUCT_ID
LEFT JOIN &{ENV}_SILVER.COMMON.DIM_DATE D
  ON D.DATE_ID = OI.ORDER_DATE_ID
GROUP BY
  OI.ORDER_DATE_ID, D.FULL_DATE, P.PRODUCT_ID, P.NAME, P.BRAND, P.CATEGORY, P.DEPARTMENT;


!set variable_substitution=false;

-- Added Table comment
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY SET COMMENT = 'Daily product-level sales view: units, gross revenue, estimated COGS, gross margin, and average selling price.';

-- Added Column comment
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN DATE_ID          COMMENT 'YYYYMMDD order date key';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN FULL_DATE        COMMENT 'Calendar date';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN PRODUCT_ID       COMMENT 'Product business key';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN PRODUCT_NAME     COMMENT 'Product name';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN BRAND            COMMENT 'Product brand';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN CATEGORY         COMMENT 'Product category';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN DEPARTMENT       COMMENT 'Product department';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN UNITS            COMMENT 'Total units sold (sum of QUANTITY)';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN GROSS_REVENUE    COMMENT 'Total sales amount (SALES_PRICE * QUANTITY)';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN EST_COGS         COMMENT 'Estimated cost of goods sold (UNIT_COST_AT_SALE * QUANTITY)';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN GROSS_MARGIN     COMMENT 'Gross revenue – estimated COGS';
ALTER VIEW VW_SALES_BY_PRODUCT_DAILY MODIFY COLUMN AVG_SELL_PRICE   COMMENT 'Average selling price per unit';