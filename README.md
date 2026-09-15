# Guía 3 — Manipulación de Datos, Transacciones y Vistas (MySQL)

Base de datos: **`Guia_3`** · SGBD: **MySQL 8.x (Workbench)** / compatible con **MariaDB 10.2+**

Sistema de gestión académica universitaria: programas, estudiantes, profesores, materias, grupos y matrículas. La guía recorre el ciclo completo de DML (INSERT / UPDATE / DELETE), control transaccional (COMMIT / ROLLBACK / SAVEPOINT), vistas (VIEWS) y un caso integrador que simula una semana de operación real.

---

## 1. Estructura del repositorio

```
Guia_3_VFFF/
├── Scripts/                          # Código fuente por actividad
│   ├── Tablas.sql                    # DDL: creación de la BD y las 6 tablas
│   ├── Datos.sql                     # Carga inicial (dataset base)
│   ├── Actividad 1/
│   │   ├── Inserciones.sql           # 10 INSERT unitarios + INSERT...SELECT + prueba FK
│   │   └── Capturas.sql              # Consultas de verificación (conteos)
│   ├── Actividad 2/
│   │   ├── Select where/Caso 1..5.sql # 5 casos de UPDATE ... WHERE
│   │   ├── Delete/Caso 1..3.sql       # 3 casos de DELETE ... WHERE
│   │   └── Delete on cascade.sql      # ALTER TABLE + ON DELETE CASCADE
│   ├── Actividad 3/
│   │   ├── Caso 1 - Commit.sql
│   │   ├── Caso 2 - Rollback.sql
│   │   └── Caso 3 - Savepoint.sql
│   ├── Actividad 4/Vistas.sql        # 4 vistas + análisis de actualizabilidad
│   └── Actividad 5/Actividad_5_Caso_Integrador.sql
├── Ejecución/                        # Copia de los scripts efectivamente ejecutados
│   ├── Tablas.sql · Datos.sql · Vistas.sql   (idénticos a Scripts/)
│   └── Actividad_5_Caso_Integrador.sql       (2 diferencias, ver §8)
└── Captruras/                        # Evidencias en imagen (PNG)
    ├── Actividad 1/                  # 3 capturas
    ├── Actividad 2/1 - Update where/ # antes/después de los 5 casos
    ├── Actividad 2/2 - Delete/       # antes/después de los 3 casos
    ├── Actividad 2/Delete on cascade - antes|despues.png
    ├── Actividad 4 y 5/              # vistas, tablas, datos, commits, rollback, savepoints
    └── Evidencias Actividad V/       # EVI1 … EVI6.10 del caso integrador
```

> Nota: la carpeta está escrita como `Captruras` (typo de `Capturas`) en el paquete original.

---

## 2. Modelo de datos

Seis tablas con integridad referencial en cascada de dependencias:

```
Programa (1) ──< Materia (1) ──< Grupo >── (1) Profesor
                                   │
                                   └──< Matricula >── (1) Estudiante
```

| Tabla | PK | FK | Campos clave |
|---|---|---|---|
| `Programa` | `IdPrograma` | — | Facultad, NombrePrograma, Duracion |
| `Estudiante` | `IdEstudiante` | — | Nombres/apellidos, Correo, Prefijo+Telefono, FechaNacimiento, Direccion |
| `Profesor` | `IdProfesor` | — | Nombres/apellidos, Correo, Teléfono, FechaNacimiento, Especialidad |
| `Materia` | `IdMateria` | `IdPrograma` → Programa | NombreMateria, CreditosMateria |
| `Grupo` | `IdGrupo` | `IdMateria` → Materia, `IdProfesor` → Profesor | Periodo, Horario, Cupo |
| `Matricula` | `IdMatricula` | `IdEstudiante` → Estudiante, `IdGrupo` → Grupo | FechaMatricula, NotaFinal `DECIMAL(3,2)`, ValorMatricula |

`Tablas.sql` hace `DROP TABLE IF EXISTS` en orden inverso de dependencia (Matricula → Grupo → Materia → Profesor → Estudiante → Programa) para poder re-ejecutarse sin violar claves foráneas.

### Dataset base (`Datos.sql`)

Hace `TRUNCATE` de las 6 tablas con `foreign_key_checks = 0` y recarga:

