# API Sistema de Toma de Asistencia - EVR

API REST para el sistema de toma de asistencia de una institución educativa.

## Requisitos

- Node.js 16+
- PostgreSQL 12+

## Instalación

1. Instalar dependencias:
```bash
npm install
```

2. Configurar variables de entorno:
```bash
cp .env.example .env
# Editar .env con tus credenciales de PostgreSQL
```

3. Crear la base de datos:
```bash
# Conectarse a PostgreSQL y ejecutar:
psql -U postgres -d postgres
CREATE DATABASE evr_db;
\q
```

4. Ejecutar el script SQL:
```bash
psql -U postgres -d evr_db -f database.sql
```

5. Iniciar el servidor:
```bash
npm start
# o para desarrollo con auto-reload:
npm run dev
```

## Estructura de Base de Datos

### Tablas principales:
- `usuarios`: Docentes y directores
- `materias`: Materias (solo secundaria)
- `grados`: Grados (PRIMERO, SEGUNDO, etc.)
- `secciones`: Secciones (A, B, etc.)
- `grado_seccion`: Combinación de grado y sección
- `alumnos`: Alumnos
- `docente_asignaciones`: Asignaciones de docentes a grados/materias
- `asistencias`: Asistencias de alumnos
- `asistencias_docentes`: Asistencias de docentes (tomadas por director)

## Endpoints de la API

### Autenticación

#### POST `/login`
Iniciar sesión.

**Body:**
```json
{
  "dni": "12345678",
  "password": "contraseña123"
}
```

**Response:**
```json
{
  "message": "Login exitoso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "dni": "12345678",
    "nombres_completos": "Juan Pérez",
    "nivel": "PRIMARIA",
    "cargo": "DOCENTE",
    "condicion": "Nombrado",
    "jornada_laboral": "Completa"
  }
}
```

#### POST `/logout`
Cerrar sesión (requiere token).

**Headers:**
```
Authorization: Bearer <token>
```

---

### Perfil Docente

#### GET `/docente/materias-grados`
Obtener listado de materias o grados asignados al docente.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (Primaria):**
```json
{
  "nivel": "PRIMARIA",
  "asignaciones": [
    {
      "asignacion_id": 1,
      "grado_seccion_id": 1,
      "grado_seccion": "PRIMERO A",
      "grado": "PRIMERO",
      "seccion": "A"
    }
  ]
}
```

**Response (Secundaria):**
```json
{
  "nivel": "SECUNDARIA",
  "asignaciones": [
    {
      "asignacion_id": 1,
      "grado_seccion_id": 7,
      "materia_id": 1,
      "materia": "RELIGIÓN",
      "grado_seccion": "PRIMERO A",
      "grado": "PRIMERO",
      "seccion": "A"
    },
    {
      "asignacion_id": 2,
      "grado_seccion_id": 11,
      "materia_id": 1,
      "materia": "RELIGIÓN",
      "grado_seccion": "QUINTO A",
      "grado": "QUINTO",
      "seccion": "A"
    }
  ]
}
```

#### POST `/docente/tomar-asistencia`
Registrar asistencia de un alumno.

**Headers:**
```
Authorization: Bearer <token>
```

**Body (Primaria):**
```json
{
  "codigo_qr": "EST001",
  "grado_seccion_id": 1
}
```

**Body (Secundaria):**
```json
{
  "codigo_qr": "EST001",
  "grado_seccion_id": 7,
  "materia_id": 1
}
```

**Response:**
```json
{
  "message": "Asistencia registrada correctamente",
  "asistencia": {
    "id": 1,
    "alumno_id": 1,
    "docente_id": 1,
    "grado_seccion_id": 1,
    "materia_id": null,
    "fecha": "2024-01-15",
    "hora": "08:30:00",
    "tipo": "PRESENTE"
  },
  "alumno": {
    "id": 1,
    "codigo_estudiante": "EST001",
    "nombres": "María",
    "apellido_paterno": "García",
    "apellido_materno": "López"
  }
}
```

---

### Perfil Director

#### GET `/director/docentes`
Obtener listado de todos los docentes.

**Headers:**
```
Authorization: Bearer <token>
```

**Response:**
```json
{
  "docentes": [
    {
      "id": 1,
      "dni": "12345678",
      "nombres_completos": "Juan Pérez",
      "nivel": "PRIMARIA",
      "condicion": "Nombrado",
      "jornada_laboral": "Completa"
    }
  ]
}
```

#### POST `/director/tomar-asistencia-docente`
Registrar asistencia de un docente.

**Headers:**
```
Authorization: Bearer <token>
```

**Body:**
```json
{
  "dni_docente": "12345678"
}
```

**Response:**
```json
{
  "message": "Asistencia del docente registrada correctamente",
  "asistencia": {
    "id": 1,
    "docente_id": 1,
    "director_id": 2,
    "fecha": "2024-01-15",
    "hora": "08:00:00",
    "tipo": "PRESENTE"
  },
  "docente": {
    "id": 1,
    "dni": "12345678",
    "nombres_completos": "Juan Pérez"
  }
}
```

---

## Códigos de Error

- `400`: Error de validación o datos incorrectos
- `401`: No autenticado (token faltante o inválido)
- `403`: Acceso denegado (permisos insuficientes)
- `404`: Recurso no encontrado
- `500`: Error interno del servidor

## Notas Importantes

1. **Autenticación**: Todos los endpoints (excepto `/login` y `/ping`) requieren el header `Authorization: Bearer <token>`

2. **Validaciones**:
   - No se puede registrar asistencia duplicada para el mismo alumno en el mismo día
   - El código QR del alumno debe corresponder al grado-sección seleccionado
   - El docente solo puede tomar asistencia en sus asignaciones

3. **Niveles**:
   - **PRIMARIA**: Un docente tiene asignado un único grado-sección (excepto Educación Física que tiene los 6)
   - **SECUNDARIA**: Un docente puede tener múltiples materias asignadas a diferentes grados

4. **Asistencias**:
   - Solo se registra tipo "PRESENTE"
   - Las faltas se calculan en el reporte (total alumnos - presentes)

## Script SQL

El archivo `database.sql` contiene:
- Definición de todas las tablas
- Índices para optimización
- Datos iniciales (grados y secciones)
- Triggers para actualización automática de `updated_at`
