-- MySQL Database Experiments
CREATE DATABASE IF NOT EXISTS practical_lab;
USE practical_lab;

DROP TABLE IF EXISTS order_items, orders, products, students, users, audit_log;
CREATE TABLE users (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(80) NOT NULL, email VARCHAR(120) NOT NULL UNIQUE, role VARCHAR(20) NOT NULL DEFAULT 'user', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE products (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL, price DECIMAL(10,2) NOT NULL CHECK (price >= 0), stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0));
CREATE TABLE students (id INT PRIMARY KEY AUTO_INCREMENT, user_id INT NOT NULL, course VARCHAR(50) NOT NULL, marks DECIMAL(5,2) CHECK (marks BETWEEN 0 AND 100), FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE orders (id INT PRIMARY KEY AUTO_INCREMENT, user_id INT NOT NULL, ordered_at DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES users(id));
CREATE TABLE order_items (order_id INT, product_id INT, quantity INT NOT NULL CHECK (quantity > 0), PRIMARY KEY (order_id, product_id), FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE, FOREIGN KEY (product_id) REFERENCES products(id));
CREATE TABLE audit_log (id INT PRIMARY KEY AUTO_INCREMENT, action_name VARCHAR(30), record_id INT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

-- INSERT, SELECT, UPDATE, DELETE, WHERE, ORDER BY, DISTINCT, LIMIT
INSERT INTO users (name,email,role) VALUES ('Riya','riya@example.com','student'),('Aman','aman@example.com','student');
INSERT INTO products (name,price,stock) VALUES ('Notebook',10,50),('Headphones',80,12),('Keyboard',45,20);
INSERT INTO students (user_id,course,marks) VALUES (1,'BCA',92),(2,'BBA',86);
SELECT * FROM users; UPDATE products SET price=48 WHERE name='Keyboard'; DELETE FROM products WHERE stock=0;
SELECT DISTINCT role FROM users; SELECT * FROM products WHERE price BETWEEN 10 AND 80 ORDER BY price DESC LIMIT 10;
SELECT * FROM users WHERE name LIKE 'A%' OR role IN ('admin','student');

-- Operators, functions, GROUP BY and HAVING
SELECT price * stock AS inventory_value, price + 5 AS increased_price FROM products;
SELECT COUNT(*) AS total, SUM(stock) AS units, AVG(price) AS average_price, MIN(price) AS cheapest, MAX(price) AS highest FROM products;
SELECT UPPER(name), LOWER(name), CONCAT(name,' product'), LENGTH(name) FROM products;
SELECT CURRENT_DATE(), CURRENT_TIMESTAMP(), YEAR(CURRENT_DATE()), DATEDIFF(CURRENT_DATE(),'2026-01-01');
SELECT role, COUNT(*) AS members FROM users GROUP BY role HAVING COUNT(*) >= 1;

-- Joins
SELECT u.name,s.course,s.marks FROM users u INNER JOIN students s ON s.user_id=u.id;
SELECT u.name,s.course FROM users u LEFT JOIN students s ON s.user_id=u.id;
SELECT u.name,s.course FROM students s RIGHT JOIN users u ON s.user_id=u.id;
SELECT a.name AS user_a,b.name AS user_b FROM users a JOIN users b ON a.id < b.id;
SELECT u.name,o.id,p.name,oi.quantity FROM users u JOIN orders o ON o.user_id=u.id JOIN order_items oi ON oi.order_id=o.id JOIN products p ON p.id=oi.product_id;

-- Subqueries
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);
SELECT * FROM users WHERE id IN (SELECT user_id FROM students WHERE marks >= 90);
SELECT p.* FROM products p WHERE EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id=p.id);
SELECT s.* FROM students s WHERE marks > (SELECT AVG(s2.marks) FROM students s2 WHERE s2.course=s.course);

