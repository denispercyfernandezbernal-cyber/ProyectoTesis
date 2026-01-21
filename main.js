const express = require("express");
const { Pool } = require("pg");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
require("dotenv").config();

const app = express();
app.use(express.json());

// ============================================
// HELPER: Obtener fecha y hora en zona horaria de Perú (America/Lima)
// ============================================
async function getPeruDateTime(pool) {
  const result = await pool.query(
    `SELECT 
      TO_CHAR(NOW() AT TIME ZONE 'America/Lima', 'YYYY-MM-DD') as fecha,
      TO_CHAR(NOW() AT TIME ZONE 'America/Lima', 'HH24:MI:SS') as hora`
  );
  return {
    fecha: result.rows[0].fecha,
    hora: result.rows[0].hora
  };
}

// Configuración de conexión a PostgreSQL
const pool = new Pool({
  host: process.env.PGHOST || "localhost",
  database: process.env.PGDATABASE || "evr_db",
  user: process.env.PGUSER || "postgres",
  password: process.env.PGPASSWORD || "postgres",
  port: process.env.PGPORT || 5432,
  ssl: process.env.PGSSLMODE === "require" ? { rejectUnauthorized: false } : false
});

// ============================================
// MIDDLEWARE
// ============================================

// Middleware para validar JWT
function verifyToken(req, res, next) {
  const authHeader = req.headers["authorization"];
  if (!authHeader) {
    return res.status(401).json({ error: "Token requerido" });
  }

  const token = authHeader.split(" ")[1];
  if (!token) {
    return res.status(401).json({ error: "Formato de token inválido" });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || "secret_key_change_in_production");
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(403).json({ error: "Token inválido o expirado" });
  }
}

// Middleware para verificar que el usuario sea DOCENTE
function verifyDocente(req, res, next) {
  if (req.user.cargo !== "DOCENTE") {
    return res.status(403).json({ error: "Acceso denegado. Solo docentes pueden acceder a este recurso." });
  }
  next();
}

// Middleware para verificar que el usuario sea DIRECTOR
function verifyDirector(req, res, next) {
  if (req.user.cargo !== "DIRECTOR") {
    return res.status(403).json({ error: "Acceso denegado. Solo directores pueden acceder a este recurso." });
  }
  next();
}

// ============================================
// ENDPOINTS PÚBLICOS
// ============================================

// Endpoint de prueba
app.get("/ping", (req, res) => {
  res.send("pong 🏓");
});

// ============================================
// AUTENTICACIÓN
// ============================================

// Login
app.post("/login", async (req, res) => {
  try {
    const { dni, password } = req.body;

    if (!dni) {
      return res.status(400).json({ error: "Debe ingresar su DNI" });
    }
    if (!password) {
      return res.status(400).json({ error: "Debe ingresar su contraseña" });
    }

    const result = await pool.query(
      "SELECT * FROM usuarios WHERE dni = $1 AND deleted_at IS NULL",
      [dni]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Usuario no encontrado" });
    }

    const user = result.rows[0];
    
    // Verificar que el hash existe y no está vacío
    if (!user.password_hash || user.password_hash.trim() === '') {
      return res.status(401).json({ error: "Contraseña no configurada" });
    }
    
    // Comparar contraseña con hash
    let match;
    try {
      match = await bcrypt.compare(password, user.password_hash);
    } catch (bcryptError) {
      console.error("Error en bcrypt.compare:", bcryptError);
      return res.status(500).json({ error: "Error al verificar contraseña", details: bcryptError.message });
    }

    if (!match) {
      return res.status(401).json({ error: "Credenciales inválidas" });
    }

    if (!process.env.JWT_SECRET) {
      console.warn("⚠️  JWT_SECRET no definido, usando clave por defecto");
    }

    const token = jwt.sign(
      {
        id: user.id,
        dni: user.dni,
        cargo: user.cargo,
        nivel: user.nivel
      },
      process.env.JWT_SECRET || "secret_key_change_in_production",
      { expiresIn: "8h" }
    );

    res.json({
      message: "Login exitoso",
      token,
      user: {
        id: user.id,
        dni: user.dni,
        nombres_completos: user.nombres_completos,
        nivel: user.nivel,
        cargo: user.cargo,
        condicion: user.condicion,
        jornada_laboral: user.jornada_laboral
      }
    });
  } catch (err) {
    console.error("Error en login:", err);
    res.status(500).json({ error: "Error interno al autenticar" });
  }
});

// Cerrar sesión (solo invalidar token en cliente, no hay logout en servidor con JWT stateless)
app.post("/logout", verifyToken, async (req, res) => {
  res.json({ message: "Sesión cerrada correctamente" });
});

// ============================================
// PERFIL DOCENTE
// ============================================

