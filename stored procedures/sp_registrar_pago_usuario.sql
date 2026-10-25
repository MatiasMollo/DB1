/*
Registra el pago de un usuario (pagos usuarios)
*/
CREATE OR ALTER PROCEDURE sp_registrar_pago_usuario
@usuario_id INT,
@cuota_id INT,
@importe DECIMAL,
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
		IF (@importe > (SELECT monto FROM cuotas WHERE id = @cuota_id))
			THROW 50032, 'El importe a pagar no puede ser mayor al monto de la cuota', 1;
		
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