-- Views and indexes
CREATE OR REPLACE VIEW student_results AS SELECT u.name,s.course,s.marks FROM users u JOIN students s ON s.user_id=u.id;
SELECT * FROM student_results;
CREATE INDEX idx_product_name ON products(name); CREATE UNIQUE INDEX idx_user_email ON users(email); DROP INDEX idx_product_name ON products;

-- Procedures and functions
DELIMITER //
CREATE PROCEDURE get_students_by_course(IN selected_course VARCHAR(50)) BEGIN SELECT * FROM students WHERE course=selected_course; END//
CREATE FUNCTION grade_for(mark DECIMAL(5,2)) RETURNS CHAR(1) DETERMINISTIC BEGIN RETURN CASE WHEN mark>=90 THEN 'A' WHEN mark>=75 THEN 'B' WHEN mark>=60 THEN 'C' ELSE 'D' END; END//
CREATE PROCEDURE stock_message(IN product_id INT) BEGIN DECLARE current_stock INT; SELECT stock INTO current_stock FROM products WHERE id=product_id; IF current_stock=0 THEN SELECT 'Out of stock' AS message; ELSE SELECT 'Available' AS message; END IF; END//
CREATE PROCEDURE count_products() BEGIN DECLARE finished INT DEFAULT 0; DECLARE product_count INT DEFAULT 0; SELECT COUNT(*) INTO product_count FROM products; WHILE finished=0 DO SELECT product_count AS total_products; SET finished=1; END WHILE; END//
DELIMITER ;
CALL get_students_by_course('BCA'); SELECT grade_for(92);

-- Triggers and audit
DELIMITER //
CREATE TRIGGER before_product_insert BEFORE INSERT ON products FOR EACH ROW BEGIN SET NEW.name=TRIM(NEW.name); END//
CREATE TRIGGER after_user_insert AFTER INSERT ON users FOR EACH ROW BEGIN INSERT INTO audit_log(action_name,record_id) VALUES ('INSERT_USER',NEW.id); END//
CREATE TRIGGER before_student_update BEFORE UPDATE ON students FOR EACH ROW BEGIN IF NEW.marks<0 THEN SET NEW.marks=0; END IF; END//
CREATE TRIGGER after_user_delete AFTER DELETE ON users FOR EACH ROW BEGIN INSERT INTO audit_log(action_name,record_id) VALUES ('DELETE_USER',OLD.id); END//
DELIMITER ;

-- Transactions, commit, rollback, savepoint
START TRANSACTION; INSERT INTO products(name,price,stock) VALUES ('Mouse',20,10); SAVEPOINT after_mouse; UPDATE products SET stock=stock-1 WHERE name='Mouse'; ROLLBACK TO after_mouse; COMMIT;
START TRANSACTION; UPDATE products SET stock=0 WHERE name='Mouse'; ROLLBACK;

-- Database design and CRUD examples
CREATE OR REPLACE VIEW product_inventory AS SELECT name,price,stock,price*stock AS value FROM products;
INSERT INTO orders(user_id) VALUES (1); INSERT INTO order_items VALUES (1,1,2);
SELECT * FROM product_inventory;

-- Advanced SQL
SELECT name FROM users WHERE role='student' UNION SELECT name FROM users WHERE role='admin';
SELECT name, CASE WHEN role='admin' THEN 'Administrator' ELSE 'Member' END AS role_label FROM users;
WITH high_scores AS (SELECT * FROM students WHERE marks>=85) SELECT * FROM high_scores;
SELECT name,marks,RANK() OVER (ORDER BY marks DESC) AS class_rank FROM student_results;
SELECT * FROM users u WHERE EXISTS (SELECT 1 FROM students s WHERE s.user_id=u.id);

-- Export/import and backup commands (run in the shell, not inside MySQL client):
-- mysqldump -u root -p practical_lab > practical_lab.sql
-- mysql -u root -p practical_lab < practical_lab.sql
-- mysqldump --single-transaction --routines practical_lab > backup.sql
