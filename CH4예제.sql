/*
Ch04 
SQL 고급
*/
USE z06;

# Dual 테이블이란?       # 1행 1열의 가상의 테이블! 특정 테이블과 관련없을때 이용
SELECT *, 1.1
FROM Book; 

SELECT *, 1.1, ROUND(1.1)       # 반올림
FROM Book;

SELECT ROUND(1.1)
FROM DUAL;

SELECT ROUND(1.1);      # MySQL에서는 FROM DUAL을 빼도 실행이 된다!


# 내장함수
## 숫자함수 
SELECT ABS(-4.5);      -- 절대값
SELECT CEIL(4.1);      -- 올림   
SELECT FLOOR(4.1);     -- 내림  
SELECT ROUND(5.36);    -- 정수로 반올림
SELECT ROUND(5.36, 1); -- 소수점 첫재짜리까지 반올림  
SELECT LOG(10);        -- 자연로그
SELECT LOG(2,10);      -- 밑이 2인 로그   
SELECT POWER(2,3);     -- 2의 3제곱
SELECT SQRT(9);        -- 제곱근
SELECT SIGN(3.45);     -- 음수면 -1, 0이면 0, 양수면 1

## 숫자함수 참고
SELECT bin(2);      # 이진법으로 변환
SELECT HEX(10);     # 16진법 
SELECT OCT(8);      # 8진법


-- -78과 +78의 절대값을 구하시오
SELECT ABS(-78), ABS(+78);
-- 4.875를 소수 첫째 자리까지 반올림한 값을 구하시오
SELECT ROUND(4.875, 1);
-- 고객별 평균 주문 금액을 백원단위에서 반올림한 값을 구하시오
SELECT  custid, ROUND(AVG(saleprice), -3)       # 소수점이 0!
FROM     madang.Orders
GROUP BY custid
;

## 문자함수
SELECT CONCAT('마당', '서점', '본점');       # 여러 문자열 합치기
SELECT LOWER('MR. SCOTT');
SELECT UPPER('mr. scott');
SELECT LPAD('Page 1', 10, '*');          # 10칸 확보후 왼쪽에서 부터 해당 문자열을 채우고 빈 공간을 *로 채움
SELECT RPAD('abC', 5, '*');              # 5칸 확보후 오른쪽에서부터 해당 문자열을 채우고 빈 공간을 *로 채움
SELECT REPLACE('JACK & JUE', 'J', 'BL');    # 해당 문자열에서 J를 BL로 바꿈
SELECT SUBSTR('ABCDEFG', 3, 4);          # 해당 문자열의 3번째 부분부터 4개를 가져와라.
SELECT TRIM('  BROWNING  ');             # 양쪽의 빈칸을 모두 없앰
SELECT REPLACE( '   BROWING   ', ' ','');
SELECT TRIM(' ' FROM '  BROWNING  ');    # 위의 TRIM과 동일 
SELECT TRIM('=' FROM '==BROWNING==');    # 앞의 =를 해당 문자열에서 지움
SELECT LENGTH('MYSQL');                  # LENGTH는 해당 문자열의 바이트를 셈
SELECT LENGTH('마이에스큐엘');
SELECT CHAR_LENGTH('MYSQL');             # CHAR_LENGTH는 해당 문자열의 길이를 셈
SELECT CHAR_LENGTH('마이에스큐엘');

## 문자함수 참고
SELECT CHAR(77, 121, 83, 81, 76);       # 해당 숫자를 아스키코드로 읽음
SELECT ASCII('A');          # 문자열이 들어가도 괜찮아!! 단, 이때는 문자열에서 첫번째 있는 문자의 아스키코드만 출력!
SELECT CONCAT_WS(',', '1st', '2nd', '3rd');    -- with separator
SELECT LEFT('mysql', 2);        # 왼쪽에서 부터 2개 문자 추출
SELECT RIGHT('mysql',3);
SELECT LTRIM('    mysql    ');          # 왼쪽빈칸은 삭제
SELECT RTRIM('    mysql    ');          # 오른쪽 빈칸을 삭제

USE madang;
-- 도서제목에 축구가 포함된 도서제목에서 '축구'를 '농구'로 변경한 이름을 출력하세요
SELECT REPLACE(bookname, '축구', '농구')
FROM    Book
WHERE   bookname LIKE '%축구%'
;
-- 굿스포츠에서 출판한 도서의 제목과 제목의 글자 수를 출력하세요
SELECT  bookname, CHAR_LENGTH(bookname)
FROM    Book
WHERE   publisher='굿스포츠'
;
-- 마당서점의 고객 중에서 같은 성(姓)을 가진 사람이 몇 명이나 되는지 구하시오
SELECT  SUBSTR(name, 1, 1) AS '성' , COUNT(SUBSTR(name, 1, 1))       # 또는 COUNT(1) 해도 됨!
FROM    Customer
GROUP BY SUBSTR(name, 1, 1)
;

