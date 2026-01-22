-- ============================================
-- SCRIPT DE MODIFICACIÓN E INSERCIÓN DE PERSONAL DE LIMPIEZA
-- I.E. N° 16793 "EULALIO VILLEGAS RAMOS"
-- ============================================
-- Este script:
-- 1. Modifica el CHECK constraint de la tabla usuarios para incluir 'PERSONAL_LIMPIEZA'
-- 2. Inserta el usuario de Personal de limpieza y mantenimiento
-- Contraseña: 123
-- Hash bcrypt de "123": $2b$10$urPccXe7RGSaTXII005lXOJJ63Pv9s6mgujunN1yBPfWdzPrDExby

-- ============================================
-- PASO 1: Modificar el CHECK constraint
-- ============================================
-- Primero eliminar el constraint existente
ALTER TABLE usuarios DROP CONSTRAINT IF EXISTS usuarios_cargo_check;

-- Agregar el nuevo constraint que incluye PERSONAL_LIMPIEZA
ALTER TABLE usuarios ADD CONSTRAINT usuarios_cargo_check 
    CHECK (cargo IN ('DOCENTE', 'DIRECTOR', 'PERSONAL_LIMPIEZA'));

-- ============================================
-- PASO 2: Insertar Personal de limpieza
-- ============================================
INSERT INTO usuarios (dni, nombres_completos, nivel, cargo, condicion, jornada_laboral, password_hash)
VALUES
    ('80535483', 'ASPAJO OLANO ALEX', 'SECUNDARIA', 'PERSONAL_LIMPIEZA', 'CONTRATO', '40', '$2b$10$urPccXe7RGSaTXII005lXOJJ63Pv9s6mgujunN1yBPfWdzPrDExby')
ON CONFLICT (dni) DO UPDATE SET
    nombres_completos = EXCLUDED.nombres_completos,
    nivel = EXCLUDED.nivel,
    cargo = EXCLUDED.cargo,
    condicion = EXCLUDED.condicion,
    jornada_laboral = EXCLUDED.jornada_laboral,
    password_hash = EXCLUDED.password_hash,
    updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- PASO 3: Verificar que se insertó correctamente
-- ============================================
SELECT 
    u.id,
    u.dni,
    u.nombres_completos,
    u.cargo,
    u.nivel,
    u.condicion,
    u.jornada_laboral,
    u.deleted_at
FROM usuarios u
WHERE u.dni = '80535483';

-- Verificar todos los usuarios de personal de limpieza
SELECT 
    u.dni,
    u.nombres_completos,
    u.cargo,
    u.nivel,
    u.condicion,
    u.jornada_laboral
FROM usuarios u
WHERE u.cargo = 'PERSONAL_LIMPIEZA' AND u.deleted_at IS NULL;
