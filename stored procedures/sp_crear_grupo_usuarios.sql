/*
Crea un grupo de usuarios
*/
CREATE OR ALTER PROCEDURE sp_crear_grupo
@nombre VARCHAR(100),
@usuario_id INT, -- Usuario inicial del grupo
@grupo_id INT OUTPUT -- Devuelve id de grupo creado
AS 
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		IF NOT EXISTS (SELECT id FROM usuarios WHERE id = @usuario_id)
			THROW 50010, 'El usuario no existe en la base de datos', 1;

		INSERT INTO grupos (nombre) VALUES (@nombre);
		SET @grupo_id = SCOPE_IDENTITY();
		INSERT INTO grupos_usuarios (grupo_id, usuario_id) VALUES (@grupo_id, @usuario_id);

		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW;
	END CATCH
END
