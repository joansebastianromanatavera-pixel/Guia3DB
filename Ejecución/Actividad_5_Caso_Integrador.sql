USE Guia_3;

-- =====================================================================
-- ACTIVIDAD 5 - CASO INTEGRADOR: SISTEMA EN OPERACIÓN
-- Simulación de 1 semana de operación (lunes a viernes)
-- Requiere haber ejecutado previamente: Tablas.sql, Datos.sql y
--   Actividad 4/Vistas.sql  (el reporte final usa esas 4 vistas).
-- Compatible con MySQL 8.x (Workbench) y MariaDB 10.2+ (Linux):
--   solo se usan INSERT/UPDATE/DELETE, vistas y SELECT estándar;
--   sin funciones de ventana, sin CTE, sin sintaxis propietaria debido a los fallos presentados en la entrega anterior.
-- =====================================================================


-- =====================================================================
-- (0) LIMPIEZA IDEMPOTENTE
-- Elimina únicamente lo que ESTA actividad crea, para poder re-ejecutar
-- el script completo sin errores de clave primaria duplicada.
-- (Un DELETE que no encuentra filas no genera error en MySQL ni MariaDB.)
-- =====================================================================
DELETE FROM Matricula WHERE IdMatricula BETWEEN 101 AND 105;
DELETE FROM Grupo     WHERE IdGrupo = 8;
DELETE FROM Materia   WHERE IdMateria = 208;


-- =====================================================================
-- DÍA 1 (LUNES) - APERTURA DE OFERTA + INSERCIÓN DE 5 NUEVOS REGISTROS
-- =====================================================================

-- Apertura de una nueva electiva y su grupo para el periodo vigente
-- (datos de apoyo necesarios para poder matricular estudiantes).
INSERT INTO Materia (IdMateria, NombreMateria, CreditosMateria, IdPrograma)
VALUES (208, 'Electiva: Bases de Datos NoSQL', 3, 1);

INSERT INTO Grupo (IdGrupo, IdMateria, IdProfesor, Periodo, Horario, Cupo)
VALUES (8, 208, 502, '2026-2', 'Sabado 8-10 am', 30);

-- ---------------------------------------------------------------------
-- LOS 5 NUEVOS REGISTROS (matrículas de la semana)
-- Ingresan en estado "Cursando": aún SIN nota final (NotaFinal = NULL).
-- ---------------------------------------------------------------------
INSERT INTO Matricula
    (IdMatricula, IdEstudiante, IdGrupo, FechaMatricula, NotaFinal, ValorMatricula)
VALUES
    (101, 1031422990, 8, '2026-09-07', NULL, 850000),
    (102, 1028886975, 8, '2026-09-07', NULL, 850000),
    (103, 1011765342, 8, '2026-09-08', NULL, 850000),
    (104, 1030281186, 8, '2026-09-08', NULL, 850000),
    (105, 1122151498, 8, '2026-09-09', NULL, 850000);

-- Verificación de la inserción
SELECT IdMatricula, IdEstudiante, IdGrupo, FechaMatricula, NotaFinal, ValorMatricula
FROM Matricula
WHERE IdMatricula BETWEEN 101 AND 105;


-- =====================================================================
-- DÍA 2 (MARTES) - ACTUALIZAR ESTADO: CUPO DEL GRUPO
-- Las 5 nuevas matrículas consumen 5 cupos del Grupo 8 (30 -> 25).
-- Se hace A TRAVÉS de la vista actualizable VistaGruposConCupo (Act. 4);
-- el WITH CHECK OPTION garantiza que el cupo resultante siga siendo > 0.
-- =====================================================================

-- ANTES
SELECT IdGrupo, Cupo FROM VistaGruposConCupo WHERE IdGrupo = 8;

UPDATE VistaGruposConCupo
SET Cupo = Cupo - 5
WHERE IdGrupo = 8;

-- DESPUÉS
SELECT IdGrupo, Cupo FROM VistaGruposConCupo WHERE IdGrupo = 8;


-- =====================================================================
-- DÍA 3 (MIÉRCOLES) - ACTUALIZAR ESTADO: NOTAS
-- 1) Cierre parcial: se registran las primeras notas de 2 de las nuevas
--    matrículas (estado "Cursando" -> "Calificado").
-- 2) Revisión académica: se corrige la nota de una matrícula existente.
-- =====================================================================

