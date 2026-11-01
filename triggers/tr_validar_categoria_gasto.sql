/*
	Valida que la categoría insertada en gastos corresponda al usuario o un grupo al que pertenezca
*/
CREATE OR ALTER TRIGGER tr_validar_categoria_gasto
ON gastos
AFTER INSERT, UPDATE 
AS
BEGIN
	IF NOT EXISTS(
		SELECT categoria_id FROM inserted 
		WHERE categoria_id IN (
			-- Categoría pertenece al usuario
			SELECT categoria_id FROM categorias_usuarios WHERE usuario_id = (SELECT usuario_id FROM inserted)
		)
		OR
		categoria_id IN (
			-- Categoría pertenece a un grupo del que el usuario es miembro
			SELECT categoria_id FROM categorias_grupos as cg
			JOIN grupos_usuarios AS gu ON gu.grupo_id = cg.grupo_id
			WHERE gu.usuario_id = (SELECT usuario_id FROM inserted)
		)			
	)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 50013, 'La categoría no tiene relación con el usuario', 1;
	END;
END;