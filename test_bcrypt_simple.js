// Test simple de bcrypt para verificar que funciona
const bcrypt = require('bcrypt');

async function testBcrypt() {
  console.log('=== TEST SIMPLE DE BCRYPT ===\n');
  
  const password = '123';
  
  try {
    // 1. Generar hash
    console.log('1. Generando hash para "123"...');
    const hash = await bcrypt.hash(password, 10);
    console.log('✅ Hash generado:');
    console.log(hash);
    console.log('Longitud:', hash.length);
    console.log('');
    
    // 2. Verificar hash
    console.log('2. Verificando hash...');
    const match = await bcrypt.compare(password, hash);
    console.log('✅ Resultado:', match ? 'COINCIDE' : 'NO COINCIDE');
    console.log('');
    
    // 3. Probar con contraseña incorrecta
    console.log('3. Probando con contraseña incorrecta "456"...');
    const wrongMatch = await bcrypt.compare('456', hash);
    console.log('✅ Resultado:', wrongMatch ? 'COINCIDE (ERROR!)' : 'NO COINCIDE (Correcto)');
    console.log('');
    
    // 4. Probar con el hash del script SQL
    console.log('4. Probando con hash del script SQL...');
    const oldHash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';
    const oldMatch = await bcrypt.compare(password, oldHash);
    console.log('Hash antiguo:', oldHash.substring(0, 30) + '...');
    console.log('✅ Resultado:', oldMatch ? 'COINCIDE' : 'NO COINCIDE');
    console.log('');
    
    // 5. SQL para actualizar
    console.log('5. SQL para actualizar usuarios:');
    console.log('--------------------------------');
    console.log(`UPDATE usuarios SET password_hash = '${hash}' WHERE deleted_at IS NULL;`);
    console.log('--------------------------------');
    
  } catch (error) {
    console.error('❌ Error:', error);
    console.error('Stack:', error.stack);
  }
}

testBcrypt();
