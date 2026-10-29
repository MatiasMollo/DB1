USE TPO;
GO

CREATE OR ALTER FUNCTION dbo.fn_gastos_grupo
(
    @grupo_id INT
)
RETURNS TABLE
AS
RETURN
(
SELECT DISTINCT
    g.id,
    g.nombre,
    g.usuario_id,
    g.fecha,
    g.monto,
    FROM gastos AS g
    INNER JOIN gastos_grupos_usuarios AS ggu
    ON g.id = ggu.gastos_id
    INNER JOIN grupos_usuarios AS gu
    ON gu.id = ggu.grupo_usuario_id
    WHERE gu.grupo_id = @grupo_id
);
GO