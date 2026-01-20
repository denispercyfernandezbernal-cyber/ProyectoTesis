-- ============================================
-- SCRIPT DE BASE DE DATOS - SISTEMA DE ASISTENCIA
-- ============================================

-- Tabla de usuarios (Docentes y Directores)
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    dni VARCHAR(20) UNIQUE NOT NULL,
    nombres_completos VARCHAR(255) NOT NULL,
    nivel VARCHAR(20) NOT NULL CHECK (nivel IN ('PRIMARIA', 'SECUNDARIA')),
    cargo VARCHAR(20) NOT NULL CHECK (cargo IN ('DOCENTE', 'DIRECTOR')),
    condicion VARCHAR(100),
    jornada_laboral VARCHAR(100),
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Tabla de materias (solo para secundaria)
CREATE TABLE IF NOT EXISTS materias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Tabla de grados
CREATE TABLE IF NOT EXISTS grados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    nivel VARCHAR(20) NOT NULL CHECK (nivel IN ('PRIMARIA', 'SECUNDARIA')),
    orden INTEGER NOT NULL, -- Para ordenar: 1=PRIMERO, 2=SEGUNDO, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nombre, nivel)
);

-- Tabla de secciones
CREATE TABLE IF NOT EXISTS secciones (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla intermedia: grado_seccion (combina grado y sección)
CREATE TABLE IF NOT EXISTS grado_seccion (
    id SERIAL PRIMARY KEY,
    grado_id INTEGER NOT NULL REFERENCES grados(id),
    seccion_id INTEGER NOT NULL REFERENCES secciones(id),
    nivel VARCHAR(20) NOT NULL CHECK (nivel IN ('PRIMARIA', 'SECUNDARIA')),
    nombre_completo VARCHAR(50) NOT NULL, -- Ej: "PRIMERO A"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(grado_id, seccion_id, nivel)
);

-- Tabla de alumnos
CREATE TABLE IF NOT EXISTS alumnos (
    id SERIAL PRIMARY KEY,
    codigo_estudiante VARCHAR(50) UNIQUE NOT NULL,
    nombres VARCHAR(255) NOT NULL,
    apellido_paterno VARCHAR(255) NOT NULL,
    apellido_materno VARCHAR(255) NOT NULL,
    sexo VARCHAR(10) CHECK (sexo IN ('M', 'F')),
    fecha_nacimiento DATE,
    estado_matricula VARCHAR(50),
    tipo_documento VARCHAR(20),
    numero_documento VARCHAR(20),
    grado_seccion_id INTEGER NOT NULL REFERENCES grado_seccion(id),
    nivel VARCHAR(20) NOT NULL CHECK (nivel IN ('PRIMARIA', 'SECUNDARIA')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Tabla de asignaciones de docentes
-- Para PRIMARIA: solo grado_seccion_id (materia_id es NULL)
-- Para SECUNDARIA: grado_seccion_id + materia_id
-- Para Educación Física de primaria: múltiples registros (uno por cada grado_seccion)
CREATE TABLE IF NOT EXISTS docente_asignaciones (
    id SERIAL PRIMARY KEY,
    docente_id INTEGER NOT NULL REFERENCES usuarios(id),
    grado_seccion_id INTEGER NOT NULL REFERENCES grado_seccion(id),
    materia_id INTEGER NULL REFERENCES materias(id), -- NULL para primaria
    nivel VARCHAR(20) NOT NULL CHECK (nivel IN ('PRIMARIA', 'SECUNDARIA')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Validación: para primaria materia_id debe ser NULL, para secundaria debe tener valor
    CONSTRAINT check_primaria_sin_materia CHECK (
        (nivel = 'PRIMARIA' AND materia_id IS NULL) OR
        (nivel = 'SECUNDARIA' AND materia_id IS NOT NULL)
    )
);

-- Tabla de matrículas de alumnos en materias (solo para SECUNDARIA)
-- Permite validar que un alumno está matriculado en una materia antes de registrar asistencia
CREATE TABLE IF NOT EXISTS alumno_materias (
    id SERIAL PRIMARY KEY,
    alumno_id INTEGER NOT NULL REFERENCES alumnos(id),
    materia_id INTEGER NOT NULL REFERENCES materias(id),
    grado_seccion_id INTEGER NOT NULL REFERENCES grado_seccion(id),
    nivel VARCHAR(20) NOT NULL CHECK (nivel = 'SECUNDARIA'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    -- Un alumno solo puede estar matriculado una vez en una materia en un grado-sección
    UNIQUE(alumno_id, materia_id, grado_seccion_id)
);

-- Tabla de asistencias de alumnos
CREATE TABLE IF NOT EXISTS asistencias (
    id SERIAL PRIMARY KEY,
    alumno_id INTEGER NOT NULL REFERENCES alumnos(id),
    docente_id INTEGER NOT NULL REFERENCES usuarios(id), -- Quien tomó la asistencia
    grado_seccion_id INTEGER NOT NULL REFERENCES grado_seccion(id),
    materia_id INTEGER NULL REFERENCES materias(id), -- NULL para primaria
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    tipo VARCHAR(20) DEFAULT 'PRESENTE' CHECK (tipo = 'PRESENTE'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de asistencias de docentes (cuando el director pasa asistencia)
CREATE TABLE IF NOT EXISTS asistencias_docentes (
    id SERIAL PRIMARY KEY,
    docente_id INTEGER NOT NULL REFERENCES usuarios(id), -- El docente al que se le pasa asistencia
    director_id INTEGER NOT NULL REFERENCES usuarios(id), -- El director que pasa la asistencia
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    tipo VARCHAR(20) DEFAULT 'PRESENTE' CHECK (tipo = 'PRESENTE'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Un docente solo puede tener una asistencia por día
    UNIQUE(docente_id, fecha)
);

-- ============================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

CREATE INDEX IF NOT EXISTS idx_usuarios_dni ON usuarios(dni);
CREATE INDEX IF NOT EXISTS idx_usuarios_cargo ON usuarios(cargo);
CREATE INDEX IF NOT EXISTS idx_usuarios_nivel ON usuarios(nivel);
CREATE INDEX IF NOT EXISTS idx_alumnos_codigo_estudiante ON alumnos(codigo_estudiante);
CREATE INDEX IF NOT EXISTS idx_alumnos_grado_seccion ON alumnos(grado_seccion_id);
CREATE INDEX IF NOT EXISTS idx_docente_asignaciones_docente ON docente_asignaciones(docente_id);
CREATE INDEX IF NOT EXISTS idx_docente_asignaciones_grado_seccion ON docente_asignaciones(grado_seccion_id);
CREATE INDEX IF NOT EXISTS idx_alumno_materias_alumno ON alumno_materias(alumno_id);
CREATE INDEX IF NOT EXISTS idx_alumno_materias_materia ON alumno_materias(materia_id);
CREATE INDEX IF NOT EXISTS idx_alumno_materias_grado_seccion ON alumno_materias(grado_seccion_id);
-- Índices únicos para evitar duplicados en asignaciones
-- Para primaria: solo docente_id + grado_seccion_id (materia_id es NULL)
CREATE UNIQUE INDEX IF NOT EXISTS idx_docente_asignaciones_unique_primaria 
  ON docente_asignaciones(docente_id, grado_seccion_id) 
  WHERE nivel = 'PRIMARIA' AND materia_id IS NULL;
-- Para secundaria: docente_id + grado_seccion_id + materia_id
CREATE UNIQUE INDEX IF NOT EXISTS idx_docente_asignaciones_unique_secundaria 
  ON docente_asignaciones(docente_id, grado_seccion_id, materia_id) 
  WHERE nivel = 'SECUNDARIA' AND materia_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_asistencias_alumno ON asistencias(alumno_id);
CREATE INDEX IF NOT EXISTS idx_asistencias_fecha ON asistencias(fecha);
-- Índice único para evitar duplicados: un alumno solo puede tener una asistencia por día y materia
-- Para primaria: materia_id es NULL, para secundaria tiene valor
-- Usamos expresión para manejar NULLs correctamente
CREATE UNIQUE INDEX IF NOT EXISTS idx_asistencias_unique_primaria 
  ON asistencias(alumno_id, grado_seccion_id, fecha) 
  WHERE materia_id IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_asistencias_unique_secundaria 
  ON asistencias(alumno_id, grado_seccion_id, materia_id, fecha) 
  WHERE materia_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_asistencias_docente_fecha ON asistencias_docentes(docente_id, fecha);

-- ============================================
-- DATOS INICIALES
-- ============================================

-- Insertar secciones
INSERT INTO secciones (nombre) VALUES ('A') ON CONFLICT DO NOTHING;

-- Insertar grados de PRIMARIA
INSERT INTO grados (nombre, nivel, orden) VALUES 
    ('PRIMERO', 'PRIMARIA', 1),
    ('SEGUNDO', 'PRIMARIA', 2),
    ('TERCERO', 'PRIMARIA', 3),
    ('CUARTO', 'PRIMARIA', 4),
    ('QUINTO', 'PRIMARIA', 5),
    ('SEXTO', 'PRIMARIA', 6)
ON CONFLICT (nombre, nivel) DO NOTHING;

-- Insertar grados de SECUNDARIA
INSERT INTO grados (nombre, nivel, orden) VALUES 
    ('PRIMERO', 'SECUNDARIA', 1),
    ('SEGUNDO', 'SECUNDARIA', 2),
    ('TERCERO', 'SECUNDARIA', 3),
    ('CUARTO', 'SECUNDARIA', 4),
    ('QUINTO', 'SECUNDARIA', 5)
ON CONFLICT (nombre, nivel) DO NOTHING;

-- Insertar grado_seccion para PRIMARIA
INSERT INTO grado_seccion (grado_id, seccion_id, nivel, nombre_completo)
SELECT g.id, s.id, 'PRIMARIA', g.nombre || ' ' || s.nombre
FROM grados g
CROSS JOIN secciones s
WHERE g.nivel = 'PRIMARIA'
ON CONFLICT (grado_id, seccion_id, nivel) DO NOTHING;

-- Insertar grado_seccion para SECUNDARIA
INSERT INTO grado_seccion (grado_id, seccion_id, nivel, nombre_completo)
SELECT g.id, s.id, 'SECUNDARIA', g.nombre || ' ' || s.nombre
FROM grados g
CROSS JOIN secciones s
WHERE g.nivel = 'SECUNDARIA'
ON CONFLICT (grado_id, seccion_id, nivel) DO NOTHING;

-- ============================================
-- FUNCIONES Y TRIGGERS
-- ============================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar updated_at
CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_materias_updated_at BEFORE UPDATE ON materias
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_grados_updated_at BEFORE UPDATE ON grados
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_secciones_updated_at BEFORE UPDATE ON secciones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_grado_seccion_updated_at BEFORE UPDATE ON grado_seccion
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_alumnos_updated_at BEFORE UPDATE ON alumnos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_docente_asignaciones_updated_at BEFORE UPDATE ON docente_asignaciones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_alumno_materias_updated_at BEFORE UPDATE ON alumno_materias
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_asistencias_updated_at BEFORE UPDATE ON asistencias
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_asistencias_docentes_updated_at BEFORE UPDATE ON asistencias_docentes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
