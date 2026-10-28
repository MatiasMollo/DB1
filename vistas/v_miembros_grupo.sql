USE TPO;
GO

-- Grupos con sus integrantes y fecha de ingreso
CREATE OR ALTER VIEW v_miembros_grupo
AS
SELECT g.id AS grupo_id,
       g.nombre AS grupo,
       gu.id AS grupo_usuario_id, -- Se expone para poder cruzar luego con gastos_grupos_usuarios
       u.id AS usuario_id,
       u.nombre,
       u.apellido,
       gu.fecha_ingreso
FROM grupos AS g
JOIN grupos_usuarios AS gu ON gu.grupo_id = g.id -- Relación grupo -> miembros
JOIN usuarios AS u ON u.id = gu.usuario_id;      -- Datos de cada miembro
GO
