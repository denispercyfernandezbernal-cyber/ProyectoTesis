-- ============================================
-- SCRIPT DE VERIFICACIÓN DE MATRÍCULA DE ALUMNO
-- Verificar matrícula del alumno 00000063073255 en COMUNICACIÓN - PRIMERO A
-- ============================================

-- 1. Verificar si el alumno existe
SELECT 
    id,
    codigo_estudiante,
    nombres,
    apellido_paterno,
    apellido_materno,
    grado_seccion_id,
    nivel,
    estado_matricula,
    deleted_at
FROM alumnos
WHERE codigo_estudiante = '00000063073255';

-- 2. Verificar el grado-sección del alumno
SELECT 
    a.id as alumno_id,
    a.codigo_estudiante,
    a.nombres,
    a.apellido_paterno,
    a.apellido_materno,
    a.grado_seccion_id,
    gs.nombre_completo as grado_seccion,
    a.nivel,
    a.estado_matricula
FROM alumnos a
LEFT JOIN grado_seccion gs ON a.grado_seccion_id = gs.id
WHERE a.codigo_estudiante = '00000063073255';

-- 3. Verificar si el alumno está matriculado en COMUNICACIÓN
SELECT 
    am.id as alumno_materia_id,
    a.codigo_estudiante,
    a.nombres,
    a.apellido_paterno,
    a.apellido_materno,
    m.id as materia_id,
    m.nombre as materia,
    gs.id as grado_seccion_id,
    gs.nombre_completo as grado_seccion,
    am.created_at,
    am.deleted_at
FROM alumno_materias am
JOIN alumnos a ON am.alumno_id = a.id
JOIN materias m ON am.materia_id = m.id
LEFT JOIN grado_seccion gs ON a.grado_seccion_id = gs.id
WHERE a.codigo_estudiante = '00000063073255'
    AND m.nombre = 'COMUNICACIÓN'
    AND am.deleted_at IS NULL;

-- 4. Verificar todas las materias en las que está matriculado el alumno
SELECT 
    m.id as materia_id,
    m.nombre as materia,
    gs.nombre_completo as grado_seccion,
    am.created_at as fecha_matricula,
    am.deleted_at
FROM alumno_materias am
JOIN alumnos a ON am.alumno_id = a.id
JOIN materias m ON am.materia_id = m.id
LEFT JOIN grado_seccion gs ON a.grado_seccion_id = gs.id
WHERE a.codigo_estudiante = '00000063073255'
    AND am.deleted_at IS NULL
ORDER BY m.nombre;

-- 5. Verificar si la materia COMUNICACIÓN existe y su ID
SELECT 
    id,
    nombre,
    nivel,
    deleted_at
FROM materias
WHERE nombre = 'COMUNICACIÓN'
    AND deleted_at IS NULL;

-- 6. Verificar si PRIMERO A tiene la materia COMUNICACIÓN asignada
SELECT 
    da.id as asignacion_id,
    u.dni,
    u.nombres_completos as docente,
    m.nombre as materia,
    gs.id as grado_seccion_id,
    gs.nombre_completo as grado_seccion
FROM docente_asignaciones da
JOIN usuarios u ON da.docente_id = u.id
JOIN materias m ON da.materia_id = m.id
JOIN grado_seccion gs ON da.grado_seccion_id = gs.id
WHERE m.nombre = 'COMUNICACIÓN'
    AND gs.id = 7  -- PRIMERO A
    AND u.deleted_at IS NULL
    AND m.deleted_at IS NULL;

-- 7. Verificar todos los alumnos matriculados en COMUNICACIÓN de PRIMERO A
SELECT 
    a.codigo_estudiante,
    a.nombres,
    a.apellido_paterno,
    a.apellido_materno,
    gs.nombre_completo as grado_seccion,
    m.nombre as materia
FROM alumno_materias am
JOIN alumnos a ON am.alumno_id = a.id
JOIN materias m ON am.materia_id = m.id
JOIN grado_seccion gs ON a.grado_seccion_id = gs.id
WHERE m.nombre = 'COMUNICACIÓN'
    AND gs.id = 7  -- PRIMERO A
    AND am.deleted_at IS NULL
    AND a.deleted_at IS NULL
ORDER BY a.apellido_paterno, a.apellido_materno;

-- 8. RESUMEN: Verificar si el alumno debería estar matriculado
-- (Verifica si el alumno está en PRIMERO A y si existe la materia COMUNICACIÓN)
SELECT 
    CASE 
        WHEN a.id IS NULL THEN '❌ El alumno NO existe'
        WHEN a.grado_seccion_id != 7 THEN CONCAT('❌ El alumno NO está en PRIMERO A, está en: ', COALESCE(gs.nombre_completo, 'Sin grado'))
        WHEN m.id IS NULL THEN '❌ La materia COMUNICACIÓN NO existe'
        WHEN am.id IS NULL THEN '❌ El alumno NO está matriculado en COMUNICACIÓN'
        WHEN am.deleted_at IS NOT NULL THEN '❌ La matrícula fue eliminada (soft delete)'
        ELSE '✅ El alumno SÍ está matriculado correctamente'
    END as estado_matricula,
    a.codigo_estudiante,
    a.nombres,
    a.apellido_paterno,
    a.apellido_materno,
    gs.nombre_completo as grado_seccion_actual,
    m.nombre as materia
FROM alumnos a
LEFT JOIN grado_seccion gs ON a.grado_seccion_id = gs.id
LEFT JOIN materias m ON m.nombre = 'COMUNICACIÓN' AND m.deleted_at IS NULL
LEFT JOIN alumno_materias am ON am.alumno_id = a.id 
    AND am.materia_id = m.id 
    AND am.deleted_at IS NULL
WHERE a.codigo_estudiante = '00000063073255';
