-- Created a database "assignment", where the datasets are been stored
use assignment;
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

-- Creating a 'User' table and loading the "User.csv" file into it
drop table user;
 CREATE TABLE User
 (
 ID VARCHAR(100),
 CREATED_DATE DATETIME,
 BIRTH_DATE DATETIME,
 STATE VARCHAR(100),
 LANGUAGE VARCHAR(100),
 GENDER VARCHAR(100)
 );
 
LOAD DATA LOCAL INFILE '/Users/ava/Downloads/cleaned_data_user.csv'
INTO TABLE assignment.user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
-- LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(ID, CREATED_DATE, BIRTH_DATE, STATE, LANGUAGE, GENDER);

-- Creating a 'transaction' table and loading the "Transaction.csv" file into it
drop table transaction; 
CREATE TABLE transaction (
    RECEIPT_ID VARCHAR(255),          -- Assuming it's an alphanumeric identifier
    PURCHASE_DATE DATETIME(6),        -- For datetime with microsecond precision
    SCAN_DATE DATETIME(6),           -- For datetime with microsecond precision
    STORE_NAME VARCHAR(255),          -- For store names (change length if needed)
    USER_ID VARCHAR(255),            -- Assuming it's an alphanumeric identifier
    BARCODE BIGINT,                  -- For large barcode numbers (change to VARCHAR if necessary)
    FINAL_QUANTITY int,            -- For floating-point quantity values
    FINAL_SALE int        -- For precise sales values (10 digits, 2 decimal places)
);

LOAD DATA LOCAL INFILE '/Users/ava/Downloads/cleaned_data_transaction.csv'
INTO TABLE assignment.transaction
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
-- LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(RECEIPT_ID, PURCHASE_DATE, SCAN_DATE, STORE_NAME, USER_ID, BARCODE, FINAL_QUANTITY, FINAL_SALE);

-- Creating a 'products' table and loading the "Products.csv" file into it
 CREATE TABLE products (
 CATEGORY_1 VARCHAR(255),
 CATEGORY_2 VARCHAR(255),
 CATEGORY_3 VARCHAR(255),
 CATEGORY_4 VARCHAR(255),
 MANUFACTURER VARCHAR(255),
 BRAND VARCHAR(255),
 BARCODE BIGINT
 );

LOAD DATA LOCAL INFILE '/Users/ava/Downloads/cleaned_data_products.csv'
INTO TABLE assignment.products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
-- LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(CATEGORY_1 , CATEGORY_2, CATEGORY_3, CATEGORY_4, MANUFACTURER ,BRAND,BARCODE);
 
 
 -- CLOSE-ENEDED QUESTIONS:
 -- Ques.1: What are the top 5 brands by receipts scanned among users 21 and over?
 SELECT 
    p.BRAND,
    COUNT(t.RECEIPT_ID) AS receipts_scanned
FROM 
    user u
JOIN 
    transaction t ON u.ID = t.USER_ID
JOIN 
    products p ON t.BARCODE = p.BARCODE
WHERE 
    TIMESTAMPDIFF(YEAR, u.BIRTH_DATE, CURDATE()) >= 21  -- Users aged 21 and over
GROUP BY 
    p.BRAND
ORDER BY 
    receipts_scanned DESC
LIMIT 6;

-- Ques.2: What are the top 5 brands by sales among users that have had their account for at least six months?
SELECT 
    p.BRAND,
    SUM(t.FINAL_SALE) AS total_sales
FROM 
    user u
JOIN 
    transaction t ON u.ID = t.USER_ID
JOIN 
    products p ON t.BARCODE = p.BARCODE
WHERE 
    TIMESTAMPDIFF(MONTH, u.CREATED_DATE, CURDATE()) >= 6  -- Users with accounts for at least 6 months
GROUP BY 
    p.BRAND
ORDER BY 
    total_sales DESC
LIMIT 5;

-- OPEN-ENDED QUESTION
-- Ques.2 : Which is the leading brand in the Dips & Salsa category?
SELECT 
    p.BRAND,
    SUM(t.FINAL_SALE) AS total_sales
FROM 
    user u
JOIN 
    transaction t ON u.ID = t.USER_ID
JOIN 
    products p ON t.BARCODE = p.BARCODE
WHERE 
    (p.CATEGORY_1 = 'Dips & Salsa' OR p.CATEGORY_2 = 'Dips & Salsa' OR 
    p.CATEGORY_3 = 'Dips & Salsa' OR p.CATEGORY_4 = 'Dips & Salsa')
GROUP BY 
    p.BRAND
ORDER BY 
    total_sales DESC
LIMIT 5;

-- Since, females are the maximum users, therefore checkinG which category does maximum female users shop
SELECT 
    CASE 
        WHEN p.CATEGORY_1 IS NOT NULL THEN p.CATEGORY_1
        WHEN p.CATEGORY_2 IS NOT NULL THEN p.CATEGORY_2
        WHEN p.CATEGORY_3 IS NOT NULL THEN p.CATEGORY_3
        WHEN p.CATEGORY_4 IS NOT NULL THEN p.CATEGORY_4
    END AS category,
    SUM(t.FINAL_SALE) AS total_sales
FROM 
    user u
JOIN 
    transaction t ON u.ID = t.USER_ID
JOIN 
    products p ON t.BARCODE = p.BARCODE
WHERE 
    u.GENDER = 'female'  
GROUP BY 
    category
ORDER BY 
    total_sales DESC
LIMIT 1;


--
SELECT MIN(BIRTH_DATE), MAX(BIRTH_DATE) FROM user;

-- Identifying which generation does maximum users belong to
SELECT 
    CASE  
        WHEN BIRTH_DATE IS NULL THEN 'Unknown'  
        WHEN BIRTH_DATE >= DATE_SUB(CURDATE(), INTERVAL 24 YEAR) THEN 'Gen Z'  
        WHEN BIRTH_DATE >= DATE_SUB(CURDATE(), INTERVAL 40 YEAR) THEN 'Millennials'  
        WHEN BIRTH_DATE >= DATE_SUB(CURDATE(), INTERVAL 56 YEAR) THEN 'Gen X'  
        WHEN BIRTH_DATE >= DATE_SUB(CURDATE(), INTERVAL 76 YEAR) THEN 'Boomers'  
        ELSE 'Silent Generation'  
    END AS generation,  
    COUNT(*) AS user_count  
FROM user  
GROUP BY generation  
ORDER BY user_count DESC;
-- END --
