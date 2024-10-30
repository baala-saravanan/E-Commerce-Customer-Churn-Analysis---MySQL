-- ******************** E-Commerce Customer Churn Analysis ********************

-- DATA CLEANING:

-- Handling Missing Values and Outliers:

-- "Impute mean for the following columns, and round off to the nearest integer if
-- required: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear,
-- DaySinceLastOrder."  
SELECT WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder
FROM customer_churn;

SET @Imputed_WarehouseToHome = (
    SELECT ROUND(AVG(WarehouseToHome))
    FROM customer_churn
    WHERE WarehouseToHome IS NOT NULL
);

SET @Imputed_HourSpendOnApp = (
    SELECT ROUND(AVG(HourSpendOnApp))
    FROM customer_churn
    WHERE HourSpendOnApp IS NOT NULL
);

SET @Imputed_OrderAmountHikeFromlastYear = (
    SELECT ROUND(AVG(OrderAmountHikeFromlastYear))
    FROM customer_churn
    WHERE OrderAmountHikeFromlastYear IS NOT NULL
);

SET @Imputed_DaySinceLastOrder = (
    SELECT ROUND(AVG(DaySinceLastOrder))
    FROM customer_churn
    WHERE DaySinceLastOrder IS NOT NULL
);


SET SQL_SAFE_UPDATES = 0;

UPDATE customer_churn
SET WarehouseToHome = @Imputed_WarehouseToHome
WHERE WarehouseToHome IS NULL;

UPDATE customer_churn
SET HourSpendOnApp = @Imputed_HourSpendOnApp
WHERE HourSpendOnApp IS NULL;

UPDATE customer_churn
SET OrderAmountHikeFromlastYear = @Imputed_OrderAmountHikeFromlastYear
WHERE OrderAmountHikeFromlastYear IS NULL;

UPDATE customer_churn
SET DaySinceLastOrder = @Imputed_DaySinceLastOrder
WHERE DaySinceLastOrder IS NULL;

SELECT WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder
FROM customer_churn;

-- SET SQL_SAFE_UPDATES = 1;

-- Impute mode for the following columns: Tenure, CouponUsed, OrderCount. 
SELECT Tenure, CouponUsed, OrderCount
FROM customer_churn;

-- SELECT Tenure, CouponUsed, OrderCount FROM customer_churn ORDER BY Tenure;

-- SELECT COUNT(Tenure) count_null FROM customer_churn WHERE Tenure = 8;

SET @Imputed_Tenure = (
	SELECT Tenure
	FROM customer_churn
	WHERE Tenure IS NOT NULL
	GROUP BY Tenure
	ORDER BY COUNT(*) DESC, Tenure
	LIMIT 1
);

SET @Imputed_CouponUsed = (
	SELECT CouponUsed
	FROM customer_churn
	WHERE CouponUsed IS NOT NULL
	GROUP BY CouponUsed
	ORDER BY COUNT(*) DESC, CouponUsed
	LIMIT 1
);

SET @Imputed_OrderCount = (
	SELECT OrderCount
	FROM customer_churn
	WHERE OrderCount IS NOT NULL
	GROUP BY OrderCount
	ORDER BY COUNT(*) DESC, OrderCount
	LIMIT 1
);

-- SET SQL_SAFE_UPDATES = 0;

UPDATE customer_churn
SET Tenure = @Imputed_Tenure
WHERE Tenure IS NULL;

UPDATE customer_churn
SET CouponUsed = @Imputed_CouponUsed
WHERE CouponUsed IS NULL;

UPDATE customer_churn
SET OrderCount = @Imputed_OrderCount
WHERE OrderCount IS NULL;

SELECT Tenure, CouponUsed, OrderCount
FROM customer_churn;

-- SET SQL_SAFE_UPDATES = 1;

-- Handle outliers in the 'WarehouseToHome' column by deleting rows where the
-- values are greater than 100.
SELECT WarehouseToHome FROM customer_churn;

-- SET SQL_SAFE_UPDATES = 0;

DELETE FROM customer_churn WHERE WarehouseToHome > 100; 

