if [ ! -f /var/www/html/.env ]; then
    cp /var/www/html/.env.example /var/www/html/.env
fi

if ! grep -q "APP_KEY=base64:" /var/www/html/.env; then
    php /var/www/html/artisan key:generate --force
fi

KEY_VAL=$(grep APP_KEY /var/www/html/.env | cut -d '=' -f2)

cat <<EOF > /var/www/html/.env
APP_NAME=Laravel
APP_ENV=local
APP_KEY=$KEY_VAL
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_DATABASE:-laravel_db}
DB_USERNAME=${DB_USERNAME:-laravel_user}
DB_PASSWORD=${DB_PASSWORD:-secretpass}

SESSION_DRIVER=file
EOF

rm -f /var/www/html/bootstrap/cache/packages.php /var/www/html/bootstrap/cache/services.php /var/www/html/bootstrap/cache/config.php
php /var/www/html/artisan config:clear
php /var/www/html/artisan package:discover --ansi
php /var/www/html/artisan migrate --force

chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
exec "$@"
