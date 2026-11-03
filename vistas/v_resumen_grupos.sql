USE TPO;
GO

--Resumen por grupo: cantidad de integrantes, cantidad de gastos y monto total gastado
CREATE OR ALTER VIEW v_resumen_grupos
AS
SELECT gr.id AS grupo_id,
       gr.nombre AS grupo,
       (SELECT COUNT(*)
        FROM grupos_usuarios AS gu
        WHERE gu.grupo_id = gr.id) AS cantidad_integrantes,-- Subconsulta: integrantes del grupo
       COUNT(g.id) AS cantidad_gastos,
       ISNULL(SUM(g.monto), 0) AS total_gastado
FROM grupos AS gr
LEFT JOIN (
    --Un registro por gasto y grupo (sin repetir por cada participante)
    SELECT DISTINCT gu.grupo_id, ggu.gasto_id
    FROM gastos_grupos_usuarios AS ggu
    JOIN grupos_usuarios AS gu ON gu.id = ggu.grupo_usuario_id
) AS gg ON gg.grupo_id = gr.id -- Left Join para incluir grupos sin gastos
LEFT JOIN gastos AS g ON g.id = gg.gasto_id
GROUP BY gr.id, gr.nombre;
GO
