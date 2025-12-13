use Store

CREATE TABLE production.parts(
    part_id   INT NOT NULL, 
    part_name VARCHAR(100)
);


INSERT INTO 
    production.parts(part_id, part_name)
VALUES
    (1,'Frame'),
    (2,'Head Tube'),
    (3,'Handlebar Grip'),
    (4,'Shock Absorber'),
    (5,'Fork');

select * from production.parts
where part_id = 4;

CREATE TABLE production.part_prices(
    part_id int,
    valid_from date,
    price decimal(18,4) not null,
    PRIMARY KEY(part_id, valid_from) -- composite key
);

CREATE CLUSTERED INDEX ix_parts_id
ON production.parts (part_id); -- creating indexes

select * from production.parts
where part_id = 4;

