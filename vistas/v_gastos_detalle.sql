USE TPO;
GO

-- Todos los gastos (grupales e individuales) con un campo tipo
CREATE OR ALTER VIEW v_gastos_detalle
AS
SELECT g.id AS gasto_id,
       g.nombre AS gasto,
       g.fecha,
       g.monto,
       u.id AS pagador_id,
       u.nombre AS pagador_nombre,
       u.apellido AS pagador_apellido,
       CASE
           WHEN EXISTS (SELECT 1
                        FROM gastos_grupos_usuarios AS ggu
                        WHERE ggu.gasto_id = g.id) THEN 'Grupal'
           ELSE 'Individual'
       END AS tipo, -- Si tiene participantes es grupal, si no es individual
       (SELECT COUNT(*)
        FROM cuotas AS c
        WHERE c.gasto_id = g.id) AS cantidad_cuotas
FROM gastos AS g
JOIN usuarios AS u ON u.id = g.usuario_id; -- Quién adelantó el gasto
GO
