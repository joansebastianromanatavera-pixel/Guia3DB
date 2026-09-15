USE Guia_3;

-- CASO 3 (TRANSACCIÓN - SAVEPOINT): Un administrador hace DOS
-- transferencias dentro de la misma transacción. La primera es correcta
-- y debe conservarse; la segunda tiene un error de negocio (el estudiante
-- destino no debía recibir el abono) y se deshace SOLO esa parte,
-- usando un punto de control (SAVEPOINT), sin perder la primera operación.

-- ANTES
SELECT IdMatricula, IdEstudiante, ValorMatricula
FROM Matricula
WHERE IdMatricula IN (9, 10, 11);

START TRANSACTION;

-- Transferencia 1 (correcta): de la Matricula 9 a la Matricula 10
UPDATE Matricula SET ValorMatricula = ValorMatricula - 100000 WHERE IdMatricula = 9;
UPDATE Matricula SET ValorMatricula = ValorMatricula + 100000 WHERE IdMatricula = 10;

-- Punto de control: si algo falla después de aquí, esta parte se conserva
SAVEPOINT despues_transferencia_1;

-- Transferencia 2 (con error de negocio): de la Matricula 10 a la Matricula 11
UPDATE Matricula SET ValorMatricula = ValorMatricula - 100000 WHERE IdMatricula = 10;
UPDATE Matricula SET ValorMatricula = ValorMatricula + 100000 WHERE IdMatricula = 11;

-- Verificación: las TRES matrículas están afectadas en este punto
SELECT IdMatricula, IdEstudiante, ValorMatricula
FROM Matricula
WHERE IdMatricula IN (9, 10, 11);

-- Se detecta el error de negocio en la Transferencia 2: se deshace SOLO
-- hasta el savepoint, conservando la Transferencia 1
ROLLBACK TO SAVEPOINT despues_transferencia_1;

COMMIT;

-- DESPUÉS: la Matricula 9 y 10 quedan con la Transferencia 1 aplicada,
-- y la Matricula 11 queda sin cambios (la Transferencia 2 se deshizo)
SELECT IdMatricula, IdEstudiante, ValorMatricula
FROM Matricula
WHERE IdMatricula IN (9, 10, 11);
