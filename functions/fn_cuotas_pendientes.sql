USE TPO;
GO

/*
    Retorna todas las cuotas pendientes que tiene el usuario (solo individuales)
*/
CREATE OR ALTER FUNCTION dbo.fn_cuotas_individuales_pendientes
(
    @usuario_id INT
)

RETURNS TABLE
AS
RETURN
(
    SELECT 
        gasto_id,
        gasto,
        cuota_id,
        numero,
        vencimiento,
        monto,
        total_pagado,
        monto_pendiente
    FROM (
        SELECT
            g.id as gasto_id,
            g.nombre as gasto,
            c.id as cuota_id,
            c.numero,
            c.vencimiento,
            c.monto,
            ISNULL(p.total_pagado, 0) AS total_pagado, -- En caso de que no haya pagado (null) se escribe "0"
            c.monto - ISNULL(p.total_pagado, 0) AS monto_pendiente
        FROM fn_gastos_usuario(@usuario_id) as g -- Reutilización de función de gastos individuales
        JOIN cuotas AS c ON c.gasto_id = g.id
        LEFT JOIN ( -- Solo Left Join porque la cuota puede no tener pagos asociados
            -- Total pagado por el usuario en cada cuota (una fila por cuota). Esto se usa porque el usuario puede hacer pagos parciales
            SELECT
                pu.cuota_id,
                SUM(pu.importe) AS total_pagado -- En caso de haber mas de un pago asignado a una cuota, se obtiene la suma
            FROM pagos_usuarios AS pu
            WHERE pu.usuario_id = @usuario_id
            GROUP BY pu.cuota_id
        ) AS p ON p.cuota_id = c.id
        WHERE c.monto - ISNULL(p.total_pagado, 0) > 0 -- con saldo pendiente
    ) AS tabla
);
GO