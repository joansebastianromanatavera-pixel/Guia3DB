USE Guia_3;

-- CASO 4 (UPDATE): Ajuste curricular en la duracion del programa academico

-- OPERACIÓN
UPDATE Programa 
SET Duracion = 9 
WHERE IdPrograma = 2;

-- DESPUÉS
SELECT IdPrograma, NombrePrograma, Duracion 
FROM Programa 
WHERE IdPrograma = 2;