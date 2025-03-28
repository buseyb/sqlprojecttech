
--1)Northwind veritabanında toplam kaç tablo vardır? Bu tabloların isimlerini listeleyiniz.

 SELECT COUNT(*) AS TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
 SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

--2)Her sipariş (Orders) için, Şirket adı (CompanyName), çalışan adı (Employee Full Name), sipariş tarihi ve
--gönderici şirketin adı (Shipper) ile birlikte bir liste çıkarın.

 select c.CompanyName,e.FirstName,e.FirstName,o.OrderDate,s.CompanyName from Orders as o 
 join Employees as e on o.EmployeeID=e.EmployeeID
 join Shippers as s on o.ShipVia=s.ShipperID
 join Customers as c on o.CustomerID=c.CustomerID;


--3)Tüm siparişlerin toplam tutarını bulun. (Order Details tablosundaki Quantity UnitPrice üzerinden hesaplayınız)

 select * from nortwind.dbo.[Order Details]
 select SUM(od.UnitPrice*od.Quantity) 'Toplam Sipariş Tutarı' from nortwind.dbo.[Order Details] as od

--4) Hangi ülkeden kaç müşteri vardır?

 select cus.Country, count(cus.CustomerID) 'Müşteri Sayısı' from nortwind.dbo.Customers as cus group by cus.Country

--5)En pahalı ürünün adını ve fiyatını listeleyiniz

 select p.ProductName, p.UnitPrice  from nortwind.dbo.products as p where p.UnitPrice = (select max(p.UnitPrice) from nortwind.dbo.Products as p)

--6) Çalışan başına düşen sipariş sayısını gösteren bir liste çıkarınız.

 select e.EmployeeID,e.FirstName,e.LastName,COUNT(o.orderID) 'Sipariş Sayısı' from Employees as e 
 join orders as o on e.EmployeeID=o.EmployeeID group by e.EmployeeID,e.FirstName,e.LastName ;

--7)1997 yılında verilen siparişleri listeleyin

 select * from nortwind.dbo.Orders as o where DATENAME(year, o.OrderDate) = 1997

--8) Ürünleri fiyat aralıklarına göre kategorilere ayırarak listeleyin: 020 → Ucuz, 2050 → Orta, 50+ → Pahalı.

select case 
 when p.UnitPrice between 0 and 20 then 'Ucuz'
 when p.UnitPrice between 20 and 50 then 'Orta'
 when p.UnitPrice > 50 then 'Pahalı' end as 'Fiyat Kategorileri'
 from nortwind.dbo.Products as p 

--9)En çok sipariş verilen ürünün adını ve sipariş adedini (adet bazında) bulun.

select top 1 p.ProductName, sum(od.Quantity) 'Toplam Sipariş Adedi' from [Order Details] as od join Products as p on od.ProductID=p.ProductID group by p.ProductName 
 
--10)Ürünler ve kategoriler bilgilerini birleştiren bir görünüm (view) oluşturun.

 SELECT HAS_PERMS_BY_NAME('dbo.vw_ProductsWithCategories', 'OBJECT', 'ALTER');
 Create View UrunlerveKategorileri As
 Select p.ProductID,p.ProductName,c.CategoryID,c.CategoryName from nortwind.dbo.Products as p join nortwind.dbo.Categories as c on p.CategoryID=c.CategoryID;
 select * from UrunlerveKategorileri

--11)Ürün silindiğinde log tablosuna kayıt yapan bir trigger yazınız.

--12)Belirli bir ülkeye ait müşterileri listeleyen bir stored procedure yazınız.

 create procedure UlkelereGoreMusteri
 @ulke nvarchar(20)
 as
 begin
 select c.CustomerID,c.ContactName,c.Country from Customers as c 
 where c.Country=@ulke order by c.CompanyName
 end
 exec UlkelereGoreMusteri 'France'; 

--13)Tüm ürünlerin tedarikçileriyle (suppliers) birlikte listesini yapın. Tedarikçisi olmayan ürünler de listelensin.

 select p.ProductID,p.ProductName,s.SupplierID,s.CompanyName from nortwind.dbo.Products as p 
 left join nortwind.dbo.Suppliers as s on p.SupplierID=s.SupplierID

--14)Fiyatı ortalama fiyatın üzerinde olan ürünleri listeleyin.

 select p.ProductID,p.ProductName,p.UnitPrice from Products as p where p.UnitPrice > (select AVG(p.UnitPrice) from Products as p)

--15)Sipariş detaylarına göre en çok ürün satan çalışan kimdir?

 select top 1 e.EmployeeID, e.FirstName, e.LastName, SUM(od.Quantity) 'Toplam Satılan Ürün' from Employees as e 
 join Orders as o on e.EmployeeID=o.EmployeeID
 join [Order Details] as od on o.OrderID=o.OrderID
 group by e.EmployeeID, e.FirstName, e.LastName

--16)Stok miktarı 10’un altında olan ürünleri listeleyiniz.
 
 select ProductID,ProductName, UnitsInStock from Products where UnitsInStock<10

--17)Her müşteri şirketinin yaptığı sipariş sayısını ve toplam harcamasını bulun

 select c.CustomerID,c.ContactName,c.CompanyName, COUNT(o.OrderID) 'Sipariş Sayısı', SUM(od.UnitPrice*od.Quantity) 'Toplam Harcama' from Customers as c join orders as o on c.CustomerID=o.CustomerID
 join [Order Details] as od on o.OrderID=od.OrderID group by c.CustomerID,c.ContactName, c.CompanyName

--18) Hangi ülkede en fazla müşteri var?
 select top 1 c.Country, COUNT(c.CustomerID) MusteriSayısı from customers as c group by c.Country order by MusteriSayısı desc

--19) Siparişlerde kaç farklı ürün olduğu bilgisini listeleyin.

 select COUNT (distinct od.productID) FarklıUrunSayısı from [Order Details] as od;
  
--20) Her kategoriye göre ortalama ürün fiyatını bulun.
 select c.CategoryID,c.CategoryName, AVG(p.UnitPrice) Ortalama from Products as p join Categories as c on p.CategoryID=c.CategoryID group by c.CategoryID,c.CategoryName

--21)Siparişleri ay ay gruplayarak kaç sipariş olduğunu listeleyin.
 select DATENAME(month,OrderDate) Ay, COUNT(*) 'Sipariş Sayısı' from Orders group by DATENAME(month,OrderDate)

--22)Her çalışanın ilgilendiği müşteri sayısını listeleyin.

 select o.EmployeeID,e.FirstName,e.LastName, COUNT(distinct o.CustomerID) 'Müşteri Sayısı' from Orders o join Employees e on o.EmployeeID=e.EmployeeID group by o.EmployeeID,e.FirstName,e.LastName

--23) Hiç siparişi olmayan müşterileri listeleyin.

 select cus.CustomerID,cus.ContactName from Customers cus left join orders ord on cus.CustomerID=ord.CustomerID 
 where ord.CustomerID IS NULL;

--24) Nakliye maliyetine göre en pahalı 5 siparişi listeleyin.
 Select Top 5 * from Orders order by Freight desc;

