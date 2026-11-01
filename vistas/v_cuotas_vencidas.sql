USE TPO;
GO

--obtener cuotas vencidas

CREATE OR ALTER VIEW v_cuotas_vencidas
AS
SELECT
    c.id AS cuota_id,
    g.id AS gasto_id,
    g.nombre AS gasto,
    g.usuario_id,
    c.numero AS numero_cuota,
    c.monto AS monto_cuota,
    c.vencimiento
FROM cuotas AS c
INNER JOIN gastos AS g
    ON c.gasto_id = g.id
WHERE c.vencimiento < GETDATE();
GO