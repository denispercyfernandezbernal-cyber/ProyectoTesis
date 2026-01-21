-- ============================================
-- SCRIPT DE INSERCIÓN DE DIRECTOR
-- I.E. N° 16793 "EULALIO VILLEGAS RAMOS"
-- ============================================
-- Contraseña: 123
-- Hash bcrypt de "123": $2b$10$urPccXe7RGSaTXII005lXOJJ63Pv9s6mgujunN1yBPfWdzPrDExby

-- Insertar Director
INSERT INTO usuarios (dni, nombres_completos, nivel, cargo, condicion, jornada_laboral, password_hash)
VALUES
    ('43019139', 'VASQUEZ OLANO JOSE LUIS', 'PRIMARIA', 'DIRECTOR', 'DESIGNADO', '40', '$2b$10$urPccXe7RGSaTXII005lXOJJ63Pv9s6mgujunN1yBPfWdzPrDExby')
ON CONFLICT (dni) DO UPDATE SET
    nombres_completos = EXCLUDED.nombres_completos,
    nivel = EXCLUDED.nivel,
    cargo = EXCLUDED.cargo,
    condicion = EXCLUDED.condicion,
    jornada_laboral = EXCLUDED.jornada_laboral,
    password_hash = EXCLUDED.password_hash,
    updated_at = CURRENT_TIMESTAMP;

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
