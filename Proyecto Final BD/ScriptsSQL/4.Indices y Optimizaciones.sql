-- Alan Logro�o, Antony Cisneros --

-- Indices y Optimizaci�n --

-- Indices Simples --

-- �ndice simple para JOINs en reservas
CREATE NONCLUSTERED INDEX idx_reserva_id_habitacion
ON Reserva (id_habitacion);
GO

-- �ndice simple para b�squeda de hu�sped por c�dula
CREATE NONCLUSTERED INDEX idx_huesped_cedula
ON Huesped (cedula);
GO

-- �ndice simple para fecha de emisi�n en facturas (ordenamientos y filtros)
CREATE NONCLUSTERED INDEX idx_factura_fecha
ON Factura (fecha_emision);
GO

-- �ndice simple para b�squedas por estado de habitaci�n
CREATE NONCLUSTERED INDEX idx_habitacion_estado
ON Habitacion (estado);
GO

-- Indices Compuestos --

-- �ndice compuesto para b�squedas por fechas de reserva
CREATE NONCLUSTERED INDEX idx_reserva_fechas
ON Reserva (fecha_ingreso, fecha_salida);
GO

-- �ndice compuesto para reportes por servicio consumido en una reserva
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

