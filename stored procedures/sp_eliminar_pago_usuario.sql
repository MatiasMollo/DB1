/*
Elimina un gasto y sus cuotas
*/
CREATE OR ALTER PROCEDURE sp_eliminar_pago_usuario
@pago_id INT
AS
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION

		-- Verifica que el pago exista
		IF NOT EXISTS (
			SELECT 1 FROM pagos_usuarios as pu
			WHERE id = @pago_id
		)
			THROW 50020, 'Error: No existe registro del pago', 1;

		DELETE FROM pagos_usuarios WHERE id = @pago_id

		COMMIT 
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END