USE TPO;
GO

/*
Llenado masivo de datos de prueba 

Requisitos previos: Tablas creadas (archivos tablas.sql)
*/

-- ============================================================
-- LIMPIEZA (opcional): descomentar para reiniciar los datos
-- ============================================================
/*
DELETE FROM pagos_usuarios;
DELETE FROM gastos_grupos_usuarios;
DELETE FROM cuotas;
DELETE FROM gastos;
DELETE FROM categorias_usuarios;
DELETE FROM categorias_grupos;
DELETE FROM categorias;
DELETE FROM grupos_usuarios;
DELETE FROM grupos;
DELETE FROM usuarios;
*/

-- ============================================================
-- 1. USUARIOS
-- ============================================================
INSERT INTO usuarios (nombre, apellido, dni) VALUES
	('Lucía', 'Fernández', 30111222),
	('Martín', 'Gómez',31222333),
	('Sofía', 'Rodríguez', 32333444),
	('Mateo', 'López', 33444555),
	('Valentina', 'Díaz', 34555666),
	('Joaquín', 'Pérez', 35666777),
	('Camila', 'Sosa', 36777888),
	('Tomás', 'Álvarez', 37888999);

-- ============================================================
-- 2. GRUPOS
-- ============================================================
INSERT INTO grupos (nombre) VALUES
	('Viaje a Bariloche'),
	('Departamento'),
	('Kartings');

-- ============================================================
-- 3. MIEMBROS DE GRUPOS
-- Bariloche: Lucía, Martín, Sofía, Mateo
-- Departamento: Lucía, Valentina, Joaquín, Camila
-- Kartings: Martín, Sofía, Tomás
-- ============================================================

-- Se usan consultas sobre dni en tabla usuarios para no depender de los IDs de la DB (en caso de borrado y restablecimiento de la misma)

INSERT INTO grupos_usuarios (grupo_id, usuario_id)
SELECT g.id, u.id
FROM grupos g
JOIN usuarios u ON u.dni IN (30111222, 31222333, 32333444, 33444555)
WHERE g.nombre = 'Viaje a Bariloche';

INSERT INTO grupos_usuarios (grupo_id, usuario_id)
SELECT g.id, u.id
FROM grupos g
JOIN usuarios u ON u.dni IN (30111222, 34555666, 35666777, 36777888)
WHERE g.nombre = 'Departamento';

INSERT INTO grupos_usuarios (grupo_id, usuario_id)
SELECT g.id, u.id
FROM grupos g
JOIN usuarios u ON u.dni IN (31222333, 32333444, 37888999)
WHERE g.nombre = 'Kartings';

-- ============================================================
-- 4. CATEGORÍAS
-- ============================================================
INSERT INTO categorias (nombre) VALUES
	('Alimentos'),
	('Transporte'),
	('Hogar'),
	('Varios'),
	('Servicios'),
	('Salud');

INSERT INTO categorias_grupos (grupo_id, categoria_id)
SELECT g.id, c.id
FROM grupos g
JOIN categorias c ON c.nombre IN ('Alimentos', 'Transporte', 'Varios')
WHERE g.nombre = 'Viaje a Bariloche';

INSERT INTO categorias_grupos (grupo_id, categoria_id)
SELECT g.id, c.id
FROM grupos g
JOIN categorias c ON c.nombre IN ('Hogar', 'Servicios', 'Alimentos')
WHERE g.nombre = 'Departamento';

INSERT INTO categorias_grupos (grupo_id, categoria_id)
SELECT g.id, c.id
FROM grupos g
JOIN categorias c ON c.nombre IN ('Alimentos', 'Varios')
WHERE g.nombre = 'Kartings';

INSERT INTO categorias_usuarios (usuario_id, categoria_id)
SELECT u.id, c.id
FROM usuarios u
JOIN categorias c ON c.nombre IN ('Salud', 'Transporte', 'Varios')
WHERE u.dni IN (30111222, 33444555, 34555666);

-- ============================================================
-- 5. GASTOS, CUOTAS Y PARTICIPANTES
-- ============================================================
DECLARE @hoy DATE = CAST(CURRENT_TIMESTAMP AS DATE);

DECLARE @g1 INT, @g2 INT, @g3 INT, @g4 INT, @g5 INT; -- Variables para almacenar id de gastos grupales
DECLARE @i1 INT, @i2 INT, @i3 INT, @i4 INT; -- Variables para almacenar id de gastos individuales

