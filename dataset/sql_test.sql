--Question 01: Using the customer table or tab, 
--please write an SQL query that shows Title, First Name 
--and Last Name and Date of Birth for each of the customers.

SELECT Title, FirstName, LastName, DateOfBirth
FROM Customer;

--Question 02: Using customer table or tab, please write an 
--SQL query that shows the number of customers in each customer
--group (Bronze, Silver & Gold). I can see visually that there 
--are 4 Bronze, 3 Silver and 3 Gold but if there were a million 
--customers how would I do this in Excel?

SELECT CustomerGroup, COUNT(*) AS NumberOfCustomers
FROM Customer
GROUP BY CustomerGroup;

--Question 03: The CRM manager has asked me to provide a 
--complete list of all data for those customers in the customer 
--table but I need to add the currencycode of each player so she
-- will be able to send the right offer in the right currency. 
--Note that the currencycode does not exist in the customer 
--table but in the account table. Please write the SQL that 
--would facilitate this.

SELECT c.*, a.CurrencyCode
FROM Customer c
JOIN Account a ON c.CustId = a.CustId;
--BONUS: How would I do this in Excel if I had a much larger 
--data set?
-- I would do this in excel by using the VLOOKUP function to match the CustId from the Customer table with the CustId in the Account table to retrieve the corresponding CurrencyCode for each customer.

--Question 04: Now I need to provide a product manager with a 
--summary report that shows, by product and by day how much 
--money has been bet on a particular product. PLEASE note that 
--the transactions are stored in the betting table and there is 
--a product code in that table that is required to be looked up 
--(classid & categortyid) to determine which product family this
-- belongs to. Please write the SQL that would provide the 
--report.

SELECT 
    p.product AS ProductName,
    DATE(b.BetDate) AS TransactionDate,
    SUM(b.Bet_Amt) AS TotalBetAmount
FROM 
    Betting b
JOIN 
    Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID      
GROUP BY 
    p.product, DATE(b.BetDate)
ORDER BY 
    p.product, DATE(b.BetDate);
--BONUS: If you imagine that 
--this was a much larger data set in Excel, how would you 
--provide this report in Excel?
-- In Excel, I would use a Pivot Table to summarize the data. I would set the ProductName as the row label, TransactionDate as the column label, and TotalBetAmount as the value field, using the SUM function to aggregate the bet amounts. This would allow me to easily see the total bet amount for each product by day.

--Question 05: You’ve just provided the report from question 4 
--to the product manager, now he has emailed me and wants it 
--changed. Can you please amend the summary report so that it 
--only summarizes transactions that occurred on or after 1st
-- November and he only wants to see Sportsbook transactions.
--Again, please write the SQL below that will do this.

SELECT 
    p.product AS ProductName,
    DATE(b.BetDate) AS TransactionDate,
    SUM(b.Bet_Amt) AS TotalBetAmount
FROM 
    Betting b   
JOIN 
    Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORY
WHERE 
    DATE(b.BetDate) >= '2012-11-01'
    AND p.product = 'Sportsbook'
GROUP BY 
    p.product, DATE(b.BetDate)  
ORDER BY 
    p.product, DATE(b.BetDate);
--BONUS: If I were delivering this via Excel, how would I do this?
-- In Excel, I would apply a filter to the previously created Pivot Table.

--Question 06: As often happens, the product manager has shown 
--his new report to his director and now he also wants different
-- version of this report. This time, he wants the all of the 
--products but split by the currencycode and customergroup of 
--the customer, rather than by day and product. He would also 
--only like transactions that occurred after 1st December. 
--Please write the SQL code that will do this.

SELECT 
    p.product AS ProductName,
    a.CurrencyCode,
    c.CustomerGroup,
    SUM(b.Bet_Amt) AS TotalBetAmount
FROM 
    Betting b
JOIN
    Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
JOIN
    Account a ON b.AccountNo = a.AccountNo  
JOIN
    Customer c ON a.CustId = c.CustId
WHERE 
    DATE(b.BetDate) > '2012-12-01'
GROUP BY 
    p.product, a.CurrencyCode, c.CustomerGroup  
ORDER BY
    p.product, a.CurrencyCode, c.CustomerGroup;

--Question 07: Our VIP team have asked to see a report of all 
--players regardless of whether they have done anything in the 
--complete timeframe or not. In our example, it is possible that 
--not all of the players have been active. Please write an SQL 
--query that shows all players Title, First Name and Last Name 
--and a summary of their bet amount for the complete period of 
--November.

