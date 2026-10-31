USE TPO;
GO

-- Gastos personales (sin participantes) con su dueño
CREATE OR ALTER VIEW v_gastos_individuales
AS
SELECT g.id AS gasto_id,
       g.nombre AS gasto,
       g.fecha,
       g.monto,
       (SELECT COUNT(*)
        FROM cuotas AS c
        WHERE c.gasto_id = g.id) AS cantidad_cuotas, -- Subconsulta: cuenta las cuotas de cada gasto
       u.id AS usuario_id,
       u.nombre,
       u.apellido
FROM gastos AS g
JOIN usuarios AS u ON u.id = g.usuario_id -- Dueño del gasto
LEFT JOIN gastos_grupos_usuarios AS ggu ON ggu.gasto_id = g.id -- Trae participantes si existen
WHERE ggu.id IS NULL;-- Sin participantes = gasto individual
GO