-- Usuarios creados anteriormente, se almacena su id en variables para usar en próximas consultas
DECLARE @u1 INT = (SELECT id FROM usuarios WHERE dni = 30111222);
DECLARE @u2 INT = (SELECT id FROM usuarios WHERE dni = 31222333);
DECLARE @u3 INT = (SELECT id FROM usuarios WHERE dni = 32333444);
DECLARE @u4 INT = (SELECT id FROM usuarios WHERE dni = 33444555);
DECLARE @u5 INT = (SELECT id FROM usuarios WHERE dni = 34555666);
DECLARE @u6 INT = (SELECT id FROM usuarios WHERE dni = 35666777);
DECLARE @u7 INT = (SELECT id FROM usuarios WHERE dni = 36777888);
DECLARE @u8 INT = (SELECT id FROM usuarios WHERE dni = 37888999);

-- G1: Alojamiento Bariloche, paga Lucía, 120.000 en 3 cuotas de 40.000
INSERT INTO gastos (usuario_id, nombre, monto) VALUES (@u1, 'Alojamiento Bariloche', 120000.00);
SET @g1 = SCOPE_IDENTITY();

-- cuota 1 creada por trigger, por lo que se cambia el monto para distribuir en la cantidad total de cuotas
UPDATE cuotas SET monto = 40000.00 WHERE gasto_id = @g1 AND numero = 1;

INSERT INTO cuotas (gasto_id, numero, vencimiento, monto) VALUES
	(@g1, 2, DATEADD(MONTH, 1, @hoy), 40000.00),
	(@g1, 3, DATEADD(MONTH, 2, @hoy), 40000.00);

INSERT INTO gastos_grupos_usuarios (gasto_id, grupo_usuario_id)
SELECT @g1, gu.id
FROM grupos_usuarios gu
JOIN grupos g ON g.id = gu.grupo_id AND g.nombre = 'Viaje a Bariloche';

-- G2: Cena Bariloche, paga Martín, 48.000 en 1 cuota
INSERT INTO gastos (usuario_id, nombre, monto) VALUES (@u2, 'Cena Bariloche', 48000.00);
SET @g2 = SCOPE_IDENTITY();

INSERT INTO gastos_grupos_usuarios (gasto_id, grupo_usuario_id)
SELECT @g2, gu.id
FROM grupos_usuarios gu
JOIN grupos g ON g.id = gu.grupo_id AND g.nombre = 'Viaje a Bariloche';


-- G3: Heladera del depto, paga Valentina, 90.000 en 6 cuotas de 15.000
INSERT INTO gastos (usuario_id, nombre, monto) VALUES (@u5, 'Heladera del depto', 90000.00);
SET @g3 = SCOPE_IDENTITY();

-- cuota 1 creada por trigger, por lo que se cambia el monto para distribuir en la cantidad total de cuotas
UPDATE cuotas SET monto = 15000.00 WHERE gasto_id = @g3 AND numero = 1;

INSERT INTO cuotas (gasto_id, numero, vencimiento, monto) VALUES
	(@g3, 2, DATEADD(MONTH, 1, @hoy), 15000.00),
	(@g3, 3, DATEADD(MONTH, 2, @hoy), 15000.00),
	(@g3, 4, DATEADD(MONTH, 3, @hoy), 15000.00),
	(@g3, 5, DATEADD(MONTH, 4, @hoy), 15000.00),
	(@g3, 6, DATEADD(MONTH, 5, @hoy), 15000.00);

INSERT INTO gastos_grupos_usuarios (gasto_id, grupo_usuario_id)
SELECT @g3, gu.id
FROM grupos_usuarios gu
JOIN grupos g ON g.id = gu.grupo_id AND g.nombre = 'Departamento';


-- G4: Internet del depto, paga Lucía, 18.000 en 1 cuota, solo entre Valentina, Joaquín y Camila ----------
INSERT INTO gastos (usuario_id, nombre, monto) VALUES (@u1, 'Internet del depto', 18000.00);
SET @g4 = SCOPE_IDENTITY();

INSERT INTO gastos_grupos_usuarios (gasto_id, grupo_usuario_id)
SELECT @g4, gu.id
FROM grupos_usuarios gu
JOIN grupos g ON g.id = gu.grupo_id AND g.nombre = 'Departamento'
WHERE gu.usuario_id IN (@u5, @u6, @u7);

-- ---------- G5: Carrera de karting, paga Tomás, 24.000 en 1 cuota ----------
INSERT INTO gastos (usuario_id, nombre, monto) VALUES (@u8, 'Carrera del viernes 16-10', 24000.00);
SET @g5 = SCOPE_IDENTITY();

INSERT INTO gastos_grupos_usuarios (gasto_id, grupo_usuario_id)
SELECT @g5, gu.id
FROM grupos_usuarios gu
JOIN grupos g ON g.id = gu.grupo_id AND g.nombre = 'Kartings';

-- ---------- Gastos individuales (sin filas en gastos_grupos_usuarios) ----------

-- I1: Lucía, 12.000 en 3 cuotas de 4.000
INSERT INTO gastos (usuario_id, nombre, monto) VALUES (@u1, 'Consulta médica', 12000.00);
SET @i1 = SCOPE_IDENTITY();