SELECT WarehouseToHome FROM customer_churn;

-- SET SQL_SAFE_UPDATES = 1;

-- Dealing with Inconsistencies:

-- Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and
-- “Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” to ensure
-- uniformity.
SELECT PreferredLoginDevice FROM customer_churn;
 
SELECT PreferedOrderCat FROM customer_churn; 

-- SET SQL_SAFE_UPDATES = 0;

UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';

SELECT PreferredLoginDevice FROM customer_churn;

UPDATE customer_churn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

SELECT PreferedOrderCat FROM customer_churn;

-- SET SQL_SAFE_UPDATES = 1;

-- Standardize payment mode values: Replace "COD" with "Cash on Delivery" and
-- "CC" with "Credit Card" in the PreferredPaymentMode column.
SELECT PreferredPaymentMode FROM customer_churn;

-- SET SQL_SAFE_UPDATES = 0;

UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';

UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

SELECT PreferredPaymentMode FROM customer_churn;

SET SQL_SAFE_UPDATES = 1;

-- DATA TRANSFORMATION:

-- Column Renaming:

-- Rename the column "PreferedOrderCat" to "PreferredOrderCat".
SELECT PreferedOrderCat FROM customer_churn;

ALTER TABLE customer_churn
RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;

SELECT PreferredOrderCat FROM customer_churn;

-- Rename the column "HourSpendOnApp" to "HoursSpentOnApp".
SELECT HourSpendOnApp FROM customer_churn;

ALTER TABLE customer_churn
RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;

SELECT HoursSpentOnApp FROM customer_churn;

-- Creating New Columns:

--   Create a new column named ‘ComplaintReceived’ with values "Yes" if the
-- corresponding value in the ‘Complain’ is 1, and "No" otherwise.
SELECT Complain FROM customer_churn;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived ENUM('Yes', 'No');

UPDATE customer_churn
SET ComplaintReceived = IF(Complain = 1, 'Yes', 'No');

SELECT ComplaintReceived FROM customer_churn;

-- Create a new column named 'ChurnStatus'. Set its value to “Churned” if the
-- corresponding value in the 'Churn' column is 1, else assign “Active”.
SELECT Churn FROM customer_churn;

ALTER TABLE customer_churn
ADD COLUMN ChurnStatus ENUM('Churned', 'Active');

UPDATE customer_churn
SET ChurnStatus = IF(Churn = 1, 'Churned', 'Active');

SELECT ChurnStatus FROM customer_churn;

SET SQL_SAFE_UPDATES = 1;

-- Column Dropping:

-- Drop the columns "Churn" and "Complain" from the table. 
SELECT Churn FROM customer_churn;

ALTER TABLE customer_churn
DROP COLUMN Churn;

SELECT Churn FROM customer_churn;

SELECT Complain FROM customer_churn;

ALTER TABLE customer_churn
DROP COLUMN Complain;

SELECT Complain FROM customer_churn;

-- DATA EXPLORATION AND ANALYSIS: 

-- 1. Retrieve the count of churned and active customers from the dataset.
SELECT ChurnStatus FROM customer_churn;

SELECT COUNT(ChurnStatus) FROM customer_churn;
 
SELECT COUNT(ChurnStatus) churned_customers
FROM customer_churn
WHERE ChurnStatus = 'Churned';

SELECT COUNT(ChurnStatus) active_customers
FROM customer_churn
WHERE ChurnStatus = 'Active';

-- 2. Display the average tenure of customers who churned.
SELECT AVG(Tenure) average_tenure_customers_churned
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- 3. Calculate the total cashback amount earned by customers who churned.
SELECT CashbackAmount FROM customer_churn;

SELECT SUM(CashbackAmount) total_CashbackAmount_earned_by_customers_churned
FROM customer_churn
WHERE ChurnStatus = 'Churned';

-- 4. Determine the percentage of churned customers who complained.
SELECT ComplaintReceived FROM customer_churn;

SELECT ChurnStatus FROM customer_churn;

-- Calculate the total number of churned customers
SET @total_churned_customers = (
    SELECT COUNT(*)
    FROM customer_churn
    WHERE ChurnStatus = 'Churned'
);

