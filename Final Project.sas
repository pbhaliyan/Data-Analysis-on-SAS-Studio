*Part 1;

Proc import datafile='/home/u59416513/ProgrammingForAnalytics/Final Project/ProductSheet.xlsx'
out= work.Product
dbms=xlsx replace;
getnames=yes;
run;

Proc import datafile='/home/u59416513/ProgrammingForAnalytics/Final Project/SalesOrderDetail.xlsx'
out= work.SalesOrderDetail
dbms=xlsx replace;
getnames=yes;
run;

proc print data = work.SalesOrderDetail(obs=5);
run;

*Part 2_Product Clean;
Data Product_Clean ;
set Product (keep=ProductID Name ProductNumber Color ListPrice);
*ListPriceNum= input;
if color ='' then color ='NA';
new_ListPrice=input(ListPrice,8.2);
rename ListPrice=ListPrice_Char;
rename new_ListPrice=ListPrice;
run;

data Product_Clean;
set Product_Clean (drop=ListPrice_Char);
format ListPrice Dollar8.2;
title 'Cleaned Data of Prodcut Sheet';
run;

*Part 2_SalesOrderDetails;
Data SalesOrderDetail_Clean dataset;
set SalesOrderDetail(keep= SalesOrderID SalesOrderDetailID OrderQty ProductID UnitPrice LineTotal ModifiedDate);

new_ModifiedDate=put(ModifiedDate, ddmmyy10.);
rename ModifiedDate=ModifiedDate_Char;
rename new_ModifiedDate=ModifiedDate;

new_UnitPrice=input(UnitPrice,8.2);
rename UnitPrice=UnitPrice_Char;
rename new_UnitPrice=UnitPrice;

new_LineTotal=input(LineTotal,8.2);
rename LineTotal=LineTotal_Char;
rename new_LineTotal=LineTotal;

new_OrderQty=input(OrderQty,10.);
rename OrderQty=OrderQty_Char;
rename new_OrderQty=OrderQty;
run;


Data salesorderdetail_clean;
Set salesorderdetail_clean;
where '2013-01-01'<= ModifiedDate <= '2014-12-31';
format ModifiedDate2 date9.;
ModifiedDate2 = input(ModifiedDate, anydtdte10.);
rename ModifiedDate=ModifiedDate_Char1;
rename ModifiedDate2=ModifiedDate;
run;


Data SalesOrderDetail_Clean;
set SalesOrderDetail_Clean(Drop= UnitPrice_Char LineTotal_Char OrderQty_Char ModifiedDate_Char ModifiedDate_Char1);
format ModifiedDate mmddyy10.
UnitPrice Dollar8.2
LineTotal Dollar8.2;
run;

*Part 3;
Proc sort data= Product_Clean;
by ProductID;
run;

Proc sort data= salesorderdetail_clean;
by ProductID;
run;

Data SalesDetails;
merge salesorderdetail_clean(in=C1) Product_Clean(in=C2);
by ProductID;
if C1= 1 and C2= 1; 
run;

Data SalesDetails;
set SalesDetails(drop=SalesOrderID SalesOrderDetailID ProductNumber ListPrice);
run;

Proc print data= salesdetails(obs=10);
run;



Data SalesAnalysis;
Set SalesDetails;
by ProductID;
if first.ProductID then SubTotal=LineTotal;
else SubTotal+LineTotal;
if last.ProductID;
format subtotal dollar10.2;
run;
Title "SalesAnalysis with subtotal value";
Proc print data= salesanalysis(obs=10);
run;


*Part 4;
*Data Analysis;
Data salesAnalysis1;
set SalesDetails;
by ProductID;
if first.ProductID then QtyTotal=OrderQty;
else QtyTotal+OrderQty;
if last.ProductID;
TotSale=UnitPrice*QtyTotal;
format Totsale dollar15.2;
run;

*Query 1;
title "number of red helmet sold in 2013 and 2014 from salesdetails dataset";
proc sql;
    select name,
        sum(OrderQty) as Number_of_Red_helmet
    from SalesAnalysis
    Where color= 'Red' and name= 'Sport-100 Helmet, Red' and (year(modifiedDate) in (2013, 2014))
    group by name;
quit;

title "number of red helmet sold in 2013 and 2014";


proc print data= salesAnalysis1;
var name qtyTotal;
where name= 'Sport-100 Helmet, Red'and (year(modifiedDate) in (2013, 2014)) ;
run;


*Query 2;
title "number of multicolor items sold in 2013 and 2014";

proc sql;
    select name, 
        sum(OrderQty) as Number_of_items_sold
    from SalesAnalysis
    Where color= 'Multi' and (year(modifiedDate) in (2013, 2014))
    group by name;
quit;


title "number of multicolor items sold in 2013 and 2014";
proc print data= salesAnalysis1;
var name qtyTotal;
where (year(modifiedDate) in (2013, 2014)) and color='Multi';
run;





*Query 3-Part 4 Data Analysis;
title "Combined Sales total of all the helmets sold in 2013 and 2014";
proc print data= salesAnalysis1;
var name totsale;
sum totsale;
where name like '%Helmet%' and (year(modifiedDate) in (2013, 2014));
format totsale dollar10.2;
run;


title "Combined Sales total of all the helmets sold in 2013 and 2014";
proc sql;
   create table helmet as 
   select 
   	year(modifiedDate) as Year,
   	sum(totsale) as totalsales
    from SalesAnalysis1
    Where name like '%Helmet%' and (year(modifiedDate) in (2013, 2014))
    group by Year;
quit;

Proc print data=helmet;
format totalsales dollar15.2;
run;

*Query 4;


title "number of yellow touring 1000 sold in 2013 and 2014";
proc print data= salesAnalysis1;
var name qtytotal;
where color='Yellow' and name like '%Touring-100%' and (year(modifiedDate) in (2013, 2014));
run;


*Query 5;
title "Total Sales in 2013 and 2014";
proc print data= salesAnalysis1;
var name;
sum totsale;
where (year(modifiedDate) in (2013, 2014));
format totsale dollar15.2;
run;

Title "Total Sales in 2013 and 2014";
proc sql;
   create table Sales as 
   select 
   	year(modifiedDate) as Year,
   	sum(QtyTotal*UnitPrice) as Total_Sales
    from SalesAnalysis1
    group by Year;
quit;

Proc print data=Sales;
format Total_Sales dollar15.2;
run;



