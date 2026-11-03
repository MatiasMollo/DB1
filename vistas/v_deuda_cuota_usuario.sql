USE TPO;
GO

--Cuánto debe cada usuario por cada cuota 
CREATE OR ALTER VIEW v_deuda_cuota_usuario
AS
--Gastos grupales: la cuota se divide en partes iguales entre los participantes
SELECT c.id AS cuota_id,
       g.id AS gasto_id,
       g.nombre AS gasto,
       c.numero AS numero_cuota,
       c.vencimiento,
       gu.grupo_id,
       gu.usuario_id,
       CAST(c.monto / p.cantidad_participantes AS DECIMAL(10,2)) AS monto_correspondiente
FROM cuotas AS c
JOIN gastos AS g ON g.id = c.gasto_id
JOIN gastos_grupos_usuarios AS ggu ON ggu.gasto_id = g.id --Una fila por participante
JOIN grupos_usuarios AS gu ON gu.id = ggu.grupo_usuario_id
JOIN (
    --Cantidad de participantes de cada gasto grupal
    SELECT gasto_id, COUNT(*) AS cantidad_participantes
    FROM gastos_grupos_usuarios
    GROUP BY gasto_id
) AS p ON p.gasto_id = g.id

UNION ALL

--Gastos individuales: el dueño del gasto debe la cuota completa
SELECT c.id,
       g.id,
       g.nombre,
       c.numero,
       c.vencimiento,
       NULL,--No pertenece a ningún grupo
       g.usuario_id,
       c.monto
FROM cuotas AS c
JOIN gastos AS g ON g.id = c.gasto_id
WHERE NOT EXISTS (SELECT 1
                  FROM gastos_grupos_usuarios AS ggu
                  WHERE ggu.gasto_id = g.id); --Sin participantes = gasto individual
GO
