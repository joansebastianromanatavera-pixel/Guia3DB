USE Guia_3;

-- CASO 2 (TRANSACCIÓN - ROLLBACK): Se intenta la misma operación de
-- transferencia pero se detecta un error de digitación en el valor
-- antes de confirmar, así que se deshace toda la operación.

-- ANTES
SELECT IdMatricula, IdEstudiante, ValorMatricula
FROM Matricula
WHERE IdMatricula IN (2, 7);

START TRANSACTION;

UPDATE Matricula
SET ValorMatricula = ValorMatricula - 300000
WHERE IdMatricula = 2;

UPDATE Matricula
SET ValorMatricula = ValorMatricula + 300000
WHERE IdMatricula = 7;

-- Verificación DENTRO de la transacción: aquí los valores SÍ cambiaron,
-- pero todavía no están confirmados en la base de datos
SELECT IdMatricula, IdEstudiante, ValorMatricula
FROM Matricula
WHERE IdMatricula IN (2, 7);

ROLLBACK;

-- DESPUÉS (vuelve al estado original porque se deshizo con ROLLBACK)
SELECT IdMatricula, IdEstudiante, ValorMatricula
FROM Matricula
WHERE IdMatricula IN (2, 7);
