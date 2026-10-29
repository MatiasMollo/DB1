USE TPO;
GO

CREATE OR ALTER FUNCTION dbo.fn_cuotas_pendientes
(
    @usuario_id INT
)

RETURNS TABLE
AS
RETURN

(
    FROM (
        SELECT
            g.id as gasto_id,
            g.nombre as gasto,
            c.numero,c.vencimiento,
            c.monto
        FROM dbo.fn_gastos_usuarios(@usuario_id) as g
        INNER JOIN cuotas as c
        ON g.id = c.gasto_id

        CASE 
            WHEN EXISTS (
                SELECT 1
                FROM gatos_grupos_usuarios AS ggu
                WHERE ggu.gasto_id = g.id
            )
            THEN (
                SELECT COUNT(*)
                FROM gastos_grupos_usuarios AS ggu
                WHERE ggu.gasto_id = g.id
            )
            ELSE 1
        END AS participantes
        )
        SELECT
            cu.gasto_id,
            cu.gasto,
            cu.cuota_id
            cu.numero,
            cu.monto,
            cu.participantes,
            cu.monto / cu.participantes AS monto_pendiente
            (
                SELECT SUM(pu.importe)
                FROM pagos_usuarios AS pu
                WHERE pu.cuota_id = cu.cuota_id
                AND pu.usuario_id = @usuario_id
            ) AS total_pagado
        FROM cuotas_del_usuario AS cu


        SELECT 
            calculos.*,
            calculos.importe_corresponde -
            CASE
                WHEN calculos.total_pagado IS NULL THEN 0
                ELSE calculos.total_pagado
            END AS importe_pendiente
            
        FROM (
            SELECT
                cu.gasto_id,
                cu.gasto,
                cu.cuota_id,
                cu.numero,
                cu.monto,
                cu.participantes,
                cu.monto / cu.participantes AS importe_corresponde,
                (
                    SELECT SUM(pu.importe)
                    FROM pagos_usuarios AS pu
                    WHERE pu.cuota_id = cu.cuota_id
                    AND pu.usuario_id = @usuario_id
                ) AS total_pagado
            FROM cuotas_del_usuario AS cu
        )AS calculos


        )  AS calculos
        WHERE calculos.importe_corresponde - 
        CASE
                WHEN calculos.total_pagado IS NULL THEN 0
                ELSE calculos.total_pagado
            END AS 0

);
GO