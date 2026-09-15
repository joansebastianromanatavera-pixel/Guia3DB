USE Guia_3;

DELETE FROM Matricula WHERE IdMatricula >= 14;
DELETE FROM Grupo WHERE IdGrupo IN (6, 7);
DELETE FROM Materia WHERE IdMateria IN (206, 207);
DELETE FROM Profesor WHERE IdProfesor IN (506, 507);
DELETE FROM Estudiante WHERE IdEstudiante IN (1098765432, 1087654321);
DELETE FROM Programa WHERE IdPrograma = 6;

-- 1. DIEZ INSERCIONES UNITARIAS (INSERT INTO ... VALUES)

INSERT INTO Programa VALUES (
    6, 'Ingenieria', 'Ingenieria Biomedica', 10
);

INSERT INTO Estudiante VALUES (
    1098765432, 'Carlos', 'Alberto', 'Mendoza', 'Perez', 
    'carlosmendoza@academia.umb.edu.co', '+57', '3001234567', '2005-03-14', 'Carrera 15 #45-12'
);

INSERT INTO Estudiante VALUES (
    1087654321, 'Laura', 'Camila', 'Torres', 'Rios', 
    'lauratorres@academia.umb.edu.co', '+57', '3187654321', '2006-11-22', 'Calle 72 #10-34'
);

INSERT INTO Profesor VALUES (
    506, 'Diego', 'Fernando', 'Castillo', 'Mora', 
    'diego.castillo@docentes.umb.edu.co', '+57', '3209876543', '1983-08-19', 'Inteligencia Artificial'
);

INSERT INTO Profesor VALUES (
    507, 'Sonia', 'Patricia', 'Navarro', 'Silva', 
    'sonia.navarro@docentes.umb.edu.co', '+57', '3114567890', '1979-04-05', 'Bases de Datos Avanzadas'
);

INSERT INTO Materia VALUES (
    206, 'Arquitectura de Software', 3, 1
);

INSERT INTO Materia VALUES (
    207, 'Biomecanica', 4, 6
);

INSERT INTO Grupo VALUES (
    6, 206, 506, '2026-2', 'Lunes 8-10 am y Miercoles 8-10 am', 30
);

INSERT INTO Grupo VALUES (
    7, 207, 507, '2026-2', 'Viernes 2-6 pm', 25
);

INSERT INTO Matricula VALUES (
    14, 1098765432, 6, '2026-08-02', 4.10, 850000
);

-- 2. INSERCIÓN MASIVA (INSERT INTO ... SELECT)

INSERT INTO Matricula (IdMatricula, IdEstudiante, IdGrupo, FechaMatricula, NotaFinal, ValorMatricula)
SELECT 
    (14 + ROW_NUMBER() OVER (ORDER BY e.IdEstudiante, g.IdGrupo)) AS IdMatricula,
    e.IdEstudiante,
    g.IdGrupo,
    '2026-08-03' AS FechaMatricula,
    CAST(ROUND(3.00 + (RAND() * 1.90), 2) AS DECIMAL(3,2)) AS NotaFinal,
    850000 AS ValorMatricula
FROM Estudiante e
CROSS JOIN Grupo g
WHERE g.IdGrupo IN (6, 7)
  AND e.IdEstudiante <> 1098765432;

-- 3. VERIFICACIÓN DE CLAVE FORÁNEA
-- CORRER CON CTRL ENTER
-- INSERT INTO Matricula VALUES (999, 9999999999, 1, '2026-08-05', 3.5, 500000);