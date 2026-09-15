USE Guia_3;

-- =====================================================================
-- ACTIVIDAD 4 - CONSTRUCCIÓN DE VISTAS (VIEWS)
-- =====================================================================

DROP VIEW IF EXISTS VistaMatriculasCompletas;
DROP VIEW IF EXISTS VistaGruposConCupo;
DROP VIEW IF EXISTS VistaPromedioPorPrograma;
DROP VIEW IF EXISTS VistaCargaProfesores;

-- ---------------------------------------------------------------------
-- VISTA 1: VistaMatriculasCompletas
-- Simplifica la consulta más frecuente del caso de estudio: ver quién
-- está matriculado, en qué materia, con qué profesor y qué nota tiene.
-- JOIN entre 5 tablas (cumple el requisito de JOIN >= 2 tablas).
-- ---------------------------------------------------------------------
CREATE VIEW VistaMatriculasCompletas AS
SELECT
    m.IdMatricula,
    CONCAT(e.PrimerNombre, ' ', e.PrimerApellido) AS Estudiante,
    mat.NombreMateria,
    CONCAT(p.PrimerNombreProfesor, ' ', p.PrimerApellidoProfesor) AS Profesor,
    g.Periodo,
    m.NotaFinal,
    m.ValorMatricula
FROM Matricula m
JOIN Estudiante e ON m.IdEstudiante = e.IdEstudiante
JOIN Grupo g       ON m.IdGrupo = g.IdGrupo
JOIN Materia mat   ON g.IdMateria = mat.IdMateria
JOIN Profesor p    ON g.IdProfesor = p.IdProfesor;

-- Consultas sobre la vista
SELECT * FROM VistaMatriculasCompletas ORDER BY IdMatricula;
SELECT * FROM VistaMatriculasCompletas WHERE NotaFinal >= 4.5;
SELECT Profesor, COUNT(*) AS EstudiantesAtendidos
FROM VistaMatriculasCompletas
GROUP BY Profesor
ORDER BY EstudiantesAtendidos DESC;


-- ---------------------------------------------------------------------
-- VISTA 2: VistaGruposConCupo
-- Basada en una sola tabla (Grupo) -> SÍ es actualizable.
-- WITH CHECK OPTION impide que una actualización deje un grupo con
-- Cupo <= 0 (violaría el WHERE que define la vista).
-- ---------------------------------------------------------------------
CREATE VIEW VistaGruposConCupo AS
SELECT IdGrupo, IdMateria, IdProfesor, Periodo, Horario, Cupo
FROM Grupo
WHERE Cupo > 0
WITH CHECK OPTION;

-- Consulta sobre la vista
SELECT * FROM VistaGruposConCupo ORDER BY Cupo DESC;

-- Prueba de actualización VÁLIDA a través de la vista (sigue cumpliendo Cupo > 0)
UPDATE VistaGruposConCupo SET Cupo = Cupo + 5 WHERE IdGrupo = 2;
SELECT * FROM VistaGruposConCupo WHERE IdGrupo = 2;

-- Prueba de actualización INVÁLIDA (debe fallar por el WITH CHECK OPTION;
-- descomentar para ver el error "CHECK OPTION failed" en Workbench)
-- UPDATE VistaGruposConCupo SET Cupo = 0 WHERE IdGrupo = 2;

-- Prueba de INSERT a través de la vista (también respeta el CHECK OPTION)
-- INSERT INTO VistaGruposConCupo VALUES (8, 201, 501, '2026-2', 'Sabado 8-10 am', 20);
-- SELECT * FROM Grupo WHERE IdGrupo = 8;


-- ---------------------------------------------------------------------
-- VISTA 3: VistaPromedioPorPrograma
-- Usa funciones de agregación (COUNT, AVG) y GROUP BY -> NO es
-- actualizable en ningún SGBD estándar.
-- ---------------------------------------------------------------------
CREATE VIEW VistaPromedioPorPrograma AS
SELECT
    pr.NombrePrograma,
    COUNT(DISTINCT e.IdEstudiante) AS TotalEstudiantes,
    ROUND(AVG(m.NotaFinal), 2) AS PromedioNotas
FROM Programa pr
JOIN Materia mat    ON mat.IdPrograma = pr.IdPrograma
JOIN Grupo g        ON g.IdMateria = mat.IdMateria
JOIN Matricula m    ON m.IdGrupo = g.IdGrupo
JOIN Estudiante e   ON e.IdEstudiante = m.IdEstudiante
GROUP BY pr.NombrePrograma;

-- Consultas sobre la vista
SELECT * FROM VistaPromedioPorPrograma ORDER BY PromedioNotas DESC;
SELECT * FROM VistaPromedioPorPrograma WHERE TotalEstudiantes > 1;

-- Prueba de que NO es actualizable (debe arrojar error de MySQL:
-- "The target table VistaPromedioPorPrograma of the UPDATE is not updatable")
-- UPDATE VistaPromedioPorPrograma SET PromedioNotas = 5.0 WHERE NombrePrograma = 'Psicologia';


-- ---------------------------------------------------------------------
-- VISTA 4: VistaCargaProfesores
-- Reporte de carga académica: grupos y estudiantes atendidos por cada
-- profesor. Usa JOIN + GROUP BY + HAVING -> tampoco es actualizable,
-- pero es un ejemplo típico de vista de reporte administrativo.
-- ---------------------------------------------------------------------
CREATE VIEW VistaCargaProfesores AS
SELECT
    CONCAT(p.PrimerNombreProfesor, ' ', p.PrimerApellidoProfesor) AS Profesor,
    p.Especialidad,
    COUNT(DISTINCT g.IdGrupo) AS GruposACargo,
    COUNT(m.IdMatricula) AS EstudiantesAtendidos
FROM Profesor p
JOIN Grupo g        ON g.IdProfesor = p.IdProfesor
LEFT JOIN Matricula m ON m.IdGrupo = g.IdGrupo
GROUP BY p.IdProfesor, Profesor, p.Especialidad
HAVING COUNT(DISTINCT g.IdGrupo) >= 1;

-- Consulta sobre la vista
SELECT * FROM VistaCargaProfesores ORDER BY EstudiantesAtendidos DESC;


-- =====================================================================
-- VERIFICACIÓN FORMAL DE ACTUALIZABILIDAD (además de las pruebas UPDATE)
-- MySQL expone esto directamente en INFORMATION_SCHEMA.VIEWS
-- =====================================================================
SELECT TABLE_NAME AS Vista, IS_UPDATABLE
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'Guia_3';

-- =====================================================================
-- ANÁLISIS PARA EL INFORME:
-- - VistaMatriculasCompletas: NO (multi-JOIN de 5 tablas).
-- - VistaGruposConCupo: SÍ (una sola tabla base, sin agregaciones); el
--   WITH CHECK OPTION además impide romper la condición WHERE al escribir.
-- - VistaPromedioPorPrograma: NO (usa GROUP BY + funciones agregadas).
-- - VistaCargaProfesores: NO (usa JOIN + GROUP BY + HAVING).
-- En general: una vista es actualizable solo si MySQL puede mapear cada
-- fila resultante a una única fila de una única tabla base, sin
-- agregaciones, DISTINCT, GROUP BY, HAVING ni UNION de por medio.
-- =====================================================================
