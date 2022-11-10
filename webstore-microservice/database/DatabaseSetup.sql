CREATE OR REPLACE TABLE Orders (ItemID bigint(20) unsigned, CustomerEmail varchar(1024), Quantity int(10) unsigned);
CREATE OR REPLACE TABLE Footwear (ItemID bigint(20) unsigned, Name varchar(1024), Description text, Cost decimal);
CREATE OR REPLACE TABLE Inventory (ItemID bigint(20) unsigned primary key, Count bigint(20) unsigned);
INSERT INTO Footwear (ItemID, Name, Description, Cost) VALUES (1, "Nike Air Max 270", "The Max Air 270 unit delivers unrivaled, all-day comfort.", 160.00);
INSERT INTO Footwear (ItemID, Name, Description, Cost) VALUES (2, "Adidas Ultraboost 4.0", "Ultraboost DNA carries the genetic information of one of our most popular performance runners, but it's born for the street", 179.99);
INSERT INTO Footwear (ItemID, Name, Description, Cost) VALUES (3, "Reebok Nano X2", "The Nano X2 invites you to be exactly who you are, wherever you are. It is one part performance and one part lifestyle.", 135.00);
INSERT INTO Inventory (ItemID, Count) VALUES (1, 25);
INSERT INTO Inventory (ItemID, Count) VALUES (2,40);
INSERT INTO Inventory (ItemID, Count) VALUES (3, 15);
