/*
Elimina a un usuario de un grupo, verifica que el mismo pertenezca
*/
CREATE OR ALTER PROCEDURE sp_eliminar_usuario_de_grupo
@usuario_id INT,
@grupo_id INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT 1 FROM grupos_usuarios WHERE usuario_id = @usuario_id AND grupo_id = @grupo_id)
			THROW 50011, 'El usuario no pertenece al grupo indicado', 1;

		DELETE FROM grupos_usuarios WHERE usuario_id = @usuario_id AND grupo_id = @grupo_id;

		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END
