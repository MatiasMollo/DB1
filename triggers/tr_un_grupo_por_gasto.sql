-- Verifica que la inserción que relaciona gastos y grupos_usuarios solo pueda asignarse a un grupo
CREATE TRIGGER tr_un_grupo_por_gasto
ON gastos_grupos_usuarios
AFTER INSERT, UPDATE
AS
BEGIN
-- En caso de cumplirse la condición, la inserción / actualización falla (disparando el error)
	IF EXISTS (
		SELECT 1
		FROM gastos_grupos_usuarios AS ggu -- Se obtienen todos los gastos_grupos_usuarios
		JOIN grupos_usuarios gu ON gu.id = ggu.grupo_usuario_id -- Al hacer join con grupos_usuarios disponemos de grupo_id para comparar
		WHERE ggu.gasto_id IN (SELECT gasto_id FROM inserted) -- Se verifica que el gasto a insertar ya está registrado y asociado a un grupo
		GROUP BY ggu.gasto_id -- Se agrupa por gasto
		HAVING COUNT(DISTINCT gu.grupo_id) > 1 -- Habiendo agrupado contamos cuantos grupos tiene cada gasto para ver que no se esté queriendo agregar a mas de un grupo
	)
	BEGIN
		ROLLBACK TRANSACTION; -- Revierte la inserción / actualización
		THROW 50001, 'Un gasto no puede pertenecer a más de un grupo.', 1;
	END
END;
GO