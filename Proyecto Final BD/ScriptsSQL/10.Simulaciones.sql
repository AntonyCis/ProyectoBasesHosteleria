-- Antony Cisneros, Alan Logroño --

-- SIMULACIONES --

-- Inserta 500 huéspedes simulados
DECLARE @i INT = 1;

WHILE @i <= 500
BEGIN
    INSERT INTO Huesped (nombres, apellidos, cedula, email, telefono)
    VALUES (
        CONCAT('Nombre', @i),
        CONCAT('Apellido', @i),
        RIGHT(CONVERT(VARCHAR(20), RAND() * 10000000000), 10),
        CONCAT('email', @i, '@ejemplo.com'),
        CONCAT('09', RIGHT(CONVERT(VARCHAR(20), RAND() * 1000000000), 8))
    );

    SET @i += 1;
END;
GO

SELECT COUNT(*) FROM Huesped;


-- Fallo de integridad Referencial --

-- Buscar Huesped con Reservas

SELECT TOP 1 H.id_huesped
FROM Huesped H
INNER JOIN Reserva R ON R.id_huesped = H.id_huesped;

-- Intenta Eliminarlo

DELETE FROM Huesped
WHERE id_huesped = 97;
