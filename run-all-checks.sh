#!/bin/bash
# run-all-checks.sh
# Corre todos los checks disponibles contra tu app

APP_URL=${1:-""}

if [ -z "$APP_URL" ]; then
  echo "Uso: bash run-all-checks.sh https://tu-app.com"
  exit 1
fi

echo "================================================"
echo "  VIBECODE SECURITY CHECKLIST"
echo "  App: $APP_URL"
echo "================================================"
echo ""

# Check 5 (sin credenciales necesarias)
bash checks/05-seo-social.sh "$APP_URL"

echo ""
echo "Para los checks 1 y 3, ejecuta manualmente:"
echo "  bash checks/01-data-exposure.sh TU_SUPABASE_URL TU_ANON_KEY"
echo "  bash checks/03-rate-limit.sh $APP_URL/api/generate"
echo ""
echo "Checks 2 y 4 requieren revisión manual — ver README.md"
