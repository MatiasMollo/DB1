USE TPO;
GO

/*
    Retorna el monto total abonado por el usuario (gastos individuales y grupales)
*/
CREATE OR ALTER FUNCTION fn_total_pagado_usuario
(
    @usuario_id INT
)

RETURNS TABLE
AS
RETURN
(
    SELECT
        SUM(pu.importe) AS total_pagado
    FROM pagos_usuarios AS pu
    WHERE pu.usuario_id = @usuario_id
);
GO