SELECT 
    c.Title,
    c.FirstName,
    c.LastName,
    COALESCE(SUM(b.Bet_Amt), 0) AS TotalBetAmount
FROM
    Customer c
LEFT JOIN
    Account a ON c.CustId = a.CustId
LEFT JOIN
    Betting b ON a.AccountNo = b.AccountNo AND DATE(b.BetDate) >= '2012-11-01' AND DATE(b.BetDate) < '2012-12-01'
GROUP BY
    c.Title, c.FirstName, c.LastName
ORDER BY
    c.LastName, c.FirstName;

--Question 08: Our marketing and CRM teams want to measure
--the number of players who play more than one product. 
--Can you please write 2 queries, one that shows the number of 
--products per player and another that shows players who play 
--both Sportsbook and Vegas.

--Query 1: Number of products per player
SELECT 
    c.CustId,
    c.FirstName,
    c.LastName,
    COUNT(DISTINCT p.product) AS NumberOfProducts   
FROM Customer c
JOIN Account a ON c.CustId = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
JOIN Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORYID
GROUP BY c.CustId, c.FirstName, c.LastName
ORDER BY NumberOfProducts DESC;
--Query 2: Players who play both Sportsbook and Vegas
SELECT
    c.CustId,
    c.FirstName,
    c.LastName
FROM Customer c
JOIN Account a ON c.CustId = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
JOIN Product p ON b.ClassId = p.CLASSID AND b.CategoryId = p.CATEGORY
WHERE p.product IN ('Sportsbook', 'Vegas')
GROUP BY c.CustId, c.FirstName, c.LastName
HAVING COUNT(DISTINCT p.product) = 2
ORDER BY c.LastName, c.FirstName;

--Question 09: Now our CRM team want to look at players who 
--only play one product, please write SQL code that shows the 
--players who only play at sportsbook, use the bet_amt > 0 as 
--the key. Show each player and the sum of their bets for both 
--products.

SELECT
    c.CustId,
    c.FirstName,
    c.LastName,
    SUM(CASE WHEN p.product = 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) AS SportsbookBetAmount,
    SUM(CASE WHEN p.product = 'Vegas'       THEN b.Bet_Amt ELSE 0 END) AS VegasBetAmount
FROM Customer c
JOIN Account a ON c.CustId    = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
JOIN Product p ON b.ClassId   = p.ClassId AND b.CategoryId = p.CategoryId
WHERE b.Bet_Amt > 0
GROUP BY c.CustId, c.FirstName, c.LastName
HAVING
    SUM(CASE WHEN p.product = 'Sportsbook' THEN b.Bet_Amt ELSE 0 END) > 0
    AND SUM(CASE WHEN p.product = 'Vegas'  THEN b.Bet_Amt ELSE 0 END) = 0
ORDER BY c.LastName, c.FirstName;

--Question 10: The last question requires us to calculate and 
--determine a player’s favorite product. This can be determined 
--by the most money staked. Please write a query that will show 
--each players favorite product.

SELECT
    c.CustId,
    c.FirstName,
    c.LastName,
    p.product AS FavoriteProduct,
    SUM(b.Bet_Amt) AS TotalBetAmount
FROM Customer c
JOIN Account a ON c.CustId = a.CustId
JOIN Betting b ON a.AccountNo = b.AccountNo
JOIN Product p ON b.ClassId = p.CLASSId AND b.CategoryId = p.CategoryId
GROUP BY c.CustId, c.FirstName, c.LastName, p.product
ORDER BY c.LastName, c.FirstName, TotalBetAmount DESC;

--Question 11: Write a query that returns the top 5 
--students based on GPA.

SELECT student_id, student_name
FROM Student_School
ORDER BY GPA DESC
LIMIT 5;

--Question 12: Write a query that returns the number of 
--students in each school. (a school should be in the output 
--even if it has no students!).

SELECT school_name, COUNT(student_id) AS number_of_students
FROM Student_School
GROUP BY school_name
ORDER BY school_name;

--Question 13: Write a query that returns the top 3 GPA students' 
--name from each university.

SELECT school_name, student_name, GPA
FROM (
    SELECT school_name, student_name, GPA,
           ROW_NUMBER() OVER (PARTITION BY school_name ORDER BY GPA DESC) AS rn
    FROM Student_School
) sub
WHERE rn <= 3
ORDER BY school_name, GPA DESC;
