USE TPO;
GO

--Cantidad de gastos y total gastado por categoría para los gastos que registró un usuario
CREATE OR ALTER FUNCTION fn_gastos_por_categoria
(
    @usuario_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT cat.id AS categoria_id,
           cat.nombre AS categoria,
           COUNT(g.id) AS cantidad_gastos,
           SUM(g.monto) AS total_gastado
    FROM gastos AS g
    JOIN categorias AS cat ON cat.id = g.categoria_id
    WHERE g.usuario_id = @usuario_id
    GROUP BY cat.id, cat.nombre
);
GO
