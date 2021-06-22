### UK E-commerce Data

use commerce;

# 데이터
SELECT * FROM commerce ;

# 국가별, 상품별 구매자 수 및 매출액
-- 매출액은 반올림해서 나타낼것
-- country의 오름차순, 구매자수의 내림차순, 매출액의 내림차순으로 정렬
SELECT country, stockcode, COUNT(DISTINCT customerID) AS BU, ROUND(SUM(quantity*unitprice)) AS SALES
FROM commerce
GROUP BY 1, 2
ORDER BY 1, 3 DESC, 4 DESC
;

# 특정 상품 구매자가 많이 구매한 상품은?
## 가장 많이 판매된 상품
SELECT  StockCode, SUM(Quantity) AS QTY,
        RANK() OVER(ORDER BY SUM(Quantity) DESC) AS RNK
FROM    commerce
GROUP BY    StockCode
ORDER BY    SUM(Quantity) DESC
LIMIT 1
;

## 가장 많이 판매된 상품이 포함된 주문내역(invoice)
WITH A AS (SELECT  DISTINCT C.InvoiceNo
FROM    commerce AS C,
        ( SELECT  StockCode, SUM(Quantity) AS QTY,
          RANK() OVER(ORDER BY SUM(Quantity) DESC) AS RNK
          FROM    commerce
          GROUP BY    StockCode
          ORDER BY    SUM(Quantity) DESC
          LIMIT 1) AS B
WHERE   C.Stockcode = B.StockCode)

SELECT  COUNT(InvoiceNO)
From    A
;


## 가장 많이 판매된 상품과 함께 판매된 다른 상품
-- ?? 왜 WITH 문을 쓰고 WHERE 절에 쓰면 에러..?

SELECT  C.Stockcode, SUM(C.quantity)
FROM    commerce AS C
WHERE   C.InvoiceNo IN (SELECT  DISTINCT C.InvoiceNo
                        FROM    commerce AS C,
                                ( SELECT  StockCode, SUM(Quantity) AS QTY,
                                RANK() OVER(ORDER BY SUM(Quantity) DESC) AS RNK
                                FROM    commerce
                                GROUP BY    StockCode
                                ORDER BY    SUM(Quantity) DESC
                                LIMIT 1) AS B
                        WHERE   C.Stockcode = B.StockCode)
GROUP BY    StockCode
ORDER BY    SUM(C.quantity) DESC
;


# 국가별 재구매율(리텐션)
WITH A AS ( SELECT   c1.Country, YEAR(c1.InvoiceDate) AS YY, 
                     COUNT(DISTINCT c2.CustomerID) / COUNT(DISTINCT c1.CustomerID) AS RETENTION_RATE
            FROM     commerce as c1
            LEFT JOIN    commerce as c2
             ON   c1.CustomerID = c2.CustomerID
                AND YEAR(c1.InvoiceDate) = (YEAR(c2.InvoiceDate) - 1 )
            GROUP BY c1.Country, YEAR(c1.InvoiceDate)
 )
SELECT *
FROM    A
WHERE   YY=2010
;



# 코호트 분석
## 고객별 첫 구매일 구하기
SELECT  DISTINCT CustomerID, MIN(InvoiceDate) AS FIRST_PURCHASE_DATE
FROM    commerce
GROUP BY    CustomerID
ORDER BY    MIN(InvoiceDate), CustomerID
;

## 고객id, 구매일, 판매액
SELECT customerid, invoicedate, unitprice*quantity AS SALES
FROM commerce
;

## 코호트 분석을 위한 테이블 생성하기
WITH    A AS ( SELECT CustomerID, InvoiceDate, UnitPrice*Quantity as SALES
               FROM commerce ),
        B AS ( SELECT  DISTINCT CustomerID, MIN(InvoiceDate) AS FIRST_PURCHASE_DATE
                FROM    commerce
                GROUP BY    CustomerID
                ORDER BY    MIN(InvoiceDate), CustomerID  )
SELECT B.*, A.*
FROM    B
LEFT JOIN   A
ON B.CustomerID = A.CustomerID
;


## 월단위 코호트 분석하기
WITH COHORT_TB AS (SELECT B.*, A.InvoiceDate, A.SALES
                    FROM    ( SELECT  DISTINCT CustomerID, MIN(InvoiceDate) AS FIRST_PURCHASE_DATE
                              FROM    commerce
                              GROUP BY    CustomerID
                              ORDER BY    MIN(InvoiceDate), CustomerID ) AS B
                    LEFT JOIN ( SELECT CustomerID, InvoiceDate, UnitPrice*Quantity as SALES
                              FROM commerce ) AS A
                    ON B.CustomerID = A.CustomerID )
SELECT  DATE_FORMAT(FIRST_PURCHASE_DATE, "%Y-%m") AS YYYYMM,
        TIMESTAMPDIFF(MONTH, FIRST_PURCHASE_DATE, InvoiceDate) AS MONTH_DIFF,
        COUNT(DISTINCT CustomerID) AS BU, ROUND(SUM(SALES),0) AS SALES
