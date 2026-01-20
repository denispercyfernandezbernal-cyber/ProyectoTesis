// Script para probar el endpoint de login
const https = require('https');

const API_URL = 'proyectotesis-production-72e2.up.railway.app';

function makeRequest(path, method, data) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(data);
    
    const options = {
      hostname: API_URL,
      port: 443,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
      },
    };

    const req = https.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseData);
          resolve({ status: res.statusCode, statusText: res.statusMessage, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, statusText: res.statusMessage, data: responseData });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

async function testLogin() {
  console.log('🔍 Probando endpoint de login...\n');
  
  const testCases = [
    { dni: '12345678', password: '123', description: 'Docente PRIMERO A' },
    { dni: '12345678', password: '1234', description: 'Docente con contraseña incorrecta' },
    { dni: '99999999', password: '123', description: 'Director' },
    { dni: '00000000', password: '123', description: 'Usuario que no existe' },
  ];

  for (const testCase of testCases) {
    try {
      console.log(`\n📝 Prueba: ${testCase.description}`);
      console.log(`   DNI: ${testCase.dni}`);
      console.log(`   Password: ${testCase.password}`);
      
      const response = await makeRequest('/login', 'POST', {
        dni: testCase.dni,
        password: testCase.password,
      });
      
      console.log(`   Status: ${response.status} ${response.statusText}`);
      console.log(`   Response:`, JSON.stringify(response.data, null, 2));
      
      if (response.status === 200 && response.data.token) {
        console.log(`   ✅ Login exitoso! Token recibido.`);
      } else {
        console.log(`   ❌ Error: ${response.data.error || 'Error desconocido'}`);
      }
    } catch (error) {
      console.error(`   ❌ Error de conexión:`, error.message);
    }
  }

  console.log('\n\n🔍 Verificando endpoint de generación de hash...\n');
  
  try {
    const hashResponse = await makeRequest('/generate-hash', 'POST', {
      password: '123',
    });
    
    console.log('   Status:', hashResponse.status);
    console.log('   Response:', JSON.stringify(hashResponse.data, null, 2));
    
    if (hashResponse.status === 200 && hashResponse.data.hash) {
      console.log('\n   ✅ Hash generado correctamente');
      console.log(`   Hash para "123": ${hashResponse.data.hash}`);
      console.log('\n   💡 Puedes usar este hash en tu base de datos:');
      console.log(`   UPDATE usuarios SET password_hash = '${hashResponse.data.hash}' WHERE dni = '12345678';`);
    }
  } catch (error) {
    console.error(`   ❌ Error:`, error.message);
  }
}

testLogin();
