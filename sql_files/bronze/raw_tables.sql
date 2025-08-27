CREATE TABLE IF NOT EXISTS DEV_BRONZE.RAW.ORDERS (
  ORDER_ID     NUMBER PRIMARY KEY COMMENT 'Primary key for Orders',
  USER_ID      NUMBER COMMENT 'Customer ID who orderd the item',
  STATUS       VARCHAR COMMENT 'It stores the status of the order',
  GENDER       VARCHAR COMMENT 'It stores the gender of the customer associated with the order', 
  CREATED_AT   TIMESTAMP_NTZ COMMENT 'It stores the timestamp when order was created',
  RETURNED_AT  TIMESTAMP_NTZ COMMENT 'It stores the timestamp when order was returned',
  SHIPPED_AT   TIMESTAMP_NTZ COMMENT 'It stores the timestamp when order was shipped',
  DELIVERED_AT TIMESTAMP_NTZ COMMENT 'It stores the timestamp when order was delivered',  
  NUM_OF_ITEM  NUMBER(18,0) COMMENT 'It stores number of items in the order'
)
COMMENT = 'It stores the order details with its status and customer ID';

CREATE TABLE IF NOT EXISTS DEV_BRONZE.RAW.ORDER_ITEMS (
  ID              NUMBER COMMENT 'It stores the unique order item ID',
  ORDER_ID        NUMBER COMMENT 'It stores the unique order ID',
  USER_ID         NUMBER COMMENT 'It stores the unique customer ID',
  PRODUCT_ID      NUMBER COMMENT 'It stores the unique product ID',
  INVENTORY_ITEM  NUMBER COMMENT 'It stores the unique inventory item ID',
  STATUS          VARCHAR COMMENT 'It stores the status of the order item',
  CREATED_AT      TIMESTAMP_NTZ COMMENT 'It stores the date and time when the order item was created',
  SHIPPED_AT      TIMESTAMP_NTZ COMMENT 'It stores the date and time when the order item was shipped',
  DELIVERED_AT    TIMESTAMP_NTZ COMMENT 'It stores the date and time when the order item was delivered',
  RETURNED_AT     TIMESTAMP_NTZ COMMENT 'It stores the date and time when the order item was returned',
  SALES_PRICE     NUMBER(18,2) COMMENT 'It stores the sales price of the order item'
) COMMENT = 'This table stores the full details of the orders with their sales price. We will be mostly using this table for further analysis related to orders';

CREATE TABLE IF NOT EXISTS DEV_BRONZE.RAW.USERS (
  ID               NUMBER COMMENT 'It stores the unique user ID',
  FIRST_NAME       VARCHAR COMMENT 'It stores the first name of the user',
  LAST_NAME        VARCHAR COMMENT 'It stores the last name of the user',
  EMAIL            VARCHAR COMMENT  'It stores the email address of the user',
  AGE              NUMBER(9,0) COMMENT  'It stores the age of the user',
  GENDER           VARCHAR  COMMENT 'It stores the gender of the user',
  STATE            VARCHAR COMMENT  'It stores the state of the user',
  STREET_ADDRESS   VARCHAR COMMENT 'It stores the street address of the user',
  POSTAL_CODE      VARCHAR COMMENT 'It stores the postal code of the user',
  CITY             VARCHAR COMMENT 'It stores the city of the user',
  COUNTRY          VARCHAR COMMENT 'It stores the country of the user',
  LATITUDE         FLOAT COMMENT 'It stores the latitude of the user',
  LONGITUDE        FLOAT COMMENT 'It stores the longitude of the user',
  TRAFFIC_SOURCE   VARCHAR COMMENT 'It stores the traffic source of the user',
  CREATED_AT       TIMESTAMP_NTZ COMMENT 'It stores the date and time when the user was created',
  USER_GEOM        VARCHAR COMMENT 'It stores the geom of the user'
) COMMENT = 'This table stores information about all the users including their age,gender,location and the date when they created account on the website/app';

