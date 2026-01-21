-- ============================================
-- SCRIPT DE ACTUALIZACIÓN DE DNI POR ID
-- ============================================
-- Ejemplo: Actualizar el DNI de un usuario específico por su ID

-- Actualizar DNI por ID
UPDATE usuarios
SET dni = 'NUEVO_DNI_AQUI',
    updated_at = CURRENT_TIMESTAMP
WHERE id = ID_DEL_USUARIO_AQUI;

-- Ejemplo concreto:
-- UPDATE usuarios
-- SET dni = '43019139',
--     updated_at = CURRENT_TIMESTAMP
-- WHERE id = 1;

-- Verificar el cambio
SELECT 
    id,
    dni,
    nombres_completos,
    cargo,
    nivel,
    updated_at
FROM usuarios
WHERE id = ID_DEL_USUARIO_AQUI;
