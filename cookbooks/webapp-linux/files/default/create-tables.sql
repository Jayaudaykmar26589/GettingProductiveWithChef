CREATE TABLE customers(
    id CHAR (32) NOT NULL,
    PRIMARY KEY(id),
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    email VARCHAR(64)
);

INSERT INTO customers (id, first_name, last_name, email) VALUES (uuid(), 'Tony', 'Stark', 'iron.man@pluralsight.com');
INSERT INTO customers (id, first_name, last_name, email) VALUES (uuid(), 'Natasha', 'Romanoff', 'black.widow@pluralsight.com');
INSERT INTO customers (id, first_name, last_name, email) VALUES (uuid(), 'Steve', 'Rogers', 'captain.america@pluralsight.com');