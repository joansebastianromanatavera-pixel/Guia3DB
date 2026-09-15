USE Guia_3;

-- CASO 1 (DELETE): Cancelacion voluntaria de matricula por parte del estudiante

-- OPERACIÓN
DELETE FROM Matricula 
WHERE IdMatricula = 5;

-- DESPUÉS
SELECT * 
FROM Matricula 
WHERE IdMatricula = 5;