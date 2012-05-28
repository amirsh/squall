#TPCH8:ver1.0

SELECT N2.NAME, EXTRACT_YEAR(ORDERS.ORDERDATE), SUM(LINEITEM.EXTENDEDPRICE*(1.0-LINEITEM.DISCOUNT)) FROM PART
inner join LINEITEM on PART.PARTKEY = LINEITEM.PARTKEY
inner join SUPPLIER on SUPPLIER.SUPPKEY = LINEITEM.SUPPKEY
inner join NATION N2 on SUPPLIER.NATIONKEY = N2.NATIONKEY
inner join ORDERS on LINEITEM.ORDERKEY = ORDERS.ORDERKEY
inner join CUSTOMER on ORDERS.CUSTKEY = CUSTOMER.CUSTKEY
inner join NATION N1 on CUSTOMER.NATIONKEY = N1.NATIONKEY
inner join REGION on N1.REGIONKEY = REGION.REGIONKEY
WHERE  REGION.NAME = 'AMERICA' AND PART.TYPE = 'ECONOMY ANODIZED STEEL' AND
ORDERS.ORDERDATE >= {d '1995-01-01'} AND ORDERS.ORDERDATE <= {d '1996-12-31'}
GROUP BY N2.NAME, ORDERS.ORDERDATE
