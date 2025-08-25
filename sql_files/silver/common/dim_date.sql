!set variable_substitution=true;

-- Target context = SILVER/COMMON for the current ENV (DEV/QA/PROD)
USE DATABASE &{ENV}_SILVER;
USE SCHEMA COMMON;


-- CREATE TABLE (REPLACE IF EXISTS)
CREATE OR REPLACE TABLE DIM_DATE (
  DATE_ID            NUMBER        PRIMARY KEY COMMENT 'YYYYMMDD SURROGATE KEY',
  FULL_DATE          DATE          COMMENT 'It stores full Calender date',
  DAY_OF_WEEK_ISO    NUMBER        COMMENT '1=MON ... 7=SUN (ISO)',
  DAY_NAME           STRING        COMMENT 'it stores the name of the day',
  WEEK_OF_YEAR_ISO   NUMBER        COMMENT 'ISO WEEK NUMBER (1-53)',
  MONTH_NUM          NUMBER        COMMENT 'It stores month number (1-12)',
  MONTH_NAME         STRING        COMMENT 'It stores month name',
  QUARTER_NUM        NUMBER        COMMENT 'It stores Quarter number (1-4)',
  YEAR_NUM           NUMBER        COMMENT 'it stores Calender year',
  IS_WEEKEND         BOOLEAN       COMMENT 'TRUE if SAT/SUN',
  IS_MONTH_START     BOOLEAN       COMMENT 'TRUE if First day of month',
  IS_MONTH_END       BOOLEAN       COMMENT 'TRUE if last day of month',
  IS_QUARTER_START   BOOLEAN       COMMENT 'TRUE if first day of quarter',
  IS_QUARTER_END     BOOLEAN       COMMENT 'TRUE if last day of quarter',
  IS_YEAR_START      BOOLEAN       COMMENT 'TRUE if JAN 1',
  IS_YEAR_END        BOOLEAN       COMMENT 'TRUE if DEC 31'
)
COMMENT = 'It is a calender loopup table. It stores one row per calender date';

-- CHOOSE RANGE (EDIT THESE TWO LINES IF NEEDED)
SET START_DATE = TO_DATE('2015-01-01');
SET END_DATE   = TO_DATE('2035-12-31');

-- POPULATE THE CALENDAR
INSERT INTO DIM_DATE
WITH SEQ AS (
  SELECT DATEADD(DAY, SEQ4(), $START_DATE) AS D
  FROM TABLE(GENERATOR(ROWCOUNT => 50000))          -- SUFFICIENT SPAN; FILTERED BELOW
)
SELECT
  TO_NUMBER(TO_CHAR(D, 'YYYYMMDD'))                          AS DATE_ID,
  D                                                          AS FULL_DATE,
  DAYOFWEEKISO(D)                                            AS DAY_OF_WEEK_ISO,     -- 1..7
  TO_CHAR(D, 'DY')                                           AS DAY_NAME,
  DATE_PART('WEEKISO', D)                                    AS WEEK_OF_YEAR_ISO,
  MONTH(D)                                                   AS MONTH_NUM,
  TO_CHAR(D, 'MON')                                          AS MONTH_NAME,
  QUARTER(D)                                                 AS QUARTER_NUM,
  YEAR(D)                                                    AS YEAR_NUM,
  CASE WHEN DAYOFWEEKISO(D) IN (6,7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
  CASE WHEN DATE_TRUNC('MONTH', D) = D THEN TRUE ELSE FALSE END    AS IS_MONTH_START,
  CASE WHEN LAST_DAY(D) = D THEN TRUE ELSE FALSE END              AS IS_MONTH_END,
  CASE WHEN DATE_TRUNC('QUARTER', D) = D THEN TRUE ELSE FALSE END AS IS_QUARTER_START,
  CASE WHEN DATE_TRUNC('QUARTER', DATEADD(DAY, 1, D)) > DATE_TRUNC('QUARTER', D)
       THEN TRUE ELSE FALSE END                                   AS IS_QUARTER_END,
  CASE WHEN DATE_TRUNC('YEAR', D) = D THEN TRUE ELSE FALSE END    AS IS_YEAR_START,
  CASE WHEN DATE_TRUNC('YEAR', DATEADD(DAY, 1, D)) > DATE_TRUNC('YEAR', D)
       THEN TRUE ELSE FALSE END                                   AS IS_YEAR_END
FROM SEQ
WHERE D BETWEEN $START_DATE AND $END_DATE;
