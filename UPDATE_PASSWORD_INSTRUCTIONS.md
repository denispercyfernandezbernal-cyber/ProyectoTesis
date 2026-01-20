# 🔧 Instrucciones para Actualizar Contraseñas

## Problema: Credenciales Inválidas

Si estás recibiendo "credenciales inválidas" después de actualizar las contraseñas, puede ser que el hash no sea correcto.

## Solución Paso a Paso:

### Paso 1: Generar un hash nuevo usando la API

Llama al endpoint de generar hash que creamos:

**POST** `https://proyectotesis-production-72e2.up.railway.app/generate-hash`

**Body (JSON):**
```json
{
  "password": "123"
}
```

**Respuesta esperada:**
```json
{
  "password": "123",
  "hash": "$2a$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```

Copia el valor de `hash` de la respuesta.

### Paso 2: Actualizar todos los usuarios con el nuevo hash

Ejecuta este SQL en tu base de datos PostgreSQL (reemplaza `<HASH_AQUI>` con el hash que obtuviste):

```sql
UPDATE usuarios 
SET password_hash = '<HASH_AQUI>',
    updated_at = CURRENT_TIMESTAMP
WHERE deleted_at IS NULL;
```

### Paso 3: Verificar que se actualizó

Ejecuta:

```sql
SELECT 
    dni,
    nombres_completos,
    cargo,
    LEFT(password_hash, 30) as hash_preview
FROM usuarios 
WHERE deleted_at IS NULL
LIMIT 5;
```

### Paso 4: Probar el login

Ahora prueba hacer login con:
- DNI: `12345678`
- Contraseña: `123`

## Alternativa: Script SQL con hash verificado

Si prefieres, aquí hay un hash que debería funcionar (generado con bcrypt v6.0.0, salt rounds 10):

```sql
UPDATE usuarios 
SET password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    updated_at = CURRENT_TIMESTAMP
WHERE deleted_at IS NULL;
```

## Verificar que el usuario existe

Si aún no funciona, verifica que el usuario existe:

```sql
SELECT 
    id,
    dni,
    nombres_completos,
    cargo,
    nivel,
    password_hash,
    deleted_at
FROM usuarios 
WHERE dni = '12345678';
```

Si `deleted_at` no es NULL, el usuario está eliminado. Si no existe el registro, necesitas insertarlo.

## Verificar la comparación de bcrypt

El código de login usa `bcrypt.compare(password, user.password_hash)`. 
Asegúrate de que:
1. El hash en la BD es un hash bcrypt válido (empieza con `$2a$10$` o `$2b$10$`)
2. No hay espacios extra en el hash
3. El hash tiene exactamente 60 caracteres

## Solución Rápida

1. Llama al endpoint `/generate-hash` con password "123"
2. Copia el hash generado
3. Ejecuta el UPDATE SQL con ese hash
4. Prueba el login de nuevo
