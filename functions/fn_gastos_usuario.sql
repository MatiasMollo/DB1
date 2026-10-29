USE TPO;
GO

CREATE OR ALTER FUNCTION dbo.fn_gastos_usuario
(
    @usuario_id INT
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
    LEFT JOIN gastos_grupos_usuarios AS ggu
    ON g.id = ggu.gasto_id
    LEFT JOIN grupos_usuarios AS gu
    ON ggu.grupo_usuario_id = gu.id
    WHERE (
        AND NOT EXISTS (
        SELECT 'ENCONTRO'
        FROM gastos_grupos_usuarios AS ggu2
        WHERE ggu2.gasto_id = g.id
        )
        OR gu.usuario_id = @usuario_id
    )
);
go