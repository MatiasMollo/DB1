USE TPO;
GO

/*
    Retorna las cuotas que estan próximas a vencer (desde ahora hasta dentro de los próximos 7 días)
*/
CREATE OR ALTER VIEW v_cuotas_proximas_vencer
AS
SELECT c.id AS cuota_id,
       g.nombre AS gasto,
       c.numero AS numero_cuota,
       c.monto,
       c.vencimiento
FROM cuotas AS c
INNER JOIN gastos AS g
    ON c.gasto_id = g.id
WHERE c.vencimiento >= GETDATE() AND c.vencimiento < GETDATE() + 7;
GO