CREATE DATABASE Hoteles;
Use Hoteles;

-- Creacion de Tablas

CREATE TABLE [Habitacion] (
  [id_habitacion] INT PRIMARY KEY IDENTITY(1, 1),
  [categoria] VARCHAR(50),
  [precio_noche] DECIMAL(10,2),
  [capacidad] INT,
  [servicios] TEXT,
  [estado] VARCHAR(20)
)
GO

CREATE TABLE [Huesped] (
  [id_huesped] INT PRIMARY KEY IDENTITY(1, 1),
  [nombres] VARCHAR(100),
  [apellidos] VARCHAR(100),
  [cedula] VARCHAR(20) UNIQUE,
  [email] VARCHAR(100),
  [telefono] VARCHAR(20)
)
GO

CREATE TABLE [Reserva] (
  [id_reserva] INT PRIMARY KEY IDENTITY(1, 1),
  [id_huesped] INT,
  [id_habitacion] INT,
  [fecha_ingreso] DATE,
  [fecha_salida] DATE,
  [forma_pago] VARCHAR(50),
  [estado] VARCHAR(20)
)
GO

CREATE TABLE [ServicioAdicional] (
  [id_servicio] INT PRIMARY KEY IDENTITY(1, 1),
  [nombre] VARCHAR(100),
  [descripcion] TEXT,
  [costo_unitario] DECIMAL(10,2)
)
GO

CREATE TABLE [ConsumoServicio] (
  [id_consumo] INT PRIMARY KEY IDENTITY(1, 1),
  [id_reserva] INT,
  [id_servicio] INT,
  [cantidad] INT,
  [fecha] DATE
)
GO

CREATE TABLE [Factura] (
  [id_factura] INT PRIMARY KEY IDENTITY(1, 1),
  [id_reserva] INT,
  [fecha_emision] DATE,
  [total] DECIMAL(10,2)
)
GO

CREATE TABLE [Usuario] (
  [id_usuario] INT PRIMARY KEY IDENTITY(1, 1),
  [username] VARCHAR(50) UNIQUE,
  [contraseña] VARBINARY(256),
  [rol_id] INT
)
GO

CREATE TABLE [Rol] (
  [id_rol] INT PRIMARY KEY IDENTITY(1, 1),
  [nombre_rol] VARCHAR(50),
  [descripcion] TEXT
)
GO

CREATE TABLE [Log_Acciones] (
  [id_log] INT PRIMARY KEY IDENTITY(1, 1),
  [usuario] VARCHAR(50),
  [ip] VARCHAR(45),
  [fecha] DATETIME,
  [accion] VARCHAR(100),
  [tabla] VARCHAR(100),
  [id_afectado] INT
)
GO

CREATE TABLE [HistorialEstadoHabitacion] (
  [id_historial] INT PRIMARY KEY IDENTITY(1, 1),
  [id_habitacion] INT,
  [estado_anterior] VARCHAR(50),
  [estado_nuevo] VARCHAR(50),
  [fecha] DATETIME
)
GO

ALTER TABLE [Reserva] ADD FOREIGN KEY ([id_huesped]) REFERENCES [Huesped] ([id_huesped])
GO

ALTER TABLE [Reserva] ADD FOREIGN KEY ([id_habitacion]) REFERENCES [Habitacion] ([id_habitacion])
GO

ALTER TABLE [ConsumoServicio] ADD FOREIGN KEY ([id_reserva]) REFERENCES [Reserva] ([id_reserva])
GO

ALTER TABLE [ConsumoServicio] ADD FOREIGN KEY ([id_servicio]) REFERENCES [ServicioAdicional] ([id_servicio])
GO

ALTER TABLE [Factura] ADD FOREIGN KEY ([id_reserva]) REFERENCES [Reserva] ([id_reserva])
GO

ALTER TABLE [Usuario] ADD FOREIGN KEY ([rol_id]) REFERENCES [Rol] ([id_rol])
GO

ALTER TABLE [HistorialEstadoHabitacion] ADD FOREIGN KEY ([id_habitacion]) REFERENCES [Habitacion] ([id_habitacion])
GO




