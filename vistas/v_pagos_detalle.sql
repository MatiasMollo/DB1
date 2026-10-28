USE TPO;
GO

-- Historial de pagos con usuario, gasto y cuota
CREATE OR ALTER VIEW v_pagos_detalle
AS
SELECT pu.id AS pago_id,
       pu.fecha AS fecha_pago,
       pu.importe,
       u.id AS usuario_id,
       u.nombre,
       u.apellido,
       g.id AS gasto_id,
       g.nombre AS gasto,
       c.id AS cuota_id,
       c.numero AS numero_cuota
FROM pagos_usuarios AS pu
JOIN usuarios AS u ON u.id = pu.usuario_id -- Quién pagó
JOIN cuotas AS c ON c.id = pu.cuota_id     -- Qué cuota pagó
JOIN gastos AS g ON g.id = c.gasto_id;     -- A qué gasto pertenece esa cuota
GO
