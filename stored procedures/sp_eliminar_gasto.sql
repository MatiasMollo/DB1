/*
Elimina un gasto y sus cuotas
*/
CREATE OR ALTER PROCEDURE sp_eliminar_gasto
@gasto_id INT
AS
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION

		-- Verifica que el gasto no tenga cuotas pagas por usuarios
		IF EXISTS (
			SELECT 1 FROM cuotas as c
			JOIN pagos_usuarios as pu ON pu.cuota_id = c.id
			WHERE gasto_id = @gasto_id
		)
			THROW 50020, 'Error: El gasto contiene pagos de usuarios, primero se deben eliminar los pagos para borar el gasto', 1;

		DELETE FROM cuotas WHERE gasto_id = @gasto_id;
		DELETE FROM gastos WHERE id = @gasto_id;

		COMMIT 
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END