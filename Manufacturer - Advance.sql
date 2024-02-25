USE db_SQLCaseStudies
--02 may 2022
SELECT TOP 1 * FROM DIM_CUSTOMER
SELECT TOP 1 * FROM DIM_DATE
SELECT TOP 1 * FROM DIM_LOCATION
SELECT TOP 1 * FROM DIM_MANUFACTURER
SELECT TOP 1 * FROM DIM_MODEL
SELECT TOP 1 * FROM FACT_TRANSACTIONS

SELECT * FROM DIM_CUSTOMER
SELECT * FROM DIM_DATE
SELECT * FROM DIM_LOCATION
SELECT * FROM DIM_MANUFACTURER
SELECT * FROM DIM_MODEL
SELECT * FROM FACT_TRANSACTIONS


--1. List all the states in which we have customers who have bought cellphones 
--from 2005 till today. 
		SELECT DISTINCT A.State FROM DIM_LOCATION AS A
		INNER JOIN FACT_TRANSACTIONS AS B
		ON A.IDLocation = B.IDLocation
		WHERE YEAR(Date)>=2005

--2. What state in the US is buying the most 'Samsung' cell phones?
		SELECT TOP 1 A.[State] FROM DIM_LOCATION AS A
		INNER JOIN FACT_TRANSACTIONS AS B
		ON A.IDLocation = B.IDLocation
		INNER JOIN DIM_MODEL AS C
		ON B.IDMODEL = C.IDMODEL
		INNER JOIN DIM_MANUFACTURER AS D
		ON C.IDManufacturer = D.IDManufacturer
		WHERE Country = 'US' AND Manufacturer_Name = 'SAMSUNG'
		GROUP BY A.[State]
		ORDER  BY SUM(B.Quantity) DESC


--3. Show the number of transactions for each model per zip code per state.
		SELECT C.Model_Name, COUNT(C.Model_Name) CNT_OF_MODEL, ZipCode, [State] FROM DIM_LOCATION AS A
		INNER JOIN FACT_TRANSACTIONS AS B
		ON A.IDLocation = B.IDLocation
		INNER JOIN DIM_MODEL AS C
		ON B.IDModel = C.IDModel
		GROUP BY C.Model_Name,ZipCode,[State]

--4. Show the cheapest cellphone (Output should contain the price also)
		SELECT TOP 1 * FROM DIM_MODEL
		ORDER BY Unit_price ASC

--5. Find out the average price for each model in the top5 manufacturers in 
--terms of sales quantity and order by average price. 
		select Model_Name, AVG(TotalPrice) as Avg_price from FACT_TRANSACTIONS as a
		inner join DIM_MODEL as b
		on a.IDModel = b.IDModel
		inner join DIM_MANUFACTURER as c
		on b.IDManufacturer = c.IDManufacturer
		where manufacturer_name in 
		(
		select top 5 Manufacturer_Name from FACT_TRANSACTIONS as a
		inner join DIM_MODEL as b
		on a.IDModel = b.IDModel
		inner join DIM_MANUFACTURER as c
		on b.IDManufacturer = c.IDManufacturer
		group by Manufacturer_Name
		order by SUM(Quantity)
		)
		group by Model_Name
		order by AVG(TotalPrice)

--6. List the names of the customers and the average amount spent in 2009, 
--where the average is higher than 500 
		SELECT CUSTOMER_NAME,AVG(TOTALPRICE) AS AVG_PRICE FROM DIM_CUSTOMER AS A
		INNER JOIN FACT_TRANSACTIONS AS B
		ON A.IDCUSTOMER = B.IDCUSTOMER
		where YEAR(B.Date) = 2009
		GROUP BY CUSTOMER_NAME
		HAVING AVG(TOTALPRICE)>500

