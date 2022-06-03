-- Views for dimension tables
USE SCHEMA IMT577_DW_NICHOLAS_FANG.PUBLIC;

CREATE OR REPLACE SECURE VIEW VIEW_DIMSTORE
    AS
        SELECT DISTINCT
             DIMSTOREID
            ,DIMLOCATIONID
            ,SOURCESTOREID
            ,STORENUMBER
            ,STOREMANAGER
    FROM DIM_STORE

CREATE OR REPLACE SECURE VIEW VIEW_DIMRESELLER
    AS
        SELECT DISTINCT
             DIMRESELLERID
            ,DIMLOCATIONID
            ,SOURCERESELLERID
            ,RESELLERNAME
            ,CONTACTNAME 
            ,PHONENUMBER 
            ,EMAILADDRESS
    FROM DIM_RESELLER

CREATE OR REPLACE SECURE VIEW VIEW_DIMCUSTOMER
    AS
        SELECT DISTINCT
             DIMCUSTOMERID
            ,DIMLOCATIONID 
            ,SOURCECUSTOMERID
            ,FULLNAME
            ,FIRSTNAME
            ,LASTNAME
            ,GENDER
            ,EMAILADDRESS
            ,PHONENUMBER
FROM DIM_CUSTOMER

CREATE OR REPLACE SECURE VIEW VIEW_DIMLOCATION
    AS
    SELECT DISTINCT
        DIMLOCATIONID
        ,SOURCELOCATIONID
        ,POSTALCODE
        ,ADDRESS
        ,CITY
        ,REGION
        ,COUNTRY
FROM DIM_LOCATION

CREATE OR REPLACE SECURE VIEW VIEW_DIMCHANNEL
    AS
        SELECT DISTINCT
        DIMCHANNELID
        ,SOURCECHANNELID
        ,SOURCECHANNELCATEGORYID
        ,CHANNELNAME
        ,CHANNELCATEGORY
FROM DIM_CHANNEL

CREATE OR REPLACE SECURE VIEW VIEW_DIMPRODUCT
    AS
       SELECT DISTINCT
            DIMPRODUCTID
            ,SOURCEPRODUCTID 
            ,SOURCEPRODUCTTYPEID
            ,SOURCEPRODUCTCATEGORYID
            ,PRODUCTNAME
            ,PRODUCTTYPE
            ,PRODUCTCATEGORY
            ,PRODUCTRETAILPRICE
            ,PRODUCTWHOLESALEPRICE
            ,PRODUCTCOST
            ,PRODUCTRETAILPROFIT
            ,PRODUCTWHOLESALEUNITPROFIT
            ,PRODUCTPROFITMARGINUNITPERCENT
            
    FROM DIM_PRODUCT

--Views for fact tables
CREATE OR REPLACE SECURE VIEW VIEW_FACTSALESACTUAL
    AS
        SELECT DISTINCT
            DIMPRODUCTID
           ,DIMSTOREID
           ,DIMRESELLERID 
           ,DIMCUSTOMERID 
           ,DIMCHANNELID 
           ,DIMSALESDATEID
           ,DIMLOCATIONID 
           ,SOURCESALESHEADERID
           ,SOURCESALESDETAILID
           ,SALESAMOUNT
           ,SALESQUANTITY
           ,SALESUNITPRICE
           ,SALESEXTENDEDCOST
           ,SALESTOTALPROFIT
   FROM FACT_SALESACTUAL

CREATE OR REPLACE SECURE VIEW VIEW_FACTPRODUCTSALESTARGET
    AS
        SELECT DISTINCT
            DIMPRODUCTID
           ,DIMTARGETDATEID
	       ,PRODUCTTARGETSALESQUANTITY
           
FROM FACT_PRODUCTSALESTARGET

CREATE OR REPLACE SECURE VIEW VIEW_FACTSRCSALESTARGET
    AS
        SELECT DISTINCT
            DIMSTOREID
           ,DIMRESELLERID
           ,DIMCHANNELID
           ,DIMTARGETDATEID
	       ,SALESTARGETAMOUNT
FROM FACT_SRCSALESTARGET

--Assessment of store 5 and 8's sales

---1. What are the overall sales amounts (q*p) of stores 5 and 8
--DAILY PRODUCT SALES
CREATE OR REPLACE SECURE VIEW VIEW_ACTUAL_SALES_DETAIL
    AS
        SELECT DISTINCT
        fsa.salesamount
        ,s.storenumber
        ,d.year  
