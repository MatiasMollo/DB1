USE TPO;
GO

--Cuotas con saldo pendiente de un usuario que vencen dentro de un rango de fechas (por ejemplo, el mes)
--Reutiliza v_saldo_cuota_usuario
CREATE OR ALTER FUNCTION fn_cuotas_vencen_en
(
    @usuario_id INT,
    @desde DATE,
    @hasta DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT cuota_id,
           gasto,
           numero_cuota,
           vencimiento,
           monto_correspondiente,
           total_pagado,
           saldo_pendiente,
           estado
    FROM v_saldo_cuota_usuario
    WHERE usuario_id = @usuario_id
      AND vencimiento BETWEEN @desde AND @hasta
      AND saldo_pendiente > 0 --Solo lo que falta pagar
);
GO
