-- Alan Logroño, Antony Cisneros --

-- CONSULTAS --

use Hoteles;

--  Consulta 1: Reporte de reservas con datos del huésped y habitación --
SELECT 
    R.id_reserva,
    H.nombres + ' ' + H.apellidos AS nombre_huesped,
    Hab.categoria,
    R.fecha_ingreso,
    R.fecha_salida,
    R.estado
FROM Reserva R
JOIN Huesped H ON R.id_huesped = H.id_huesped
JOIN Habitacion Hab ON R.id_habitacion = Hab.id_habitacion
ORDER BY R.fecha_ingreso DESC;

--  Consulta 2: Total consumido en servicios por cada reserva --
SELECT 
    R.id_reserva,
    H.nombres + ' ' + H.apellidos AS huesped,
    SUM(CS.cantidad * SA.costo_unitario) AS total_servicios
FROM Reserva R
JOIN Huesped H ON R.id_huesped = H.id_huesped
JOIN ConsumoServicio CS ON R.id_reserva = CS.id_reserva
JOIN ServicioAdicional SA ON CS.id_servicio = SA.id_servicio
GROUP BY R.id_reserva, H.nombres, H.apellidos
ORDER BY total_servicios DESC;

-- Consulta 3: habitaciones ocupadas hoy (sin usar estado) --
SELECT DISTINCT 
    Hab.id_habitacion,
    Hab.categoria,
    Hab.precio_noche,
    R.fecha_ingreso,
    R.fecha_salida,
    H.nombres + ' ' + H.apellidos AS huesped
FROM Reserva R
JOIN Habitacion Hab ON R.id_habitacion = Hab.id_habitacion
JOIN Huesped H ON R.id_huesped = H.id_huesped
WHERE CAST(GETDATE() AS DATE) BETWEEN R.fecha_ingreso AND R.fecha_salida;

-- Consulta 4: Facturas emitidas con datos de huésped y total --
SELECT 
    F.id_factura,
    H.nombres + ' ' + H.apellidos AS cliente,
    F.fecha_emision,
    F.total
FROM Factura F
JOIN Reserva R ON F.id_reserva = R.id_reserva
JOIN Huesped H ON R.id_huesped = H.id_huesped
ORDER BY F.fecha_emision DESC;

-- Consulta 5: Servicios más utilizados en el hotel --
SELECT 
    SA.nombre,
    COUNT(*) AS veces_usado,
    SUM(CS.cantidad) AS total_cantidad
FROM ConsumoServicio CS
JOIN ServicioAdicional SA ON CS.id_servicio = SA.id_servicio
GROUP BY SA.nombre
ORDER BY veces_usado DESC;
GO

-- Procedimientos Almacenados -- 

-- 1. Agregar reserva (con validaciones cruzadas) --

CREATE PROCEDURE AgregarReserva
    @id_huesped INT,
    @id_habitacion INT,
    @fecha_ingreso DATE,
    @fecha_salida DATE,
    @forma_pago VARCHAR(50)
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Reserva
        WHERE id_habitacion = @id_habitacion
        AND estado = 'reservado'
        AND (
            (@fecha_ingreso BETWEEN fecha_ingreso AND fecha_salida) OR
            (@fecha_salida BETWEEN fecha_ingreso AND fecha_salida)
        )
    )
    BEGIN
        RAISERROR('La habitación ya está reservada en esas fechas.', 16, 1);
        RETURN;
    END

    INSERT INTO Reserva (id_huesped, id_habitacion, fecha_ingreso, fecha_salida, forma_pago, estado)
    VALUES (@id_huesped, @id_habitacion, @fecha_ingreso, @fecha_salida, @forma_pago, 'reservado');
END;
GO

--  2. Actualizar reservas vencidas a estado “finalizado” --
CREATE PROCEDURE FinalizarReservasAntiguas
AS
BEGIN
    UPDATE Reserva
    SET estado = 'finalizado'
    WHERE estado = 'reservado' AND fecha_salida < CAST(GETDATE() AS DATE);
END;
GO

-- 3. Eliminar seguro de una reserva (si no tiene factura asociada) --

CREATE PROCEDURE EliminarReservaSegura
    @id_reserva INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Factura WHERE id_reserva = @id_reserva)
    BEGIN
        RAISERROR('No se puede eliminar la reserva. Tiene una factura asociada.', 16, 1);
        RETURN;
    END

    DELETE FROM Reserva WHERE id_reserva = @id_reserva;
END;
GO

--  4. Reporte de reservas en un rango de fechas --

CREATE PROCEDURE ReporteReservasPorFecha
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SELECT 
        R.id_reserva,
        H.nombres + ' ' + H.apellidos AS huesped,
        Hab.categoria,
        R.fecha_ingreso,
        R.fecha_salida,
        R.estado
    FROM Reserva R
    JOIN Huesped H ON R.id_huesped = H.id_huesped
    JOIN Habitacion Hab ON R.id_habitacion = Hab.id_habitacion
    WHERE R.fecha_ingreso BETWEEN @fecha_inicio AND @fecha_fin;