CREATE TABLE IF NOT EXISTS DEV_BRONZE.RAW.EVENTS (
  ID             NUMBER COMMENT 'It stores the unique event ID',
  USER_ID        NUMBER COMMENT 'It stores the unique user ID',
  SEQUENCE       NUMBER(18,0) COMMENT 'It stores the sequence number of the event',
  SESSION_ID     VARCHAR COMMENT 'It stores the session ID of the event',
  CREATED_AT     TIMESTAMP_NTZ COMMENT 'It stores the date and time when the event was created',
  IP_ADDRESS     VARCHAR COMMENT 'It stores the IP address of the event',
  CITY           VARCHAR COMMENT 'It stores the city of the event',
  STATE          VARCHAR COMMENT 'It stores the state of the event',
  POSTAL_CODE    VARCHAR COMMENT 'It stores the postal code of the event',
  BROWSER        VARCHAR COMMENT 'It stores the browser used for the event',
  TRAFFIC_SOURCE VARCHAR COMMENT 'It stores the traffic source of the event',
  URI            VARCHAR COMMENT 'It stores the URI of the event',
  EVENT_TYPE     VARCHAR COMMENT 'It stores the type of the event'
) COMMENT = "It stores event related information. Example, which user did what in the website/app and through which traffic source and browser";

CREATE TABLE IF NOT EXISTS DEV_BRONZE.RAW.PRODUCTS (
  ID                     NUMBER COMMENT 'It stores unique product ID',
  COST                   NUMBER(18,2) COMMENT 'It stores cost of the product',
  CATEGORY               VARCHAR COMMENT 'It stores category of the product',
  NAME                   VARCHAR COMMENT 'It stores name of the product',
  BRAND                  VARCHAR COMMENT 'It stores Brand of the product',
  RETAIL_PRICE           NUMBER(18,2) COMMENT 'It stores Retail price of the product',
  DEPARTMENT             VARCHAR COMMENT 'It stores department of the product Women/Men/Kids',
  SKU                    VARCHAR COMMENT 'It stores SKU of the product',
  DISTRIBUTION_CENTER_ID NUMBER COMMENT 'It stores distribution center id of the product'
) COMMENT = 'This tables stores the product details including their cost, category,retail price';

CREATE TABLE IF NOT EXISTS DEV_BRONZE.RAW.DISTRIBUTION_CENTERS (
  ID                      NUMBER COMMENT 'It stores distribution center ID',
  NAME                    VARCHAR COMMENT 'It stores name of distribution center',
  LATTITUDE               FLOAT COMMENT 'It stores Latitude of distribution center',
  LONGITUDE               FLOAT COMMENT 'It stores Longitude of distribution center',
  DISTRIBUTION_CENTER_GEOM VARCHAR COMMENT 'It stores geom distribution center'
) COMMENT = 'It stores information about all distribution centers with their location details';

CREATE TABLE IF NOT EXISTS DEV_BRONZE.RAW.INVENTORY_ITEMS (
  ID                    NUMBER COMMENT 'It stores the unique inventory item ID',
  PRODUCT_ID            NUMBER COMMENT 'It stores the unique product ID',
  CREATED_AT            TIMESTAMP_NTZ COMMENT 'It stores the date and time when the item was created',
  SOLD_AT               TIMESTAMP_NTZ COMMENT 'It stores the date and time when the item was sold',
  COST                  NUMBER(18,2) COMMENT 'It stores the cost of the item',
  PRODUCT_CATEGORY      VARCHAR COMMENT 'It stores the category of the product',
  PRODUCT_NAME          VARCHAR COMMENT 'It stores the name of the product',
  PRODUCT_BRAND         VARCHAR COMMENT 'It stores the brand of the product',
  PRODUCT_RETAIL_PRICE  NUMBER(18,2) COMMENT 'It stores the retail price of the product',
  PRODUCT_DEPARTMENT    VARCHAR COMMENT 'It stores the department of the product',
  PRODUCT_SKU           VARCHAR COMMENT 'It stores the SKU of the product'
) COMMENT = 'It stores information about inventory items, when they were sold and their cost';