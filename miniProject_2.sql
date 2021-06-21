USE instacart;

# 데이터
SELECT * FROM aisles LIMIT 100;
SELECT * FROM departments LIMIT 100;
SELECT * FROM order_products__prior LIMIT 100;
SELECT * FROM orders LIMIT 100;
SELECT * FROM products LIMIT 100;

# 지표 추출
## 전체 주문 건수
SELECT count(order_id) AS '전체 주문 건수'
FROM orders;

/*
데이터의 정합성을 고려해서 데이터베이스를 create했다면 id가 중복될 일이 없겠지만
csv형태로 데이터를 건네받다보면 데이터의 중복이 발생하는 경우도 있다.
이런 사태를 미연에 방지하기 위해 중복유무를 distinct로 체크해주는건 좋은 습관이다.
*/
SELECT count(order_id), count(distinct order_id)
FROM orders;


## 구매자 수
SELECT  count(distinct user_id) AS BU
FROM    orders
;

## 상품별 주문 건수
SELECT  pr.product_id, p.*, COUNT( DISTINCT pr.order_id) AS ORDERS_CNT
FROM    products as p
RIGHT JOIN   order_products__prior AS pr
ON  pr.product_id = p.product_id
GROUP BY    pr.product_id
ORDER BY    product_name
;



## 카트에 가장 먼저 넣는 상품 10개
SELECT  product_id, COUNT(add_to_cart_order) AS N_ADD_TO_CART_ORDER, 
        ROW_NUMBER() OVER(ORDER BY COUNT(add_to_cart_order) DESC)
FROM    order_products__prior
WHERE   add_to_cart_order = 1
GROUP BY    product_id
LIMIT   10
;

## 시간별 주문 건수
SELECT  order_hour_of_day, COUNT(order_id)  AS N_ORDER_ID
FROM    orders
GROUP BY    order_hour_of_day
ORDER BY    order_hour_of_day
;

## 첫 구매 후 다음 구매까지 걸린 평균 일수
SELECT  AVG(days_since_prior_order) AS "첫 구매 후 다음 구매까지 걸린 평균 일수"
FROM    orders
WHERE   order_number = 2
;

## 주문 건당 평균 구매 상품 수(UPT, Unit Per Transaction)
WITH no AS ( SELECT   pr.product_id, pr.order_id, COUNT(pr.order_id) AS n_orders
             FROM  order_products__prior AS pr
             GROUP BY pr.order_id )
SELECT  SUM(n_orders) / COUNT(DISTINCT order_id)
FROM no
;

## 인당 평균 주문 건수 
SELECT  COUNT(DISTINCT order_id) / COUNT(DISTINCT user_id) AS AVG_N_ORDER_BY_USER
FROM orders
;


## 재구매율이 가장 낮은 상품 3위까지
WITH    re_ord AS ( SELECT  pr.product_id, SUM(pr.reordered) / COUNT(DISTINCT pr.order_id) AS RATIO,
                            DENSE_RANK() OVER(ORDER BY SUM(pr.reordered) / COUNT(DISTINCT pr.order_id) ) AS RNK
                    FROM    order_products__prior AS pr
                    LEFT JOIN    orders AS o
                    ON  o.order_id = pr.order_id
                    GROUP BY    pr.product_id
                    HAVING  SUM(pr.reordered) >= 1 )
                    
SELECT *
FROM    re_ord
WHERE   RNK <= 3
;
      
      
WITH    re_ord AS ( SELECT  pr.product_id, SUM(pr.reordered) / COUNT(DISTINCT pr.order_id) AS RATIO,
                            DENSE_RANK() OVER(ORDER BY SUM(pr.reordered) / COUNT(DISTINCT pr.order_id) ) AS RNK
                    FROM    order_products__prior AS pr
                    GROUP BY    pr.product_id
                    HAVING  SUM(pr.reordered) >= 1 )
                    
SELECT *
FROM    re_ord
WHERE   RNK <= 3
;

