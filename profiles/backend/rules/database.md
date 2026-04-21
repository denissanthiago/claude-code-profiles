---
paths:
  - "src/db/**/*.ts"
  - "prisma/**/*"
  - "drizzle/**/*"
  - "migrations/**/*"
  - "src/**/repositories/**/*.ts"
  - "src/**/models/**/*.ts"
---

# Base de datos

Se carga al tocar código que interactúa con la DB.

## Migrations

- **Una migration por cambio lógico.** No mezclar "agregar tabla users" con "renombrar campo en orders".
- **Nunca editar una migration ya aplicada** en cualquier entorno. Crear una nueva.
- Nombres descriptivos: `add_users_email_index`, no `update_1`.
- Reversibles cuando sea posible (down migration).
- Review de migrations antes de apply: muchas acciones son irreversibles.

## DDL peligroso

Antes de correr, **confirmar con el usuario**:

- `DROP TABLE`, `DROP COLUMN`, `DROP INDEX`
- `ALTER TABLE ... RENAME` en tablas con uso activo
- `TRUNCATE`
- Cambios de tipo que pueden perder datos

## Indexes

- Agregar cuando haya queries lentas medibles, no preventivamente.
- Indexes en FKs, unique constraints, columnas de búsqueda frecuente.
- Multi-column en orden de selectividad.
- Revisar `EXPLAIN ANALYZE` antes de asumir que un index se usa.

## Transacciones

- Operaciones que afectan múltiples tablas relacionadas → transacción.
- Mantener transacciones cortas. Side effects externos (HTTP, email) FUERA de la transacción.
- Row-level locks (`SELECT ... FOR UPDATE`) con cuidado: deadlocks.

## N+1

- Detectar queries en loops. Usar `include`/`JOIN` o data loaders (DataLoader).
- Revisar con logging de queries en dev.

## Seeding

- Seeds idempotentes: `ON CONFLICT DO NOTHING` o upserts.
- Separar seeds de dev de seeds de prod.
- Jamás datos reales de usuarios en seeds.

## Conexiones

- Pool de conexiones correctamente dimensionado (típicamente 10-30 según carga).
- Cerrar conexiones en scripts one-shot.
- Usar PgBouncer o similar en prod con muchos workers serverless.

## Backups

- Antes de una migration destructiva en prod: snapshot.
- Validar que el restore funciona — nunca probar por primera vez en una emergencia.

## Naming

- Tablas: `snake_case`, plural (`users`, `blog_posts`).
- Columnas: `snake_case`.
- FKs: `<tabla_singular>_id` (`user_id`).
- Timestamps: `created_at`, `updated_at`, `deleted_at` para soft-delete.
