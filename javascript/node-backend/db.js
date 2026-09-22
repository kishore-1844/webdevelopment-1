import mysql from 'mysql2/promise';

export const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'practical_lab',
  waitForConnections: true,
  connectionLimit: 10
});

export async function listUsers() {
  const [rows] = await pool.query('SELECT id, name, email, role FROM users ORDER BY id DESC');
  return rows;
}