- **5 programas** — Ingeniería de Software, Enfermería, Cine y Televisión, Administración de Empresas, Psicología (8 semestres c/u).
- **5 estudiantes** — IDs `1031422990`, `1011765342`, `1028886975`, `1030281186`, `1122151498`.
- **5 profesores** — IDs `501`–`505`, con especialidad.
- **5 materias** — IDs `201`–`205` (3 de Ing. de Software, 2 de Psicología).
- **5 grupos** — IDs `1`–`5`. El grupo `5` es del periodo **`2025-1`** (obsoleto, se depura en la Actividad 5); los demás son `2026-2`.
- **13 matrículas** — IDs `1`–`13`, con notas entre 3.5 y 4.8 y valores entre 450.000 y 1.200.000.

---

## 3. Orden de ejecución

Los scripts son dependientes entre sí. Ejecutar en este orden:

```
1. Scripts/Tablas.sql                     -- crea BD y tablas
2. Scripts/Datos.sql                      -- carga dataset base (13 matrículas)
3. Scripts/Actividad 1/Inserciones.sql    -- añade registros nuevos
4. Scripts/Actividad 2/*                  -- UPDATE / DELETE / CASCADE
5. Scripts/Actividad 3/*                  -- transacciones
6. Scripts/Actividad 4/Vistas.sql         -- crea las 4 vistas (REQUISITO de la Act. 5)
7. Scripts/Actividad 5/Actividad_5_Caso_Integrador.sql
```

La Actividad 5 **depende explícitamente** de `Tablas.sql`, `Datos.sql` y `Vistas.sql`, porque su reporte final consulta las 4 vistas.

---

## 4. Actividad 1 — Inserción de datos

**Archivo:** `Scripts/Actividad 1/Inserciones.sql` · **Evidencias:** `Captruras/Actividad 1/` (3 capturas)

Comienza con un bloque de `DELETE` idempotente (borra los IDs que este script crea, en orden hijo → padre) para poder re-ejecutarse sin error de PK duplicada.

### 4.1 Diez inserciones unitarias (`INSERT INTO ... VALUES`)

| # | Tabla | Registro insertado |
|---|---|---|
| 1 | Programa | `6` — Ingeniería Biomédica (10 semestres) |
| 2 | Estudiante | `1098765432` — Carlos Alberto Mendoza Pérez |
| 3 | Estudiante | `1087654321` — Laura Camila Torres Ríos |
| 4 | Profesor | `506` — Diego Fernando Castillo Mora (Inteligencia Artificial) |
| 5 | Profesor | `507` — Sonia Patricia Navarro Silva (Bases de Datos Avanzadas) |
| 6 | Materia | `206` — Arquitectura de Software (3 créditos, programa 1) |
| 7 | Materia | `207` — Biomecánica (4 créditos, programa 6) |
| 8 | Grupo | `6` — Materia 206, Profesor 506, cupo 30 |
| 9 | Grupo | `7` — Materia 207, Profesor 507, cupo 25 |
| 10 | Matricula | `14` — Estudiante 1098765432 en Grupo 6, nota 4.10 |

El orden respeta la integridad referencial: primero los padres (Programa, Estudiante, Profesor), luego Materia → Grupo → Matricula.

### 4.2 Inserción masiva (`INSERT INTO ... SELECT`)

Matricula todos los estudiantes existentes (excepto el `1098765432`, que ya está matriculado) en los grupos `6` y `7` mediante un `CROSS JOIN`:

```sql
INSERT INTO Matricula (...)
SELECT (14 + ROW_NUMBER() OVER (ORDER BY e.IdEstudiante, g.IdGrupo)) AS IdMatricula,
       e.IdEstudiante, g.IdGrupo, '2026-08-03',
       CAST(ROUND(3.00 + (RAND() * 1.90), 2) AS DECIMAL(3,2)),
       850000
FROM Estudiante e CROSS JOIN Grupo g
WHERE g.IdGrupo IN (6, 7) AND e.IdEstudiante <> 1098765432;
```

Puntos técnicos:
- `ROW_NUMBER() OVER (...)` genera IDs consecutivos a partir de 14 sin necesidad de AUTO_INCREMENT.
- `RAND()` produce notas aleatorias en el rango **3.00 – 4.90**, redondeadas a 2 decimales para encajar en `DECIMAL(3,2)`.
- Requiere MySQL 8.x (las funciones de ventana no existen en versiones anteriores).

### 4.3 Verificación de clave foránea

