USE TPO;
GO

/*
Prueba de los permisos definidos en seguridad.sql
EXECUTE AS USER ejecuta las sentencias como si las hiciera ese usuario, y REVERT vuelve al usuario original.
Los accesos denegados se capturan con TRY / CATCH para que el script siga y muestre el error.
*/

-- usuario_consulta: puede leer vistas, no puede leer tablas ni modificar datos
EXECUTE AS USER = 'usuario_consulta';
	SELECT * FROM v_gastos_detalle; --Permitido

	BEGIN TRY
		SELECT * FROM usuarios; --Denegado: no tiene acceso a las tablas (protege el DNI)
	END TRY
	BEGIN CATCH
		PRINT 'usuario_consulta -> ' + ERROR_MESSAGE();
	END CATCH;

	BEGIN TRY
		EXEC sp_eliminar_pago_usuario @pago_id = 1;--Denegado: no puede ejecutar SPs que modifican datos
	END TRY
	BEGIN CATCH
		PRINT 'usuario_consulta -> ' + ERROR_MESSAGE();
	END CATCH;

REVERT;
GO


-- usuario_app: puede ejecutar SPs y leer vistas, no puede escribir directo en las tablas
EXECUTE AS USER = 'usuario_app';

	SELECT * FROM v_pagos_detalle;--Permitido

	-- Permitido: el SP lee las tablas por dentro aunque el usuario no tenga permiso sobre ellas
	EXEC sp_obtener_posibles_pagos_por_importe @usuario_id = 1, @monto = 10000;

	BEGIN TRY
		-- Denegado: para cargar un gasto debe usar sp_crear_gasto, que valida las reglas de negocio
		INSERT INTO gastos (nombre, usuario_id, monto, categoria_id) VALUES ('Prueba', 1, 100, 1);
	END TRY
	BEGIN CATCH
		PRINT 'usuario_app -> ' + ERROR_MESSAGE();
	END CATCH;

REVERT;
GO
