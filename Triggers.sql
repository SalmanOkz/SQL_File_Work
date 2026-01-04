use Store

CREATE PROC usp_divide(
    @a decimal,
    @b decimal,
    @c decimal output
) AS
BEGIN
    BEGIN TRY
        SET @c = @a/ @b;
    END TRY
    BEGIN CATCH
        SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH
END;
GO


-- trigger
CREATE TABLE production.upd_product_audits(
    change_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year SMALLINT NOT NULL,
    list_price DEC(10,2) NOT NULL,
    updated_at DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK( operation = 'UPD')
);



CREATE TRIGGER production.trg_product_audit
ON production.products
AFTER INSERT, DELETE
AS
BEGIN
SET NOCOUNT ON;
INSERT INTO
    production.product_audits
        (
            product_id,
            product_name,
            brand_id,
            category_id,
            model_year,
            list_price,
            updated_at,
            operation
        )
SELECT
    i.product_id,
    product_name,
    brand_id,
    category_id,
    model_year,
    i.list_price,
    GETDATE(),
    'INS'
FROM
    inserted AS i
UNION ALL
    SELECT
        d.product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        d.list_price,
        getdate(),
        'DEL'
    FROM
        deleted AS d;
end

INSERT INTO production.products(
    product_name, 
    brand_id, 
    category_id, 
    model_year, 
    list_price
)
VALUES (
    'Test product',
    1,
    1,
    2018,
    599
);

SELECT 
    * 
FROM 
    production.product_audits;

    DELETE FROM 
    production.products
WHERE 
    product_id = 322;


    SELECT 
    * 
FROM 
    production.upd_product_audits;


CREATE TRIGGER production.trg_upd_product_audit
ON production.products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO production.upd_product_audits
    (
        product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        list_price,
        updated_at,
        operation
    )
    SELECT
        i.product_id,
        i.product_name,
        i.brand_id,
        i.category_id,
        i.model_year,
        i.list_price,
        GETDATE(),
        'UPD'
    FROM inserted i;
END

--------------

UPDATE production.products
SET
    product_name = 'Test product updated',
    list_price = 550
WHERE product_id = 22;

select * from upd_product_audits


-- SQL Server INSTEAD OF Trigger

CREATE TABLE production.brand_approvals(
    brand_id INT IDENTITY PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL
);

------------------

CREATE VIEW production.vw_brands 
AS
SELECT
    brand_name,
    'Approved' approval_status
FROM
    production.brands
UNION
SELECT
    brand_name,
    'Pending Approval' approval_status
FROM
    production.brand_approvals;

----------------------------

CREATE TRIGGER production.trg_vw_brands 
ON production.vw_brands
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO production.brand_approvals ( 
        brand_name
    )
    SELECT
        i.brand_name
    FROM
        inserted i
    WHERE
        i.brand_name NOT IN (
            SELECT 
                brand_name
            FROM
                production.brands
        );
END

---------**----------------**-------

INSERT INTO production.vw_brands(brand_name)
VALUES('Eddy Merckx');

---------**----------------**--------

SELECT
	brand_name,
	approval_status
FROM
	production.vw_brands;

----------------------------

SELECT 
	*
FROM 
	production.brand_approvals;


-- Trigger
-- After(insert, update, delete)
-- Inserted

CREATE TABLE index_logs (
    log_id INT IDENTITY PRIMARY KEY,
    event_data XML NOT NULL,
    changed_by SYSNAME NOT NULL
);
GO

select * from index_logs;

CREATE TRIGGER trg_index_changes
ON DATABASE
FOR	
    CREATE_INDEX,
    ALTER_INDEX, 
    DROP_INDEX
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO index_logs (
        event_data,
        changed_by
    )
    VALUES (
        EVENTDATA(),
        USER
    );
END;
GO


CREATE NONCLUSTERED INDEX nidx_fname
ON sales.customers(first_name);
GO

CREATE NONCLUSTERED INDEX nidx_lname
ON sales.customers(last_name);
GO


CREATE TABLE view_index_logs (
    log_id INT IDENTITY PRIMARY KEY,
    event_data XML NOT NULL,
    changed_by SYSNAME NOT NULL
);
GO

select * from view_index_logs;



CREATE TRIGGER trg_view_index_changes
ON DATABASE
FOR	
    CREATE_VIEW,
    ALTER_VIEW, 
    DROP_VIEW
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO view_index_logs (
        event_data,
        changed_by
    )
    VALUES (
        EVENTDATA(),
        USER
    );
END;
GO

drop view categories

CREATE VIEW categories AS
SELECT
    *
FROM [production].[categories];

disable trigger trg_view_index_changes
on database;

enable trigger trg_view_index_changes
on database;

SELECT 
    definition   
FROM 
    sys.sql_modules  
WHERE 
    object_id = OBJECT_ID('[production].[trg_product_audit]'); 

select * from sys.triggers;


drop trigger [production].[trg_product_audit]

-- Functions in sql

CREATE FUNCTION sales.udfNetSale(
    @quantity INT,
    @list_price DEC(10,2),
    @discount DEC(4,2)
)
RETURNS DEC(10,2)
AS 
BEGIN
    RETURN @quantity * @list_price * (1 - @discount);
END;


select sales.udfNetSale (2,10.5,0.25) as net_price

create function sales.avg_price_product
(
    @quantity dec(10,2),
    @production_price int
)
returns dec(10,2)
as begin
    return @production_price / @quantity ;

    end

select sales.avg_price_product(5.5,5) as avg_price


CREATE FUNCTION udfProductInYear (
    @model_year INT
)
RETURNS TABLE
AS
RETURN
    SELECT 
        product_name,
        model_year,
        list_price
    FROM
        production.products
    WHERE
        model_year = @model_year;

SELECT 
    * 
FROM 
    udfProductInYear(2017);


-- these are simple variables

DECLARE @product_table TABLE (
    product_name VARCHAR(MAX) NOT NULL,
    brand_id INT NOT NULL,
    list_price DEC(11,2) NOT NULL
);


INSERT INTO @product_table
SELECT
    product_name,
    brand_id,
    list_price
FROM
    production.products
WHERE
    category_id = 1;


    SELECT
    *
FROM
    @product_table;


drop function avg_price_product

