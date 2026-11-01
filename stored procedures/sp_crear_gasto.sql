/*
Permite crear gastos individuales y especificar cantidad de cuotas. 
Al finalizar, retorna el ID del gasto creado, el cual puede asociarse a un grupo y repartirse entre usuarios llamando a otro SP
*/

CREATE OR ALTER PROCEDURE sp_crear_gasto
@usuario_id INT,
@importe DECIMAL(10,2),
@cuotas INT = 1, -- Por defecto una cuota para un gasto normal (sin cuotas / de contado)
@fecha DATETIME = NULL,
@categoria_id INT,
@gasto_id INT OUTPUT -- Devuelve el ID 
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		IF NOT EXISTS (SELECT id FROM usuarios WHERE id = @usuario_id)
			THROW 50010, 'El usuario no existe en la base de datos', 1;

		-- Se verifica que la categoría pertenezca al usuario o a un grupo del usuario
		IF NOT EXISTS (
				SELECT id FROM categorias_usuarios WHERE id = @categoria_id
			) AND NOT EXISTS (
				SELECT id FROM categorias_grupos as cg
				WHERE cg.grupo_id IN (SELECT grupo_id FROM grupos_usuarios WHERE usuario_id = @usuario_id)
				AND cg.categoria_id = @categoria_id
			)
			THROW 50013, 'La categoría seleccionada no tiene relación con el usuario', 1;

		INSERT INTO gastos (usuario_id, fecha, monto, categoria_id) VALUES (@usuario_id, @fecha, @importe, @categoria_id);
		SET @gasto_id = SCOPE_IDENTITY(); --Scope Identity devuelve la última generación de un campo IDENTITY, en este caso, gasto_id

		-- Al haberse creado la primera cuota por trigger, si la cantidad de cuotas es > 1, se debe calcular el importe de la primera y ditribuir entre la cantidad total de cuotas
		IF @cuotas > 1
		BEGIN
			DECLARE @importe_por_cuota DECIMAL(10,2) = @importe / @cuotas;
			DECLARE @numero_cuota INT = 2; -- Contador para cuotas

			-- Actualización de la primera cuota creada por trigger
			UPDATE cuotas SET monto = @importe_por_cuota WHERE gasto_id = @gasto_id;

			-- Inserción de las cuotas faltantes
			WHILE @numero_cuota < @cuotas
			BEGIN
				INSERT INTO cuotas (gasto_id, numero, vencimiento, monto) VALUES (
					@gasto_id,
					@numero_cuota,
					DATEADD(MONTH, @numero_cuota - 1, CAST(@fecha as DATE)),
					@importe_por_cuota
				);
				SET @numero_cuota = @numero_cuota + 1;
			END;
		END;

		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		THROW; -- Se vuelve a disparar el error, si no estuviera esta línea, el SP fallaría en silencio
	END CATCH;
END;