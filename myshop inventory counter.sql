/****** TRIGGER 1 *******/
/* When you delete FROM product table it will be goes to backout table */
DELIMITER //
CREATE TRIGGER product_delete
AFTER DELETE ON product
for each ROW 
BEGIN 
	INSERT INTO backout
	( upc, product_name, weight_gm, price_CAD)
	VALUES
	(old.upc, old.product_name, old.weight_gm, old.price_CAD);
END//
DELIMITER ;
/*QUERY FOR TRIGGER product_delete try */
DELETE FROM product
WHERE upc = "890171910109";


/****** TRIGGER 2 *******/
/* when you insert same upc product it will automatic removed from backout */
DELIMITER //
CREATE trigger back_product
AFTER INSERT ON product
for each ROW 
BEGIN 
	DELETE FROM backout
	WHERE upc IN(SELECT upc FROM product );
END//
DELIMITER ;
/*QUERY FOR TRIGGER back_product try */
INSERT INTO product
(upc, product_name, weight_gm, price_CAD)
VALUES ('890171910109', 'PARLE-G', 799, 2.47);


/****** PROCEDURE ********/
/* I want to count inventory at a trigger on insert statement of each_product_sale_details
(on real life when product will be sold at that time i want to see avaible product on floor)*/
DELIMITER //
CREATE PROCEDURE inventory_count
(qty_of_each_product INT, upc_sale VARCHAR(255))
BEGIN
	UPDATE inventory 
	SET quantity_of_product = quantity_of_product - qty_of_each_product
	WHERE upc = upc_sale;
END //
DELIMITER ;
/*trigger for inventory count(CALL the procedure)*/
DELIMITER //
CREATE trigger count_inventory
AFTER INSERT ON each_product_sale_details
for each ROW 
BEGIN 
	CALL INventory_count(new.qty_of_each_product,new.upc);
END//
DELIMITER ;
/*Query for insert row in each_product_sale_details*/
INSERT INTO each_product_sale_details  
(order_id, upc, qty_of_each_product)
values (5, '1356200038',7);



/******* View **********/
CREATE VIEW low_on_floor AS
SELECT * FROM inventory
WHERE quantity_of_product <=10;
/*To run the view */
Select * from low_on_floor;


/***** SOME CREATIVE WORK *******/
/*********** for data entry in inventory just run this query when you insert any new item in product table 
(MAIN PURPOSE: to reduce time and mistake)******/
INSERT IGNORE INTO inventory(upc)
SELECT upc FROM product;
/* SET up default value for quantity_of_product in invertory table for now. */


/* sample to try above query */
INSERT INTO product
(upc, product_name, weight_gm, price_CAD)
VALUES ('62891540905', 'Great Value Chocolate & Vanilla Creme', 300, 2.27);