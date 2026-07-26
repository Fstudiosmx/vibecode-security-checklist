#!/bin/bash
# check-seo-social.sh
# Check 5: SEO y preview social

URL=${1:-"https://tu-app.com"}

echo "[CHECK 5] Verificando SEO y meta tags en: $URL"

# Verificar og:title
OG_TITLE=$(curl -s "$URL" | grep -o 'og:title.*content="[^"]*"' | head -1)
if [ -z "$OG_TITLE" ]; then
  echo "❌ og:title no encontrado"
else
  echo "✅ og:title: $OG_TITLE"
fi

# Verificar og:image
OG_IMAGE=$(curl -s "$URL" | grep -o 'og:image.*content="[^"]*"' | head -1)
if [ -z "$OG_IMAGE" ]; then
  echo "❌ og:image no encontrado — el link preview estará vacío"
else
  echo "✅ og:image encontrado"
fi

# Verificar robots.txt
ROBOTS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/robots.txt")
if [ "$ROBOTS" = "200" ]; then
  echo "✅ robots.txt existe"
else
  echo "❌ robots.txt no encontrado (HTTP $ROBOTS)"
fi

# Verificar sitemap
SITEMAP=$(curl -s -o /dev/null -w "%{http_code}" "$URL/sitemap.xml")
if [ "$SITEMAP" = "200" ]; then
  echo "✅ sitemap.xml existe"
else
  echo "❌ sitemap.xml no encontrado (HTTP $SITEMAP)"
fi

echo ""
echo "Preview social: https://opengraph.xyz/url?url=$URL"
echo "Security headers: https://securityheaders.com/?q=$URL"