From fact_salesactual as fsa
join dim_store s on fsa.dimstoreid = s.dimstoreid
join dim_date d on fsa.dimsalesdateid = d.date_pkey
WHERE (s.STORENUMBER = 'Store Number 5' OR s.STORENUMBER = 'Store Number 8')
GROUP BY s.STORENUMBER, d.YEAR, fsa.salesamount

CREATE OR REPLACE SECURE VIEW VIEW_PRODUCT_SALES_DAILY
    AS
        SELECT DISTINCT
        S.SOURCESTOREID
        ,S.STORENUMBER
        ,P.SOURCEPRODUCTID
        ,FSA.SALESQUANTITY
        ,FSA.SALESUNITPRICE
        ,FSA.SALESAMOUNT
        ,FSA.SALESTOTALPROFIT
        ,D.DATE
    
FROM DIM_STORE S
JOIN FACT_SALESACTUAL FSA ON FSA.DIMSTOREID = S.DIMSTOREID
JOIN DIM_PRODUCT P ON P.DIMPRODUCTID = FSA.DIMPRODUCTID
JOIN DIM_DATE D ON FSA.DIMSALESDATEID = D.DATE_PKEY 
WHERE STORENUMBER IN ('Store Number 5', 'Store Number 8')

Select * from  VIEW_PRODUCT_SALES_DAILY
SELECT TOP 10 * FROM FACT_SALESACTUAL WHERE DIMSALESDATEID != -1
SELECT TOP 10 * FROM DIM_DATE WHERE DATE_PKEY = -1
SELECT * FROM DIM_STORE
SELECT TOP 20 * FROM STAGE_SALESHEADER WHERE DATE != '1/3/13'


--YEARLY PRODUCT SALES
CREATE OR REPLACE SECURE VIEW VIEW_PRODUCT_SALES_YEARLY
    AS
        SELECT DISTINCT
        S.SOURCESTOREID
        ,S.STORENUMBER
        ,P.SOURCEPRODUCTID
        ,D.YEAR
        ,SUM(FSA.SALESAMOUNT) AS SALESAMOUNT
        ,SUM(FSA.SALESTOTALPROFIT) AS SALESTOTALPROFIT
    
FROM DIM_STORE S
JOIN FACT_SALESACTUAL FSA ON FSA.DIMSTOREID = S.DIMSTOREID
JOIN DIM_PRODUCT P ON P.DIMPRODUCTID = FSA.DIMPRODUCTID
JOIN DIM_DATE D ON FSA.DIMSALESDATEID = D.DATE_PKEY 
WHERE STORENUMBER IN ('Store Number 5', 'Store Number 8')
GROUP BY S.SOURCESTOREID, S.STORENUMBER, P.SOURCEPRODUCTID, D.YEAR 

--How are they performing compared to target? Will they meet their 2014 target?
--TARGET YEARLY SALES
CREATE OR REPLACE SECURE VIEW VIEW_TARGET_YEARLY_SALES
    AS
        SELECT DISTINCT
        S.STORENUMBER
        ,D.YEAR
        ,SUM(FST.SALESTARGETAMOUNT) AS SALESTARGETAMOUNT
FROM FACT_SRCSALESTARGET FST
JOIN DIM_STORE S ON S.DIMSTOREID = FST.DIMSTOREID
JOIN DIM_DATE D ON FST.DIMTARGETDATEID = D.DATE_PKEY
WHERE STORENUMBER IN ('Store Number 5', 'Store Number 8')
GROUP BY S.STORENUMBER, D.YEAR

--TARGET YEARLY SALES VS ACTUAL SALES AMOUNT
CREATE OR REPLACE SECURE VIEW VIEW_DAILY_SALESTARGET_VS_SALESAMOUNT
    AS
        SELECT DISTINCT
             S.STORENUMBER
            ,D.DATE
            ,FST.SALESTARGETAMOUNT AS DAILYSALESTARGETAMOUNT
            ,FSA.SALESAMOUNT AS DAILYSALESAMOUNT 
            
FROM FACT_SRCSALESTARGET FST
JOIN DIM_STORE S ON S.DIMSTOREID = FST.DIMSTOREID
JOIN DIM_DATE D ON D.DATE_PKEY = FST.DIMTARGETDATEID
JOIN FACT_SALESACTUAL FSA ON FSA.DIMSTOREID = FST.DIMSTOREID 
WHERE STORENUMBER IN ('Store Number 5', 'Store Number 8')

