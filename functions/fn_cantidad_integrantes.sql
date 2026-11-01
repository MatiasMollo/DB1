USE TPO;
GO

CREATE OR ALTER FUNCTION fn_cantidad_integrantes
(
    @id_grupo INT
)

RETURNS TABLE
AS
RETURN
(
    SELECT 
    COUNT(*) AS cantidad_integrantes
    FROM grupos_usuarios AS gu
    WHERE gu.grupo_id = @id_grupo
);
GO