-- Calculate the number of churned customers who complained
SET @churned_customers_who_complained = (
    SELECT COUNT(*)
    FROM customer_churn
    WHERE ChurnStatus = 'Churned' AND ComplaintReceived = 'Yes'
);

-- Calculate the percentage of churned customers who complained
SELECT (@churned_customers_who_complained / @total_churned_customers) * 100 AS percentage_of_churned_customers_who_complained;

-- 5. Find the gender distribution of customers who complained.
SELECT Gender FROM customer_churn;

SELECT ComplaintReceived FROM customer_churn;

SELECT COUNT(Gender) gender_distribution_of_customers_who_complained
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

-- Calculate total number of complaints:
SET @total_complaint = (
	SELECT COUNT(*)
	FROM customer_churn
	WHERE ComplaintReceived = 'Yes'
);    

-- Calculate gender distribution with count and percentage:
SELECT Gender, COUNT(Gender) count_of_gender_distribution_of_customers_who_complained, CONCAT(ROUND((COUNT(Gender)/@total_complaint) * 100), '%') percentage_count_of_gender_distribution_of_customers_who_complained
FROM customer_churn
WHERE ComplaintReceived = 'Yes'
GROUP BY Gender;

-- 6. Identify the city tier with the highest number of churned customers whose
-- preferred order category is Laptop & Accessory.
SELECT CityTier FROM customer_churn; 

SELECT ChurnStatus FROM customer_churn;

SELECT PreferredOrderCat FROM customer_churn;

SELECT MAX(CityTier) highest_city_tier FROM customer_churn;

SELECT CityTier, COUNT(ChurnStatus) highest_no_of_churned_customers, PreferredOrderCat
FROM customer_churn
WHERE ChurnStatus = 'Churned' AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier 
ORDER BY ChurnStatus 
DESC LIMIT 1;

-- 7. Identify the most preferred payment mode among active customers.
SELECT PreferredPaymentMode most_preferred_payment_mode_among_active_customers, COUNT(PreferredPaymentMode) total_no_of_most_preferred_payment_mode_among_active_customers
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY total_no_of_most_preferred_payment_mode_among_active_customers DESC 
LIMIT 1;

-- 8. List the preferred login device(s) among customers who took more than 10 days
-- since their last order. 
SELECT PreferredLoginDevice FROM customer_churn;

SELECT COUNT(DaySinceLastOrder) FROM customer_churn WHERE DaySinceLastOrder > 10; 

SELECT CustomerID, PreferredLoginDevice list_of_preferred_login_device_customers_more_than_10_days
FROM customer_churn
WHERE DaySinceLastOrder > 10;

-- 9. List the number of active customers who spent more than 3 hours on the app.
SELECT ChurnStatus FROM customer_churn;

SELECT HoursSpentOnApp FROM customer_churn; 

SELECT COUNT(HoursSpentOnApp) FROM customer_churn WHERE HoursSpentOnApp > 3; 

SELECT COUNT(*) no_of_active_customers_spent_more_than_3_hrs_on_app
FROM customer_churn
WHERE HoursSpentOnApp > 3 AND ChurnStatus = 'Active';

-- 10. Find the average cashback amount received by customers who spent at least 2
-- hours on the app.
SELECT CashbackAmount FROM customer_churn; 

SELECT AVG(CashbackAmount) average_CashbackAmount_received_customers_atleast_2_HoursSpentOnApp
FROM customer_churn
WHERE HoursSpentOnApp >= 2;

-- 11. Display the maximum hours spent on the app by customers in each preferred
-- order category. 
SELECT PreferredOrderCat FROM customer_churn;

SELECT PreferredOrderCat, MAX(HoursSpentOnApp) max_HoursSpentOnApp
FROM customer_churn
GROUP BY PreferredOrderCat;

-- 12. Find the average order amount hike from last year for customers in each marital
-- status category.
SELECT OrderAmountHikeFromlastYear FROM customer_churn;

SELECT MaritalStatus FROM customer_churn;