Línea comentada al final, pensada para ejecutarse manualmente (Ctrl+Enter) y demostrar el error:

```sql
-- INSERT INTO Matricula VALUES (999, 9999999999, 1, '2026-08-05', 3.5, 500000);
```

El estudiante `9999999999` no existe → MySQL rechaza la operación con error 1452 (`Cannot add or update a child row: a foreign key constraint fails`). Es la prueba de que la restricción FK está activa.

### 4.4 Verificación (`Capturas.sql`)

Un `UNION ALL` que cuenta filas en las 6 tablas, más un `SELECT * FROM Matricula WHERE IdMatricula >= 14` (el corte en 14 porque el dataset base ya traía 13 matrículas).

---

## 5. Actividad 2 — Actualización y eliminación

**Evidencias:** `Captruras/Actividad 2/` — cada caso tiene captura *antes* y *después*.

Todos los scripts siguen el mismo patrón: comentario con la justificación de negocio → operación DML → `SELECT` de verificación.

### 5.1 Cinco casos de `UPDATE ... WHERE`

| Caso | Justificación de negocio | Operación |
|---|---|---|
| 1 | Actualización de datos de contacto por solicitud del estudiante | `UPDATE Estudiante SET Telefono, Direccion WHERE IdEstudiante = 1031422990` |
| 2 | Ampliación de cupo por alta demanda | `UPDATE Grupo SET Cupo = Cupo + 10 WHERE IdGrupo = 2` |
| 3 | Bonificación por taller extracurricular | `UPDATE Matricula SET NotaFinal = LEAST(5.00, NotaFinal + 0.20) WHERE IdGrupo = 4` |
| 4 | Ajuste curricular en la duración del programa | `UPDATE Programa SET Duracion = 9 WHERE IdPrograma = 2` |
| 5 | Descuento institucional del 10% en matrículas altas | `UPDATE Matricula SET ValorMatricula = ROUND(ValorMatricula * 0.90) WHERE ValorMatricula > 1000000` |

Detalles de diseño:
- **Caso 2 y 3** usan actualización *relativa* (`Cupo = Cupo + 10`), no un valor fijo: el nuevo valor depende del actual.
- **Caso 3** protege el dominio de la nota con `LEAST(5.00, ...)`: ninguna nota puede superar 5.00 aunque se sume la bonificación.
- **Caso 5** afecta múltiples filas a la vez (todas las matrículas con valor > 1.000.000, es decir las de 1.200.000) y verifica con `IdMatricula IN (1, 6, 9)`.

### 5.2 Tres casos de `DELETE ... WHERE`

| Caso | Justificación | Operación | Resultado esperado |
|---|---|---|---|
| 1 | Cancelación voluntaria de matrícula | `DELETE FROM Matricula WHERE IdMatricula = 5` | `SELECT` posterior devuelve 0 filas |
| 2 | Cierre de grupo académico sin inscritos | `DELETE FROM Grupo WHERE IdGrupo = 5` | 0 filas |
| 3 | Anulación de aspirante sin historial | `DELETE FROM Estudiante WHERE IdEstudiante = 1099999999` | 0 filas |

El orden importa: el Caso 1 elimina la matrícula del grupo 5 **antes** de que el Caso 2 elimine el grupo; de lo contrario la FK bloquearía la operación.

### 5.3 `ON DELETE CASCADE`

**Archivo:** `Actividad 2/Delete on cascade.sql`

Reconfiguración estructural (DDL) de la FK de `Matricula`:

```sql
ALTER TABLE Matricula DROP FOREIGN KEY `1`;

ALTER TABLE Matricula
ADD CONSTRAINT fk_matricula_estudiante_cascade
FOREIGN KEY (IdEstudiante) REFERENCES Estudiante(IdEstudiante)
ON DELETE CASCADE;

DELETE FROM Estudiante WHERE IdEstudiante = 1098887777;
```

Demostración: al borrar el estudiante, MySQL elimina automáticamente **todas sus matrículas**. Los dos `SELECT` finales (sobre `Estudiante` y sobre `Matricula`) deben devolver cero filas, probando el borrado en cascada.

> Advertencia: `` DROP FOREIGN KEY `1` `` usa el nombre autogenerado de la restricción. Ese nombre puede variar entre entornos; conviene confirmarlo con `SHOW CREATE TABLE Matricula;` antes de ejecutar.

---

