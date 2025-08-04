-- Alan Logroño, Antony Cisneros --

-- VISTAS -- 
-- Recepcionista --
-- Función: gestionar reservas, ver huéspedes, asignar habitaciones.

CREATE OR ALTER VIEW Vista_Recepcionista_Reservas
AS
SELECT 
    R.id_reserva,
    R.id_habitacion,
    H.id_habitacion AS numero_habitacion,
    R.id_huesped,
    R.fecha_ingreso,
    R.fecha_salida,
    R.estado
FROM Reserva R
INNER JOIN Habitacion H ON R.id_habitacion = H.id_habitacion;
GO

CREATE OR ALTER VIEW Vista_Recepcionista_Huespedes
AS
SELECT 
    id_huesped,
    nombres,
    apellidos,
    cedula,
    email,
    telefono
FROM Huesped;
GO

-- CAMARERA --
-- Función: ver estado y ocupación de habitaciones para limpieza y mantenimiento.

CREATE OR ALTER VIEW Vista_Camarera_Habitaciones
AS
SELECT 
    id_habitacion,
    categoria,
    estado,
    servicios
FROM Habitacion
WHERE estado IN ('ocupada', 'mantenimiento', 'limpieza');
GO

-- ADMINISTRADOR --
-- Función: tener control completo de operaciones (sin ver contraseñas).
CREATE OR ALTER VIEW Vista_Admin_Usuarios
AS
SELECT 
    id_usuario,
    username,
    rol_id
FROM Usuario;
GO

-- Facturas Vista
CREATE OR ALTER VIEW Vista_Admin_Reservas_Facturas
AS
SELECT 
    R.id_reserva,
    R.fecha_ingreso,
    R.fecha_salida,
    R.estado AS estado_reserva,
    F.id_factura,
    F.total
FROM Reserva R
LEFT JOIN Factura F ON R.id_reserva = F.id_reserva;
GO

-- Asignacion de Vistas a roles --
GRANT SELECT ON Vista_Recepcionista_Reservas TO RolRecepcionista;
GRANT SELECT ON Vista_Camarera_Habitaciones TO RolCamarera;
GRANT SELECT ON Vista_Admin_Reservas_Facturas TO RolAdministrador;