END;
GO

-- 5. Facturación automática de una reserva (calculando total) --

CREATE PROCEDURE GenerarFacturaReserva
    @id_reserva INT
AS
BEGIN
    DECLARE @total_servicios DECIMAL(10,2) = 0;
    DECLARE @dias INT;
    DECLARE @precio_noche DECIMAL(10,2);
    DECLARE @habitacion INT;

    SELECT @dias = DATEDIFF(DAY, fecha_ingreso, fecha_salida), @habitacion = id_habitacion
    FROM Reserva WHERE id_reserva = @id_reserva;

    SELECT @precio_noche = precio_noche
    FROM Habitacion WHERE id_habitacion = @habitacion;

    SELECT @total_servicios = ISNULL(SUM(SA.costo_unitario * CS.cantidad), 0)
    FROM ConsumoServicio CS
    JOIN ServicioAdicional SA ON CS.id_servicio = SA.id_servicio
    WHERE id_reserva = @id_reserva;

    INSERT INTO Factura (id_reserva, fecha_emision, total)
    VALUES (
        @id_reserva,
        GETDATE(),
        (@dias * @precio_noche) + @total_servicios
    );
END;
GO

-- FUNCIONES DEFINIDAS POR EL USUARIO -- 

-- Función 1: Calcular duración de una reserva en días --

CREATE FUNCTION fn_duracion_reserva (
    @id_reserva INT
)
RETURNS INT
AS
BEGIN
    DECLARE @dias INT;

    SELECT @dias = DATEDIFF(DAY, fecha_ingreso, fecha_salida)
    FROM Reserva
    WHERE id_reserva = @id_reserva;

    RETURN @dias;
END;
GO

SELECT dbo.fn_duracion_reserva(1) AS dias_reserva; -- Uso --
GO

-- Función 2: Calcular el porcentaje de ocupación de habitaciones (dado un rango) --

CREATE FUNCTION fn_porcentaje_ocupacion (
    @fecha_inicio DATE,
    @fecha_fin DATE
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total INT = (SELECT COUNT(*) FROM Habitacion);
    DECLARE @ocupadas INT = (
        SELECT COUNT(DISTINCT id_habitacion)
        FROM Reserva
        WHERE fecha_ingreso <= @fecha_fin AND fecha_salida >= @fecha_inicio
    );

    IF @total = 0
        RETURN 0;

    RETURN CAST(@ocupadas AS DECIMAL(5,2)) * 100 / @total;
END;
GO

SELECT dbo.fn_porcentaje_ocupacion('2025-07-01', '2025-07-31') AS ocupacion_julio; -- Uso --
GO


-- Función 3: Obtener estado textual de una reserva --
CREATE FUNCTION fn_estado_texto (
    @id_reserva INT
)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @estado VARCHAR(20);

    SELECT @estado = estado FROM Reserva WHERE id_reserva = @id_reserva;

    RETURN 
        CASE 
            WHEN @estado = 'reservado' THEN 'Reserva activa'
            WHEN @estado = 'finalizado' THEN 'Reserva finalizada'
            WHEN @estado = 'cancelado' THEN 'Reserva cancelada'
            ELSE 'Desconocido'
        END;
END;
GO

SELECT dbo.fn_estado_texto(5) AS estado_legible; --USO--
GO

-- TRIGGERS --

-- Trigger 1: Auditoría – registrar inserciones en Reserva --

CREATE TRIGGER trg_log_insert_reserva
ON Reserva
AFTER INSERT
AS
BEGIN
    INSERT INTO Log_Acciones (usuario, ip, accion, tabla, id_afectado)
    SELECT SYSTEM_USER, '127.0.0.1', 'INSERT', 'Reserva', id_reserva
    FROM inserted;
END;
GO

-- Trigger 2: Cambiar estado de habitación automáticamente al reservar --

CREATE TRIGGER trg_actualizar_estado_habitacion
ON Reserva
AFTER INSERT
AS
BEGIN
    UPDATE Habitacion
    SET estado = 'ocupada'
    WHERE id_habitacion IN (
        SELECT id_habitacion FROM inserted
    );
END;
GO

-- Trigger 3: Historial de estado de habitación (auditoría de cambio manual) --

CREATE TRIGGER trg_historial_estado_habitacion
ON Habitacion
AFTER UPDATE
AS
BEGIN
    INSERT INTO HistorialEstadoHabitacion (id_habitacion, estado_anterior, estado_nuevo, fecha)
    SELECT 
        i.id_habitacion,
        d.estado,
        i.estado,
        GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON i.id_habitacion = d.id_habitacion
    WHERE i.estado <> d.estado;
END;
GO
