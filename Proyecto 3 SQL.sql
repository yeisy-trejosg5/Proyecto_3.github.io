--- Seleccionar todas las líneas y todas columnas de una tabla
	SELECT * FROM dbo.Orders ; 

---Seleccionar columnas OrderID y ShipCity
	SELECT OrderID, ShipCity FROM dbo.Orders ; 
	SELECT Distinct ShipCity FROM dbo.Orders ; 

---Seleccionar solo 10 lineas de OrderID y ShipCity
	SELECT TOP 10 OrderID, ShipCity FROM dbo.Orders ; 

---Seleccionar solo 10 de todas las columnas
	SELECT TOP 10 * FROM dbo.Orders ; 

---Orden descendente (de mayor a menor)---
	SELECT TOP 25 * FROM dbo.Orders
	ORDER BY 1 desc

---Orden descendente de la columna 4: OrderDate
	SELECT TOP 25 * FROM dbo.Orders
	ORDER BY 4 desc

---Máximos y mínimos  / Fechas de primera y ultima órden
	SELECT MAX(OrderDate) FROM dbo.Orders
	SELECT MIN(OrderDate) FROM dbo.Orders

--Cambiar nombres de columas que salen sin nombre
	SELECT MAX(OrderDate) AS MaxOrderDate FROM dbo.Orders
	SELECT MIN(OrderDate) AS MinOrderDate FROM dbo.Orders

---Cantidad de ordenes de un país en específico
	SELECT * FROM dbo.Orders
	WHERE ShipCountry = 'Brazil'
	
	SELECT * FROM dbo.Orders
	WHERE ShipCountry = 'USA'

-----Años en tabla de ordenes
	Select Distinct Year(OrderDate)
	FROM [NORTHWND].[dbo].[Orders] 

---Cantidad de ordenes que no sean de una ciudad en específico
	SELECT * FROM dbo.Orders
	WHERE ShipCity < > 'Rio de Janeiro'

---Consultas de Diferentes tablas: Ordenes asociadas al número de empleado 
	SELECT * FROM [NORTHWND].[dbo].[Employees]
	WHERE EmployeeID = '2'

	SELECT * FROM [NORTHWND].[dbo].[Orders]
	WHERE EmployeeID = '2'

---Consultas enlazadas a ordenes/empleado/cliente
	SELECT * FROM [NORTHWND].[dbo].[Orders]
	WHERE OrderID = '10265'
	
	SELECT * FROM [NORTHWND].[dbo].[Employees]
	WHERE EmployeeID = '2'

	SELECT * FROM dbo.Customers
	WHERE CustomerID = 'BLONP'

---Otras tablas
	SELECT * FROM dbo.Customers



---Productos que más se han vendido (Ventas por productos)
	SELECT 
    p.ProductID,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantitySold,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSalesAmount
FROM dbo.Products p
INNER JOIN dbo.[Order Details] od 
    ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductID, 
    p.ProductName
ORDER BY 
    TotalSalesAmount DESC; 

	---------
	SELECT * FROM [NORTHWND].[dbo].[Order Details] 
	WHERE OrderID = '10273'

----Monto de la orden en total
	SELECT OrderID, ProductID, UnitPrice, Quantity, Discount, 
			(UnitPrice * Quantity) - (Discount*Quantity) 'Total'
	FROM [NORTHWND].[dbo].[Order Details] 
	WHERE OrderID = '10273'


--Sumatorias por orden de productos / Función de GroupBy
	SELECT OrderID,
	SUM(Quantity) 'SumQuantity',
	MAX (UnitPrice) 'MaxUnitPrice',
	MIN (UnitPrice) 'MinUnitPrice'
FROM [NORTHWND].[dbo].[Order Details]
WHERE OrderID = '10273'
group by OrderID

----Sumatorias
	SELECT OrderID, 
			SUM(UnitPrice) * SUM(Quantity) -SUM(Discount) * SUM(Quantity) 'TotalMalo',
			SUM((UnitPrice * Quantity) - (Discount*Quantity)) 'Total'
	FROM [NORTHWND].[dbo].[Order Details] 
	WHERE OrderID = '10248'
	group by OrderID

--- Top de 10 clientes por monto total
SELECT TOP 10
    c.CustomerID,
    c.CompanyName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM dbo.Customers c
JOIN dbo.Orders o 
    ON c.CustomerID = o.CustomerID
JOIN [NORTHWND].[dbo].[Order Details] od 
    ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSales DESC;

--Filtros de agregación y agrupación + Función de having
	SELECT OrderID, 
			SUM((UnitPrice * Quantity) - (Discount*Quantity)) 'Total'
	FROM [NORTHWND].[dbo].[Order Details] 
	group by OrderID
	having SUM((UnitPrice * Quantity) - (Discount*Quantity)) >=1000

----Función JOINs entre tablas (Total de cada orden con cliente y fecha)
	SELECT 
    o.OrderID,
    o.OrderDate,
    c.CompanyName AS CustomerName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS OrderTotal
FROM dbo.Orders o
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
GROUP BY 
    o.OrderID,
    o.OrderDate,
    c.CompanyName
ORDER BY OrderTotal DESC;

----Órdenes con nombre del cliente, empleado y transportista
SELECT 
    o.OrderID,
    o.OrderDate,
    c.CompanyName      AS CustomerName,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    s.CompanyName      AS ShipperName,
    o.ShipCountry
FROM dbo.Orders o
JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
JOIN dbo.Employees e ON o.EmployeeID = e.EmployeeID
JOIN dbo.Shippers s ON o.ShipVia = s.ShipperID;

---Ventas por país de clientes
SELECT 
    c.Country,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS SalesByCountry
FROM dbo.Customers c
JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.Country
ORDER BY SalesByCountry DESC;

---Empleado que vende más
SELECT 
    e.EmployeeID,
    (e.FirstName + ' ' + e.LastName) AS EmployeeName,
    COUNT(DISTINCT o.OrderID) AS OrdersCount,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM dbo.Employees e
JOIN dbo.Orders o ON e.EmployeeID = o.EmployeeID
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    e.EmployeeID,
    e.FirstName,
    e.LastName
ORDER BY TotalSales DESC;

---Rankin de clientes por ventas
SELECT 
    c.CustomerID,
    c.CompanyName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales,
    RANK() OVER (ORDER BY 
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC
    ) AS SalesRank
FROM dbo.Customers c
JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY SalesRank;

---Acumulado de ventas por cliente en el tiempo
SELECT
    c.CustomerID,
    c.CompanyName,
    o.OrderDate,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS OrderTotal,
    SUM(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))) OVER (
        PARTITION BY c.CustomerID
        ORDER BY o.OrderDate
    ) AS RunningTotalCustomer
FROM dbo.Customers c
JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    c.CustomerID,
    c.CompanyName,
    o.OrderDate
ORDER BY c.CustomerID, o.OrderDate;

