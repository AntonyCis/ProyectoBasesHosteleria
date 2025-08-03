-- Antony Cisneros, Alan Logroño --

-- Auditoria --

--  Mejora en Log Acciones
DROP TABLE IF EXISTS Log_Acciones;
GO

CREATE TABLE Log_Acciones (
    id_log INT IDENTITY PRIMARY KEY,
    usuario VARCHAR(100),
    rol_actual VARCHAR(50),
    terminal VARCHAR(100),
    ip VARCHAR(50),
    fecha DATETIME DEFAULT GETDATE(),
    accion VARCHAR(50),
    tabla VARCHAR(50),
    transaccion_sql NVARCHAR(MAX),
    id_afectado INT
);
GO

-- Trigger Tabla Usuario -- 

CREATE OR ALTER TRIGGER trg_auditoria_usuario
ON Usuario
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @accion VARCHAR(20)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @accion = 'UPDATE'
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @accion = 'INSERT'
    ELSE
        SET @accion = 'DELETE'

    INSERT INTO Log_Acciones (
        usuario, rol_actual, terminal, ip, fecha,
        accion, tabla, transaccion_sql, id_afectado
    )
    SELECT
        SYSTEM_USER,
        USER_NAME(),
        HOST_NAME(),
        CONVERT(VARCHAR(50), CONNECTIONPROPERTY('client_net_address')),
        GETDATE(),
        @accion,
        'Usuario',
        @accion + ' en Usuario',
        COALESCE(i.id_usuario, d.id_usuario)
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_usuario = d.id_usuario;
END;
GO

-- Prueba Usuarios --

INSERT INTO Usuario (username, contraseña, rol_id)
VALUES ('prueba_trigger', HASHBYTES('SHA2_256', 'clave123'), 1);

UPDATE Usuario
SET username = 'trigger_editado'
WHERE username = 'prueba_trigger';

DELETE FROM Usuario
WHERE username = 'trigger_editado';
GO

-- Trigger Habitación -- 

CREATE OR ALTER TRIGGER trg_auditoria_habitacion
ON Habitacion
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @accion VARCHAR(20);

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @accion = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @accion = 'INSERT';
    ELSE
        SET @accion = 'DELETE';

    INSERT INTO Log_Acciones (
        usuario, rol_actual, terminal, ip, fecha,
        accion, tabla, transaccion_sql, id_afectado
    )
    SELECT
        SYSTEM_USER,
        USER_NAME(),
        HOST_NAME(),
        CONVERT(VARCHAR(50), CONNECTIONPROPERTY('client_net_address')),
        GETDATE(),
        @accion,
        'Habitacion',
        @accion + ' en Habitacion',
        COALESCE(i.id_habitacion, d.id_habitacion)
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_habitacion = d.id_habitacion;
END;
GO

-- Pruebas

INSERT INTO Habitacion (categoria, precio_noche, capacidad, servicios, estado)
VALUES ('Suite', 85.00, 4, 'TV, WiFi, Aire acondicionado', 'disponible');
GO
-- Trigger Tabla Reserva --

CREATE OR ALTER TRIGGER trg_auditoria_reserva
ON Reserva
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @accion VARCHAR(20);

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @accion = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @accion = 'INSERT';
    ELSE
        SET @accion = 'DELETE';

    INSERT INTO Log_Acciones (
        usuario, rol_actual, terminal, ip, fecha,
        accion, tabla, transaccion_sql, id_afectado
    )
    SELECT
        SYSTEM_USER,
        USER_NAME(),
        HOST_NAME(),
        CONVERT(VARCHAR(50), CONNECTIONPROPERTY('client_net_address')),
        GETDATE(),
        @accion,
        'Reserva',
        @accion + ' en Reserva',
        COALESCE(i.id_reserva, d.id_reserva)
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_reserva = d.id_reserva;
END;
GO

-- Prueba --

INSERT INTO Reserva (id_habitacion, id_huesped, fecha_ingreso, fecha_salida, estado)
VALUES (1, 1, '2025-08-15', '2025-08-17', 'pendiente');
GO

-- Trigger Tabla Factura --
CREATE OR ALTER TRIGGER trg_auditoria_factura
ON Factura
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @accion VARCHAR(20);

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
        SET @accion = 'UPDATE';
    ELSE IF EXISTS (SELECT 1 FROM inserted)
        SET @accion = 'INSERT';
    ELSE
        SET @accion = 'DELETE';

    INSERT INTO Log_Acciones (
        usuario, rol_actual, terminal, ip, fecha,
        accion, tabla, transaccion_sql, id_afectado
    )
    SELECT
        SYSTEM_USER,
        USER_NAME(),
        HOST_NAME(),
        CONVERT(VARCHAR(50), CONNECTIONPROPERTY('client_net_address')),
        GETDATE(),
        @accion,
        'Factura',
        CONCAT(@accion, ' en Factura'),
        CASE 
            WHEN @accion = 'INSERT' THEN i.id_factura
            WHEN @accion = 'DELETE' THEN d.id_factura
            ELSE COALESCE(i.id_factura, d.id_factura)
        END
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.id_factura = d.id_factura;
END;
GO


-- Prueba --
INSERT INTO Factura (id_reserva, fecha_emision, total)
VALUES (1, GETDATE(), 150.00);
GO

DELETE FROM Factura
WHERE id_factura = 51;


-- Trazabilidad / Hash --

CREATE TABLE HistorialCambios (
    id INT IDENTITY PRIMARY KEY,
    tabla VARCHAR(50),
    id_afectado INT,
    campo_modificado VARCHAR(50),
    valor_anterior VARCHAR(255),
    hash_anterior VARBINARY(64),
    fecha DATETIME DEFAULT GETDATE(),
    usuario VARCHAR(100)
);
GO

-- Trigger Ejemplo Trazabilidad --
CREATE OR ALTER TRIGGER trg_track_estado_habitacion
ON Habitacion
AFTER UPDATE
AS
BEGIN
    INSERT INTO HistorialCambios (
        tabla, id_afectado, campo_modificado,
        valor_anterior, hash_anterior, usuario
    )
    SELECT 
        'Habitacion',
        d.id_habitacion,
        'estado',
        d.estado,
        HASHBYTES('SHA2_256', d.estado),
        SYSTEM_USER
    FROM inserted i
    INNER JOIN deleted d ON i.id_habitacion = d.id_habitacion
    WHERE i.estado <> d.estado;
END;
GO