-- cuota 1 creada por trigger, por lo que se cambia el monto para distribuir en la cantidad total de cuotas

UPDATE cuotas SET monto = 4000.00 WHERE gasto_id = @i1 AND numero = 1;

INSERT INTO cuotas (gasto_id, numero, vencimiento, monto) VALUES
	(@i1, 2, DATEADD(MONTH, 1, @hoy), 4000.00),
	(@i1, 3, DATEADD(MONTH, 2, @hoy), 4000.00);

-- I2: Mateo, 8.500 en 1 cuota
INSERT INTO gastos (usuario_id, nombre, monto) VALUES (@u4, 'Carga de transporte', 8500.00);
SET @i2 = SCOPE_IDENTITY();

-- I3: Valentina, 60.000 en 12 cuotas de 5.000
INSERT INTO gastos (usuario_id, nombre, monto) VALUES (@u5, 'Notebook', 60000.00);
SET @i3 = SCOPE_IDENTITY();

-- cuota 1 creada por trigger, por lo que se cambia el monto para distribuir en la cantidad total de cuotas
UPDATE cuotas SET monto = 5000.00 WHERE gasto_id = @i3 AND numero = 1;
INSERT INTO cuotas (gasto_id, numero, vencimiento, monto) VALUES
	(@i3, 2, DATEADD(MONTH, 1, @hoy), 5000.00),
	(@i3, 3, DATEADD(MONTH, 2, @hoy), 5000.00),
	(@i3, 4, DATEADD(MONTH, 3, @hoy), 5000.00),
	(@i3, 5, DATEADD(MONTH, 4, @hoy), 5000.00),
	(@i3, 6, DATEADD(MONTH, 5, @hoy), 5000.00),
	(@i3, 7, DATEADD(MONTH, 6, @hoy), 5000.00),
	(@i3, 8, DATEADD(MONTH, 7, @hoy), 5000.00),
	(@i3, 9, DATEADD(MONTH, 8, @hoy), 5000.00),
	(@i3, 10, DATEADD(MONTH, 9, @hoy), 5000.00),
	(@i3, 11, DATEADD(MONTH, 10, @hoy), 5000.00),
	(@i3, 12, DATEADD(MONTH, 11, @hoy), 5000.00);

-- I4: Camila, 3.200,50 en 1 cuota
INSERT INTO gastos (usuario_id, nombre, monto) VALUES (@u7, 'Café y medialunas', 3200.50);
SET @i4 = SCOPE_IDENTITY();

-- ============================================================
-- 6. PAGOS
-- Reparto en partes iguales: cada participante debe (cuota / cantidad de participantes).
-- G1: cuota 40.000 -> 10.000 por persona (4 participantes)
-- G3: cuota 15.000 -> 3.750 por persona (4 participantes)
-- G5: 24.000 -> 8.000 por persona (3 participantes)
-- ============================================================

-- G1, cuota 1: Martín, Sofía y Mateo pagan su parte completa
INSERT INTO pagos_usuarios (usuario_id, cuota_id, importe)
SELECT u.id, c.id, 10000.00
FROM usuarios u
JOIN cuotas c ON c.gasto_id = @g1 AND c.numero = 1
WHERE u.dni IN (31222333, 32333444, 33444555);

-- G1, cuota 2: Mateo hace un pago parcial
INSERT INTO pagos_usuarios (usuario_id, cuota_id, importe)
SELECT @u4, c.id, 5000.00
FROM cuotas c
WHERE c.gasto_id = @g1 AND c.numero = 2;

-- G3, cuota 1: Joaquín paga completo, Camila paga parcial
INSERT INTO pagos_usuarios (usuario_id, cuota_id, importe)
SELECT @u6, c.id, 3750.00
FROM cuotas c
WHERE c.gasto_id = @g3 AND c.numero = 1;

INSERT INTO pagos_usuarios (usuario_id, cuota_id, importe)
SELECT @u7, c.id, 2000.00
FROM cuotas c
WHERE c.gasto_id = @g3 AND c.numero = 1;

-- G5, cuota 1: Sofía paga su parte
INSERT INTO pagos_usuarios (usuario_id, cuota_id, importe)
SELECT @u3, c.id, 8000.00
FROM cuotas c
WHERE c.gasto_id = @g5 AND c.numero = 1;

-- I1 (individual de Lucía): paga la cuota 1
INSERT INTO pagos_usuarios (usuario_id, cuota_id, importe)
SELECT @u1, c.id, 4000.00
FROM cuotas c
WHERE c.gasto_id = @i1 AND c.numero = 1;

-- I3 (individual de Valentina): paga la cuota 1
INSERT INTO pagos_usuarios (usuario_id, cuota_id, importe)
SELECT @u5, c.id, 5000.00
FROM cuotas c
WHERE c.gasto_id = @i3 AND c.numero = 1;
GO