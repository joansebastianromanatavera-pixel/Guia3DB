USE Guia_3;

-- CASO 3 (UPDATE): Bonificación de nota final por participación en taller extracurricular

-- OPERACIÓN
UPDATE Matricula 
SET NotaFinal = LEAST(5.00, NotaFinal + 0.20)
WHERE IdGrupo = 4;

-- DESPUÉS
SELECT IdMatricula, IdEstudiante, IdGrupo, NotaFinal 
FROM Matricula 
WHERE IdGrupo = 4;