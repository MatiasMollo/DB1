USE TPO;
GO

CREATE OR ALTER FUNCTION dbo.fn_total_pagado_usuario
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
