# 🔐 Vibecode Security Checklist

> Los 5 checks que debes correr **antes de lanzar** cualquier app construida con AI. Cada uno toma ~10 minutos y puede salvarte de una brecha, una factura de $300 o un lanzamiento muerto.

Basado en el artículo de [Jiri George Dolejs](https://medium.com/@jiri-george-dolejs) — *"The 5 Things That Break a Vibecoded App in Week One"*.

---

## ⚡ Checks rápidos

| # | Check | Riesgo si falla |
|---|-------|-----------------|
| 1 | [¿Quién puede leer tus datos?](#check-1--quién-puede-leer-tus-datos) | Exposición total de DB |
| 2 | [El leak de dos cuentas (IDOR)](#check-2--el-leak-de-dos-cuentas-idor) | Usuarios leen datos de otros |
| 3 | [La factura que te llega a ti](#check-3--la-factura-que-te-llega-a-ti) | Bill de $300+ overnight |
| 4 | [El flujo de pago](#check-4--el-flujo-de-pago) | Producto gratis / precio manipulado |
| 5 | [¿Te puede encontrar alguien?](#check-5--te-puede-encontrar-alguien) | Lanzamiento sin clics |

---

## Check 1 — ¿Quién puede leer tus datos?

**Pregunta real:** ¿Puede un extraño sin login leer datos privados?

### Flavor A: Clave maestra expuesta
Busca en el JS cargado en el browser:
```
service_role | sk_live | SUPABASE_SERVICE | OPENAI_API_KEY
```
Abre DevTools → Sources → Ctrl+F. Si aparece, **ya está filtrada**.

### Flavor B: DB que responde a extraños
```bash
curl "https://TU-PROYECTO.supabase.co/rest/v1/profiles?select=*" \
  -H "apikey: TU_ANON_KEY"
```
Si devuelve filas reales → tu DB es pública.

### Fix
- Activa **Row Level Security** en cada tabla
- Agrega política: usuarios solo leen sus propias filas
- Si encontraste una clave filtrada: **rótala** (no solo la borres del código)

---

## Check 2 — El leak de dos cuentas (IDOR)

**Pregunta real:** ¿Puedes, logueado como tú, leer datos privados de otro usuario?

### Cómo testear
1. Crea dos cuentas: A y B
2. Con B, crea algo privado — nota el ID en la URL (ej: `/api/orders/1042`)
3. Logueate como A, intenta acceder directo a `/api/orders/1042`
4. Si A recibe los datos de B → tu app está rota

### Fix
Cada endpoint debe filtrar por el ID del usuario autenticado (del token/sesión), **nunca** por el ID que viene en la URL o el body.

> ⚠️ Haz este check aunque omitas los demás. Es el que sale en las noticias.

---

## Check 3 — La factura que te llega a ti

**Pregunta real:** ¿Puede alguien llamar tu endpoint de pago-por-uso infinitamente?

### Test rápido (15 requests)
```bash
for i in $(seq 1 15); do
  curl -s -o /dev/null -w "%{http_code}\n" \
    -X POST "https://TU-APP.com/api/generate" \
    -H "Content-Type: application/json" -d '{"prompt":"test"}'
done
```
- 15x `200` → **no hay rate limit** ❌
- Empieza a responder `429` después de ~10 → protegido ✅

### Fix
- Rate limit por IP/usuario: ej. 10 req/min → 429
- Endpoints costosos detrás de auth
- Re-corre el loop para confirmar

---

## Check 4 — El flujo de pago

**Pregunta real:** ¿Puede alguien obtener tu producto gratis o pagar el precio que quiera?

### Hole 1: Webhook sin firma verificada
Busca en tu handler de Stripe:
```js
stripe.webhooks.constructEvent(body, signature, secret)
```
Si solo ves `JSON.parse(body)` sin esa verificación → cualquiera puede enviar un fake "payment succeeded".

### Hole 2: Precio definido en el frontend
Busca en el código cliente dónde se setea `amount` o `price`. Si viene del frontend y se envía al server → el usuario puede editarlo.

### Fix
- Verifica siempre la firma del webhook server-side
- El precio se determina en el server, desde un product ID — nunca desde el request
- Implementa idempotencia para no procesar el mismo pago dos veces

---

## Check 5 — ¿Te puede encontrar alguien?

**Pregunta real:** Cuando postees el link, ¿se ve como algo que vale la pena clickear?

### Tests
```bash
# Preview de redes sociales
https://opengraph.xyz → pega tu URL

# SEO básico
https://tu-app.com/robots.txt
https://tu-app.com/sitemap.xml

# 404 personalizado
https://tu-app.com/esto-no-existe

# Security headers
https://securityheaders.com
```

### Fix
- Agrega `og:title`, `og:description`, `og:image` (1200×630) al `<head>`
- Crea `robots.txt` y `sitemap.xml`
- Diseña una página 404 con tu branding
- Configura security headers básicos

---

## 🧠 El patrón detrás de los 5

Ninguno es sobre código mal escrito. Cada uno es un **guardrail faltante** — el AI optimizó para "funciona en el demo", y el demo tiene un usuario amigable, sin extraños, sin incentivo de romper nada.

Tú eres el usuario amigable. Estos 5 checks son lo más cercano a enviarle un extraño a tu app antes de que llegue uno de verdad.

---

## 🛠️ Uso como Skill para agentes AI

Este repositorio puede usarse como skill de referencia en agentes Claude Code, OpenCode u otros:

```
Antes de hacer deploy de cualquier app, ejecuta los 5 checks del archivo README.md
del repo Fstudiosmx/vibecode-security-checklist en el orden listado.
Reporta cada check como PASS ✅ o FAIL ❌ con evidencia.
```

---

## Créditos

- Artículo original: *"The 5 Things That Break a Vibecoded App in Week One"* — Jiri George Dolejs
- Herramienta automatizada: [ShipCheck](https://shipcheck.dev) (€9.99 one-time)
- Skill estructurada para Fstudiosmx por [@luisitoys12](https://github.com/luisitoys12)
