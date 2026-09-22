import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import express from 'express';
import cookieParser from 'cookie-parser';
import session from 'express-session';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'development-only-secret';
const users = [];
const students = [{ id: 1, name: 'Riya', course: 'BCA', marks: 92 }];
const products = [{ id: 1, name: 'Notebook', price: 10 }];
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(session({ secret: process.env.SESSION_SECRET || 'development-session-secret', resave: false, saveUninitialized: false, cookie: { httpOnly: true, sameSite: 'lax' } }));
app.use((req, res, next) => { console.log(new Date().toISOString(), req.method, req.originalUrl); next(); });
function requireAuth(req, res, next) { const token = req.headers.authorization?.replace('Bearer ', ''); if (!token) return res.status(401).json({ error: 'Authentication required' }); try { req.user = jwt.verify(token, JWT_SECRET); next(); } catch { res.status(401).json({ error: 'Invalid token' }); } }
function requireAdmin(req, res, next) { if (req.user?.role !== 'admin') return res.status(403).json({ error: 'Admin role required' }); next(); }
app.get('/', (req, res) => res.json({ message: 'Node.js practical backend is running', routes: ['/api/students', '/api/products', '/api/users'] }));
app.get('/api/students', (req, res) => res.json(students));
app.post('/api/students', (req, res) => { const { name, course, marks } = req.body; if (!name || !course || marks === undefined) return res.status(400).json({ error: 'name, course, and marks are required' }); const student = { id: Date.now(), name, course, marks: Number(marks) }; students.push(student); res.status(201).json(student); });
app.put('/api/students/:id', (req, res) => { const item = students.find(x => x.id === Number(req.params.id)); if (!item) return res.status(404).json({ error: 'Student not found' }); Object.assign(item, req.body); res.json(item); });
app.delete('/api/students/:id', (req, res) => { const index = students.findIndex(x => x.id === Number(req.params.id)); if (index < 0) return res.status(404).json({ error: 'Student not found' }); res.json(students.splice(index, 1)[0]); });
app.get('/api/products', (req, res) => res.json(products));
app.post('/api/products', requireAuth, requireAdmin, (req, res) => { const product = { id: Date.now(), name: req.body.name, price: Number(req.body.price) }; if (!product.name || Number.isNaN(product.price)) return res.status(400).json({ error: 'Valid name and price are required' }); products.push(product); res.status(201).json(product); });
app.post('/auth/register', async (req, res) => { const { email, password } = req.body; if (!email || !password || password.length < 8) return res.status(400).json({ error: 'Email and 8-character password required' }); if (users.some(x => x.email === email)) return res.status(409).json({ error: 'User exists' }); const user = { id: Date.now(), email, password: await bcrypt.hash(password, 10), role: 'user' }; users.push(user); res.status(201).json({ id: user.id, email: user.email }); });
app.post('/auth/login', async (req, res) => { const user = users.find(x => x.email === req.body.email); if (!user || !(await bcrypt.compare(req.body.password || '', user.password))) return res.status(401).json({ error: 'Invalid credentials' }); req.session.userId = user.id; const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '1h' }); res.cookie('logged_in', 'true', { httpOnly: true, sameSite: 'lax' }).json({ token }); });
app.post('/auth/logout', (req, res) => req.session.destroy(() => { res.clearCookie('logged_in'); res.json({ message: 'Logged out' }); }));
app.get('/api/protected', requireAuth, (req, res) => res.json({ message: 'Protected data', user: req.user }));
app.use((req, res) => res.status(404).json({ error: 'Not found' }));
app.use((err, req, res, next) => { console.error(err); res.status(500).json({ error: 'Internal server error' }); });
app.listen(PORT, () => console.log(`Express server listening on http://localhost:${PORT}`));

// Built-in HTTP, fs, and path examples kept in one runnable module.
export async function builtInExamples() { const file = path.join(process.cwd(), 'node-example.txt'); await fs.writeFile(file, 'Node.js fs module example'); return fs.readFile(file, 'utf8'); }
export const basicServer = http.createServer((req, res) => { res.writeHead(200, { 'content-type': 'text/plain' }); res.end('Basic client-server response'); });
