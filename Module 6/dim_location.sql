--Create Table
create or replace table IMT577_DW_NICHOLAS_FANG.PUBLIC.DIM_LOCATION (
    DIMLOCATIONID               INT IDENTITY(1,1) CONSTRAINT PK_DIMLOCATIONID PRIMARY KEY NOT NULL, 
    SOURCELOCATIONID            INT IDENTITY(1,1) NOT NULL,
    POSTALCODE                  VARCHAR(255),
    ADDRESS                     VARCHAR(255),
    CITY                        VARCHAR(255),
    REGION                      VARCHAR(255),
    COUNTRY                     VARCHAR(255)
);

--Load unknown
INSERT INTO DIM_LOCATION (
    DIMLOCATIONID,
    SOURCELOCATIONID,
    POSTALCODE,
    ADDRESS,
    CITY,
    REGION,
    COUNTRY
)
VALUES(
    -2,
    -2,
    'NA',
    'NA',
    'NA',
    'NA',
    'NA'
);

--Load data
INSERT INTO DIM_LOCATION (
    --DIMLOCATIONID,
    --SOURCELOCATIONID,
    POSTALCODE,
    ADDRESS,
    CITY,
    REGION,
    COUNTRY
)
SELECT * FROM (
  SELECT
    --{{ dbt_utils.surrogate_key(['ADDRESS', 'POSTALCODE']) }} AS SOURCELOCATIONID
    --'1',
    --'1',
    c.POSTALCODE,    
    c.ADDRESS,
    c.CITY,
    c.STATEPROVINCE AS REGION,
    c.COUNTRY
  FROM STAGE_CUSTOMER AS c
) AS customer_locations
union
SELECT * FROM (
  select
    --{{ dbt_utils.surrogate_key(['ADDRESS', 'POSTALCODE']) }} as ID,
    --'1',
    --'1',
    r.POSTALCODE,    
    r.ADDRESS,
    r.CITY,
    r.STATEPROVINCE AS REGION,
    r.COUNTRY
  FROM STAGE_RESELLER AS r
) AS reseller_locations
union
SELECT * FROM (
  SELECT
    --{{ dbt_utils.surrogate_key(['ADDRESS', 'POSTALCODE']) }} as ID,
    --'1',
    --'1',
    s.POSTALCODE,
    s.ADDRESS,
    s.CITY,
    s.STATEPROVINCE AS REGION,
    s.COUNTRY
  FROM STAGE_STORE AS s
) AS store_locations
