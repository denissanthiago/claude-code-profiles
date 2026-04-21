---
paths:
  - "src/api/**/*.ts"
  - "src/routes/**/*.ts"
  - "src/controllers/**/*.ts"
  - "app/api/**/*.ts"
---

# Diseño de APIs

Se carga al tocar archivos de endpoints.

## Validación de inputs

- **Siempre Zod** (o equivalente) en el boundary. Nunca confiar en el input raw.
- Parseo temprano: falla con 400 antes de que el input toque la lógica.
- Schemas reutilizables entre endpoints.

```typescript
const CreateUserBody = z.object({
  email: z.string().email(),
  age: z.number().int().positive(),
});

const parsed = CreateUserBody.safeParse(await req.json());
if (!parsed.success) return jsonError(400, parsed.error);
```

## Naming de endpoints

- RESTful: `GET /users`, `POST /users`, `GET /users/:id`, `PATCH /users/:id`, `DELETE /users/:id`.
- Sub-resources anidados: `GET /users/:id/posts`.
- Acciones no-CRUD como POST a un path verbal: `POST /users/:id/reset-password`.

## Status codes

- `200 OK` → GET/PATCH exitoso con body
- `201 Created` → POST exitoso con recurso creado en el body
- `204 No Content` → DELETE exitoso, sin body
- `400 Bad Request` → input inválido (validación falló)
- `401 Unauthorized` → falta autenticación
- `403 Forbidden` → autenticado pero sin permiso
- `404 Not Found` → recurso no existe
- `409 Conflict` → conflicto con estado actual (ej. unique constraint)
- `422 Unprocessable Entity` → semánticamente inválido
- `500 Internal Server Error` → bug en el servidor (no filtrar detalles)

## Formato de respuesta

Consistente en toda la API:

```typescript
// Éxito
{ data: T, meta?: {...} }

// Error
{ error: { code: string, message: string, details?: {...} } }
```

## Idempotencia

- `GET`, `PUT`, `DELETE` deben ser idempotentes.
- `POST` no es idempotente por default. Para casos sensibles, soportar header `Idempotency-Key`.

## Paginación

- Cursor-based preferido sobre offset para listas grandes.
- Response: `{ data: [...], meta: { nextCursor: string | null } }`.

## Versionado

- Breaking changes → nueva versión: `/v2/users`.
- Deprecaciones → response header `Deprecation: true` + fecha de sunset.
