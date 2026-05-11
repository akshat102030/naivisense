# NaiviSense API

Node.js 20 / Express 4 / TypeScript 5 / MongoDB / Redis

## Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Copy env and fill in secrets
cp .env.example .env
# Generate JWT secrets:
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# 3. Start MongoDB + Redis (Docker required)
docker compose up -d

# 4. Run dev server
npm run dev
# → http://localhost:8000/health

# 5. Run tests
npm test
```

## Endpoints (summary)

| Method | Path | Auth |
|--------|------|------|
| POST | /api/v1/auth/register | — |
| POST | /api/v1/auth/login | — |
| POST | /api/v1/auth/refresh | — |
| GET  | /api/v1/users/me | Bearer |
| POST | /api/v1/children | center_head |
| GET  | /api/v1/children | scoped by role |
| POST | /api/v1/sessions | therapist |
| POST | /api/v1/sessions/:id/notes | therapist |
| POST | /api/v1/home-plans | therapist |
| POST | /api/v1/home-plans/:id/tasks/:taskId/log | parent |
| GET  | /api/v1/verification/pending | center_head |
| POST | /api/v1/verification/:logId | center_head |
| POST | /api/v1/alerts | parent |
| GET  | /api/v1/reports/progress | Bearer |

## Environment Variables

See `.env.example` for all required variables.

## Tech Stack

- Express 4 + TypeScript 5
- MongoDB 7 via Mongoose 8
- JWT (access 15min, refresh 7d) + bcrypt cost 12
- Zod validation on all inputs
- BullMQ + Redis for background jobs
- AWS S3 (ap-south-1) — presigned URLs / server upload
- Pino logging
- Vitest + Supertest + mongodb-memory-server for tests
