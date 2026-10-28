USE TPO;
GO

-- Gastos grupales con su grupo, pagador, cantidad de participantes y cantidad de cuotas
CREATE OR ALTER VIEW v_gastos_grupos
AS
SELECT g.id AS gasto_id,
       g.nombre AS gasto,
       g.fecha,
       g.monto,
       gr.id AS grupo_id,
       gr.nombre AS grupo,
       u.id AS pagador_id,
       u.nombre AS pagador_nombre,
       u.apellido AS pagador_apellido,
       COUNT(ggu.id) AS cantidad_participantes, -- Una fila de gastos_grupos_usuarios por participante
       (SELECT COUNT(*)
        FROM cuotas AS c
        WHERE c.gasto_id = g.id) AS cantidad_cuotas
FROM gastos AS g
JOIN usuarios AS u ON u.id = g.usuario_id                          -- Quién adelantó el gasto
JOIN gastos_grupos_usuarios AS ggu ON ggu.gasto_id = g.id          -- Solo gastos con participantes (grupales)
JOIN grupos_usuarios AS gu ON gu.id = ggu.grupo_usuario_id         -- Participante -> membresía
JOIN grupos AS gr ON gr.id = gu.grupo_id                           -- Membresía -> grupo
GROUP BY g.id, g.nombre, g.fecha, g.monto,
         gr.id, gr.nombre,
         u.id, u.nombre, u.apellido;
GO
