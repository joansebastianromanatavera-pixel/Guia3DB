USE Guia_3;

-- CASO 1 (TRANSACCIÓN - COMMIT): Reembolso administrativo transferido
-- de la matrícula de un estudiante a otro dentro del mismo periodo.
-- Nota: el esquema no tiene tabla "Cuenta"/"Saldo"; se usa ValorMatricula
-- como el "saldo" que se transfiere, siguiendo el mismo principio que
-- una transferencia bancaria (dos UPDATE que deben ejecutarse como
-- una sola unidad atómica).

-- ANTES
SELECT IdMatricula, IdEstudiante, ValorMatricula
FROM Matricula
WHERE IdMatricula IN (1, 6);

START TRANSACTION;

-- Débito en la matrícula origen
UPDATE Matricula
SET ValorMatricula = ValorMatricula - 200000
WHERE IdMatricula = 1;

-- Crédito en la matrícula destino
UPDATE Matricula
SET ValorMatricula = ValorMatricula + 200000
WHERE IdMatricula = 6;

-- Verificación DENTRO de la transacción (aún no es definitivo)
SELECT IdMatricula, IdEstudiante, ValorMatricula
FROM Matricula
WHERE IdMatricula IN (1, 6);

COMMIT;

-- DESPUÉS (los cambios ya son permanentes por el COMMIT)
SELECT IdMatricula, IdEstudiante, ValorMatricula
FROM Matricula
WHERE IdMatricula IN (1, 6);
