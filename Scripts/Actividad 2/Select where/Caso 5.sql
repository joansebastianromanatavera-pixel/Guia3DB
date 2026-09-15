USE Guia_3;

-- CASO 5 (UPDATE): Aplicacion de descuento institucional del 10% en matriculas de alto valor

-- OPERACIÓN
UPDATE Matricula 
SET ValorMatricula = ROUND(ValorMatricula * 0.90)
WHERE IdMatricula > 0 
  AND ValorMatricula > 1000000;

-- DESPUÉS
SELECT IdMatricula, IdEstudiante, ValorMatricula 
FROM Matricula 
WHERE IdMatricula IN (1, 6, 9);