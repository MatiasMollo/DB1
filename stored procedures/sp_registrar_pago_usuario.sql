/*
Registra el pago de un usuario (pagos usuarios)
*/
CREATE OR ALTER PROCEDURE sp_registrar_pago_usuario
@usuario_id INT,
@cuota_id INT,
@importe DECIMAL(10,2),
@fecha DATETIME
AS
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION

		-- Verificación existencia de usuario
		IF NOT EXISTS (SELECT id FROM usuarios WHERE id = @usuario_id)
			THROW 50010, 'El usuario no existe en la base de datos', 1;

		-- Verificación existencia de cuota
		IF NOT EXISTS (SELECT id FROM cuotas WHERE id = @cuota_id)
			THROW 50030, 'La cuota no existe en la DB', 1;

		-- Verificación de que la cuota pertenezca al usuario (o al grupo del usuario
		IF NOT EXISTS(
			SELECT 1 FROM gastos as g
			LEFT JOIN gastos_grupos_usuarios as ggu ON ggu.gasto_id = g.id -- Left Join porque el gasto puede ser grupal o individual
			WHERE g.id = (SELECT gasto_id FROM cuotas WHERE id = @cuota_id)
			AND (
				-- Gasto individual
				g.usuario_id = @usuario_id 
				OR
				-- Gasto grupal
				ggu.grupo_usuario_id IN (
					SELECT id FROM grupos_usuarios WHERE usuario_id = @usuario_id
				)
			)
		)
			THROW 50012, 'El usuario no tiene relación alguna con la cuota', 1;

		-- Verificación de importe (solo mayor al monto de la cuota, por restricción de DB ya se verifica > 0)

		DECLARE @integrantes INT = 1; -- Por defecto se toma como gasto individual

		-- Se verifica que el gasto no sea grupal
		IF EXISTS (
			SELECT 1 FROM grupos_usuarios as gu
			JOIN gastos_grupos_usuarios as ggu ON gu.id = ggu.grupo_usuario_id
			JOIN gastos as g on g.id = ggu.gasto_id
			JOIN cuotas as c ON c.gasto_id = g.id
			WHERE c.id = @cuota_id
			
		)
			SET @integrantes = (
				SELECT COUNT(id) FROM grupos_usuarios as gu
				WHERE gu.id IN (
					SELECT grupo_usuario_id FROM gastos_grupos_usuarios as ggu
					JOIN gastos as g on g.id = ggu.gasto_id
					JOIN cuotas as c on c.id = g.id
					WHERE c.id = @cuota_id
				)
			)

		-- División de la cuota entre los integrantes
		DECLARE @maximo_posible DECIMAL(10,2) = (SELECT monto FROM cuotas WHERE id = @cuota_id) / @integrantes

		IF (@importe > @maximo_posible)
			THROW 50032, 'El importe que se está intentado abonar es mayor al gasto o a la participación por usuario', 1;
		
		INSERT INTO pagos_usuarios (usuario_id, cuota_id, importe, fecha) VALUES (
			@usuario_id,
			@cuota_id,
			@importe,
			@fecha
		);
		
		COMMIT 
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END