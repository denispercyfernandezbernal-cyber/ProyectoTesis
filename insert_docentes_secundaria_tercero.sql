-- ============================================
-- SCRIPT DE ASIGNACIONES DE DOCENTES - TERCERO A
-- I.E. N° 16793 "EULALIO VILLEGAS RAMOS"
-- ============================================
-- NOTA: Los docentes ya fueron insertados previamente
-- Este script solo crea las asignaciones para TERCERO A (grado_seccion_id = 9)
-- Total: 11 asignaciones (algunos docentes tienen 2 materias)

-- Asignación 1: PALACIOS DURAND GLADYS SILVIA -> COMUNICACIÓN -> TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '27995531' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'COMUNICACIÓN' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '27995531');

-- Asignación 2: YRIGOÍN NÚÑEZ ROGER -> MATEMATICA -> TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '33673704' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'MATEMATICA' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '33673704');

-- Asignación 3: MINCHAN CRISOSTOMO TEOFILO -> CIENCIAS SOCIALES -> TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '33568570' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'CIENCIAS SOCIALES' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '33568570');

-- Asignación 4: MINCHAN CRISOSTOMO TEOFILO -> DESARROLLO PERSONAL, CUIDADANIA Y CIVICA -> TERCERO A (segunda materia del mismo docente)
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '33568570' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'DESARROLLO PERSONAL, CUIDADANIA Y CIVICA' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '33568570');

-- Asignación 5: VENTURA PINCHI MICHAEL -> TUTORIA -> TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '73425024' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'TUTORIA' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '73425024');

-- Asignación 6: CHUQUIMANGO DÍAZ JUCE SANE -> ARTE Y CULTURA -> TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '44009597' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'ARTE Y CULTURA' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '44009597');

-- Asignación 7: CHUQUIMANGO DÍAZ JUCE SANE -> EDUCACION RELIGIOSA -> TERCERO A (segunda materia del mismo docente)
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '44009597' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'EDUCACION RELIGIOSA' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '44009597');

-- Asignación 8: MENDOZA MEDINA SEGUNDO ALEJANDRO -> CIENCIA Y TECNOLOGIA -> TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '33563003' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'CIENCIA Y TECNOLOGIA' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '33563003');

-- Asignación 9: ROJAS CULQUI NELIDA -> EDUCACION PARA EL TRABAJO -> TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '45019362' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'EDUCACION PARA EL TRABAJO' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '45019362');

-- Asignación 10: ROJAS CULQUI NELIDA -> INGLES -> TERCERO A (segunda materia del mismo docente)
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '45019362' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'INGLES' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '45019362');

-- Asignación 11: CERDAN JIMENEZ DUVI HOLVER -> EDUCACION FISICA -> TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '43137938' LIMIT 1),
    9, -- TERCERO A
    (SELECT id FROM materias WHERE nombre = 'EDUCACION FISICA' AND deleted_at IS NULL LIMIT 1),
    'SECUNDARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '43137938');

-- Verificar asignaciones para TERCERO A (debería mostrar 11 registros)
SELECT 
    u.dni,
    u.nombres_completos,
    m.nombre as materia,
    gs.nombre_completo as grado_seccion,
    da.nivel
FROM docente_asignaciones da
JOIN usuarios u ON da.docente_id = u.id
JOIN materias m ON da.materia_id = m.id
JOIN grado_seccion gs ON da.grado_seccion_id = gs.id
WHERE u.nivel = 'SECUNDARIA' 
    AND gs.id = 9 -- TERCERO A
    AND u.deleted_at IS NULL
    AND m.deleted_at IS NULL
ORDER BY u.nombres_completos, m.nombre;

-- Resumen: Contar asignaciones por docente en TERCERO A
SELECT 
    u.dni,
    u.nombres_completos,
    COUNT(da.id) as total_materias
FROM docente_asignaciones da
JOIN usuarios u ON da.docente_id = u.id
JOIN grado_seccion gs ON da.grado_seccion_id = gs.id
WHERE u.nivel = 'SECUNDARIA' 
    AND gs.id = 9 -- TERCERO A
    AND u.deleted_at IS NULL
GROUP BY u.dni, u.nombres_completos
ORDER BY total_materias DESC, u.nombres_completos;
