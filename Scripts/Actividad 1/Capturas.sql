USE Guia_3;

SELECT 'Programa' AS Tabla, COUNT(*) AS Total FROM Programa
UNION ALL
SELECT 'Estudiante', COUNT(*) FROM Estudiante
UNION ALL
SELECT 'Profesor', COUNT(*) FROM Profesor
UNION ALL
SELECT 'Materia', COUNT(*) FROM Materia
UNION ALL
SELECT 'Grupo', COUNT(*) FROM Grupo
UNION ALL
SELECT 'Matricula', COUNT(*) FROM Matricula;

SELECT * FROM Matricula WHERE IdMatricula >= 14; -- desde 14 pq matricula ya tenia 13 antes