// Listado de materias o grados que el docente tiene a cargo
app.get("/docente/materias-grados", verifyToken, verifyDocente, async (req, res) => {
  try {
    const docenteId = req.user.id;
    const nivel = req.user.nivel;

    let result;

    if (nivel === "PRIMARIA") {
      // Para primaria: mostrar grados asignados
      result = await pool.query(
        `SELECT 
          da.id as asignacion_id,
          gs.id as grado_seccion_id,
          gs.nombre_completo as grado_seccion,
          g.nombre as grado,
          s.nombre as seccion
        FROM docente_asignaciones da
        JOIN grado_seccion gs ON da.grado_seccion_id = gs.id
        JOIN grados g ON gs.grado_id = g.id
        JOIN secciones s ON gs.seccion_id = s.id
        WHERE da.docente_id = $1 AND da.nivel = 'PRIMARIA'
        ORDER BY g.orden`,
        [docenteId]
      );
    } else {
      // Para secundaria: mostrar materias con sus grados
      result = await pool.query(
        `SELECT 
          da.id as asignacion_id,
          da.grado_seccion_id,
          da.materia_id,
          m.nombre as materia,
          gs.nombre_completo as grado_seccion,
          g.nombre as grado,
          s.nombre as seccion
        FROM docente_asignaciones da
        JOIN materias m ON da.materia_id = m.id
        JOIN grado_seccion gs ON da.grado_seccion_id = gs.id
        JOIN grados g ON gs.grado_id = g.id
        JOIN secciones s ON gs.seccion_id = s.id
        WHERE da.docente_id = $1 AND da.nivel = 'SECUNDARIA'
        ORDER BY m.nombre, g.orden`,
        [docenteId]
      );
    }

    res.json({
      nivel,
      asignaciones: result.rows
    });
  } catch (err) {
    console.error("Error al obtener materias/grados:", err);
    res.status(500).json({ error: "Error al obtener materias o grados asignados" });
  }
});

// Toma de asistencia (docente)
app.post("/docente/tomar-asistencia", verifyToken, verifyDocente, async (req, res) => {
  try {
    const { codigo_qr, grado_seccion_id, materia_id } = req.body;
    const docenteId = req.user.id;
    const nivel = req.user.nivel;

    if (!codigo_qr) {
      return res.status(400).json({ error: "Debe proporcionar el código QR" });
    }
    if (!grado_seccion_id) {
      return res.status(400).json({ error: "Debe proporcionar el grado-sección" });
    }

    // Validar que la asignación pertenece al docente
    let asignacionQuery;
    if (nivel === "PRIMARIA") {
      asignacionQuery = await pool.query(
        `SELECT id FROM docente_asignaciones 
         WHERE docente_id = $1 AND grado_seccion_id = $2 AND nivel = 'PRIMARIA'`,
        [docenteId, grado_seccion_id]
      );
    } else {
      if (!materia_id) {
        return res.status(400).json({ error: "Debe proporcionar la materia para nivel secundaria" });
      }
      asignacionQuery = await pool.query(
        `SELECT id FROM docente_asignaciones 
         WHERE docente_id = $1 AND grado_seccion_id = $2 AND materia_id = $3 AND nivel = 'SECUNDARIA'`,
        [docenteId, grado_seccion_id, materia_id]
      );
    }

    if (asignacionQuery.rows.length === 0) {
      return res.status(403).json({ error: "No tiene asignación para este grado-sección/materia" });
    }

    // Buscar alumno por código de estudiante
    const alumnoResult = await pool.query(
      `SELECT id, codigo_estudiante, nombres, apellido_paterno, apellido_materno, grado_seccion_id
       FROM alumnos 
       WHERE codigo_estudiante = $1 AND deleted_at IS NULL`,
      [codigo_qr]
    );

    if (alumnoResult.rows.length === 0) {
      return res.status(404).json({ error: "Alumno no encontrado" });
    }

    const alumno = alumnoResult.rows[0];

    // Validar que el alumno pertenece al grado-sección correcto
    if (alumno.grado_seccion_id !== parseInt(grado_seccion_id)) {
      return res.status(400).json({ 
        error: "El alumno no pertenece al grado-sección seleccionado" 
      });
    }

    // Para SECUNDARIA: Validar que el alumno está matriculado en la materia
    if (nivel === "SECUNDARIA") {
      const matriculaQuery = await pool.query(
        `SELECT id FROM alumno_materias 
         WHERE alumno_id = $1 AND materia_id = $2 AND grado_seccion_id = $3 
         AND nivel = 'SECUNDARIA' AND deleted_at IS NULL`,
        [alumno.id, materia_id, grado_seccion_id]
      );

      if (matriculaQuery.rows.length === 0) {
        return res.status(400).json({ 
          error: "El alumno no está matriculado en esta materia" 
        });
      }
    }

    // Obtener fecha y hora actual en zona horaria de Perú
    const { fecha, hora } = await getPeruDateTime(pool);

    // Verificar que no exista asistencia para este día
    let existenciaQuery;
    if (nivel === "PRIMARIA") {
      existenciaQuery = await pool.query(
        `SELECT id FROM asistencias 
         WHERE alumno_id = $1 AND grado_seccion_id = $2 AND materia_id IS NULL AND fecha = $3`,
        [alumno.id, grado_seccion_id, fecha]
      );
    } else {
      existenciaQuery = await pool.query(
        `SELECT id FROM asistencias 
         WHERE alumno_id = $1 AND grado_seccion_id = $2 AND materia_id = $3 AND fecha = $4`,
        [alumno.id, grado_seccion_id, materia_id, fecha]
      );
    }

    if (existenciaQuery.rows.length > 0) {
      return res.status(400).json({ error: "Ya existe una asistencia registrada para este alumno en la fecha seleccionada" });
    }

    // Registrar asistencia
    let insertQuery;
    if (nivel === "PRIMARIA") {
      insertQuery = await pool.query(
        `INSERT INTO asistencias (alumno_id, docente_id, grado_seccion_id, materia_id, fecha, hora, tipo)
         VALUES ($1, $2, $3, NULL, $4, $5, 'PRESENTE')
         RETURNING *`,
        [alumno.id, docenteId, grado_seccion_id, fecha, hora]
      );
    } else {
      insertQuery = await pool.query(
        `INSERT INTO asistencias (alumno_id, docente_id, grado_seccion_id, materia_id, fecha, hora, tipo)
         VALUES ($1, $2, $3, $4, $5, $6, 'PRESENTE')
         RETURNING *`,
        [alumno.id, docenteId, grado_seccion_id, materia_id, fecha, hora]
      );
    }

    res.json({
      message: "Asistencia registrada correctamente",
      asistencia: insertQuery.rows[0],
      alumno: {
        id: alumno.id,
        codigo_estudiante: alumno.codigo_estudiante,
        nombres: alumno.nombres,
        apellido_paterno: alumno.apellido_paterno,
        apellido_materno: alumno.apellido_materno
      }
    });
  } catch (err) {
    console.error("Error al tomar asistencia:", err);
    
    // Manejar error de duplicado
    if (err.code === "23505") {
      return res.status(400).json({ error: "Ya existe una asistencia registrada para este alumno en la fecha seleccionada" });
    }
    
    res.status(500).json({ error: "Error al registrar asistencia" });
  }
});