## 날짜&시간함수
SELECT '2019-02-14', ADDDATE('2019-02-14', INTERVAL 1 DAY);

### 문자열 => 날짜열로 바꾸기!        STR_TO_DATE(문자열, format)
SELECT STR_TO_DATE('2019-02-14', '%Y-%m-%d');
SELECT STR_TO_DATE('2019/02/14', '%Y/%m/%d');
SELECT STR_TO_DATE('20190214', '%Y%m%d');

### 날짜 => 문자열로 바꾸기!         DATE_FORMAT(date, 포맷)
SELECT DATE_FORMAT('2019-02-14', '%Y-%m-%d');
SELECT DATE_FORMAT('2019-02-14', '%Y/%m/%d');
SELECT DATE_FORMAT('2019-02-14', '%y/%m/%d');

### 날짜 연산
SELECT ADDDATE('2019-02-14', INTERVAL 10 DAY);
SELECT ADDDATE('2019-02-14', INTERVAL -10 DAY);
SELECT '2019-02-14' + INTERVAL 10 DAY;
SELECT '2019-02-14' - INTERVAL 10 DAY;

## 해당 날짜와 시간에서 각각 추출
SELECT DATE('2003-12-31 01:02:03');     
SELECT YEAR('2003-12-31 01:02:03');
SELECT MONTH('2003-12-31 01:02:03');
SELECT DAY('2003-12-31 01:02:03');
SELECT HOUR('2003-12-31 01:02:03');
SELECT MINUTE('2003-12-31 01:02:03');
SELECT SECOND('2003-12-31 01:02:03');

## 앞DATE에서 뒤DATE를 뺌.. 몇일이나 차이나냐를 볼때!
SELECT DATEDIFF('2019-02-14', '2019-02-04');  -- 10
SELECT DATEDIFF('2019-02-04', '2019-02-14');  -- -10
SELECT SYSDATE();
SELECT SYSDATE() + INTERVAL 9 HOUR;

## 날짜함수 포맷
###  SYSDATE(); 서버가 돌아가고 있는 서버의 시간 ... 보통 UTC기준
SELECT ADDDATE(SYSDATE(), INTERVAL 9 HOUR);

SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%w');        # 우리나라의 시간으로 보기위해 9시간 더해야지!!
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%W');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%a');        # 포맷에 따라 날짜 추출!!
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%d');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%D');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%j');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%h');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%H');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%i');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%m');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%M');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%b');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%s');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%y');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR), '%Y');
SELECT DATE_FORMAT((SYSDATE() + INTERVAL 9 HOUR),
    '오늘은 %Y년 %m월 %d일 %W이며 %Y년의 %j번째 날입니다.');

-- 마당서점은 주문일로부터 10일 후 매출을 확정한다. 각 주문의 확정일자를 구하시오.
SELECT orderdate AS 주문일자, 
       ADDDATE(orderdate, INTERVAL 10 DAY) AS 확정일자
FROM    Orders
;
-- 마당서점이 2014년 7월 7일에 주문받은 도서의 주문번호, 주문일, 고객번호, 도서번호를 보이시오. 단 주문일은 %Y-%m-%d형태로 표시한다.
SELECT  orderid, orderdate, custid, bookid
FROM    Orders
WHERE   orderdate = '2014-07-07'       # orderdate가 이미 date포맷이기 때문에 이걸 알아 들음!!
;
-- 단 주문일은 %Y년%m월%d일형태로 표시한다.
SELECT  orderid, orderdate,
        DATE_FORMAT(orderdate, '%Y년 %m월 %d일'),
        custid, bookid
FROM    Orders
WHERE   orderdate = '2014-07-07'
;
-- 현재 DBMS의 날짜, 시간, 요일을 확인하시오
SELECT  STSDATE(),
        DATE_FORMAT(SYSDATE(),'%m월 %d일'),
        DATE(SYSDATE()),
        TIME(SYSDATE()),
        DATE_FORMAT(SYSDATE(),'%W'), DATE_FORMAT(SYSDATE(),'%a')
;

# NULL값 처리
-- 아직 지정되지 않은 값.
-- 0, ''(빈문자), ' '(공백)과 다른 특별한 값
-- 비교연산이나 문자, 숫자함수 수행시 결과는 NULL로 나온
SELECT NULL;
SELECT NULL + 1;        # NULL은 특수함! 따라서 연산할 수 없음
SELECT CONCAT('문자', NULL);      # 결과 역시 NULL
SELECT NULL < 100;      # 애초에 비교대상이 아님!
SELECT NULL = 0;
SELECT NULL = NULL;      
SELECT NULL IS NULL;        # TRUE