## Department별 재구매 수가 가장 많은 상품
WITH d_tmp AS ( SELECT   d.department_id, d.department, p.product_id, p.product_name, SUM(pr.reordered) AS N_REORDERED,
                        DENSE_RANK() OVER(PARTITION BY department_id ORDER BY SUM(pr.reordered) DESC) AS RNK
                FROM    order_products__prior AS pr
                LEFT JOIN  products AS p
                ON pr.product_id = p.product_id
                LEFT JOIN departments AS d
                ON p.department_id = d.department_id
                GROUP BY d.department_id, d.department, p.product_id, p.product_name
) 
SELECT  *
FROM    d_tmp
WHERE   RNK = 1
;


# 구매자 분석
## 유저별 10분위 구하기
SELECT *,
        CASE WHEN RNK BETWEEN 1    AND 316  THEN 'Quantile_1'
             WHEN RNK BETWEEN 317  AND 632  THEN 'Quantile_2'
             WHEN RNK BETWEEN 633  AND 948  THEN 'Quantile_3'
             WHEN RNK BETWEEN 949  AND 1264 THEN 'Quantile_4'
             WHEN RNK BETWEEN 1265 AND 1580 THEN 'Quantile_5'
             WHEN RNK BETWEEN 1581 AND 1895 THEN 'Quantile_6'
             WHEN RNK BETWEEN 1896 AND 2211 THEN 'Quantile_7'
             WHEN RNK BETWEEN 2212 AND 2527 THEN 'Quantile_8'
             WHEN RNK BETWEEN 2528 AND 2843 THEN 'Quantile_9'
             WHEN RNK BETWEEN 2844 AND 3159 THEN 'Quantile_10'
             END AS quantile
FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY N_ORDERS DESC) AS RNK
    FROM (
        SELECT user_id, COUNT(DISTINCT ORDER_ID) AS N_ORDERS
        FROM orders
        GROUP BY 1
        ) AS A 
    ) AS AA
;
## 각 분위수의 주문 건수
WITH tmp AS (
    SELECT *,
        CASE WHEN RNK BETWEEN 1    AND 316  THEN 'Quantile_1'
             WHEN RNK BETWEEN 317  AND 632  THEN 'Quantile_2'
             WHEN RNK BETWEEN 633  AND 948  THEN 'Quantile_3'
             WHEN RNK BETWEEN 949  AND 1264 THEN 'Quantile_4'
             WHEN RNK BETWEEN 1265 AND 1580 THEN 'Quantile_5'
             WHEN RNK BETWEEN 1581 AND 1895 THEN 'Quantile_6'
             WHEN RNK BETWEEN 1896 AND 2211 THEN 'Quantile_7'
             WHEN RNK BETWEEN 2212 AND 2527 THEN 'Quantile_8'
             WHEN RNK BETWEEN 2528 AND 2843 THEN 'Quantile_9'
             WHEN RNK BETWEEN 2844 AND 3159 THEN 'Quantile_10'
             END AS quantile
    FROM (
        SELECT *, ROW_NUMBER() OVER (ORDER BY N_ORDERS DESC) AS RNK
        FROM (
            SELECT user_id, COUNT(DISTINCT ORDER_ID) AS N_ORDERS
            FROM orders
            GROUP BY 1
            ) AS A 
        ) AS AA  )

SELECT  quantile, SUM(N_ORDERS)
FROM    tmp
GROUP BY    quantile
;

## VIP 구매 비중
WITH tmp AS (
    SELECT *,
        CASE WHEN RNK BETWEEN 1    AND 316  THEN 'Quantile_1'
             WHEN RNK BETWEEN 317  AND 632  THEN 'Quantile_2'
             WHEN RNK BETWEEN 633  AND 948  THEN 'Quantile_3'
             WHEN RNK BETWEEN 949  AND 1264 THEN 'Quantile_4'
             WHEN RNK BETWEEN 1265 AND 1580 THEN 'Quantile_5'
             WHEN RNK BETWEEN 1581 AND 1895 THEN 'Quantile_6'
             WHEN RNK BETWEEN 1896 AND 2211 THEN 'Quantile_7'
             WHEN RNK BETWEEN 2212 AND 2527 THEN 'Quantile_8'
             WHEN RNK BETWEEN 2528 AND 2843 THEN 'Quantile_9'
             WHEN RNK BETWEEN 2844 AND 3159 THEN 'Quantile_10'
             END AS quantile
    FROM (
        SELECT *, ROW_NUMBER() OVER (ORDER BY N_ORDERS DESC) AS RNK
        FROM (
            SELECT user_id, COUNT(DISTINCT ORDER_ID) AS N_ORDERS
            FROM orders
            GROUP BY 1
            ) AS A 
        ) AS AA  )

