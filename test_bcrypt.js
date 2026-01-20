// Script para verificar el hash de bcrypt
const bcrypt = require("bcrypt");

// Hash almacenado en la base de datos
const storedHash = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy";
const password = "123";

// Verificar si la contraseña coincide
bcrypt.compare(password, storedHash, (err, result) => {
  if (err) {
    console.error("Error:", err);
    return;
  }
  
  console.log("Contraseña:", password);
  console.log("Hash almacenado:", storedHash);
  console.log("¿Coincide?:", result);
  
  if (result) {
    console.log("✅ El hash es correcto");
  } else {
    console.log("❌ El hash NO coincide");
    
    // Generar un nuevo hash
    bcrypt.hash(password, 10, (err, newHash) => {
      if (err) {
        console.error("Error generando hash:", err);
        return;
      }
      console.log("\nNuevo hash generado:", newHash);
      console.log("\nUsa este hash en la base de datos:");
      console.log(`UPDATE usuarios SET password_hash = '${newHash}' WHERE dni = '12345678';`);
    });
  }
});
