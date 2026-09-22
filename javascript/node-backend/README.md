# Node.js Backend Experiments

Run `npm install`, then `npm start`. The server exposes student and product CRUD endpoints, registration/login/logout, JWT protected data, cookies, sessions, request logging, validation middleware, role authorization, 404 handling, and error handling.

Examples:

- `GET /api/students`
- `POST /api/students` with `{ "name": "Neha", "course": "BCA", "marks": 88 }`
- `PUT /api/students/:id`
- `DELETE /api/students/:id`
- `POST /auth/register`
- `POST /auth/login`
- `GET /api/protected` with `Authorization: Bearer <token>`

Set `DB_HOST`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME` before using `db.js`. The MySQL schema is in `../mysql/mysql-experiments.sql`.
