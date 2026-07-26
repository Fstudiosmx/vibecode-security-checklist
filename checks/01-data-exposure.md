# Check 1: Exposición de datos

## Script de verificación

```bash
#!/bin/bash
# check-data-exposure.sh

PROJECT_URL=${1:-"https://TU-PROYECTO.supabase.co"}
ANON_KEY=${2:-"TU_ANON_KEY"}
TABLE=${3:-"profiles"}

echo "[CHECK 1] Testeando exposición pública de tabla: $TABLE"

RESPONSE=$(curl -s \
  "$PROJECT_URL/rest/v1/$TABLE?select=*" \
  -H "apikey: $ANON_KEY")

COUNT=$(echo $RESPONSE | python3 -c "import sys,json; data=json.load(sys.stdin); print(len(data) if isinstance(data,list) else 0)" 2>/dev/null)

if [ "$COUNT" -gt "0" ]; then
  echo "❌ FAIL: La tabla '$TABLE' devolvió $COUNT filas sin autenticación"
  echo "   Fix: Activa Row Level Security en Supabase"
else
  echo "✅ PASS: La tabla '$TABLE' no devuelve datos sin auth"
fi
```

## Uso
```bash
bash checks/01-data-exposure.sh https://mi-proyecto.supabase.co mi-anon-key usuarios
```
