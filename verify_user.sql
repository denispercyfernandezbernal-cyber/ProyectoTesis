-- Script para verificar si el usuario existe y su hash
SELECT 
    id,
    dni,
    nombres_completos,
    cargo,
    nivel,
    password_hash,
    LEFT(password_hash, 20) as hash_preview,
    LENGTH(password_hash) as hash_length
FROM usuarios 
WHERE dni = '12345678';

-- Si el usuario no existe, ejecutar esto para crearlo:
-- INSERT INTO usuarios (dni, nombres_completos, nivel, cargo, condicion, jornada_laboral, password_hash)
-- VALUES ('12345678', 'ÁGUILAR BAUTISTA', 'PRIMARIA', 'DOCENTE', 'Nombrado', 'Completa', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy');

-- Si necesitas actualizar el hash de la contraseña "123", ejecuta esto después de generar un nuevo hash:
-- UPDATE usuarios SET password_hash = '<nuevo_hash_aqui>' WHERE dni = '12345678';
