# 🏨 Sistema de Gestión Hotelera - SQL Server

Este proyecto implementa una base de datos completa para la gestión de un hotel, desarrollada en **SQL Server**, con enfoque en buenas prácticas de modelado, seguridad, auditoría y recuperación de datos.

---

## 📂 Contenido del repositorio

| Carpeta/Archivo                  | Descripción |
|----------------------------------|-------------|
| `scripts/`                        | Contiene todos los archivos `.sql` organizados por módulo: creación de tablas, triggers, vistas, roles, respaldos, funciones, etc. |
| `backup/`                         | Copia de seguridad (`.bak`) de la base de datos `Hoteles`. |
| `diagramas/`                      | Diagrama ER exportado desde dbdiagram.io en PNG o PDF. |
| `README.md`                       | Este archivo. |
| `informe/`                        | Informe técnico completo en Word o PDF para presentación académica. |

---

## 🧱 Estructura de la base de datos

- **Entidades principales:**
  - `Huesped`
  - `Habitacion`
  - `Reserva`
  - `Factura`
  - `Usuario`
  - `Rol`
  - `ConsumoServicio`
  - `Log_Acciones` (auditoría)
  - `Notificaciones` (simulada)

- **Relaciones referenciales** implementadas con `FOREIGN KEY`.
- Como adicional: Se aumentaron dos tablas extras ctanto Notificaciones como Historial de Intentos para pruebas.

---

## 🔒 Seguridad

- Roles personalizados: `Administrador`, `Recepcionista`, `Camarera`, `Usuario`.
- Vistas limitadas por rol para control de acceso.
- Permisos aplicados con `GRANT` y `REVOKE`.
- Hash de contraseñas con `HASHBYTES`.
- Registro de intentos de acceso fallidos (Tabla Extra).

---

## 📋 Auditoría

- Triggers en tablas clave (`Usuario`, `Habitacion`, `Reserva`, `Factura`) para registrar cambios en `Log_Acciones`.
- Registro automático de:
  - Usuario que ejecuta la acción.
  - Rol y terminal.
  - IP de conexión.
  - Fecha y tipo de acción (`INSERT`, `UPDATE`, `DELETE`).
- Reportes por usuario, módulo, fecha o tipo de acción.

---

## 💾 Respaldos y recuperación

- ✅ **Respaldo en caliente** con `BACKUP DATABASE`.
- ✅ **Simulación de respaldo en frío** mediante copia manual de archivos `.mdf` y `.ldf` con el servicio SQL detenido.
- Incluye ejemplo de restauración.

---

## ⚙️ Funciones y procedimientos

- Funciones definidas por el usuario:
  - Calcular duración de estadía.
  - Calcular porcentaje de ocupación.
  - Edad del huésped (si aplica).
- Procedimientos almacenados:
  - Crear reservas, cancelar facturas, consultar habitaciones disponibles, etc.

---

## 🧪 Simulaciones implementadas

- ✅ Inserción masiva (500 registros) para pruebas de rendimiento.
- ✅ Fallos de integridad referencial (bloqueo de eliminaciones inseguras).
- ✅ Auditoría de operaciones sensibles.
- 🚫 SQL Injection bloqueado (simulado).
- ✅ Restauración desde backup ante pérdida de datos.

---

## 🚀 Requisitos

- SQL Server 2019 o superior.
- SQL Server Management Studio (SSMS) / Preferiblemente la version 21.
- Windows (para respaldo en frío con servicios).

---

## 📜 Licencia

Proyecto académico - Uso libre para fines educativos.  
Autor: [Antony Cisneros, Alan Logroño]  
Fecha: [2025]

---

## 📌 Notas

Este repositorio es parte de un proyecto académico de base de datos para la gestión de un sistema hotelero. Se enfoca en aspectos técnicos avanzados como integridad referencial, auditoría, roles, seguridad y respaldos.

