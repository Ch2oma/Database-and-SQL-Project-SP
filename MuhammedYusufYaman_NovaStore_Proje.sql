-- BÖLÜM 1:

-- 1. Categories Tablosu
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

-- 2. Customers Tablosu
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    City VARCHAR(20) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL
);

-- 3. Products Tablosu
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT DEFAULT 0,
    CategoryID INT NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- 4. Orders Tablosu
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- 5. OrderDetails Tablosu 
CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- BÖLÜM 2:

-- Kategoriler
INSERT INTO Categories (CategoryName) VALUES 
('Elektronik'), 
('Giyim'), 
('Kitap'), 
('Kozmetik'), 
('Ev ve Yaşam');

-- Ürünler
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES 
('Kablosuz Kulaklık', 750.00, 15, 1),
('Akıllı Saat', 1250.50, 8, 1),
('Laptop', 22000.00, 4, 1),
('Kot Pantolon', 450.00, 45, 2),
('Deri Ceket', 1800.00, 12, 2),
('SQL Eğitim Kitabı', 120.00, 25, 3),
('Roman - Suç ve Ceza', 85.00, 18, 3),
('Parfüm', 950.00, 30, 4),
('Yüz Kremi', 350.00, 12, 4),
('Kahve Makinesi', 2500.00, 10, 5),
('Çelik Tencere Seti', 1450.00, 7, 5);

-- Müşteriler
INSERT INTO Customers (FullName, City, Email) VALUES 
('Ahmet Yılmaz', 'İstanbul', 'ahmet.yilmaz@example.com'),
('Ayşe Demir', 'Ankara', 'ayse.demir@example.com'),
('Mehmet Kaya', 'İzmir', 'mehmet.kaya@example.com'),
('Zeynep Çelik', 'Bursa', 'zeynep.celik@example.com'),
('Can Arslan', 'Antalya', 'can.arslan@example.com');

-- Siparişler
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES 
(1, '2026-03-01 10:30:00', 1200.00),
(2, '2026-03-05 14:15:00', 22000.00),
(3, '2026-03-10 09:45:00', 495.00),
(1, '2026-03-12 16:20:00', 950.00),
(4, '2026-03-15 11:10:00', 4300.00),
(5, '2026-03-18 13:00:00', 205.00),
(2, '2026-03-20 17:40:00', 1450.00),
(3, '2026-03-22 12:05:00', 1250.50);

-- Sipariş Detayları
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES 
(1, 1, 1), 
(1, 4, 1), 
(2, 3, 1), 
(3, 6, 2), 
(3, 7, 1), 
(4, 8, 1), 
(5, 5, 1), 
(5, 10,1),
(6, 6, 1), 
(6, 7, 1), 
(7, 11,1),
(8, 2, 1);
GO

-- BÖLÜM 3:

-- 1. Temel Listeleme
SELECT ProductName, Stock FROM Products WHERE Stock < 20 ORDER BY Stock DESC;

-- 2. Veri Birleştirme (JOIN)
SELECT c.FullName, c.City, o.OrderDate, o.TotalAmount 
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID;

-- 3. Çoklu Birleştirme
SELECT c.FullName, p.ProductName, p.Price, cat.CategoryName 
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
INNER JOIN Categories cat ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Ahmet Yılmaz';

-- 4. Gruplama ve Aggregate
SELECT cat.CategoryName, COUNT(p.ProductID) AS UrunSayisi 
FROM Categories cat
LEFT JOIN Products p ON cat.CategoryID = p.CategoryID
GROUP BY cat.CategoryName;

-- 5. Ciro Analizi
SELECT c.FullName, SUM(o.TotalAmount) AS ToplamCiro 
FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.FullName ORDER BY ToplamCiro DESC;

-- 6. Zaman Analizi
SELECT o.OrderID, o.OrderDate, DATEDIFF(DAY, o.OrderDate, GETDATE()) AS GecenGunSayisi 
FROM Orders o;
GO

-- BÖLÜM 4:

-- 1. View Oluşturma
IF OBJECT_ID('vw_SiparisOzet', 'V') IS NOT NULL
    DROP VIEW vw_SiparisOzet;
GO

CREATE VIEW vw_SiparisOzet AS
SELECT 
    c.FullName AS MusteriAdi,
    o.OrderDate AS SiparisTarihi,
    p.ProductName AS UrunAdi,
    od.Quantity AS Adet
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID;
GO

-- 2. Yedekleme
-- C sürücüsünde 'Yedek' klasörünü oluştur
BACKUP DATABASE NovaStoreDB 
TO DISK = 'C:\Yedek\NovaStoreDB.bak' 
WITH FORMAT, INIT, 
NAME = 'NovaStoreDB-Tam Yedekleme';
GO