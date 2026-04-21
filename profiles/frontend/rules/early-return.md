---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---

# Early Return Pattern

- Usá **early return** para validaciones, guardas y casos borde al inicio de funciones.
- **Evitá `else`** cuando el bloque `if` ya retorna, lanza o sale del flujo. El código del `else` debe ir al nivel de la función.
- Invertí condiciones cuando ayude a salir antes y reducir anidamiento (flatten nesting).
- Manejá primero los casos negativos/inválidos; dejá el "happy path" como flujo principal sin indentación extra.
- No envuelvas el cuerpo entero de una función en un `if` cuando podés retornar temprano en el caso opuesto.
- Aplicá lo mismo a loops: usá `continue` en vez de envolver el cuerpo del loop en un `if`.

## Ejemplos

❌ Evitar:
```ts
function getUserName(user) {
  if (user) {
    if (user.name) {
      return user.name;
    } else {
      return "Anónimo";
    }
  } else {
    return null;
  }
}
```

✅ Preferir:
```ts
function getUserName(user) {
  if (!user) return null;
  if (!user.name) return "Anónimo";
  return user.name;
}
```
