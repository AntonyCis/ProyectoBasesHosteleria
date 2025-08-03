-- Antony Cisneros, Alan Logroño --
PRINT 'Iniciando backup de Hoteles';

BACKUP DATABASE [Hoteles]
TO DISK = 'C:\Backups_SQL_Projects\Hosteleria_Final.bak'
WITH
    NOFORMAT,
    INIT,
    NAME = 'Hosteleria_Finall Backup',
    SKIP,
    NOREWIND,
    NOUNLOAD,
    STATS = 10;

PRINT '>>> Backup completado en C:\Backups_SQL_Projects\Hosteleria_Final.bak';
GO