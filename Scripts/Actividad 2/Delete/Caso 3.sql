USE Guia_3;

-- CASO 3 (DELETE): Anulacion de registro de aspirante sin historial academico

-- OPERACION
DELETE FROM Estudiante 
WHERE IdEstudiante = 1099999999;

-- DESPUES
SELECT * 
FROM Estudiante 
WHERE IdEstudiante = 1099999999;