SELECT 100 = 100;   # TRUE == 1
SELECT 1 = 100;     # FALSE == 0

-- 집계함수 사용시 NULL이 포함된 행 집계에서 빠진다.
USE madang;
SELECT *
FROM Customer;

SELECT COUNT(*), COUNT(name), COUNT(phone)      ## COUNT(*)는 전체 행의 수!!
FROM Customer;                  # NULL은 집계함수 사용시 아예 빠져버린다!

-- ISNULL, IS NOT NULL로 다뤄야 한다.
SELECT *
FROM Customer
WHERE phone IS NULL;        # WHERE phone = NULL 을 사용하면 안된다!!

SELECT *
FROM Customer
WHERE phone IS NOT NULL;

-- IFNULL로 처리한다.
SELECT custid, name, address, IFNULL(phone, '연락처 없음')   # NULL이 아니라면 앞의 값을, NULL이 라면 뒤의 값을 출력
FROM Customer;


# 변수
-- 고객 목록에서 고객번호, 이름, 전화번호를 앞의 두 명만 보이시오
SELECT  custid, name, phone
FROM    Customer
WHERE   custid < 3;         # 또는 LIMIT 2 단, 얘는 다 뽑은다음에 앞의 두개만 보여주는 것!
-- 일반적인 경우에는 custid를 쓸 수 있지만 정렬 기준이 달라지는 경우 쓸 수 없다!!!
SET @seq:=0;        # 변수 @seq를 0으로 초기화
SELECT  (@seq := @seq + 1 ) AS 순번,
        custid, name, phone
FROM    Customer
WHERE   @seq < 3
;
-- 변수 선언방식
SET @seq:=0;        # 변수 @seq를 0으로 초기화
SELECT  (@seq := @seq + 1 ) AS 순번,
        custid, name, phone
FROM    Customer
WHERE   @seq < 3
;

-- 판매건별로 누적매출을 구하시오.
SET @seq := 0;
SELECT  orderid, custid, bookid, saleprice, orderdate,
        (@seq := @seq + saleprice) AS 누적매출
FROM    Orders
;

# 부속질의
## SELECT 부속질의
-- 단일행+단일열 결과
SELECT 1;
SELECT SUM(saleprice) FROM Orders;

-- 마당서점의 고객별 판매액을 보이시오(고객이름과 고객별 판매액을 출력).
SELECT custid, SUM(saleprice),
        O.custid + 1,            # 연산이 가능하다면 서브쿼리도 쓸 수 있는 것
        ( SELECT name FROM Customer AS C WHERE C.custid = O.custid )
FROM Orders AS O
GROUP BY custid
;

-- Orders 테이블에 각 주문에 맞는 도서이름을 출력하세요

## FROM 부속질의
-- 고객번호가 2 이하인 고객의 판매액을 보이시오(고객이름과 고객별 판매액 출력).
SELECT C.name, O.saleprice     
FROM    Orders AS O,
        ( SELECT *
          FROM  Customer
          WHERE custid <= 2) AS C
WHERE   O.custid = C.custid
GROUP BY C.custid, C.name
;
## WHERE 부속질의
-- 평균 주문금액 이하의 주문에 대해서 주문번호와 금액을 보이시오
SELECT AVG(saleprice)
FROM    Orders
;
SELECT *
FROM Orders
WHERE saleprice <= (SELECT AVG(saleprice)
                    FROM    Orders)
;
-- 각 고객의 평균 주문금액보다 큰 금액의 주문 내역에 대해서 주문번호, 고객번호, 금액을 보이시오.
SELECT *
FROM Orders AS O,
     (SELECT custid, AVG(saleprice) AS avg_saleprice
      FROM  Orders
      GROUP BY custid) AS AA
WHERE   O.custid = AA.custid
    AND avg_saleprice < saleprice;
    
## WHERE절 서브쿼리 이용하기
SELECT *
FROM Orders AS O_1
WHERE saleprice > ( SELECT AVG(saleprice)
                    FROM Orders AS O_2
                    WHERE   O_1.custid = O_2.custid)   ## O_1에서 일치하는 애들만 가져온다!!
;
-- 대한민국에 거주하는 고객에게 판매한 도서의 총판매액을 구하시오.
SELECT SUM(saleprice)
FROM   Orders
WHERE   custid IN ( SELECT custid
                    FROM Customer
                    WHERE   address LIKE '%대한민국%')
