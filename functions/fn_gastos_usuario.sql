USE TPO;
GO

/*
    Retorna todos los gastos de un usuario por id
*/
CREATE OR ALTER FUNCTION fn_gastos_usuario
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
    g.monto
    FROM gastos AS g
    LEFT JOIN gastos_grupos_usuarios AS ggu ON g.id = ggu.gasto_id
    WHERE ggu.id IS NULL -- Se verifica que el gasto no esté registrado como grupal
    AND g.usuario_id = @usuario_id
);
go