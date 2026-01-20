-- SOLUCIÓN DIRECTA: Actualizar contraseñas a "123"
-- Paso 1: Obtén un hash nuevo llamando al endpoint:
-- POST https://proyectotesis-production-72e2.up.railway.app/generate-hash
-- Body: {"password": "123"}
-- Copia el hash de la respuesta y úsalo abajo

-- Paso 2: Ejecuta este SQL (reemplaza <HASH_GENERADO> con el hash del paso 1):
UPDATE usuarios 
SET password_hash = '<HASH_GENERADO>',
    updated_at = CURRENT_TIMESTAMP
WHERE deleted_at IS NULL;

-- O usa este hash (generado con bcrypt):
UPDATE usuarios 
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    updated_at = CURRENT_TIMESTAMP
WHERE deleted_at IS NULL;

-- Verificar usuario específico
SELECT dni, nombres_completos, cargo, password_hash 
FROM usuarios 
WHERE dni = '12345678';
