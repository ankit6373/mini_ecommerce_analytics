!set variable_substitution=true;

-- Target context = SILVER/STAGING for the current ENV (DEV/QA/PROD)
USE DATABASE &{ENV}_SILVER;
USE SCHEMA STAGING;

CREATE OR REPLACE TABLE ORDERS AS
SELECT
  ORDER_ID::NUMBER AS ORDER_ID,
  USER_ID::NUMBER AS CUSTOMER_ID,
  STATUS::VARCHAR AS STATUS,
  GENDER::VARCHAR AS GENDER,
  CREATED_AT::TIMESTAMP_NTZ AS CREATED_AT,
  SHIPPED_AT::TIMESTAMP_NTZ AS SHIPPED_AT,
  DELIVERED_AT::TIMESTAMP_NTZ AS DELIVERED_AT,
  RETURNED_AT::TIMESTAMP_NTZ AS RETURNED_AT,
  NUM_OF_ITEM::NUMBER(18,0) AS NUM_OF_ITEM
FROM &{ENV}_BRONZE.RAW.ORDERS;


-- Add the primary key constraint
ALTER TABLE ORDERS ADD CONSTRAINT PK_ORDERS PRIMARY KEY(ORDER_ID);

-- Add a desription for the entire table
ALTER TABLE INVENTORY_ITEMS SET COMMENT = 'This table stores information about the orders including their status and customer details';

-- Add comments to each column
ALTER TABLE ORDERS MODIFY COLUMN ORDER_ID COMMENT 'It stores unique order ID';
ALTER TABLE ORDERS MODIFY COLUMN CUSTOMER_ID COMMENT 'It stores unique customer ID';
ALTER TABLE ORDERS MODIFY COLUMN STATUS COMMENT 'It stores the status of the order';
ALTER TABLE ORDERS MODIFY COLUMN GENDER COMMENT 'It stores the gender of the customer';
ALTER TABLE ORDERS MODIFY COLUMN CREATED_AT COMMENT 'It stores the date and time when the order was created';
ALTER TABLE ORDERS MODIFY COLUMN SHIPPED_AT COMMENT 'It stores the date and time when the order was shipped';
ALTER TABLE ORDERS MODIFY COLUMN DELIVERED_AT COMMENT 'It stores the date and time when the order was delivered';
ALTER TABLE ORDERS MODIFY COLUMN RETURNED_AT COMMENT 'It stores the date and time when the order was returned';
ALTER TABLE ORDERS MODIFY COLUMN NUM_OF_ITEM COMMENT 'It stores the number of items in the order';


