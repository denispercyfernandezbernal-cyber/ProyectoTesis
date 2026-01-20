# Variables de Entorno para Railway

## Variables Requeridas para PostgreSQL

Agrega estas variables de entorno en Railway en tu servicio de API:

### 1. Variables de PostgreSQL

```
PGHOST=<host_de_railway_postgres>
PGDATABASE=<nombre_de_la_base_de_datos>
PGUSER=<usuario_postgres>
PGPASSWORD=<contraseña_postgres>
PGPORT=5432
PGSSLMODE=require
```

**Nota:** Railway generalmente proporciona estas variables automáticamente si conectas el servicio PostgreSQL como dependencia. Si conectas los servicios, Railway puede generar variables como:
- `PGHOST=xxx.railway.app`
- `PGDATABASE=railway`
- `PGUSER=postgres`
- `PGPASSWORD=xxx`
- `PGPORT=5432`

### 2. Variables de la API

```
JWT_SECRET=<clave_secreta_para_jwt>
PORT=3000
```

## Pasos para Configurar en Railway

### Opción A: Conectar PostgreSQL como Dependencia (Recomendado)

1. En tu proyecto Railway, selecciona tu servicio de API (Node.js)
2. Ve a la pestaña "Variables"
3. Busca la sección "Connect to Database" o "Add Dependency"
4. Selecciona tu servicio PostgreSQL
5. Railway agregará automáticamente las variables de conexión

### Opción B: Configurar Manualmente

1. En tu proyecto Railway, selecciona tu servicio de API (Node.js)
2. Ve a la pestaña "Variables"
3. Haz clic en "New Variable" o "Raw Editor"
4. Agrega cada variable una por una:

```
PGHOST=containers-us-west-xxx.railway.app
PGDATABASE=railway
PGUSER=postgres
PGPASSWORD=tu_contraseña_aquí
PGPORT=5432
PGSSLMODE=require
JWT_SECRET=tu_clave_secreta_segura_aqui
PORT=3000
```

**Para obtener las credenciales de PostgreSQL:**
1. Selecciona tu servicio PostgreSQL en Railway
2. Ve a la pestaña "Variables"
3. Allí verás: `PGHOST`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`, `PGPORT`
4. Copia estos valores al servicio de tu API

## Ejemplo de Valores en Railway

Railway generalmente usa estos nombres:
- **PGHOST**: Algo como `containers-us-west-xxx.railway.app` o una IP
- **PGDATABASE**: Generalmente `railway`
- **PGUSER**: Generalmente `postgres`
- **PGPASSWORD**: Una contraseña generada automáticamente
- **PGPORT**: `5432`
- **PGSSLMODE**: Debe ser `require` para Railway (conexión segura)

## Verificar la Configuración

Después de configurar las variables, reinicia tu servicio de API en Railway y verifica los logs para confirmar que se conecta correctamente a PostgreSQL.

## Notas Importantes

⚠️ **IMPORTANTE**: 
- `PGSSLMODE` debe ser `require` en Railway (no `disable`)
- La contraseña y JWT_SECRET deben ser valores seguros en producción
- No compartas estas credenciales públicamente