## 6. Actividad 3 — Control transaccional

**Evidencias:** `Captruras/Actividad 4 y 5/Actividad3-Commits*.png`, `Actividad3-Rollback.png`, `Actividad3-savepoints*.png`

Nota de diseño declarada en el propio script: el esquema no tiene tabla `Cuenta`/`Saldo`, así que se usa **`ValorMatricula` como si fuera el saldo**, replicando el principio de una transferencia bancaria (dos UPDATE que deben ejecutarse como una sola unidad atómica).

### Caso 1 — `COMMIT`

Reembolso administrativo transferido entre matrículas:

```sql
START TRANSACTION;
  UPDATE Matricula SET ValorMatricula = ValorMatricula - 200000 WHERE IdMatricula = 1;  -- débito
  UPDATE Matricula SET ValorMatricula = ValorMatricula + 200000 WHERE IdMatricula = 6;  -- crédito
  SELECT ...;   -- verificación DENTRO de la transacción
COMMIT;
SELECT ...;     -- cambios ya permanentes
```

Demuestra **atomicidad**: los dos UPDATE se confirman juntos. El `SELECT` intermedio muestra los valores modificados pero aún no definitivos.

### Caso 2 — `ROLLBACK`

Misma operación (300.000 entre matrículas 2 y 7), pero se detecta un error de digitación antes de confirmar:

```sql
START TRANSACTION;
  UPDATE ... -300000 WHERE IdMatricula = 2;
  UPDATE ... +300000 WHERE IdMatricula = 7;
  SELECT ...;   -- los valores SÍ cambiaron, pero no están confirmados
ROLLBACK;
SELECT ...;     -- vuelve al estado original
```

Demuestra que el `ROLLBACK` revierte la transacción completa. Comparar los dos `SELECT` (antes/después) es la evidencia: son idénticos.

### Caso 3 — `SAVEPOINT`

Dos transferencias dentro de una misma transacción; la segunda tiene un error de negocio y se deshace **solo esa parte**:

```sql
START TRANSACTION;
  -- Transferencia 1 (correcta): Matricula 9 → Matricula 10, 100.000
  SAVEPOINT despues_transferencia_1;
  -- Transferencia 2 (errónea): Matricula 10 → Matricula 11, 100.000
  SELECT ...;   -- las TRES matrículas están afectadas en este punto
ROLLBACK TO SAVEPOINT despues_transferencia_1;
COMMIT;
```

**Resultado final:** las matrículas 9 y 10 conservan la Transferencia 1; la matrícula 11 queda sin cambios. Demuestra reversión **parcial** — el concepto central del savepoint.

---

## 7. Actividad 4 — Vistas (VIEWS)

**Archivo:** `Scripts/Actividad 4/Vistas.sql` (136 líneas) · **Evidencias:** `Captruras/Actividad 4 y 5/Actividad4-Vistas*.png` (11 capturas)

Empieza con `DROP VIEW IF EXISTS` de las cuatro vistas (script re-ejecutable).

### Vista 1 — `VistaMatriculasCompletas`

JOIN de **5 tablas** (Matricula, Estudiante, Grupo, Materia, Profesor). Responde la consulta más frecuente del caso: quién está matriculado, en qué materia, con qué profesor y con qué nota. Usa `CONCAT` para armar nombres completos.

Consultas de prueba: listado completo, filtro `NotaFinal >= 4.5`, y agregación `GROUP BY Profesor` para contar estudiantes atendidos.

### Vista 2 — `VistaGruposConCupo` — **la única actualizable**

```sql
CREATE VIEW VistaGruposConCupo AS
SELECT IdGrupo, IdMateria, IdProfesor, Periodo, Horario, Cupo
FROM Grupo WHERE Cupo > 0
WITH CHECK OPTION;
```

Una sola tabla base, sin agregaciones → MySQL puede mapear cada fila a una fila única de `Grupo`. El script incluye tres pruebas:

1. **UPDATE válido** (`Cupo = Cupo + 5`): funciona, sigue cumpliendo `Cupo > 0`.
2. **UPDATE inválido** (`Cupo = 0`, comentado): falla con `CHECK OPTION failed` porque rompería el `WHERE` que define la vista.
3. **INSERT a través de la vista** (comentado): también sujeto al `CHECK OPTION`.

### Vista 3 — `VistaPromedioPorPrograma`

