-- ============================================
-- SCRIPT PARA ACTUALIZAR CONTRASEÑA A "123"
-- PARA TODOS LOS USUARIOS
-- ============================================
-- Contraseña: 123
-- Hash bcrypt de "123": $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- Actualizar contraseña de TODOS los usuarios activos (no eliminados) a "123"
UPDATE usuarios 
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    updated_at = CURRENT_TIMESTAMP
WHERE deleted_at IS NULL;

-- Verificar que se actualizaron correctamente
SELECT 
    id,
    dni,
    nombres_completos,
    cargo,
    nivel,
    LEFT(password_hash, 30) as hash_preview,
    updated_at
FROM usuarios 
WHERE deleted_at IS NULL
ORDER BY cargo, nivel, nombres_completos;

-- Contar usuarios actualizados
SELECT 
    cargo,
    nivel,
    COUNT(*) as total_usuarios
FROM usuarios 
WHERE deleted_at IS NULL
GROUP BY cargo, nivel
ORDER BY cargo, nivel;
