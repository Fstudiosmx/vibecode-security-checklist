# Check 3: Rate Limiting

## Script de verificación

```bash
#!/bin/bash
# check-rate-limit.sh

ENDPOINT=${1:-"https://TU-APP.com/api/generate"}
MAX_REQUESTS=${2:-15}
FAIL_COUNT=0

echo "[CHECK 3] Testeando rate limit en: $ENDPOINT"
echo "Enviando $MAX_REQUESTS requests..."

for i in $(seq 1 $MAX_REQUESTS); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -d '{"prompt":"test"}')
  
  if [ "$STATUS" = "429" ]; then
    echo "✅ PASS: Rate limit activado en request #$i (HTTP 429)"
    exit 0
  fi
  
  echo "  Request $i: HTTP $STATUS"
done

echo "❌ FAIL: $MAX_REQUESTS requests completados sin rate limiting"
echo "   Fix: Implementa límite de 10 req/min por IP con respuesta 429"
```

## Uso
```bash
bash checks/03-rate-limit.sh https://mi-app.com/api/generate 15
```
