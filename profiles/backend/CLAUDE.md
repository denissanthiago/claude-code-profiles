## Perfil: backend

Stack base asumido (ajustá al aplicar si tu repo usa otro):

- **Runtime:** Node.js ≥ 20 o Bun (detectar desde `package.json` o `bun.lockb`)
- **Lenguaje:** TypeScript estricto
- **HTTP framework:** libre — Express / Fastify / Hono / Elysia (según repo)
- **DB:** PostgreSQL (default). SQLite/MySQL/etc. según proyecto
- **ORM/Query builder:** Prisma o Drizzle (según repo). Raw SQL válido para queries complejas
- **Infra local:** Docker + docker-compose
- **Tests:** Vitest / Bun test / Jest
- **Validación:** Zod para inputs y configs

### Convenciones

- Toda entrada del mundo exterior validada con Zod antes de tocar lógica.
- Errores esperables tipados explícitamente. `Result<T, E>` o discriminated unions > excepciones para flujo de negocio.
- Logging estructurado (pino/bunyan). Nunca `console.log` en código de producción.
- Migrations versionadas, nunca edits a migrations aplicadas.
- Secretos: solo vía env vars. Jamás hardcodeados.

### Comandos típicos

```bash
# Dev
pnpm dev              # o: bun dev / npm run dev

# DB
docker compose up -d db
pnpm db:migrate       # Prisma: npx prisma migrate dev
pnpm db:seed
psql postgresql://localhost:5432/mydb  # Conexión manual

# Tests
pnpm test             # unit
pnpm test:integration

# Build
pnpm build
```

### Qué NO tocar

- `.env*` — variables sensibles.
- `*-lock.*` — lockfiles.
- `./data/**` — volumenes de DB locales (docker).
- `./migrations/applied/**` — migrations que ya se corrieron en algún entorno.
- Nunca `docker system prune` sin confirmación explícita del usuario.
- Nunca `DROP DATABASE` ni `DROP TABLE` sin confirmación explícita.

### MCPs globales disponibles

- `context7` — docs actualizados de librerías (Prisma, Drizzle, frameworks HTTP)
- `exa` — research general
- `playwright` — para testear APIs con un cliente HTTP real si hace falta
- `obsidian` — notas/documentación

### Contexto del proyecto

<!-- Edita esta sección al aplicar el perfil con los detalles específicos de tu repo -->

- **Nombre del proyecto:** TODO
- **Qué hace:** TODO
- **Puerto dev:** 3000 (default)
- **DB:** postgresql://localhost:5432/TODO
- **Integraciones externas:** TODO
- **Deploy target:** TODO (Vercel / Fly.io / Railway / AWS / etc.)
