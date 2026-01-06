#!/bin/sh
set -e

#libwatcher_ver=$(readlink -f /usr/local/lib/libwatcher-c.so.0 | grep -oP 'libwatcher-c\.so\.0\.\K[0-9.]+')
#if [ "$libwatcher_ver" != "13.6" ]; then
#    echo "🔍 The current version of libwatcher is 0.$libwatcher_ver. Downgrading to working version (0.13.6)..."
#    echo "This is a temporary fix for the watcher. It is meant to disapear once watcher works properly with Mutagen."
#    cd /usr/local/lib
#    rm libwatcher-c.so.0
#    ln -s libwatcher-c.so.0.13.6 libwatcher-c.so.0
#    echo "✅ Downgraded libwatcher to version 0.13.6 successfully!"
#    cd /app
#else
#    echo "✅ libwatcher is already in version 0.13.6."
#fi

frankenphp fmt --overwrite /etc/frankenphp/Caddyfile
echo "✅ Reformated Caddyfile."

while [ -z "$(ls -A /app 2>/dev/null)" ]; do
  echo "⏳ Waiting for '/app' to contain files..."
  sleep 10
done
echo "✅ Repository '/app' contains files."

while [ -z "$(ls -A /app/assets 2>/dev/null)" ]; do
  echo "⏳ Waiting for '/app/assets' to contain files..."
  sleep 10
done

while [ -z "$(ls -A /app/bin 2>/dev/null)" ]; do
  echo "⏳ Waiting for '/app/bin' to contain files..."
  sleep 10
done

while [ -z "$(ls -A /app/config 2>/dev/null)" ]; do
  echo "⏳ Waiting for '/app/config' to contain files..."
  sleep 10
done

while [ -z "$(ls -A /app/public 2>/dev/null)" ]; do
  echo "⏳ Waiting for '/app/public' to contain files..."
  sleep 10
done

while [ -z "$(ls -A /app/src 2>/dev/null)" ]; do
  echo "⏳ Waiting for '/app/src' to contain files..."
  sleep 10
done

while [ -z "$(ls -A /app/templates 2>/dev/null)" ]; do
  echo "⏳ Waiting for '/app/templates' to contain files..."
  sleep 10
done

echo "✅ Local repository is here!"

while [ -z "$(ls -A /app/bin/console 2>/dev/null)" ]; do
  echo "⏳ Waiting for the binary '/app/bin/console'."
  sleep 10
done

while ! composer i --prefer-dist --no-progress -n; do
  echo "❌ Failed to install dependencies with Composer, retrying in 10 seconds..."
  sleep 10
done
echo "✅ Composer has installed dependencies successfully!"

while ! php bin/console importmap:install; do
  echo "❌ Failed to install dependencies with AssetMapper, retrying in 10 seconds..."
  sleep 10
done
echo "✅ AssetMapper has installed dependencies successfully!"

if [ "$1" = 'frankenphp' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ]; then
  # Display information about the current project
  # Or about an error in project initialization
  php bin/console -V

  echo "✅ PHP app is ready!"
fi

exec docker-php-entrypoint "$@"
