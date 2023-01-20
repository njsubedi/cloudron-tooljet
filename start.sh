#!/bin/bash
set -eu

# ensure that data directory is owned by 'cloudron' user
chown -R cloudron:cloudron /app/data

if [[ ! -f /app/data/env ]]; then
  # Copy default ENV file
  cp /app/code/.env.example /app/data/env

  # Generate keys only on first run
  crudini --set /app/data/env "" LOCKBOX_MASTER_KEY "$(openssl rand -hex 32)"
  crudini --set /app/data/env "" SECRET_KEY_BASE "$(openssl rand -hex 64)"

  # Turn off home pinging (only on first run)
  crudini --set /app/data/env "" CHECK_FOR_UPDATES "0"
  crudini --set /app/data/env "" ENABLE_MARKETPLACE_FEATURE "false"
  crudini --set /app/data/env "" DISABLE_APP_TELEMETRY "true"
  crudini --set /app/data/env "" DISABLE_TOOLJET_TELEMETRY "true"

  # Disable sign-ups on first run
  crudini --set /app/data/env "" DISABLE_SIGNUPS "true"

  # Only log ORM errors
  crudini --set /app/data/env "" ORM_LOGGING "error"
fi

# Tooljet requires TOOLJET_HOST to start with http:// or https:// so CLOUDRON_APP_DOMAIN won't work here.
crudini --set /app/data/env "" NODE_ENV "production"
crudini --set /app/data/env "" SERVER_HOST "server"
crudini --set /app/data/env "" TOOLJET_HOST "$CLOUDRON_APP_ORIGIN"
crudini --set /app/data/env "" TOOLJET_SERVER_URL "$CLOUDRON_APP_ORIGIN"

# Disable builtin database (not needed because of postgres addon)
crudini --set /app/data/env "" ENABLE_TOOLJET_DB "false"

# Database settings
crudini --set /app/data/env "" PG_HOST "$CLOUDRON_POSTGRESQL_HOST"
crudini --set /app/data/env "" PG_PORT "$CLOUDRON_POSTGRESQL_PORT"
crudini --set /app/data/env "" PG_USER "$CLOUDRON_POSTGRESQL_USERNAME"
crudini --set /app/data/env "" PG_PASS "$CLOUDRON_POSTGRESQL_PASSWORD"
crudini --set /app/data/env "" PG_DB "$CLOUDRON_POSTGRESQL_DATABASE"
crudini --set /app/data/env "" PG_DB_OWNER "false"

# SMTP Settings
crudini --set /app/data/env "" DEFAULT_FROM_EMAIL "$CLOUDRON_MAIL_FROM"
crudini --set /app/data/env "" SMTP_USERNAME "$CLOUDRON_MAIL_SMTP_USERNAME"
crudini --set /app/data/env "" SMTP_PASSWORD "$CLOUDRON_MAIL_SMTP_PASSWORD"
crudini --set /app/data/env "" SMTP_DOMAIN "$CLOUDRON_MAIL_SMTP_SERVER"
crudini --set /app/data/env "" SMTP_PORT "$CLOUDRON_MAIL_SMTP_PORT"

# Start Tooljet
/usr/local/bin/gosu cloudron:cloudron /app/code/server/scripts/boot.sh