`COUNT(DISTINCT ...)`, `AVG(...)` y `GROUP BY` sobre un JOIN de 5 tablas → **no actualizable en ningún SGBD estándar**. El script deja comentado un `UPDATE` que debe arrojar `The target table ... is not updatable`.

### Vista 4 — `VistaCargaProfesores`

Reporte administrativo: grupos a cargo y estudiantes atendidos por profesor. Usa `LEFT JOIN` (para incluir profesores con grupos vacíos) + `GROUP BY` + `HAVING` → tampoco actualizable.

### Verificación formal de actualizabilidad

```sql
SELECT TABLE_NAME AS Vista, IS_UPDATABLE
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'Guia_3';
```

| Vista | ¿Actualizable? | Motivo |
|---|---|---|
| `VistaMatriculasCompletas` | **NO** | multi-JOIN de 5 tablas |
| `VistaGruposConCupo` | **SÍ** | una sola tabla base, sin agregaciones (+ `WITH CHECK OPTION`) |
| `VistaPromedioPorPrograma` | **NO** | `GROUP BY` + funciones agregadas |
| `VistaCargaProfesores` | **NO** | `JOIN` + `GROUP BY` + `HAVING` |

**Regla general** (conclusión del informe): una vista es actualizable solo si el SGBD puede mapear cada fila del resultado a una única fila de una única tabla base, sin agregaciones, `DISTINCT`, `GROUP BY`, `HAVING` ni `UNION` de por medio.

---

## 8. Actividad 5 — Caso integrador: sistema en operación

**Archivo:** `Scripts/Actividad 5/Actividad_5_Caso_Integrador.sql` (179 líneas) · **Evidencias:** `Captruras/Evidencias Actividad V/` (EVI1 … EVI6.10, 24 capturas)

Simula **una semana completa de operación** (lunes a viernes). Escrito deliberadamente sin funciones de ventana, sin CTE y sin sintaxis propietaria, para que funcione tanto en MySQL 8.x como en MariaDB 10.2+.

Arranca con un bloque de limpieza idempotente (`DELETE` de matrículas 101–105, grupo 8 y materia 208) que permite re-ejecutar el script completo.

### Día 1 (lunes) — Apertura de oferta e inserción

- Nueva materia `208` — *Electiva: Bases de Datos NoSQL* (3 créditos, programa 1).
- Nuevo grupo `8` — profesor 502, periodo 2026-2, sábados 8-10 am, **cupo 30**.
- **Los 5 registros nuevos**: matrículas `101`–`105`, todas en el grupo 8, con `NotaFinal = NULL` (estado "Cursando", aún sin calificar) y valor 850.000.

### Día 2 (martes) — Actualizar estado: cupo

Las 5 matrículas consumen 5 cupos (**30 → 25**). La actualización se hace **a través de la vista actualizable** `VistaGruposConCupo`, no directamente sobre la tabla — así se conecta la Actividad 4 con la 5, y el `WITH CHECK OPTION` garantiza que el cupo resultante siga siendo > 0.

### Día 3 (miércoles) — Actualizar estado: notas

1. Cierre parcial: se registran las primeras notas (`101 → 4.00`, `102 → 4.30`), pasando de "Cursando" a "Calificado".
2. Revisión académica: se corrige la nota de una matrícula preexistente (`Matricula 9: 3.5 → 4.20`).

### Día 4 (jueves) — Actualizar estado: pago

Beca del 20% sobre **todas** las matrículas del estudiante `1122151498`:

```sql
UPDATE Matricula SET ValorMatricula = ValorMatricula * 0.80 WHERE IdEstudiante = 1122151498;
```

### Día 5 (viernes) — Eliminar datos obsoletos

El grupo `5` pertenece al periodo cerrado `2025-1`. Se depura respetando la integridad referencial: **primero la tabla hija, después la padre**.

```sql
DELETE FROM Matricula WHERE IdGrupo = 5;   -- 1) hija
DELETE FROM Grupo WHERE Periodo = '2025-1'; -- 2) padre
```

El `SELECT` de verificación debe devolver cero filas.

### Reporte de estado semanal

Cinco bloques, todos construidos **sobre las vistas de la Actividad 4**:

