-- ============================================
-- SCRIPT DE INSERCIÓN DE DIRECTOR
-- I.E. N° 16793 "EULALIO VILLEGAS RAMOS"
-- ============================================
-- Contraseña: 123
-- Hash bcrypt de "123": $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- Insertar Director
INSERT INTO usuarios (dni, nombres_completos, nivel, cargo, condicion, jornada_laboral, password_hash)
VALUES
    ('99999999', 'DIRECTOR GENERAL', 'PRIMARIA', 'DIRECTOR', 'Nombrado', 'Completa', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy')
ON CONFLICT (dni) DO NOTHING;

-- Verificar que se insertó correctamente
SELECT 
    u.dni,
    u.nombres_completos,
    u.cargo,
    u.nivel,
    u.condicion,
    u.jornada_laboral
FROM usuarios u
WHERE u.cargo = 'DIRECTOR' AND u.deleted_at IS NULL;