SELECT MaritalStatus, AVG(OrderAmountHikeFromlastYear) average_OrderAmountHikeFromlastYear
FROM customer_churn
GROUP BY MaritalStatus;

-- 13. Calculate the total order amount hike from last year for customers who are single
-- and prefer mobile phones for ordering.
SELECT MaritalStatus, PreferredOrderCat, SUM(OrderAmountHikeFromlastYear) total_OrderAmountHikeFromlastYear
FROM customer_churn
WHERE PreferredOrderCat = 'Mobile Phone' AND MaritalStatus = 'Single'
GROUP BY MaritalStatus;

-- 14. Find the average number of devices registered among customers who used UPI as
-- their preferred payment mode.
SELECT NumberOfDeviceRegistered FROM customer_churn;

SELECT PreferredPaymentMode FROM customer_churn;

SELECT PreferredPaymentMode, AVG(NumberOfDeviceRegistered) average_NumberOfDeviceRegistered
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI'
GROUP BY PreferredPaymentMode;

-- 15. Determine the city tier with the highest number of customers.
SELECT CityTier, COUNT(CityTier) CityTier_highest_no_of_customers
FROM customer_churn
GROUP BY CityTier
ORDER BY CityTier_highest_no_of_customers DESC 
LIMIT 1;

-- 16. Find the marital status of customers with the highest number of addresses.
SELECT MaritalStatus, COUNT(NumberOfAddress) highest_NumberOfAddress
FROM customer_churn
GROUP BY MaritalStatus
ORDER BY highest_NumberOfAddress DESC 
LIMIT 1;

-- 17. Identify the gender that utilized the highest number of coupons.
SELECT Gender, COUNT(CouponUsed) highest_CouponUsed
FROM customer_churn
GROUP BY Gender
ORDER BY highest_CouponUsed DESC
LIMIT 1;

-- 18. List the average satisfaction score in each of the preferred order categories.
SELECT PreferredOrderCat, AVG(SatisfactionScore) average_SatisfactionScore
FROM customer_churn
GROUP BY PreferredOrderCat;

-- 19. Calculate the total order count for customers who prefer using credit cards and
-- have the maximum satisfaction score. 
SELECT SUM(OrderCount) total_customers_OrderCount_using_credit_cards, MAX(SatisfactionScore) maximum_satisfaction_score
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card';

-- 20. How many customers are there who spent only one hour on the app and days
-- since their last order was more than 5? 
SELECT COUNT(HoursSpentOnApp) customers_spent_only_one_hour_on_app
FROM customer_churn
WHERE HoursSpentOnApp = 1 AND DaySinceLastOrder > 5;

-- 21. What is the average satisfaction score of customers who have complained?
SELECT AVG(SatisfactionScore) average_SatisfactionScore_customers_complained
FROM customer_churn
WHERE ComplaintReceived = 'Yes';

-- 22. How many customers are there in each preferred order category?
SELECT PreferredOrderCat, COUNT(*) customers_each_PreferredOrderCat
FROM customer_churn
GROUP BY PreferredOrderCat;

-- 23. What is the average cashback amount received by married customers?
SELECT AVG(CashbackAmount) average_CashbackAmount_received_married_customers
FROM customer_churn
WHERE MaritalStatus = 'Married';

-- 24. What is the average number of devices registered by customers who are not
-- using Mobile Phone as their preferred login device?
SELECT PreferredLoginDevice FROM customer_churn;

SELECT NumberOfDeviceRegistered FROM customer_churn;

SELECT AVG(NumberOfDeviceRegistered) average_NumberOfDeviceRegistered_not_using_mobilephone
FROM customer_churn
WHERE PreferredLoginDevice <> 'Mobile Phone';

-- 25. List the preferred order category among customers who used more than 5 coupons.
SELECT CouponUsed FROM customer_churn;

SELECT PreferredOrderCat customers_Count_PreferredOrderCat_more_than_5_coupons
FROM customer_churn
WHERE CouponUsed > 5;

SELECT PreferredOrderCat, COUNT(*) customers_Count_PreferredOrderCat_more_than_5_coupons
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat;

