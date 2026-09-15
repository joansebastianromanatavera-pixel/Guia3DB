USE Guia_3;

-- CASO 2 (DELETE): Cierre de grupo academico sin estudiantes inscritos

-- OPERACIÓN
DELETE FROM Grupo 
WHERE IdGrupo = 5;

-- DESPUÉS
SELECT * 
FROM Grupo 
WHERE IdGrupo = 5;