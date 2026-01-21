-- ============================================
-- SCRIPT DE ACTUALIZACIÓN DE CONTRASEÑAS
-- I.E. N° 16793 "EULALIO VILLEGAS RAMOS"
-- ============================================
-- Este script actualiza todas las contraseñas de usuarios activos
-- al hash bcrypt proporcionado: $2b$10$urPccXe7RGSaTXII005lXOJJ63Pv9s6mgujunN1yBPfWdzPrDExby

-- Actualizar todas las contraseñas de usuarios activos
UPDATE usuarios
SET password_hash = '$2b$10$urPccXe7RGSaTXII005lXOJJ63Pv9s6mgujunN1yBPfWdzPrDExby',
    updated_at = CURRENT_TIMESTAMP
WHERE deleted_at IS NULL;

-- Verificar la actualización
SELECT 
    COUNT(*) as total_usuarios_actualizados
FROM usuarios
WHERE password_hash = '$2b$10$urPccXe7RGSaTXII005lXOJJ63Pv9s6mgujunN1yBPfWdzPrDExby'
    AND deleted_at IS NULL;

-- Mostrar algunos usuarios actualizados como ejemplo
SELECT 
    id,
    dni,
    nombres_completos,
    cargo,
    nivel,
    password_hash,
    updated_at
FROM usuarios
WHERE deleted_at IS NULL
ORDER BY updated_at DESC
LIMIT 10;
