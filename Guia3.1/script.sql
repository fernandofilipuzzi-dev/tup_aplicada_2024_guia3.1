USE MASTER

DROP DATABASE IF EXISTS EmpresaDB;

CREATE DATABASE EmpresaDB;

GO

USE EmpresaDB;

DROP TABLE IF EXISTS Empresas;

CREATE TABLE Empresas
(
    Id  INT PRIMARY KEY IDENTITY(1,1),
    Anio_Actual INT
);

GO

USE EmpresaDB;

DROP TABLE IF EXISTS Empleados;

CREATE TABLE Empleados
(
    Id  INT PRIMARY KEY IDENTITY(1,1),
    DNI INT NOT NULL UNIQUE,
    Apellido NVARCHAR(50) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    Anio_Contratado INT NOT NULL,
    Monto_Basico_Nominal decimal(18,2),
    Horas_Extras_50 INT,
    Horas_Extras_100 INT,
    Id_Empresa INT,
    FOREIGN KEY (Id_Empresa) REFERENCES Empresas(Id) ON DELETE CASCADE
);

GO

USE EmpresaDB;

DROP TABLE IF EXISTS Liquidaciones;

CREATE TABLE Liquidaciones
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    Anio INT ,
    Mes  INT,
    Monto_Basico DECIMAL(18,2),
    Porc_Antiguedad DECIMAL(18,2),
    Monto_Antiguedad DECIMAL(18,2),
    Horas_Extras_50 INT,
    Monto_Extras_50 DECIMAL(18,2),
    Horas_Extras_100 INT,
    Monto_Extras_100 DECIMAL(18,2),
    Nominal DECIMAL(18,2),
    Id_Empleado INT,
    Id_Empresa INT,
    FOREIGN KEY (Id_Empleado) REFERENCES Empleados(Id) ON DELETE CASCADE,
    FOREIGN KEY (Id_Empresa) REFERENCES Empresas(Id)
)

GO

USE EmpresaDB;

DROP PROCEDURE IF EXISTS SP_Crear_Liquidaciones;

GO

DECLARE @Anio_Actual INT=2024;
DECLARE @Id_Empresa INT;

INSERT INTO Empresas (Anio_Actual)
VALUES (@Anio_Actual);

SET @Id_Empresa = SCOPE_IDENTITY();

INSERT INTO Empleados (DNI, Apellido, Nombre, Anio_Contratado, Monto_Basico_Nominal, Horas_Extras_50, Horas_Extras_100, Id_Empresa)
VALUES(20343242,'Galvez','Jorge', 2020, 2030400, 2,1, @Id_Empresa),
(21343242,'Liniers','Cecilia', 2010, 4030400, 2,1, @Id_Empresa),
(21343243,'Acosta','Marta', 2015, 3030400, 2,1, @Id_Empresa),
(22343243,'Cedrón','Gerardo', 2016, 6030400, 2,1, @Id_Empresa)

GO

DROP PROCEDURE IF EXISTS SP_Crear_Liquidaciones

GO

CREATE PROCEDURE SP_Crear_Liquidaciones
(
    @Anio INT,
    @Mes INT
)
AS
BEGIN
    DECLARE Cursor_Empleado CURSOR FOR SELECT Id FROM Empleados;

    DECLARE @Anio_Contratado INT;
    DECLARE @Porc_Antiguedad decimal(18,2);
    DECLARE @Monto_Antiguedad decimal(18,2);
    DECLARE @Monto_Basico decimal(18,2);
    DECLARE @Horas_Extras_50 INT;
    DECLARE @Monto_Extras_50 decimal(18,2);
    DECLARE @Horas_Extras_100 INT;
    DECLARE @Monto_Extras_100 decimal(18,2);
    DECLARE @Nominal decimal(18,2);

    DECLARE @Id_Empleado INT;

    OPEN Cursor_Empleado;

    FETCH NEXT FROM Cursor_Empleado INTO @Id_Empleado;

    WHILE @@FETCH_STATUS=0
    BEGIN

        SELECT @Anio_Contratado=e.Anio_Contratado,
                @Monto_Basico=e.Monto_Basico_Nominal,
                @Horas_Extras_50=e.Horas_Extras_50,
                @Horas_Extras_100=e.Horas_Extras_100
        FROM Empleados e WHERE Id=@Id_Empleado;

        SET @Porc_Antiguedad =(@Anio-@Anio_Contratado)/20.0*100;
        SET @Monto_Antiguedad=@Monto_Basico*@Porc_Antiguedad/100;
        SET @Monto_Extras_50 =@Monto_Basico/40.0*@Horas_Extras_50*1.5;
        SET @Monto_Extras_100 =@Monto_Basico/40.0*@Horas_Extras_100*2;
        SET @Nominal =@Monto_Basico+@Monto_Extras_50+@Monto_Extras_100;

        INSERT INTO Liquidaciones (Anio, Mes, Monto_Basico, Porc_Antiguedad,  Monto_Antiguedad,
                        Horas_Extras_50,
                        Monto_Extras_50,
                        Horas_Extras_100,
                        Monto_Extras_100,
                        Nominal,
                        Id_Empleado)
        VALUES(@Anio, @Mes, @Monto_Basico,
                @Porc_Antiguedad,
                @Monto_Antiguedad,
                @Horas_Extras_50,
                @Monto_Extras_50,
                @Horas_Extras_100,
                @Monto_Extras_100,
                @Nominal,
                @Id_Empleado)

        DECLARE @Id_Liquidacion INT;
        SET @Id_Liquidacion = SCOPE_IDENTITY();

        --en construcción!
        
        FETCH NEXT FROM Cursor_Empleado INTO @Id_Empleado;
    END

    CLOSE Cursor_Empleado;
    DEALLOCATE Cursor_Empleado;
    
END

GO 

EXEC SP_Crear_Liquidaciones @Anio=2024, @Mes=7
EXEC SP_Crear_Liquidaciones @Anio=2024, @Mes=8

GO

SELECT * FROM LIQUIDACIONES