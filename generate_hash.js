// Script para generar un hash bcrypt correcto para la contraseña "123"
const bcrypt = require('bcrypt');

async function generateHash() {
  const password = '123';
  console.log('🔐 Generando hash bcrypt para la contraseña: "123"\n');
  
  try {
    // Generar hash con salt rounds = 10
    const hash = await bcrypt.hash(password, 10);
    console.log('✅ Hash generado correctamente:\n');
    console.log(hash);
    console.log('\n📋 SQL para actualizar usuarios:');
    console.log('-----------------------------------');
    console.log(`UPDATE usuarios SET password_hash = '${hash}' WHERE deleted_at IS NULL;`);
    console.log('-----------------------------------\n');
    
    // Verificar que el hash funciona
    const isValid = await bcrypt.compare(password, hash);
    if (isValid) {
      console.log('✅ Verificación: El hash funciona correctamente');
    } else {
      console.log('❌ ERROR: El hash NO funciona');
    }
    
    // Probar con el hash antiguo que estaba en el script
    const oldHash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';
    const oldIsValid = await bcrypt.compare(password, oldHash);
    console.log(`\n🔍 Verificando hash antiguo: ${oldIsValid ? '✅ Válido' : '❌ Inválido'}`);
    
  } catch (error) {
    console.error('❌ Error generando hash:', error);
  }
}

generateHash();
