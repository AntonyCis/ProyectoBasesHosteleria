-- Antony Cisneros, Alan Logroño --

-- RESTAURACION --

-- Se debe estar en master
USE master;
GO

-- Poner la base de datos en modo de usuario único..
ALTER DATABASE [Hoteles] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Restauracion de la base:
RESTORE DATABASE [Hoteles]
FROM DISK = 'C:\Backups_SQL_Projects\Hosteleria_Final.bak'
WITH
    FILE = 1,
    NOUNLOAD,
    REPLACE,
    STATS = 5;
GO

-- Devolver la base de datos a modo multi-usuario para que pueda ser usada normalmente.
ALTER DATABASE [Hoteles] SET MULTI_USER;
GO

USE Hoteles;
GO