-- 3. Assess product sales by day of the week at stores 5 and 8. What can we learn about sales trends?
-- VIEW SALES BY DAY OF WEEK 
CREATE OR REPLACE SECURE VIEW VIEW_SALES_BY_DAYOFWEEK
    AS
        SELECT DISTINCT
            FSA.DIMSTOREID
            ,S.STORENUMBER
            ,P.PRODUCTNAME
            ,P.PRODUCTCATEGORY
            ,D.DAY_NUM_IN_WEEK
            ,D.DAY_NAME
            ,D.Year
            ,sum(FSA.SALESAMOUNT) as SALESAMOUNT
FROM FACT_SALESACTUAL AS FSA
JOIN DIM_STORE AS S ON FSA.DIMSTOREID = S.DIMSTOREID
JOIN DIM_PRODUCT AS P ON FSA.DIMPRODUCTID = P.DIMPRODUCTID
JOIN DIM_DATE D ON FSA.DIMSALESDATEID = D.DATE_PKEY  
WHERE S.STORENUMBER in ('Store Number 5', 'Store Number 8')
GROUP BY FSA.DIMSTOREID, S.STORENUMBER, P.PRODUCTNAME, P.PRODUCTCATEGORY, D.DAY_NUM_IN_WEEK, D.DAY_NAME

-- 4. Compare the performance of all stores located in states that have more than one store to all stores that are the only store in the state. 
-- What can we learn about having more than one store in a state?
-- LOCATION METRICS
CREATE OR REPLACE SECURE VIEW VIEW_LOCATION_METRICS
    AS
        SELECT DISTINCT
        COUNT(L.*) AS NUM_LOCATIONS
        ,L.REGION AS STATENAME
FROM DIM_LOCATION AS L
GROUP BY STATENAME

-- SALES BY STATE
CREATE OR REPLACE SECURE VIEW VIEW_SALES_BY_STATE
    AS 
        SELECT DISTINCT
        L.CITY
        ,VLM.STATENAME
        ,VLM.NUM_LOCATIONS
        ,SUM(FSA.SALESAMOUNT) as SALESAMOUNT
        ,SUM(FSA.SALESTOTALPROFIT) AS SALESTOTALPROFIT
        ,D.YEAR
FROM FACT_SALESACTUAL AS FSA
JOIN DIM_LOCATION AS L ON L.DIMLOCATIONID = FSA.DIMLOCATIONID
JOIN VIEW_LOCATION_METRICS AS VLM ON VLM.STATENAME = L.REGION
JOIN DIM_DATE D ON FSA.DIMSALESDATEID = D.DATE_PKEY 
GROUP BY L.CITY, VLM.STATENAME, VLM.NUM_LOCATIONS, D.YEAR

--VIEW PRODUCT SALES DETAIL 
CREATE OR REPLACE SECURE VIEW VIEW_PRODUCT_SALES_DETAIL
    AS
        SELECT DISTINCT
             P.PRODUCTNAME
            ,P.PRODUCTTYPE
            ,P.PRODUCTCATEGORY
            ,P.PRODUCTPROFITMARGINUNITPERCENT
            ,SD.SALESQUANTITY
            ,SD.SALESAMOUNT
            ,PST.PRODUCTTARGETSALESQUANTITY
            ,ROUND(PST.PRODUCTTARGETSALESQUANTITY * P.PRODUCTRETAILPRICE, 2) AS PRODUCTTARGETSALESAMOUNT
            ,D.YEAR
            ,S.STORENUMBER
FROM DIM_PRODUCT P 
JOIN STAGE_SALESDETAIL SD ON SD.PRODUCTID = P.SOURCEPRODUCTID
JOIN FACT_PRODUCTSALESTARGET PST ON PST.DIMPRODUCTID = P.DIMPRODUCTID
Join FACT_SALESACTUAL FSA ON FSA.DIMPRODUCTID = P.DIMPRODUCTID
JOIN DIM_DATE D ON PST.DIMTARGETDATEID = D.DATE_PKEY
JOIN DIM_STORE S ON FSA.DIMLOCATIONID = S.DIMLOCATIONID
WHERE (S.STORENUMBER = 'Store Number 5' OR S.STORENUMBER = 'Store Number 8') 
    AND (P.PRODUCTTYPE = 'Men''s Casual' OR P.PRODUCTTYPE ='Women''s Casual');