;
SELECT custid
FROM Customer
WHERE   address LIKE '%대한민국%'
;
-- (ALL 사용하는 문제지만 ALL 사용하지않아도 해결됨) 3번 고객이 주문한 도서의 최고 금액보다 더 비싼 도서를 구입한 주문의 주문번호와 금액을 보이시오. 
-- 3번 고객이 주문한 도서의 최고 금액보다 더 비싼 도서를 구입한 주문의 주문번호와 금액을 보이시오.
## ALL 사용
SELECT *                ## ALL은 모든 데이터 하나하나씩 비교하는 것! 굳이 그럴필요 없고 시간낭비..
FROM Orders
WHERE saleprice > ALL (SELECT saleprice
                        FROM Orders
                        WHERE custid=3)
;
## ALL 미사용
SELECT *
FROM Orders
WHERE saleprice > (SELECT MAX(saleprice) FROM Orders WHERE custid=3)
;

-- (EXIST 활용하지 않아도 해결됨) 대한민국에 거주하는 고객에게 판매한 도서의 총 판매액을 구하시오.
SELECT *
FROM Orders AS OD
WHERE EXISTS (SELECT *
              FROM Customer AS CS
              WHERE address LIKE '%대한민국%'
                AND CS.custid = OD.custid)
;

## EXIST 미사용
SELECT *
FROM Orders AS OD
WHERE ( SELECT custid FROM   Customer WHERE address LIKE '%대한민국%' )
;

# 뷰
## CASE 문
SELECT  orderid, saleprice,
    CASE WHEN saleprice < 10000 THEN '저가'
         WHEN saleprice >= 10000 AND saleprice < 20000 THEN '증가'
         ELSE '고가' END
FROM    Orders
;
SELECT  orderdate, DATE_FORMAT(orderdate, '%a'),
        (CASE    DATE_FORMAT(orderdate, '%a')
            WHEN    'Sat' THEN '주말'
            WHEN    'Sun' THEN '주말'
            ELSE    '주중' END) week_or_weekend,
        saleprice
FROM Orders
;
-- 주중/주말별 평균 saleprice를 구하시오.
USE madang;
SELECT *
FROM ( SELECT  orderdate, DATE_FORMAT(orderdate, '%a'),
                (CASE    DATE_FORMAT(orderdate, '%a')
                    WHEN    'Sat' THEN '주말'
                    WHEN    'Sun' THEN '주말'
                    ELSE    '주중' END) AS week_or_weekend,
                saleprice
        FROM Orders )  AS A
GROUP BY week_or_weekend
;

SELECT *
FROM Orders;
-- IF(expr1, expr2, expr3)
## expr1이 참일 경우 expr2를 리턴, 거짓일 경우 expr3를 리턴
SELECT  bookname, price, IF(price < 10000, '만원 미만', '만원 이상')
FROM    Book
;

-- IFNULL(expr1, expr2)
## NOT NULL인 경우 expr1을 리턴, NULL인 경우 expr2를 리턴
SELECT  name, phone, IFNULL(phone, '정보없음')
FROM    Customer
;

## LIKE 매번 쓰지 않는 대신에

CREATE VIEW VW_BOOK
AS  SELECT * 
    FROM   Book
    WHERE   bookname    LIKE '%축구%'
        AND price >= 10000
;
SELECT * FROM VW_BOOK

## 이렇게 보고싶은 것을 뷰로 가상의 테이블로 하여서 한번에 보는 방법!!!


-- Book 테이블에서 ‘축구’라는 문구가 포함된 자료만 보여주는 뷰
-- 주소에 '대한민국'을 포함하는 고객들로 구성된 뷰를 만들고 조회하시오. 뷰의 이름은 vw_Customer로 설정하시오.
-- Orders 테이블에 고객이름과 도서이름을 바로 확인할 수 있는 뷰를 생성한 후, ‘김연아’ 고객이 구입한 도서의 주문번호, 도서이름, 주문액을 보이시오.

## 뷰의 수정
-- vw_Customer는 주소가 대한민국인 고객을 보여준다. 이 뷰를 영국을 주소로 가진 고객으로 변경하시오. phone 속성은 필요 없으므로 포함시키지 마시오.

## 뷰의 삭제
-- 뷰 vw_Customer를 삭제하시오.

# 인덱스
-- 인덱스를 직접 만들 필요는 없지만 개념은 이해해야 합니다.
## 인덱스가 있으면 조회 시간이 단축된다!!
## 문법대로 한다고 다 빨리지는 것은 아님..
## 어떤 컬럼을 건들이느냐에 따라 다름..