-- 26. List the top 3 preferred order categories with the highest average cashback amount.
SELECT PreferredOrderCat top_3_PreferredOrderCat, AVG(CashbackAmount) highest_average_CashbackAmount
FROM customer_churn
GROUP BY top_3_PreferredOrderCat
ORDER BY highest_average_CashbackAmount DESC
LIMIT 3;

-- 27. Find the preferred payment modes of customers whose average tenure is 10
-- months and have placed more than 500 orders.
SELECT PreferredPaymentMode, COUNT(OrderCount) placed_more_than_500_orders, AVG(Tenure) average_tenure_10_months
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING placed_more_than_500_orders > 500
ORDER BY average_tenure_10_months DESC
LIMIT 1;

-- 28. Categorize customers based on their distance from the warehouse to home such
-- as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km,
-- 'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the
-- churn status breakdown for each distance category.
SELECT
	CASE
		WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
		WHEN WarehouseToHome <= 10 THEN 'Close Distance'
		WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
		ELSE 'Far Distance'
	END AS distances,
ChurnStatus, COUNT(ChurnStatus) ChurnStatus_breakdown_each_distance_category
FROM customer_churn
GROUP BY ChurnStatus,distances
ORDER BY distances;

-- 29. List the customer’s order details who are married, live in City Tier-1, and their
-- order counts are more than the average number of orders placed by all
-- customers.
SELECT OrderCount FROM customer_churn;

SELECT AVG(OrderCount) INTO @average_OrderCount FROM customer_churn;

SELECT 
		CustomerID,
		CityTier,
		MaritalStatus,
		OrderCount,  
		Tenure, 
		PreferredLoginDevice, 
		WarehouseToHome, 
		PreferredPaymentMode, 
		Gender, 
		HoursSpentOnApp, 
		NumberOfDeviceRegistered, 
		PreferredOrderCat, 
		SatisfactionScore,  
		NumberOfAddress, 
		OrderAmountHikeFromlastYear, 
		CouponUsed, 
		DaySinceLastOrder, 
		CashbackAmount, 
		ComplaintReceived, 
		ChurnStatus
FROM customer_churn
WHERE MaritalStatus = 'Married' AND CityTier = 1 AND OrderCount > @average_OrderCount;

-- 30. a) Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the following data:
CREATE TABLE customer_returns(
					ReturnID      INT,
                    CustomerID    INT  PRIMARY KEY,
                    ReturnDate    DATE,
                    RefundAmount  INT
                    );
                    
-- DROP TABLE customer_returns;
                   
INSERT INTO customer_returns(ReturnID, CustomerID, ReturnDate, RefundAmount) VALUES
			(1001, 50022, '2023-01-01', 2130),
			(1002, 50316, '2023-01-23', 2000),
			(1003, 51099, '2023-02-14', 2290),
			(1004, 52321, '2023-03-08', 2510),
			(1005, 52928, '2023-03-20', 3000),
			(1006, 53749, '2023-04-17', 1740),
			(1007, 54206, '2023-04-21', 3250),
			(1008, 54838, '2023-04-30', 1990);
            
-- 30. b) Display the return details along with the customer details of those who have
-- churned and have made complaints.
SELECT cr.*, 
	cc.Tenure,
    cc.PreferredLoginDevice,
    cc.CityTier,
    cc.WarehouseToHome,
    cc.PreferredPaymentMode,
    cc.Gender,
    cc.HoursSpentOnApp,
    cc.NumberOfDeviceRegistered,
    cc.PreferredOrderCat,
    cc.SatisfactionScore,
    cc.MaritalStatus,
    cc.NumberOfAddress,
    cc.OrderAmountHikeFromlastYear,
    cc.CouponUsed,
    cc.OrderCount,
    cc.DaySinceLastOrder,
    cc.CashbackAmount,
    cc.ComplaintReceived,
    cc.ChurnStatus
FROM customer_returns cr
JOIN customer_churn cc
ON cr.CustomerID = cc.CustomerID
WHERE cc.ChurnStatus = 'Churned' AND cc.ComplaintReceived = 'Yes';

-- ******************** THANK YOU ********************