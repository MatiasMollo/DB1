USE TPO;
GO
--DETECTAMOS el error de si hay gastos sin cuotas
CREAT OR ALTER VIEW v_gastos_sin_cuotas
AS
SELECT
    g.id AS gasto_id,
    g.nombre AS gasto,
    g.usuario_id,
    g.fecha,
    g.monto
FROM gastos AS g
LEFT JOIN cuotas AS c 
    ON g.id = c.gastos_id
WHERE c.id IS NULL;
GO 