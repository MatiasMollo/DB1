-- Valida que el usuario que registra una cuota paga grupal pertenezca al grupo. También valida que la cuota le corresponda si el gasto es individual
CREATE TRIGGER tr_validar_pertenencia_cuota_usuario
ON pagos_usuarios
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS(
		SELECT 1 FROM inserted AS i
		JOIN cuotas as c on c.id = i.cuota_id
		JOIN gastos as g on g.id = c.gasto_id
		WHERE NOT i.usuario_id IN (
			-- Caso válido: El usuario participa del gasto grupal (se niega con el Not del where para detectar casos inválidos)
			SELECT gu.usuario_id FROM gastos_grupos_usuarios as ggu
			JOIN grupos_usuarios as gu on gu.id = ggu.grupo_usuario_id
			WHERE ggu.gasto_id = g.id
		)
		AND NOT (
			-- Caso válido: El usaurio es el responsable de registrar el gasto y el gasto no está registrado como grupal (se niega con el Not del where para detectar casos inválidos)
			i.usuario_id = g.usuario_id 
			AND
			NOT EXISTS ( -- Verifica que el gasto no esté registrado como grupal
				SELECT 1 FROM gastos_grupos_usuarios as ggu2
				WHERE ggu2.gasto_id = g.id
			)
		)
	)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 50003, 'Al usuario no le corresponde la cuota que se está intentando abonar', 1;
	END;
	
END;
GO