-- ANTES
SELECT IdMatricula, NotaFinal FROM Matricula WHERE IdMatricula IN (101, 102, 9);

-- 1) Registro de notas finales de las nuevas matrículas
UPDATE Matricula SET NotaFinal = 4.00 WHERE IdMatricula = 101;
UPDATE Matricula SET NotaFinal = 4.30 WHERE IdMatricula = 102;

-- 2) Corrección de nota tras revisión (Matricula 9: 3.5 -> 4.2)
UPDATE Matricula SET NotaFinal = 4.20 WHERE IdMatricula = 9;

-- DESPUÉS
SELECT IdMatricula, NotaFinal FROM Matricula WHERE IdMatricula IN (101, 102, 9);


-- =====================================================================
-- DÍA 4 (JUEVES) - ACTUALIZAR ESTADO: PAGO (BECA)
-- Se aplica una beca del 20% sobre el valor de TODAS las matrículas del
-- estudiante 1122151498 (estado de pago con descuento).
-- =====================================================================

-- ANTES
SELECT IdMatricula, ValorMatricula
FROM Matricula
WHERE IdEstudiante = 1122151498;

UPDATE Matricula
SET ValorMatricula = ValorMatricula * 0.80
WHERE IdEstudiante = 1122151498;

-- DESPUÉS
SELECT IdMatricula, ValorMatricula
FROM Matricula
WHERE IdEstudiante = 1122151498;


-- =====================================================================
-- DÍA 5 (VIERNES) - ELIMINAR DATOS OBSOLETOS
-- El Grupo 5 pertenece al periodo cerrado '2025-1' (año anterior).
-- Es información obsoleta: se depura junto con sus matrículas.
-- El orden respeta la integridad referencial: primero las matrículas
-- (tabla hija) y luego el grupo (tabla padre).
-- =====================================================================

-- ANTES: qué se va a eliminar
SELECT g.IdGrupo, g.Periodo, m.IdMatricula
FROM Grupo g
LEFT JOIN Matricula m ON m.IdGrupo = g.IdGrupo
WHERE g.Periodo = '2025-1';

-- 1) Matrículas del grupo obsoleto
DELETE FROM Matricula WHERE IdGrupo = 5;

-- 2) Grupo obsoleto
DELETE FROM Grupo WHERE IdGrupo = '5';

-- DESPUÉS: no debe devolver filas
SELECT g.IdGrupo, g.Periodo
FROM Grupo g
WHERE g.Periodo = '2025-1';


-- =====================================================================
-- REPORTE DE ESTADO SEMANAL (usando las vistas de la Actividad 4)
-- =====================================================================

-- --- 1. Detalle de matrículas activas (las nuevas aparecen; las que
--        aún no tienen nota se muestran con NotaFinal en NULL) ---------
SELECT '1. MATRICULAS ACTIVAS (detalle)' AS Reporte;
SELECT *
FROM VistaMatriculasCompletas
ORDER BY IdMatricula;

-- --- 2. Grupos con cupo disponible (refleja el ajuste del Grupo 8) ----
SELECT '2. GRUPOS CON CUPO DISPONIBLE' AS Reporte;
SELECT *
FROM VistaGruposConCupo
ORDER BY Cupo DESC;

-- --- 3. Rendimiento por programa (promedio de notas registradas) ------
SELECT '3. PROMEDIO Y ESTUDIANTES POR PROGRAMA' AS Reporte;
SELECT *
FROM VistaPromedioPorPrograma
ORDER BY PromedioNotas DESC;

-- --- 4. Carga académica por profesor ----------------------------------
SELECT '4. CARGA ACADEMICA POR PROFESOR' AS Reporte;
SELECT *
FROM VistaCargaProfesores
ORDER BY EstudiantesAtendidos DESC;

-- --- 5. Indicadores globales de la semana (calculados sobre la vista) --
SELECT '5. INDICADORES GLOBALES' AS Reporte;
SELECT
    COUNT(*)                                   AS TotalMatriculasActivas,
    SUM(CASE WHEN NotaFinal IS NULL THEN 1 ELSE 0 END) AS SinNotaAun,
    SUM(CASE WHEN NotaFinal IS NOT NULL THEN 1 ELSE 0 END) AS Calificadas,
    ROUND(AVG(NotaFinal), 2)                    AS PromedioGeneral,
    SUM(ValorMatricula)                         AS RecaudoTotal
FROM VistaMatriculasCompletas;
