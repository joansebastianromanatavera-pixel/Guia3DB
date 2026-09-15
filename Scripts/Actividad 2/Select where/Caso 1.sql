USE Guia_3;

-- CASO 1 (UPDATE): Actualización de datos de contacto por solicitud del estudiante

UPDATE Estudiante 
SET Telefono = '3198889900', 
    Direccion = 'Calle 160 #85-20'
WHERE IdEstudiante = 1031422990;

-- DESPUÉS
SELECT IdEstudiante, PrimerNombre, PrimerApellido, Telefono, Direccion 
FROM Estudiante 
WHERE IdEstudiante = 1031422990;