FROM    COHORT_TB
GROUP BY 1,2
;


# 고객 세그먼트
## RFM
SELECT  DISTINCT CustomerID, DATEDIFF("2011-12-01", MAX(InvoiceDate)) AS RECENCY,
        COUNT(DISTINCT InvoiceNo) AS FREQUENCY,
        ROUND(SUM(Quantity*UnitPrice),0)AS MONETARY
FROM    commerce
GROUP BY    CustomerID
;

## 재구매 segment
### 먼저 고객별, 제품별로 몇 개 년도에서 구매가 발생했는지를 구해주세요.
SELECT  CustomerID, StockCode, Count(DISTINCT YEAR(InvoiceDate)) AS UNIQUE_YYYY
FROM    commerce
GROUP BY    CustomerID, StockCode
;

### 재구매 segment 나누기
WITH RE AS ( SELECT  CustomerID, StockCode, Count(DISTINCT YEAR(InvoiceDate)) AS UNIQUE_YYYY
             FROM    commerce
             GROUP BY    CustomerID, StockCode )

SELECT  A.CustomerID,
        (CASE WHEN repurchase_num >= 2 THEN 1
              ELSE 0
         END) AS repurchase_segmentation
FROM ( SELECT  CustomerID, MAX(UNIQUE_YYYY) AS repurchase_num
        FROM    RE
        GROUP BY CustomerID
        ORDER BY    CustomerID) AS A
;


# 일자별 첫 구매수 
WITH COHORT_TB AS (SELECT B.*, A.InvoiceDate, A.SALES
                    FROM    ( SELECT  DISTINCT CustomerID, MIN(InvoiceDate) AS FIRST_PURCHASE_DATE
                              FROM    commerce
                              GROUP BY    CustomerID
                              ORDER BY    MIN(InvoiceDate), CustomerID ) AS B
                    LEFT JOIN ( SELECT CustomerID, InvoiceDate, UnitPrice*Quantity as SALES
                              FROM commerce ) AS A
                    ON B.CustomerID = A.CustomerID )
SELECT  FIRST_PURCHASE_DATE, COUNT(DISTINCT CustomerID) AS FIRST_BU
FROM    COHORT_TB
GROUP BY    FIRST_PURCHASE_DATE
;

# 상품별 첫 구매 수

WITH F AS ( 
    SELECT  CustomerID,  MIN(InvoiceDate) AS FIRST_PURCHASE_DATE
    FROM    commerce
    GROUP BY    1 )
    
SELECT  C.StockCode, COUNT(DISTINCT F.CustomerID) AS FIRST_BU
FROM F, commerce AS C
WHERE C.CustomerID = F.CustomerID
 AND F.FIRST_PURCHASE_DATE = C.InvoiceDate
GROUP BY    C.StockCode
ORDER BY    COUNT(DISTINCT C.CustomerID) DESC
;




# 첫 구매 후 이탈하는 고객 비중
## 이탈률
WITH RE AS ( SELECT  CustomerID, Count(DISTINCT InvoiceDate) AS buy_num
             FROM    commerce
             GROUP BY    CustomerID)
             
SELECT  COUNT(CASE WHEN buy_num = 1 THEN 1 END) / COUNT(CASE WHEN buy_num >= 1 THEN 1 END) AS BOUNCE_RATE 
FROM    RE
;
SELECT  CustomerID, Count(DISTINCT InvoiceNo) AS buy_num
             FROM    commerce
             GROUP BY    CustomerID;
;


## 국가별 이탈률
SELECT Country, 
       COUNT(CASE WHEN A.buy_num = 1 THEN CustomerID END) / COUNT(CustomerID) AS BOUNCE_RATE
FROM ( SELECT  Country, CustomerID, COUNT(DISTINCT InvoiceDate) as buy_num
        FROM    commerce
        GROUP BY 1,2 ) AS A
GROUP BY Country
;

# 판매량
## 판매량이 2010년 대비 2011년에 20%이상 증가한 상품 리스트
SELECT StockCode, QTY_2011, QTY_2010, (QTY_2011-QTY_2010)/QTY_2010 AS QTY_INCREASE_RATE
FROM ( SELECT  StockCode, 
                SUM(CASE WHEN YEAR(InvoiceDate) = 2011 THEN Quantity END) AS QTY_2011,
                SUM(CASE WHEN YEAR(InvoiceDate) = 2010 THEN Quantity END) AS QTY_2010
        FROM    commerce
        GROUP BY   StockCode) AS A
WHERE  (QTY_2011-QTY_2010)/QTY_2010 >= 0.2
ORDER BY   (QTY_2011-QTY_2010)/QTY_2010, QTY_2011 DESC
;

SELECT StockCode,
        COUNT(Quantity)
FROM commerce
WHERE   YEAR(InvoiceDate) = 2011
GROUP BY StockCode;
