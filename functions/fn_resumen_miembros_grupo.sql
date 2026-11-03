USE TPO;
GO

--Por cada miembro de un grupo: cuánto le corresponde pagar, cuánto pagó y cuánto le falta
--Reutiliza v_saldo_cuota_usuario
CREATE OR ALTER FUNCTION fn_resumen_miembros_grupo
(
    @grupo_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT u.id AS usuario_id,
           u.nombre,
           u.apellido,
           SUM(s.monto_correspondiente) AS total_correspondiente,
           SUM(s.total_pagado) AS total_pagado,
           SUM(s.saldo_pendiente) AS saldo_pendiente
    FROM v_saldo_cuota_usuario AS s
    JOIN usuarios AS u ON u.id = s.usuario_id
    WHERE s.grupo_id = @grupo_id
    GROUP BY u.id, u.nombre, u.apellido
);
GO
