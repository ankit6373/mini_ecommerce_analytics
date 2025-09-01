!set variable_substitution=true;

-- Target context = SILVER/MARKETING for the current ENV (DEV/QA/PROD)
USE DATABASE &{ENV}_SILVER;
USE SCHEMA FINANCE;

CREATE OR REPLACE TABLE FACT_REVENUE_DAILY AS
WITH SALES_D AS (
  SELECT
    ORDER_DATE_ID AS DATE_ID,
    SUM(SALES_PRICE) AS GROSS_REVENUE
  FROM &{ENV}_SILVER.SALES.FACT_ORDER_ITEMS
  GROUP BY ORDER_DATE_ID
),
RETURNS_D AS (
  SELECT
    RETURN_DATE_ID AS DATE_ID,
    SUM(REFUND_AMOUNT) AS REFUNDS
  FROM &{ENV}_SILVER.SALES.FACT_RETURNS
  GROUP BY RETURN_DATE_ID
)
SELECT
  COALESCE(S.DATE_ID, R.DATE_ID)                                AS DATE_ID,
  COALESCE(S.GROSS_REVENUE, 0)                                  AS GROSS_REVENUE,
  COALESCE(R.REFUNDS, 0)                                        AS REFUNDS,
  COALESCE(S.GROSS_REVENUE, 0) - COALESCE(R.REFUNDS, 0)         AS NET_REVENUE
FROM SALES_D S
FULL OUTER JOIN RETURNS_D R
  ON S.DATE_ID = R.DATE_ID;

-- We used outer join here, because it is possible that we will have a day that has sales but not return
-- and day that has returned but no sales (in case customers returned old orders)
-- with outer join, if a day exists only in sales, it will still apears with returns 0 and same for returns
-- if a date exists in both then they are matched
-- this way every relevant date showes up in this table

-- COMMENTS: FACT_REVENUE_DAILY
ALTER TABLE FACT_REVENUE_DAILY SET COMMENT = 'It stores daily revenue rollup: gross sales by order date, refunds by return date, and net revenue.';

ALTER TABLE FACT_REVENUE_DAILY MODIFY COLUMN DATE_ID COMMENT 'YYYYMMDD date key for daily aggregation (join to DIM_DATE / DIM_FISCAL_CALENDAR)';
ALTER TABLE FACT_REVENUE_DAILY MODIFY COLUMN GROSS_REVENUE COMMENT 'Sum of FACT_ORDER_ITEMS.SALES_PRICE grouped by ORDER_DATE_ID';
ALTER TABLE FACT_REVENUE_DAILY MODIFY COLUMN REFUNDS COMMENT 'Sum of FACT_RETURNS.REFUND_AMOUNT grouped by RETURN_DATE_ID';
ALTER TABLE FACT_REVENUE_DAILY MODIFY COLUMN NET_REVENUE COMMENT 'GROSS_REVENUE minus REFUNDS';
