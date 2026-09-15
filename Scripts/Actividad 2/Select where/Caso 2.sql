USE Guia_3;

-- CASO 2 (UPDATE): Ampliación de cupo por alta demanda académica

-- OPERACIÓN
UPDATE Grupo 
SET Cupo = Cupo + 10 
WHERE IdGrupo = 2;

-- DESPUÉS
SELECT IdGrupo, IdMateria, Cupo 
FROM Grupo 
WHERE IdGrupo = 2;