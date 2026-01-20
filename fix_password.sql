-- ============================================
-- SCRIPT PARA CORREGIR CONTRASEÑA DEL USUARIO
-- ============================================

-- Opción 1: Usar este hash (generado con bcrypt para "123")
-- Este hash debería funcionar correctamente
UPDATE usuarios 
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
WHERE dni = '12345678';

-- Opción 2: Si el hash anterior no funciona, genera uno nuevo usando:
-- POST https://proyectotesis-production-72e2.up.railway.app/generate-hash
-- Body: { "password": "123" }
-- Y luego actualiza con el hash que recibas:

-- UPDATE usuarios 
-- SET password_hash = '<hash_generado_aqui>'
-- WHERE dni = '12345678';

-- Verificar que se actualizó correctamente
SELECT dni, nombres_completos, LEFT(password_hash, 30) as hash_preview
FROM usuarios 
WHERE dni = '12345678';
