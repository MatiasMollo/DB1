USE TPO;
GO

--Lo que debe cada usuario por cuota, lo que pagó, el saldo y el estado (Pagada, Parcial o Pendiente)
CREATE OR ALTER VIEW v_saldo_cuota_usuario
AS
SELECT d.cuota_id,
       d.gasto_id,
       d.gasto,
       d.numero_cuota,
       d.vencimiento,
       d.grupo_id,
       d.usuario_id,
       d.monto_correspondiente,
       ISNULL(p.total_pagado, 0) AS total_pagado, -- Si no hay pagos, el total es 0
       d.monto_correspondiente - ISNULL(p.total_pagado, 0) AS saldo_pendiente,
       CASE
           WHEN ISNULL(p.total_pagado, 0) >= d.monto_correspondiente THEN 'Pagada'
           WHEN ISNULL(p.total_pagado, 0) > 0 THEN 'Parcial'
           ELSE 'Pendiente'
       END AS estado
FROM v_deuda_cuota_usuario AS d
LEFT JOIN (
    --Total pagado por cada usuario en cada cuota (puede haber varios pagos parciales)
    SELECT cuota_id, usuario_id, SUM(importe) AS total_pagado
    FROM pagos_usuarios
    GROUP BY cuota_id, usuario_id
) AS p ON p.cuota_id = d.cuota_id AND p.usuario_id = d.usuario_id; --Left Join porque la cuota puede no tener pagos
GO
