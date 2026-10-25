/*
Permite crear gastos individuales y especificar cantidad de cuotas. 
Al finalizar, retorna el ID del gasto creado, el cual puede asociarse a un grupo y repartirse entre usuarios llamando a otro SP
*/

CREATE OR ALTER PROCEDURE crear_gasto
@usuario_id INT,
@importe DECIMAL(10,2),
@cuotas INT = 1, -- Por defecto una cuota para un gasto normal (sin cuotas / de contado)
@fecha DATETIME = NULL,
@gasto_id INT OUTPUT -- Devuelve el ID creado
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
		IF NOT EXISTS (SELECT id FROM usuarios WHERE id = @usuario_id)
			THROW 50010, 'El usuario no existe en la base de datos', 1;

		INSERT INTO gastos (usuario_id, fecha, monto) VALUES (@usuario_id, @fecha, @importe);
		SET @gasto_id = SCOPE_IDENTITY(); --Scope Identity devuelve la última generación de un campo IDENTITY, en este caso, gasto_id

		-- Al haberse creado la primera cuota por trigger, si la cantidad de cuotas es > 1, se debe calcular el importe de la primera y ditribuir entre la cantidad total de cuotas
		IF @cuotas > 1
		BEGIN
			DECLARE @importe_por_cuota DECIMAL = @importe / @cuotas;
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