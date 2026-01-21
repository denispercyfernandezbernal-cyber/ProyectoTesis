-- ============================================
-- SCRIPT DE MATRÍCULA DE ALUMNOS EN MATERIAS - SECUNDARIA
-- I.E. N° 16793 "EULALIO VILLEGAS RAMOS"
-- ============================================
-- Este script matricula a TODOS los alumnos de SECUNDARIA
-- en TODAS las materias de SECUNDARIA
-- Basado en el principio: todos los alumnos deben estar inscritos en todas las materias

-- Insertar matrículas: cada alumno de secundaria en todas las materias
INSERT INTO alumno_materias (alumno_id, materia_id, grado_seccion_id, nivel, created_at, updated_at)
SELECT DISTINCT
    a.id as alumno_id,
    m.id as materia_id,
    a.grado_seccion_id,
    'SECUNDARIA' as nivel,
    CURRENT_TIMESTAMP as created_at,
    CURRENT_TIMESTAMP as updated_at
FROM alumnos a
CROSS JOIN materias m
WHERE a.nivel = 'SECUNDARIA'
    AND a.deleted_at IS NULL
    AND m.deleted_at IS NULL
ON CONFLICT (alumno_id, materia_id, grado_seccion_id) DO NOTHING;

-- Verificar el total de matrículas creadas
SELECT 
    COUNT(*) as total_matriculas
FROM alumno_materias
WHERE nivel = 'SECUNDARIA'
    AND deleted_at IS NULL;

-- Verificar matrículas por grado-sección
SELECT 
    gs.nombre_completo as grado_seccion,
    COUNT(DISTINCT am.alumno_id) as total_alumnos,
    COUNT(DISTINCT am.materia_id) as total_materias,
    COUNT(*) as total_matriculas
FROM alumno_materias am
JOIN alumnos a ON am.alumno_id = a.id
JOIN grado_seccion gs ON am.grado_seccion_id = gs.id
WHERE am.nivel = 'SECUNDARIA'
    AND am.deleted_at IS NULL
    AND a.deleted_at IS NULL
GROUP BY gs.id, gs.nombre_completo
ORDER BY gs.id;

-- Verificar matrículas por materia
SELECT 
    m.nombre as materia,
    COUNT(DISTINCT am.alumno_id) as total_alumnos_matriculados
FROM alumno_materias am
JOIN materias m ON am.materia_id = m.id
WHERE am.nivel = 'SECUNDARIA'
    AND am.deleted_at IS NULL
    AND m.deleted_at IS NULL
GROUP BY m.id, m.nombre
ORDER BY m.nombre;

-- Verificar el alumno específico (00000063073255) en COMUNICACIÓN
SELECT 
    a.codigo_estudiante,
    a.nombres,
    a.apellido_paterno,
    a.apellido_materno,
    gs.nombre_completo as grado_seccion,
    m.nombre as materia,
    am.created_at as fecha_matricula
FROM alumno_materias am
JOIN alumnos a ON am.alumno_id = a.id
JOIN materias m ON am.materia_id = m.id
JOIN grado_seccion gs ON am.grado_seccion_id = gs.id
WHERE a.codigo_estudiante = '00000063073255'
    AND m.nombre = 'COMUNICACIÓN'
    AND am.deleted_at IS NULL;

-- Verificar todos los alumnos de PRIMERO A matriculados en COMUNICACIÓN
SELECT 
    a.codigo_estudiante,
    a.nombres,
    a.apellido_paterno,
    a.apellido_materno,
    m.nombre as materia
FROM alumno_materias am
JOIN alumnos a ON am.alumno_id = a.id
JOIN materias m ON am.materia_id = m.id
JOIN grado_seccion gs ON am.grado_seccion_id = gs.id
WHERE gs.id = 7  -- PRIMERO A
    AND m.nombre = 'COMUNICACIÓN'
    AND am.deleted_at IS NULL
    AND a.deleted_at IS NULL
ORDER BY a.apellido_paterno, a.apellido_materno;

-- RESUMEN: Verificar que todos los alumnos de secundaria tienen todas las materias
SELECT 
    gs.nombre_completo as grado_seccion,
    COUNT(DISTINCT a.id) as total_alumnos,
    COUNT(DISTINCT m.id) as total_materias,
    COUNT(DISTINCT a.id) * COUNT(DISTINCT m.id) as matriculas_esperadas,
    COUNT(am.id) as matriculas_actuales,
    CASE 
        WHEN COUNT(am.id) = COUNT(DISTINCT a.id) * COUNT(DISTINCT m.id) 
        THEN '✅ COMPLETO'
        ELSE '❌ FALTANTE'
    END as estado
FROM grado_seccion gs
LEFT JOIN alumnos a ON a.grado_seccion_id = gs.id AND a.nivel = 'SECUNDARIA' AND a.deleted_at IS NULL
LEFT JOIN materias m ON m.deleted_at IS NULL
LEFT JOIN alumno_materias am ON am.grado_seccion_id = gs.id 
    AND am.alumno_id = a.id 
    AND am.materia_id = m.id 
    AND am.deleted_at IS NULL
WHERE gs.nivel = 'SECUNDARIA'
GROUP BY gs.id, gs.nombre_completo
ORDER BY gs.id;
