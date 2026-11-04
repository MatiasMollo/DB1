USE TPO;
GO

/*
Seguridad de la base de datos
Se definen tres roles. Los permisos se otorgan al rol y no a cada usuario, así para dar o quitar acceso a una persona solo se la agrega o saca del rol.

- rol_administrador: mantenimiento completo de la BD.
- rol_aplicacion: la app que usan los usuarios finales. Solo ejecuta SPs y consulta vistas / funciones.
- rol_consulta: reportes. Solo lectura sobre vistas y funciones.

Ningún rol (salvo el administrador) tiene permisos sobre las tablas. Toda modificación pasa por los Stored Procedures, que son los que validan las reglas de negocio.
*/

--LOGINS (nivel servidor): permiten conectarse al motor SQL Server
-- Se verifica que no existan para que el script se pueda ejecutar más de una vez
-- Las contraseñas son de ejemplo
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_admin')
	CREATE LOGIN login_admin WITH PASSWORD = 'admin';

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_app')
	CREATE LOGIN login_app WITH PASSWORD = 'user';

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_consulta')
	CREATE LOGIN login_consulta WITH PASSWORD = 'consulta';
GO

--USUARIOS (nivel base de datos): asocian cada login a la base TPO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuario_admin')
	CREATE USER usuario_admin FOR LOGIN login_admin;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuario_app')
	CREATE USER usuario_app FOR LOGIN login_app;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuario_consulta')
	CREATE USER usuario_consulta FOR LOGIN login_consulta;
GO

--ROLES
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_administrador' AND type = 'R')
	CREATE ROLE rol_administrador;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_aplicacion' AND type = 'R')
	CREATE ROLE rol_aplicacion;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_consulta' AND type = 'R')
	CREATE ROLE rol_consulta;
GO


--PERMISOS: rol_administrador
-- CONTROL sobre la base otorga todos los permisos sobre todos sus objetos
GRANT CONTROL ON DATABASE::TPO TO rol_administrador;
GO


--PERMISOS: rol_aplicacion
-- Stored Procedures: única vía para insertar, modificar o eliminar datos
-- No hace falta dar permisos sobre las tablas: como el SP y las tablas tienen el mismo dueño (dbo),
GRANT EXECUTE ON sp_crear_gasto TO rol_aplicacion;
GRANT EXECUTE ON sp_crear_grupo TO rol_aplicacion;
GRANT EXECUTE ON sp_eliminar_gasto TO rol_aplicacion;
GRANT EXECUTE ON sp_eliminar_pago_usuario TO rol_aplicacion;
GRANT EXECUTE ON sp_eliminar_usuario_de_grupo TO rol_aplicacion;
GRANT EXECUTE ON sp_registrar_pago_usuario TO rol_aplicacion;
GRANT EXECUTE ON sp_obtener_posibles_pagos_por_importe TO rol_aplicacion;
--Vistas: lectura de la información ya armada (ninguna expone el DNI de los usuarios)
GRANT SELECT ON v_miembros_grupo TO rol_aplicacion;
GRANT SELECT ON v_gastos_individuales TO rol_aplicacion;
GRANT SELECT ON v_gastos_grupos TO rol_aplicacion;
GRANT SELECT ON v_gastos_detalle TO rol_aplicacion;
GRANT SELECT ON v_pagos_detalle TO rol_aplicacion;
GRANT SELECT ON v_cuotas_vencidas TO rol_aplicacion;
GRANT SELECT ON v_cuotas_proximas_vencer TO rol_aplicacion;
GRANT SELECT ON v_deuda_cuota_usuario TO rol_aplicacion;
GRANT SELECT ON v_saldo_cuota_usuario TO rol_aplicacion;
GRANT SELECT ON v_resumen_grupos TO rol_aplicacion;
--Funciones: al devolver una tabla, se consultan con SELECT (no con EXECUTE)
GRANT SELECT ON fn_cantidad_integrantes TO rol_aplicacion;
GRANT SELECT ON fn_cuotas_individuales_pendientes TO rol_aplicacion;
GRANT SELECT ON fn_gastos_grupo TO rol_aplicacion;
GRANT SELECT ON fn_gastos_usuario TO rol_aplicacion;
GRANT SELECT ON fn_total_pagado_usuario TO rol_aplicacion;
GRANT SELECT ON fn_gastos_por_categoria TO rol_aplicacion;
GRANT SELECT ON fn_cuotas_vencen_en TO rol_aplicacion;
GRANT SELECT ON fn_resumen_miembros_grupo TO rol_aplicacion;
GO


--PERMISOS: rol_consulta
-- Solo lectura: vistas y funciones
GRANT SELECT ON v_miembros_grupo TO rol_consulta;
GRANT SELECT ON v_gastos_individuales TO rol_consulta;
GRANT SELECT ON v_gastos_grupos TO rol_consulta;
GRANT SELECT ON v_gastos_detalle TO rol_consulta;
GRANT SELECT ON v_pagos_detalle TO rol_consulta;
GRANT SELECT ON v_cuotas_vencidas TO rol_consulta;
GRANT SELECT ON v_cuotas_proximas_vencer TO rol_consulta;
GRANT SELECT ON v_deuda_cuota_usuario TO rol_consulta;
GRANT SELECT ON v_saldo_cuota_usuario TO rol_consulta;
GRANT SELECT ON v_resumen_grupos TO rol_consulta;
GRANT SELECT ON fn_cantidad_integrantes TO rol_consulta;
GRANT SELECT ON fn_cuotas_individuales_pendientes TO rol_consulta;
GRANT SELECT ON fn_gastos_grupo TO rol_consulta;
GRANT SELECT ON fn_gastos_usuario TO rol_consulta;
GRANT SELECT ON fn_total_pagado_usuario TO rol_consulta;
GRANT SELECT ON fn_gastos_por_categoria TO rol_consulta;
GRANT SELECT ON fn_cuotas_vencen_en TO rol_consulta;
GRANT SELECT ON fn_resumen_miembros_grupo TO rol_consulta;
-- Único SP permitido: no modifica datos, solo simula qué cuotas se podrían pagar con un monto
GRANT EXECUTE ON sp_obtener_posibles_pagos_por_importe TO rol_consulta;
GO


--ASIGNACIÓN DE USUARIOS A ROLES
ALTER ROLE rol_administrador ADD MEMBER usuario_admin;
ALTER ROLE rol_aplicacion ADD MEMBER usuario_app;
ALTER ROLE rol_consulta ADD MEMBER usuario_consulta;
GO


--QUITAR PERMISOS (REVOKE)
-- Si se decide que la app no pueda eliminar gastos, se le quita el permiso al rol:
-- REVOKE EXECUTE ON sp_eliminar_gasto FROM rol_aplicacion;
-- Para quitarle el acceso a una persona, alcanza con sacarla del rol:
-- ALTER ROLE rol_aplicacion DROP MEMBER usuario_app;