SELECT  C.total AS TOTAL_ORDERS, B.sum_n AS VIP_ORDERS, B.sum_n/C.total AS VIP_ORDERS_RATIO
FROM    ( SELECT  quantile, SUM(N_ORDERS) AS sum_n
         FROM    tmp
         WHERE   quantile = "Quantile_1") AS B,
        ( SELECT SUM(N_ORDERS) AS total
          FROM   tmp ) AS C
;

# 상품 분석
## 재구매 비중이 높은 순서대로 상품을 정렬하라. 단, 주문 건수가 10건 이하인 제품은 제외한다.
WITH tmp AS ( SELECT  product_id, SUM(reordered) AS reorders, COUNT(DISTINCT order_id) AS N_ORDERS
             FROM    order_products__prior
             GROUP BY    product_id)  
             
SELECT  A.product_id, p.product_name, A.REORDER_RATE, A.N_ORDERS
FROM ( SELECT  product_id, reorders/N_ORDERS AS REORDER_RATE , N_ORDERS
        FROM    tmp
        WHERE   N_ORDERS > 10 ) AS A
LEFT JOIN products AS p
ON A.product_id = p.product_id
ORDER BY A.REORDER_RATE DESC
;


## 아래 주어진 시간대별로 segmentation 한 뒤,시간대별로 가장 많은 주문이 발생한 제품 TOP 5를 구하여라.
/*
    - 6~8시: 1_BREAKFAST
    - 11~13시: 2_LAUNCH
    - 18~20시: 3_DINNER
    - 나머지 시간대: 4_OTHER_TIME
*/

WITH T AS (
     SELECT  orders.*, pr.product_id,
            (CASE WHEN order_hour_of_day BETWEEN 6 AND 8 THEN  "1_BREAKFAST"
                 WHEN order_hour_of_day BETWEEN 11 AND 13 THEN  "2_LAUNCH"
                 WHEN order_hour_of_day BETWEEN 18 AND 20 THEN  "3_DINNER"
                 ELSE "4_OTHER_TIME"
                 END )AS TIME_SEGMENTATION
     FROM    orders,
            order_products__prior AS pr
     WHERE    orders.order_id = pr.order_id 
    )
    
SELECT ord.*, p.product_name
FROM    ( SELECT  TIME_SEGMENTATION, product_id, COUNT(order_id) AS N_ORDERS,
                  RANK() OVER(PARTITION BY TIME_SEGMENTATION ORDER BY COUNT(order_id) DESC)  AS RNK
          FROM    T
          GROUP BY    TIME_SEGMENTATION, product_id ) AS ord,
          products AS p
WHERE   ord.product_id = p.product_id
    AND RNK <= 5
ORDER BY    ord.TIME_SEGMENTATION, RNK 
;


/*SELECT  orders.*, pr.product_id, p.product_name,
            (CASE WHEN order_hour_of_day BETWEEN 6 AND 8 THEN  "1_BREAKFAST"
                 WHEN order_hour_of_day BETWEEN 11 AND 13 THEN  "2_LAUNCH"
                 WHEN order_hour_of_day BETWEEN 18 AND 20 THEN  "3_DINNER"
                 ELSE "4_OTHER_TIME"
                 END )AS TIME_SEGMENTATION
     FROM    orders,
            order_products__prior AS pr
     LEFT JOIN products AS p
     ON  pr.product_id = p.product_id
     WHERE    orders.order_id = pr.order_id 
 
    ;*/
    