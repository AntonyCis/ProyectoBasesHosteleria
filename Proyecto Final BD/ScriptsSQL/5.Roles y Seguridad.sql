-- Antony Cisneros, Alan Logroño --

-- Seguridad y Roles -- 

-- Creación de Roles personalizados -- 

-- Rol para administradores
CREATE ROLE RolAdministrador;

-- Rol para recepcionistas
CREATE ROLE RolRecepcionista;

-- Rol para auditores
CREATE ROLE RolAuditor;

-- Rol para camareras
CREATE ROLE RolCamarera;

-- Rol para clientes (usuarios con acceso limitado)
CREATE ROLE RolCliente;

-- Asignacion de usuarios a los roles creados --

-- Crear usuario de ejemplo (si aún no existe)
CREATE LOGIN recepcion1 WITH PASSWORD = 'Recep@123';
CREATE USER recepcion1 FOR LOGIN recepcion1;

-- Asignar usuario a rol
EXEC sp_addrolemember 'RolRecepcionista', 'recepcion1';

-- Asignacion de permisos con GRANT --

-- otorgar permisos SELECT e INSERT a recepcionistas
GRANT SELECT, INSERT ON Reserva TO RolRecepcionista;
GRANT SELECT ON Huesped TO RolRecepcionista;

--  Auditor solo con permisos de lectura 
GRANT SELECT ON Log_Acciones TO RolAuditor;

-- Administrador con control total 
GRANT SELECT, INSERT, UPDATE, DELETE ON Habitacion TO RolAdministrador;
GRANT CONTROL ON DATABASE::[Hoteles] TO RolAdministrador;

-- Revocar permisos con REVOKE --

-- Revocar permiso de inserción de reservas a recepcionista (EJECUTAR PARA PRUEBA!!)
REVOKE INSERT ON Reserva FROM RolRecepcionista;


-- Encriptación de datos sensibles --

-- Encriptar contraseñas (hash SHA2) al guardar en tabla Usuario --

-- Inserción segura de contraseña con HASH
INSERT INTO Usuario (username, contraseña, rol_id)
VALUES ('cisnerosaa25', HASHBYTES('SHA2_256', 'clave123'), 6);

-- Encriptación y desencriptación con AES (requiere clave simétrica)

-- Crear una clave simétrica para AES
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'HotelesClaveMaestra123!';

CREATE CERTIFICATE CertHotel
WITH SUBJECT = 'Certificado para AES';

CREATE SYMMETRIC KEY ClaveAES
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertHotel;
GO

-- Encriptar email (ejemplo)
OPEN SYMMETRIC KEY ClaveAES DECRYPTION BY CERTIFICATE CertHotel;

UPDATE Huesped
SET email = ENCRYPTBYKEY(KEY_GUID('ClaveAES'), email)
WHERE id_huesped = 1;

-- Desencriptar email (solo en SELECT) Para Verificacion
SELECT 
    id_huesped,
    CONVERT(VARCHAR(100), DECRYPTBYKEY(email)) AS email_desencriptado
FROM Huesped
WHERE id_huesped = 1;

CLOSE SYMMETRIC KEY ClaveAES;

-- Simulación de intentos fallidos --

-- Tabla para registrar Eventos
CREATE TABLE IntentosFallidos (
    id INT IDENTITY PRIMARY KEY,
    usuario_intento VARCHAR(50),
    fecha DATETIME DEFAULT GETDATE(),
    ip_origen VARCHAR(50),
    resultado VARCHAR(20),
    observacion VARCHAR(100)
);
GO


-- Procedimiento simulado de login
CREATE PROCEDURE LoginSimulado
    @username VARCHAR(50),
    @clave VARCHAR(50)
AS
BEGIN
    DECLARE @existe INT;

    SELECT @existe = COUNT(*) 
    FROM Usuario
    WHERE username = @username 
      AND contraseña = HASHBYTES('SHA2_256', @clave);

    IF @existe = 1
    BEGIN
        PRINT 'Inicio de sesión exitoso';
    END
    ELSE
    BEGIN
        INSERT INTO IntentosFallidos (usuario_intento, ip_origen, resultado, observacion)
        VALUES (@username, '127.0.0.1', 'Fallido', 'Usuario o clave incorrecta');

        PRINT 'Inicio de sesión fallido';
    END
END;
GO

-- Ejemplo de Uso 
EXEC LoginSimulado 'cisnerosaa25', 'clave_mal';
EXEC LoginSimulado 'cisnerosaa25', 'clave123';

-- Simular vulnerabilidad INYECCION SQL (no usar en producción)
SELECT * FROM Usuario WHERE username = '' OR '1'='1';
