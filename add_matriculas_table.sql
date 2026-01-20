-- ============================================
-- TABLA DE MATRÍCULAS DE ALUMNOS EN MATERIAS
-- Para validar que un alumno está matriculado en una materia específica
-- ============================================

-- Tabla de matrículas (relación alumno-materia)
-- Solo se usa para SECUNDARIA, ya que en PRIMARIA todos los alumnos están en todas las clases
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

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_alumno_materias_alumno ON alumno_materias(alumno_id);
CREATE INDEX IF NOT EXISTS idx_alumno_materias_materia ON alumno_materias(materia_id);
CREATE INDEX IF NOT EXISTS idx_alumno_materias_grado_seccion ON alumno_materias(grado_seccion_id);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_alumno_materias_updated_at BEFORE UPDATE ON alumno_materias
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comentario explicativo
COMMENT ON TABLE alumno_materias IS 'Relación entre alumnos y materias en SECUNDARIA. Permite validar que un alumno está matriculado en una materia antes de registrar asistencia.';