// Obtener contador de asistencias del día actual
app.get("/docente/contador-asistencias", verifyToken, verifyDocente, async (req, res) => {
  try {
    const { grado_seccion_id, materia_id } = req.query;
    const docenteId = req.user.id;
    const nivel = req.user.nivel;

    if (!grado_seccion_id) {
      return res.status(400).json({ error: "Debe proporcionar el grado-sección" });
    }

    // Obtener fecha actual en zona horaria de Perú
    const { fecha } = await getPeruDateTime(pool);

    let countQuery;
    if (nivel === "PRIMARIA") {
      countQuery = await pool.query(
        `SELECT COUNT(*) as total
         FROM asistencias 
         WHERE docente_id = $1 
           AND grado_seccion_id = $2 
           AND materia_id IS NULL 
           AND fecha = $3`,
        [docenteId, grado_seccion_id, fecha]
      );
    } else {
      if (!materia_id) {
        return res.status(400).json({ error: "Debe proporcionar la materia para nivel secundaria" });
      }
      countQuery = await pool.query(
        `SELECT COUNT(*) as total
         FROM asistencias 
         WHERE docente_id = $1 
           AND grado_seccion_id = $2 
           AND materia_id = $3 
           AND fecha = $4`,
        [docenteId, grado_seccion_id, materia_id, fecha]
      );
    }

    const total = parseInt(countQuery.rows[0].total);

    res.json({
      total: total,
      fecha: fecha
    });
  } catch (err) {
    console.error("Error al obtener contador de asistencias:", err);
    res.status(500).json({ error: "Error al obtener contador de asistencias" });
  }
});

// ============================================
// PERFIL DIRECTOR
// ============================================

