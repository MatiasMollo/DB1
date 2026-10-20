-- Verificar que el usuario que pagó el gasto grupal pertenezca al grupo
CREATE TRIGGER tr_usuario_perteneciente_a_gasto_grupal
ON gastos_grupos_usuarios 
AFTER INSERT, UPDATE
AS
BEGIN
/**
	Al cumplirse la condición, el trigger falla disparando el error.

	El funcionamiento es el siguiente: Se busca en la tabla de grupos_usuarios y se cruza con el usuario de la inserción.
	Luego, se busca que el conjunto obtenido hasta el momento coincida en el id de la tabla grupos_usuarios que se está queriendo insertar.

	De esta manera, en caso de no haber ningún resultado, significaría que se está queriendo insertar un gasto para un usuario en un grupo al cuál no pertenece
**/

	IF EXISTS(
		SELECT 1 FROM inserted as i
		WHERE NOT EXISTS (
			SELECT 1 FROM grupos_usuarios as gu -- Se obtienen los registros de grupos - usuarios
			WHERE gu.usuario_id = (SELECT usuario_id FROM gastos as g on g.id = i.gasto_id) -- Se obtiene el usuario en base al gasto de la inserción
			AND gu.grupo_id = (SELECT grupo_id FROM grupos_usuarios as gu2 on gu2.id = i.grupo_usuario_id) -- Se obtienen los datos del grupo en la DB
		)
	)
	BEGIN 
		ROLLBACK TRANSACTION;
		THROW 50002, 'El usuario que pagó el gasto no pertenece al grupo que se está intentando agregar', 1;
	END;
END;
GO


