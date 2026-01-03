-- PROJECT: Telco Customer Churn Data Cleaning & Transformation
-- GOAL: Prepare raw data for visualization in Tableau
-- SKILLS USED: Data Profiling, Data Cleaning, Data Transformation, Aggregate Functions, Converting Data Types, and Handling Missing Values.

-- Steps:
-- 1. SELECT DATABASE
USE telco_analysis; 


-- 2. DATA PROFILING
-- Check table structure and initial data types
DESC telco_churn;

-- Check total row count
SELECT COUNT(*) FROM telco_churn;

-- Check for duplicate Customer IDs
SELECT CustomerID, COUNT(*) 
FROM telco_churn 
GROUP BY CustomerID 
HAVING COUNT(*) > 1;


-- 3. DATA CLEANING=
-- Replace empty strings (spaces) in Total Charges with '0'
UPDATE telco_churn 
SET `Total Charges` = '0' 
WHERE `Total Charges` = ' ';


-- 4. DATA TRANSFORMATION
-- Convert text columns to Decimal for mathematical calculations and mapping
ALTER TABLE telco_churn 
MODIFY COLUMN `Total Charges` DECIMAL(15,2),
MODIFY COLUMN `Monthly Charges` DECIMAL(10,2),
MODIFY COLUMN `Latitude` DECIMAL(10,6),
MODIFY COLUMN `Longitude` DECIMAL(11,6);


-- 5. FINAL VERIFICATION
-- Ensure no missing values remain in the numeric ranges
SELECT 
    MIN(`Total Charges`) AS min_total, 
    MAX(`Total Charges`) AS max_total,
    MIN(`Monthly Charges`) AS min_monthly
FROM telco_churn;


-- Confirm final table structure is correct
DESC telco_churn;