// Listado de docentes
app.get("/director/docentes", verifyToken, verifyDirector, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
        id,
        dni,
        nombres_completos,
        nivel,
        condicion,
        jornada_laboral
      FROM usuarios 
      WHERE cargo = 'DOCENTE' AND deleted_at IS NULL
      ORDER BY nombres_completos`
    );

    res.json({
      docentes: result.rows
    });
  } catch (err) {
    console.error("Error al obtener docentes:", err);
    res.status(500).json({ error: "Error al obtener lista de docentes" });
  }
});

// Toma de asistencia de docentes (director)
app.post("/director/tomar-asistencia-docente", verifyToken, verifyDirector, async (req, res) => {
  try {
    const { dni_docente } = req.body;
    const directorId = req.user.id;

    if (!dni_docente) {
      return res.status(400).json({ error: "Debe proporcionar el DNI del docente" });
    }

    // Buscar docente por DNI
    const docenteResult = await pool.query(
      `SELECT id, dni, nombres_completos 
       FROM usuarios 
       WHERE dni = $1 AND cargo = 'DOCENTE' AND deleted_at IS NULL`,
      [dni_docente]
    );

    if (docenteResult.rows.length === 0) {
      return res.status(404).json({ error: "Docente no encontrado" });
    }

    const docente = docenteResult.rows[0];

    // Obtener fecha y hora actual en zona horaria de Perú
    const { fecha, hora } = await getPeruDateTime(pool);

    // Verificar que no exista asistencia para este día
    const existenciaQuery = await pool.query(
      `SELECT id FROM asistencias_docentes 
       WHERE docente_id = $1 AND fecha = $2`,
      [docente.id, fecha]
    );

    if (existenciaQuery.rows.length > 0) {
      return res.status(400).json({ error: "Ya existe una asistencia registrada para este docente en la fecha seleccionada" });
    }

    // Registrar asistencia del docente
    const insertQuery = await pool.query(
      `INSERT INTO asistencias_docentes (docente_id, director_id, fecha, hora, tipo)
       VALUES ($1, $2, $3, $4, 'PRESENTE')
       RETURNING *`,
      [docente.id, directorId, fecha, hora]
    );

    res.json({
      message: "Asistencia del docente registrada correctamente",
      asistencia: insertQuery.rows[0],
      docente: {
        id: docente.id,
        dni: docente.dni,
        nombres_completos: docente.nombres_completos
      }
    });
  } catch (err) {
    console.error("Error al tomar asistencia de docente:", err);
    
    // Manejar error de duplicado
    if (err.code === "23505") {
      return res.status(400).json({ error: "Ya existe una asistencia registrada para este docente en la fecha seleccionada" });
    }
    
    res.status(500).json({ error: "Error al registrar asistencia del docente" });
  }
});

// ============================================
// INICIO DEL SERVIDOR
// ============================================

// Endpoint temporal para generar hash de contraseña (SOLO PARA DESARROLLO)
// ELIMINAR EN PRODUCCIÓN
app.post("/generate-hash", express.json(), async (req, res) => {
  try {
    // Verificar que req.body existe
    if (!req.body) {
      return res.status(400).json({ error: "No se recibieron datos en el body" });
    }
    
    const password = req.body?.password || req.body?.pass || null;
    if (!password) {
      return res.status(400).json({ 
        error: "Debe proporcionar una contraseña",
        hint: "Enviar: { \"password\": \"123\" }",
        received: req.body
      });
    }
    
    // Generar hash con salt rounds = 10
    const hash = await bcrypt.hash(password, 10);
    
    // Verificar que el hash funciona comparándolo
    const verify = await bcrypt.compare(password, hash);
    
    res.json({ 
      password, 
      hash,
      verified: verify,
      hash_length: hash.length,
      hash_preview: hash.substring(0, 20) + "...",
      sql_update: `UPDATE usuarios SET password_hash = '${hash}' WHERE deleted_at IS NULL;`
    });
  } catch (error) {
    res.status(500).json({ error: error.message, stack: error.stack });
  }
});

// Endpoint de debug para verificar usuario y hash (SOLO PARA DESARROLLO)
// ELIMINAR EN PRODUCCIÓN
app.post("/debug-user", async (req, res) => {
  try {
    const { dni, password } = req.body;
    if (!dni) {
      return res.status(400).json({ error: "Debe proporcionar un DNI" });
    }

    const result = await pool.query(
      "SELECT id, dni, nombres_completos, cargo, nivel, password_hash, deleted_at FROM usuarios WHERE dni = $1",
      [dni]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Usuario no encontrado" });
    }

    const user = result.rows[0];
    let match = null;
    let matchResult = false;

    if (password) {
      match = await bcrypt.compare(password, user.password_hash);
      matchResult = match;
    }

    res.json({
      usuario: {
        id: user.id,
        dni: user.dni,
        nombres_completos: user.nombres_completos,
        cargo: user.cargo,
        nivel: user.nivel,
        deleted_at: user.deleted_at,
        hash_length: user.password_hash ? user.password_hash.length : 0,
        hash_preview: user.password_hash ? user.password_hash.substring(0, 30) + "..." : null,
        hash_starts_with: user.password_hash ? user.password_hash.substring(0, 7) : null
      },
      password_provided: !!password,
      password_match: matchResult,
      message: password 
        ? (matchResult ? "✅ La contraseña es correcta" : "❌ La contraseña NO coincide") 
        : "No se proporcionó contraseña para verificar"
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${port}`);
});
