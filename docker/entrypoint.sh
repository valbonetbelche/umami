#!/bin/sh
set -e

RENDER_PORT="${PORT:-3000}"
UMAMI_PORT=3000

export PORT="${UMAMI_PORT}"
export HOSTNAME="0.0.0.0"

cd /app
su nextjs -s /bin/sh -c "yarn start-docker" &

i=0
while [ "$i" -lt 60 ]; do
  if curl -sf "http://127.0.0.1:${UMAMI_PORT}/api/heartbeat" >/dev/null 2>&1; then
    break
  fi
  i=$((i + 1))
  sleep 2
done

cat > /etc/nginx/http.d/default.conf <<NGINX
server {
    listen ${RENDER_PORT};
    server_name _;

    location = /healthz {
        access_log off;
        default_type text/plain;
        return 200 'ok';
    }

    location / {
        proxy_pass http://127.0.0.1:${UMAMI_PORT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
NGINX

exec nginx -g 'daemon off;'
