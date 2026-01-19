-- ============================================
-- SCRIPT DE INSERCIÓN DE DOCENTES - PRIMARIA
-- I.E. N° 16793 "EULALIO VILLEGAS RAMOS"
-- ============================================
-- Contraseña para todos: 123
-- Hash bcrypt de "123": $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- Insertar docentes de PRIMARIA
INSERT INTO usuarios (dni, nombres_completos, nivel, cargo, condicion, jornada_laboral, password_hash)
VALUES
    -- Docente de PRIMERO A
    ('12345678', 'ÁGUILAR BAUTISTA', 'PRIMARIA', 'DOCENTE', 'Nombrado', 'Completa', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    
    -- Docente de SEGUNDO A
    ('23456789', 'TERAN BURGOS', 'PRIMARIA', 'DOCENTE', 'Nombrado', 'Completa', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    
    -- Docente de TERCERO A
    ('34567890', 'REGALADO VILCHEZ', 'PRIMARIA', 'DOCENTE', 'Nombrado', 'Completa', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    
    -- Docente de CUARTO A
    ('45678901', 'ANGELDONES GOMEZ', 'PRIMARIA', 'DOCENTE', 'Nombrado', 'Completa', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    
    -- Docente de QUINTO A
    ('56789012', 'MOSQUEDA CULLAMPE', 'PRIMARIA', 'DOCENTE', 'Nombrado', 'Completa', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    
    -- Docente de SEXTO A
    ('67890123', 'VELIZ MURILLO', 'PRIMARIA', 'DOCENTE', 'Nombrado', 'Completa', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    
    -- Docente de EDUCACIÓN FÍSICA (enseña a todos los grados)
    ('78901234', 'LUCANO LLATAS', 'PRIMARIA', 'DOCENTE', 'Nombrado', 'Completa', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy');

-- Crear asignaciones de docentes a grados-secciones
-- Nota: grado_seccion_id corresponde a: 1=PRIMERO A, 2=SEGUNDO A, 3=TERCERO A, 4=CUARTO A, 5=QUINTO A, 6=SEXTO A

-- Asignación: ÁGUILAR BAUTISTA -> PRIMERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '12345678' LIMIT 1),
    1, -- PRIMERO A
    NULL, -- Sin materia para PRIMARIA
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '12345678');

-- Asignación: TERAN BURGOS -> SEGUNDO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '23456789' LIMIT 1),
    2, -- SEGUNDO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '23456789');

-- Asignación: REGALADO VILCHEZ -> TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '34567890' LIMIT 1),
    3, -- TERCERO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '34567890');

-- Asignación: ANGELDONES GOMEZ -> CUARTO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '45678901' LIMIT 1),
    4, -- CUARTO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '45678901');

-- Asignación: MOSQUEDA CULLAMPE -> QUINTO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '56789012' LIMIT 1),
    5, -- QUINTO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '56789012');

-- Asignación: VELIZ MURILLO -> SEXTO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '67890123' LIMIT 1),
    6, -- SEXTO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '67890123');

-- Asignaciones: LUCANO LLATAS (Educación Física) -> Todos los grados de PRIMARIA
-- PRIMERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '78901234' LIMIT 1),
    1, -- PRIMERO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '78901234');

-- SEGUNDO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '78901234' LIMIT 1),
    2, -- SEGUNDO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '78901234');

-- TERCERO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '78901234' LIMIT 1),
    3, -- TERCERO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '78901234');

-- CUARTO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '78901234' LIMIT 1),
    4, -- CUARTO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '78901234');

-- QUINTO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '78901234' LIMIT 1),
    5, -- QUINTO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '78901234');

-- SEXTO A
INSERT INTO docente_asignaciones (docente_id, grado_seccion_id, materia_id, nivel)
SELECT 
    (SELECT id FROM usuarios WHERE dni = '78901234' LIMIT 1),
    6, -- SEXTO A
    NULL,
    'PRIMARIA'
WHERE EXISTS (SELECT 1 FROM usuarios WHERE dni = '78901234');

-- Verificar que se insertaron correctamente
SELECT 
    u.dni,
    u.nombres_completos,
    u.cargo,
    u.nivel,
    gs.nombre_completo as grado_seccion,
    COUNT(da.id) as total_asignaciones
FROM usuarios u
LEFT JOIN docente_asignaciones da ON u.id = da.docente_id
LEFT JOIN grado_seccion gs ON da.grado_seccion_id = gs.id
WHERE u.cargo = 'DOCENTE' AND u.nivel = 'PRIMARIA' AND u.deleted_at IS NULL
GROUP BY u.id, u.dni, u.nombres_completos, u.cargo, u.nivel, gs.nombre_completo
ORDER BY u.nombres_completos, gs.nombre_completo;
