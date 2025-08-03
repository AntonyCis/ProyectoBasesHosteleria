-- Alan Logroño, Antony Cisneros --

-- Indices y Optimización --

-- Indices Simples --

-- Índice simple para JOINs en reservas
CREATE NONCLUSTERED INDEX idx_reserva_id_habitacion
ON Reserva (id_habitacion);
GO

-- Índice simple para búsqueda de huésped por cédula
CREATE NONCLUSTERED INDEX idx_huesped_cedula
ON Huesped (cedula);
GO

-- Índice simple para fecha de emisión en facturas (ordenamientos y filtros)
CREATE NONCLUSTERED INDEX idx_factura_fecha
ON Factura (fecha_emision);
GO

-- Índice simple para búsquedas por estado de habitación
CREATE NONCLUSTERED INDEX idx_habitacion_estado
ON Habitacion (estado);
GO

-- Indices Compuestos --

-- Índice compuesto para búsquedas por fechas de reserva
CREATE NONCLUSTERED INDEX idx_reserva_fechas
ON Reserva (fecha_ingreso, fecha_salida);
GO

-- Índice compuesto para reportes por servicio consumido en una reserva
CREATE NONCLUSTERED INDEX idx_consumo_servicio
ON ConsumoServicio (id_reserva, id_servicio);
GO

-- Evaluacion de Rendimiento --

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Consulta a evaluar
SELECT *
FROM Factura
WHERE fecha_emision BETWEEN '2025-07-01' AND '2025-07-31';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;


-- Evaluacion con plan grafico de 500 inserciones (Presionar control M y Ver plan de ejecucion). --

SELECT *
FROM Reserva
WHERE fecha_ingreso BETWEEN '2025-07-01' AND '2025-07-31';

