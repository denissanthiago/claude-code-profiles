---
paths:
  - "src/**/*.ts"
  - "app/**/*.ts"
---

# Seguridad

OWASP Top 10 aplicado al backend. Se carga al tocar código.

## Inputs

- Nunca confiar en input del cliente. Validar TODO con Zod en el boundary.
- Escape/sanitize si se usa en HTML, SQL raw, shell, regex.

## SQL

- **Prohibido concatenar strings para queries.** Usar placeholders o query builders:
  ```typescript
  // MAL
  db.raw(`SELECT * FROM users WHERE id = '${userId}'`)
  // BIEN
  db.raw(`SELECT * FROM users WHERE id = $1`, [userId])
  ```
- Con Prisma/Drizzle, las queries parametrizadas son el default. No usar `$queryRawUnsafe`.

## Auth

- Cada endpoint privado pasa por middleware de auth. Explícito mejor que implícito.
- JWTs: verificar firma, expiración, issuer, audience.
- Passwords: hash con bcrypt/argon2id. Jamás en claro.
- Rate limiting por IP/usuario en endpoints sensibles (login, reset-password, signup).

## Secrets

- Solo en env vars. Nunca en código ni en commits.
- `.env` en `.gitignore`. Usar `.env.example` con placeholder values.
- Rotar keys si sospechás leak. Documentar proceso.

## Logs

- Nunca loggear passwords, tokens, secrets, PII innecesaria.
- Redact en logs estructurados: `{ password: '[REDACTED]' }`.
- IDs de usuario OK, emails OK en logs internos (revisar GDPR si aplica).

## CORS

- Allowlist de origins específicos. Jamás `Access-Control-Allow-Origin: *` en prod para endpoints con auth.
- `credentials: true` solo si necesario.

## Headers de seguridad

- `Strict-Transport-Security: max-age=31536000`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY` (o `SAMEORIGIN`)
- CSP si servís HTML.

## Dependencias

- Audit regular: `npm audit` / `pnpm audit` / `bun audit`.
- Lockfile commiteado. Nunca `npm install --latest` ciego en prod.

## Errores

- En 500s, responder mensaje genérico. Nunca stack trace al cliente.
- Loggear internamente el stack completo.
- Distinguir errores esperables (400/404) de bugs (500).
