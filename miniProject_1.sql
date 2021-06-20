-- Practice -- 
USE classicmodels;

-- 어떤 데이터가 있는지 먼저 확인하기
select * from orders;

# 구매지표 추출
## 매출액(일자별, 월별, 연도별)
### 일별 매출액 조회
SELECT  DATE_FORMAT(orderdate, '%Y-%m-%d') AS orderdate, SUM(D.quantityOrdered*D.priceEach)
FROM    orderdetails AS D
RIGHT JOIN   orders as O
ON  D.orderNumber = O.orderNumber
GROUP BY DATE_FORMAT(orderdate, '%Y-%m-%d')
;

### 월별 매출액 조회 
SELECT  DATE_FORMAT(orderdate, '%Y-%m') AS yyyymm, SUM(D.quantityOrdered*D.priceEach)
FROM    orderdetails AS D
RIGHT JOIN   orders AS O 
ON D.orderNumber = O.orderNumber
GROUP BY DATE_FORMAT(orderdate,'%Y-%m')
;


### 연도별 매출액 조회
SELECT  DATE_FORMAT(orderdate, '%Y') AS yyyy, SUM(D.quantityOrdered*D.priceEach) AS sales
FROM    orderdetails AS D
RIGHT JOIN   orders AS O 
ON D.orderNumber = O.orderNumber
GROUP BY DATE_FORMAT(orderdate,'%Y')
;


## 구매자수, 구매 건수(일자별, 월별, 연도별)
### 일자별
SELECT  DATE_FORMAT(orderdate, '%Y-%m-%d') AS orderdate, COUNT(DISTINCT C.customerNumber) AS n_purchaser, COUNT(1) AS n_orders
FROM    customers AS C
RIGHT JOIN   orders AS O 
ON C.customerNumber = O.customerNumber
GROUP BY DATE_FORMAT(orderdate,'%Y-%m-%d')
ORDER BY DATE_FORMAT(orderdate,'%Y-%m-%d')
;

/*select * from customers;
select * from customers;
SELECT  *
FROM    customers AS C
LEFT JOIN   orders AS O 
ON C.customerNumber = O.customerNumber
GROUP BY DATE_FORMAT(orderdate,'%Y-%m-%d')
ORDER BY DATE_FORMAT(orderdate,'%Y-%m-%d')
; */
### 월별
SELECT  DATE_FORMAT(orderdate, '%Y-%m') AS YYYYMM, COUNT(DISTINCT C.customerNumber) AS n_purchaser, COUNT(1) AS n_orders
FROM    customers AS C
RIGHT JOIN   orders AS O 
ON C.customerNumber = O.customerNumber
GROUP BY DATE_FORMAT(orderdate,'%Y-%m')
ORDER BY DATE_FORMAT(orderdate,'%Y-%m')
;

### 연도별
SELECT  YEAR(orderdate) AS YYYY, COUNT(DISTINCT C.customerNumber) AS n_purchaser, COUNT(1) AS n_orders
FROM    customers AS C
RIGHT JOIN   orders AS O 
ON C.customerNumber = O.customerNumber
GROUP BY YEAR(orderdate)
ORDER BY YEAR(orderdate)
;


## 인당매출액 AMV
### 연도별
WITH year_sales AS ( SELECT  YEAR(orderdate) AS yyyy, SUM(D.quantityOrdered*D.priceEach) AS sales
                  FROM    orderdetails AS D
                  RIGHT JOIN   orders AS O 
                  ON D.orderNumber = O.orderNumber
                  GROUP BY DATE_FORMAT(orderdate,'%Y')),
     year_num AS (SELECT  DATE_FORMAT(orderdate, '%Y') AS YYYY, COUNT(DISTINCT C.customerNumber) AS n_purchaser, COUNT(1) AS n_orders
               FROM    customers AS C
               RIGHT JOIN   orders AS O 
               ON C.customerNumber = O.customerNumber
               GROUP BY DATE_FORMAT(orderdate,'%Y'))
               
SELECT  P.*, N.n_purchaser, P.sales/N.n_purchaser AS AMV
FROM year_sales AS P,
     year_num AS N
WHERE P.yyyy = N.YYYY
;

## 건당 구매 금액 ATV
### 연도별
WITH year_sales AS ( SELECT  YEAR(orderdate) AS yyyy, SUM(D.quantityOrdered*D.priceEach) AS sales
                  FROM    orderdetails AS D
                  LEFT JOIN   orders AS O 
                  ON D.orderNumber = O.orderNumber
                  GROUP BY DATE_FORMAT(orderdate,'%Y')),
     year_num AS (SELECT  DATE_FORMAT(orderdate, '%Y') AS YYYY, COUNT(DISTINCT C.customerNumber) AS n_purchaser, COUNT(1) AS n_orders
               FROM    customers AS C
               RIGHT JOIN   orders AS O 
               ON C.customerNumber = O.customerNumber
               GROUP BY DATE_FORMAT(orderdate,'%Y'))

SELECT  P.*, N.n_orders AS n_ordernumbers, P.sales/N.n_orders AS ATV
FROM year_sales AS P,
     year_num AS N
WHERE P.yyyy = N.YYYY
;


# 그룹별 구매 지표 구하기
## 국가별, 도시별 매출액
-- orders , customers, orderdetails JOIN
SELECT C.country, C.city, SUM(D.quantityOrdered*priceEach) AS sales
FROM    orders AS O,
        customers AS C,
        orderdetails AS D
WHERE   O.orderNumber = D.orderNumber
       AND O.customerNumber = C.customerNumber