--7. List if there is any model that was in the top 5 in terms of quantity, 
--simultaneously in 2008, 2009 and 2010 

		select * from 
		(select top 5 Model_Name from DIM_MODEL as a
		inner join FACT_TRANSACTIONS as b
		on a.IDModel = b.IDModel
		where YEAR(date) = 2008
		group by Model_Name
		order by SUM(Quantity) desc
		) as t1
		intersect
		select * from 
		(select top 5 Model_Name from DIM_MODEL as a
		inner join FACT_TRANSACTIONS as b
		on a.IDModel = b.IDModel
		where YEAR(date) = 2009
		group by Model_Name
		order by SUM(Quantity) desc
		) as t2
		intersect
		select * from 
		(select top 5 Model_Name from DIM_MODEL as a
		inner join FACT_TRANSACTIONS as b
		on a.IDModel = b.IDModel
		where YEAR(date) = 2010
		group by Model_Name
		order by SUM(Quantity) desc
		) as t3


--8. Show the manufacturer with the 2nd top sales in the year of 2009 and the 
--manufacturer with the 2nd top sales in the year of 2010. 

		SELECT * FROM
		(
		SELECT A.Manufacturer_Name,SUM(TotalPrice) AS SUM_TOTALPRICE FROM DIM_MANUFACTURER AS A
		INNER JOIN DIM_MODEL AS B
		ON A.IDManufacturer = B.IDManufacturer
		INNER JOIN FACT_TRANSACTIONS AS C
		ON B.IDModel = C.IDModel
		WHERE YEAR(Date) = 2009
		GROUP BY A.Manufacturer_Name
		ORDER BY SUM_TOTALPRICE DESC
		OFFSET 1 ROW
		FETCH FIRST 1 ROW ONLY
		) AS T
		UNION ALL
		SELECT * FROM
		(
		SELECT A.Manufacturer_Name,SUM(TotalPrice) AS SUM_TOTALPRICE FROM DIM_MANUFACTURER AS A
		INNER JOIN DIM_MODEL AS B
		ON A.IDManufacturer = B.IDManufacturer
		INNER JOIN FACT_TRANSACTIONS AS C
		ON B.IDModel = C.IDModel
		WHERE YEAR(Date) = 2010
		GROUP BY A.Manufacturer_Name
		ORDER BY SUM_TOTALPRICE DESC
		OFFSET 1 ROW
		FETCH FIRST 1 ROW ONLY
		) AS T

--9. Show the manufacturers that sold cellphones in 2010 but did not in 2009. 
		SELECT DISTINCT A.Manufacturer_Name FROM DIM_MANUFACTURER AS A
		INNER JOIN DIM_MODEL AS B
		ON A.IDManufacturer = B.IDManufacturer
		INNER JOIN FACT_TRANSACTIONS AS C
		ON B.IDModel = C.IDModel
		WHERE YEAR(Date) = 2010
		EXCEPT
		SELECT DISTINCT A.Manufacturer_Name FROM DIM_MANUFACTURER AS A
		INNER JOIN DIM_MODEL AS B
		ON A.IDManufacturer = B.IDManufacturer
		INNER JOIN FACT_TRANSACTIONS AS C
		ON B.IDModel = C.IDModel
		WHERE YEAR(Date) = 2009

--10. Find top 100 customers and their average spend, average quantity by each 
--year. Also find the percentage of change in their spend.
		SELECT B.Customer_Name, AVG(TotalPrice) AS AVG_SPENT, AVG(Quantity) AS QUANTITY,YEAR(Date) AS [YEAR]
		,LAG(AVG(TotalPrice),1) OVER (PARTITION BY CUSTOMER_NAME ORDER BY YEAR(DATE)) AS LAG_,
		((AVG(TotalPrice)- LAG(AVG(TotalPrice),1) OVER (PARTITION BY CUSTOMER_NAME ORDER BY YEAR(DATE)))/AVG(TotalPrice)*100) AS CHANGE_PERCENT
		FROM FACT_TRANSACTIONS AS A
		INNER JOIN DIM_CUSTOMER AS B
		ON A.IDCustomer = B.IDCustomer
		GROUP BY B.Customer_Name, YEAR(DATE)
		ORDER BY B.Customer_Name, YEAR(DATE)