1. Detalle de matrículas activas (`VistaMatriculasCompletas`) — las nuevas aparecen, las no calificadas con `NotaFinal` en NULL.
2. Grupos con cupo disponible (`VistaGruposConCupo`) — refleja el ajuste del grupo 8.
3. Promedio y estudiantes por programa (`VistaPromedioPorPrograma`).
4. Carga académica por profesor (`VistaCargaProfesores`).
5. **Indicadores globales** calculados sobre la vista:

```sql
SELECT COUNT(*) AS TotalMatriculasActivas,
       SUM(CASE WHEN NotaFinal IS NULL THEN 1 ELSE 0 END) AS SinNotaAun,
       SUM(CASE WHEN NotaFinal IS NOT NULL THEN 1 ELSE 0 END) AS Calificadas,
       ROUND(AVG(NotaFinal), 2) AS PromedioGeneral,
       SUM(ValorMatricula) AS RecaudoTotal
FROM VistaMatriculasCompletas;
```

### Diferencias entre `Scripts/` y `Ejecución/`

La copia en `Ejecución/` del caso integrador tiene dos cambios respecto a la de `Scripts/`:

| Línea | `Scripts/` | `Ejecución/` |
|---|---|---|
| 10 | `...sin sintaxis propietaria.` | `...sin sintaxis propietaria debido a los fallos presentados en la entrega anterior.` |
| 134 | `DELETE FROM Grupo WHERE Periodo = '2025-1';` | `DELETE FROM Grupo WHERE IdGrupo = '5';` |

La versión de `Scripts/` es la más correcta conceptualmente (borra por criterio de negocio —periodo obsoleto— y no por un ID concreto). Los otros tres archivos (`Tablas.sql`, `Datos.sql`, `Vistas.sql`) son idénticos en ambas carpetas.

---

## 9. Conceptos demostrados

| Concepto | Dónde |
|---|---|
| DDL con orden de dependencias | `Tablas.sql` |
| `INSERT` unitario y masivo (`INSERT...SELECT`, `CROSS JOIN`, `ROW_NUMBER`) | Actividad 1 |
| Violación de FK como prueba de integridad | Actividad 1 |
| `UPDATE` relativo, `LEAST()`, actualización multi-fila | Actividad 2 |
| `DELETE` respetando el orden hija → padre | Actividad 2 y 5 |
| `ALTER TABLE` + `ON DELETE CASCADE` | Actividad 2 |
| Atomicidad: `START TRANSACTION` / `COMMIT` | Actividad 3 |
| Reversión total: `ROLLBACK` | Actividad 3 |
| Reversión parcial: `SAVEPOINT` / `ROLLBACK TO SAVEPOINT` | Actividad 3 |
| Vistas multi-JOIN, de agregación y actualizables | Actividad 4 |
| `WITH CHECK OPTION` | Actividad 4 y 5 |
| `INFORMATION_SCHEMA.VIEWS` / `IS_UPDATABLE` | Actividad 4 |
| Escritura DML a través de una vista | Actividad 5, Día 2 |
| Scripts idempotentes y reportes con `CASE WHEN` | Actividad 5 |

---

## 10. Observaciones y puntos de mejora

**Sobre los datos** (`Datos.sql`):

- Correo con typo: `andresduenas.fm@academima.umb.edu.co` (debería ser `academia`).
- Fechas de nacimiento inverosímiles en `Profesor`: `1901-02-20` (ID 504) y `1575-04-18` (ID 505).
- Tres profesores comparten el mismo teléfono `3135548965` (IDs 502, 504, 505).
- `ValorMatricula` está declarado `INT` pero los datos se insertan como `950000.00`; MySQL trunca el decimal sin avisar. Convendría `DECIMAL(10,2)`.
- Un estudiante tiene fecha de nacimiento de 1991 y el resto de 2006-2007 — verificar si es intencional.

**Sobre el código:**

- `` ALTER TABLE Matricula DROP FOREIGN KEY `1` `` depende de un nombre autogenerado; es frágil entre entornos. Mejor nombrar las FK explícitamente en `Tablas.sql`.
- `Actividad 1/Inserciones.sql` usa `ROW_NUMBER()`, que rompe la compatibilidad con MariaDB que sí busca la Actividad 5.
- `DELETE FROM Estudiante WHERE IdEstudiante = 1099999999` y el caso de cascada sobre `1098887777` referencian registros que no existen en `Datos.sql`; hay que crearlos antes o el `DELETE` afecta 0 filas (no da error, pero la evidencia queda vacía).
- La carpeta de evidencias está escrita `Captruras`.
