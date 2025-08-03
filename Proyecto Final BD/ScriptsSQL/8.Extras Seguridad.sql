-- Antony Cisneros, Alan Logroño --

-- Extras --
-- Eliminacion segura

CREATE OR ALTER PROCEDURE sp_EliminacionSeguraHuesped (@id_huesped INT)
AS
BEGIN
    UPDATE Huesped
    SET
        Nombres = 'Usuario Eliminado',
        Apellidos = '',
        Telefono = '0000000000',
        cedula = 'N/A'
    WHERE id_huesped = @id_huesped;
END
GO