GROUP BY C.country, C.city
;

## 북미 vs 비북미 매출액 비교
WITH salesby_country AS ( SELECT  C.country,SUM(D.quantityOrdered*priceEach) AS sales
                          FROM    orders AS O,
                                  customers AS C,
                                  orderdetails AS D
                          WHERE   O.orderNumber = D.orderNumber
                              AND O.customerNumber = C.customerNumber
                          GROUP BY C.country )

SELECT  cn.country_group, SUM(cn.sales) AS sales
FROM    (SELECT sales,
                ( CASE WHEN country = "USA" THEN 'North America'
                       WHEN country = "CANADA" THEN 'North America'
                       ELSE 'Others'
                    END) AS country_group 
         FROM salesby_country) AS cn
GROUP BY country_group
;


/* WITH salesby_country AS ( SELECT  C.country,SUM(D.quantityOrdered*priceEach) AS sales
                          FROM    orders AS O,
                                  customers AS C,
                                  orderdetails AS D
                          WHERE   O.orderNumber = D.orderNumber
                              AND O.customerNumber = C.customerNumber
                          GROUP BY C.country )
SELECT sales,
        ( CASE country WHEN IN ("USA" , "CANADA") THEN 'North America'
               ELSE 'Others'
               END) AS country_group 
FROM salesby_country
;
*/

# 매출 Top5 국가 및 매출
WITH salesby_country AS ( SELECT  C.country,SUM(D.quantityOrdered*priceEach) AS sales
                          FROM    orders AS O,
                                  customers AS C,
                                  orderdetails AS D
                          WHERE   O.orderNumber = D.orderNumber
                              AND O.customerNumber = C.customerNumber
                          GROUP BY C.country )
SELECT  s.country, s.sales, 
        RANK() OVER(ORDER BY s.sales DESC) AS RNK
FROM    salesby_country AS s
LIMIT 5
;


# 재구매율 Retention Rate. 국가별로 구매에 대한 연간 리텐션을 구하라.
WITH ordered_cust AS ( SELECT  C.country, O.orderdate, O.customerNumber
                            FROM    orders AS O,
                                    customers AS C
                            WHERE   O.customerNumber = C.customerNumber
                        )

SELECT 
       o1.country, YEAR(o1.orderdate), COUNT(DISTINCT o1.customerNumber) AS BU_1,
       COUNT(DISTINCT o2.customerNumber) AS BU_2, COUNT(DISTINCT o2.customerNumber)/COUNT(DISTINCT o1.customerNumber) AS 1_year_retention_rate
FROM    ordered_cust AS o1
LEFT JOIN  ordered_cust  AS o2
ON  o1.customerNumber = o2.customerNumber
   AND YEAR(o1.orderdate)  = (YEAR(o2.orderdate) -1)
GROUP BY o1.country, YEAR(o1.orderdate)
;

/* SELECT  C.country, O.orderdate, O.customerNumber
                            FROM    orders AS O,
                                    customers AS C
                            WHERE   O.customerNumber = C.customerNumber
; */


# Best Seller. 미국시장에서 역대 누적 판매액이 가장 높은 모델 Top5를 구하라.
SELECT  P.productCode, P.productName, SUM(D.quantityOrdered*priceEach) AS sales, 
        RANK() OVER(ORDER BY SUM(D.quantityOrdered*priceEach) DESC)
FROM    orders AS O,
        customers AS C,
        orderdetails AS D,
        products AS P
WHERE   O.orderNumber = D.orderNumber
    AND O.customerNumber = C.customerNumber
    AND P.productCode = D.productCode
    AND C.country = 'USA'
GROUP BY P.productCode
LIMIT 5
;



## Churn과 Non-Churn의 수를 구하라.
/*SELECT  c.customerNumber, o.orderdate
FROM    customers AS c
RIGHT JOIN  orders as o
ON  c.customerNumber = o.customerNumber
;
*/

SELECT  A.ISCHURN, COUNT(A.customerNumber) AS n_customer
FROM ( SELECT  (CASE  WHEN ABS(DATEDIFF(MAX(o.orderdate), '2005-06-01')) >= 90 THEN 'CHURN'
                    ELSE 'NON_CHURN'
                    END) AS ISCHURN,
				c.customerNumber
       FROM    customers AS c
       RIGHT JOIN  orders as o
       ON  c.customerNumber = o.customerNumber
       GROUP BY c.customerNumber)  AS A
GROUP BY A.ISCHURN
;


/*SELECT c.customerNumber, o.orderdate, MAX(o.orderdate), DATEDIFF('2005-06-01',MAX(o.orderdate))
FROM    customers AS c
RIGHT JOIN  orders as o
ON  c.customerNumber = o.customerNumber
GROUP BY c.customerNumber
;
*/


## Churn Rate를 구하라
WITH	ischurn AS ( SELECT  A.ISCHURN, COUNT(A.customerNumber) AS n_customer
					 FROM ( SELECT  (CASE  WHEN ABS(DATEDIFF(MAX(o.orderdate), '2005-06-01')) >= 90 THEN 'CHURN'
									  ELSE 'NON_CHURN'
									  END) AS ISCHURN,
							c.customerNumber
							FROM    customers AS c
							RIGHT JOIN  orders as o
							ON  c.customerNumber = o.customerNumber
							GROUP BY c.customerNumber)  AS A
					 GROUP BY A.ISCHURN)
SELECT  I.n_customer AS n_CHURN, SUM(I.n_customer) AS n_TOTAL, 
	    I.n_customer/SUM(I.n_customer) AS CHURN_RATE
FROM	ischurn AS I
;