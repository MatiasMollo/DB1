USE TPO;
GO

/*
	Se encarga de ver cuantas cuotas puede pagar el usuario con un importe específico.
	Utiliza un cursor para calcular el importe fila por fila, contempla pagos parciales realizados con anterioridad.
	Prioriza las cuotas mas viejas (por id) que no hayan sido abonadas

	Aclaración: Funciona solo con gastos grupales.
*/
CREATE OR ALTER PROCEDURE sp_obtener_posibles_pagos_por_importe
	@usuario_id INT,
	@monto DECIMAL (10,2)
AS
BEGIN
	-- Verificación de que el usuario pertenezca a al menos un grupo
	IF NOT EXISTS (SELECT 1 FROM grupos_usuarios WHERE usuario_id = @usuario_id)
		THROW 50010, 'El usuario no existe o no pertenece a ningún grupo', 1;

	-- Verificación de monto
	IF @monto IS NULL OR @monto < 0
		THROW 50040, 'El monto es inválido', 1;

	-- Se crea una tabla la cual se va a ir llenando con el recorrido del cursor
	DECLARE @resultado TABLE (
		cuota_id INT,
		gasto_nombre VARCHAR(100),
		grupo_nombre VARCHAR(100),
		numero_cuota INT,
		deuda_antes_abonar DECIMAL(10,2),
		importe_a_abonar DECIMAL(10,2),
		saldo_pendiente DECIMAL(10,2)
	);

	-- Variables del cursor
	DECLARE
        @cuota_id INT,
        @gasto_nombre VARCHAR(100),
        @grupo_nombre VARCHAR(100),
        @numero_cuota INT,
		@deuda_antes_abonar DECIMAL(10,2),
        @deuda_pendiente DECIMAL(10,2),
        @importe_abonar DECIMAL(10,2),
        @monto_disponible DECIMAL(10,2);

	SET @monto_disponible = @monto;

	BEGIN TRY
		DECLARE cursor_cuotas CURSOR FOR

			SELECT 
				c.id as cuota_id, 
				g.nombre as gasto_nombre, 
				c.numero as numero_cuota, 
				gr.nombre as grupo_nombre,
				((c.monto / cantidad.usuarios) - ISNULL(pagos.total_pagado,0)) AS deuda_pendiente
			FROM cuotas as c
			JOIN gastos as g on g.id = c.gasto_id
			JOIN gastos_grupos_usuarios as ggu on ggu.gasto_id = g.id
			JOIN grupos_usuarios as gu on gu.id = ggu.grupo_usuario_id
			JOIN grupos as gr on gr.id = gu.grupo_id 

			LEFT JOIN (
				-- Se obtienen todos los pagos parciales del usuario por cada cuota (en caso de existir)
				SELECT cuota_id, usuario_id, SUM(importe) as total_pagado
				FROM pagos_usuarios as pu
				WHERE usuario_id = @usuario_id
				GROUP BY cuota_id, usuario_id
			) as pagos on pagos.cuota_id = c.id

			JOIN (
				-- Se obtiene la cantidad de usuarios entre los que se reparte el gasto para saber que monto le corresponde a cada uno 
				SELECT gasto_id, COUNT(DISTINCT gu.usuario_id) as usuarios 
				FROM gastos_grupos_usuarios as ggu
				JOIN grupos_usuarios as gu on gu.id = ggu.grupo_usuario_id
				GROUP BY ggu.gasto_id
			) as cantidad on cantidad.gasto_id = g.id

			WHERE gu.usuario_id = @usuario_id AND 
			((c.monto / cantidad.usuarios) - ISNULL(pagos.total_pagado,0)) > 0
			ORDER BY c.vencimiento ASC, c.id ASC; -- Se ordena de forma ascendente por vencimiento de cuota. Si hay varias cuotas con el mismo vencimiento se desempata por ID

		-- Apertura del cursor
		OPEN cursor_cuotas;
		FETCH NEXT FROM cursor_cuotas INTO @cuota_id, @gasto_nombre, @numero_cuota, @grupo_nombre, @deuda_pendiente;

		-- Recorrido del cursor
		WHILE @@FETCH_STATUS = 0 AND @monto_disponible > 0
		BEGIN
			-- Si el monto disponible alcanza para cubrir la deuda pendiente se cancela de forma total, si no alcanza, se abona de forma parcial con el monto disponible
			SET @importe_abonar = CASE 
				WHEN @monto_disponible >= @deuda_pendiente THEN 
					@deuda_pendiente 
				ELSE 
					@monto_disponible 
				END;

			-- Se inserta en la tabla resultado el gasto que se podría haber pagado
			INSERT INTO @resultado (cuota_id, gasto_nombre, grupo_nombre, numero_cuota, deuda_antes_abonar, importe_a_abonar, saldo_pendiente) VALUES (
				@cuota_id,
				@gasto_nombre,
				@grupo_nombre,
				@numero_cuota,
				@deuda_pendiente,
				@importe_abonar,
				@deuda_pendiente - @importe_abonar
			);

			-- Se resta el monto disponible para la próxima iteración
			SET @monto_disponible = @monto_disponible - @importe_abonar;

			FETCH NEXT FROM cursor_cuotas INTO @cuota_id, @gasto_nombre, @numero_cuota, @grupo_nombre, @deuda_pendiente;
		END;

		-- Cierre de cursor
		CLOSE cursor_cuotas;
		DEALLOCATE cursor_cuotas;
		
		-- Muestra final de los resultados obtenidos
		SELECT * FROM @resultado;
	END TRY
	BEGIN CATCH
		-- Desalojo de memoria en caso de error de ejecución
		CLOSE cursor_cuotas;
		DEALLOCATE cursor_cuotas;
	END CATCH
END;