# Test Watcher

This is a test for e-dant's libwatcher and trying to fix the issue with Mutagen.

---

## Table of Content

<!-- TOC -->

* [Environment](#environment)
* [Run](#run)
* [Test](#test)
* [Troubleshoot](#troubleshoot)

<!-- TOC -->

---

## Environment

Tested with the following setup:

- Windows 11
    - WSL 2
- Mutagen
- JetBrains PhpStorm
- Docker
    - Docker Desktop (necessary under Windows)
    - Container (FrankenPHP 1.11.1; PHP 8.4; Debian 13; Symfony 6.4)

---

## Run

1. Build the environment with Docker, only with `compose.yaml`
2. Run "Synchronisation code" after its containers are running
3. Wait until `docker-entrypoint.sh` has finished its work

---

## Test

- Try to edit `public/index.php` from the host and see if FrankenPHP saw the changes from there.
- Try to edit `public/index.php` from the container and see if FrankenPHP saw the changes from there.

Currently, only the second point is working with this log appearing in the container's logs:

```log
2026/01/06 21:50:49.993	INFO	frankenphp	filesystem changes detected	{"events": [{"effect_time":"2026-01-06T21:50:49.842465848Z","path_name":"/app/public/index.php","effect_type":"modify","path_type":"file"}]}
```

To downgrade to version 0.13.6, uncomment the following lines of codes in `docker-entrypoint.sh` then rebuild the Docker image:

```bash
libwatcher_ver=$(readlink -f /usr/local/lib/libwatcher-c.so.0 | grep -oP 'libwatcher-c\.so\.0\.\K[0-9.]+')
if [ "$libwatcher_ver" != "13.6" ]; then
    echo "🔍 The current version of libwatcher is 0.$libwatcher_ver. Downgrading to working version (0.13.6)..."
    echo "This is a temporary fix for the watcher. It is meant to disapear once watcher works properly with Mutagen."
    cd /usr/local/lib
    rm libwatcher-c.so.0
    ln -s libwatcher-c.so.0.13.6 libwatcher-c.so.0
    echo "✅ libwatcher is now in version 0.13.6 !"
    cd /app
else
    echo "✅ libwatcher is already in version 0.13.6."
fi
```

To switch versions of libwatcher manually, run the following commands in the container:

```bash
cd /usr/local/lib
rm libwatcher-c.so.0
ln -s libwatcher-c.so.<version> libwatcher-c.so.0
```

---

## Troubleshoot

Use this command to monitor Mutagen and see if it is working properly:

- macOS, Linux (Shell/Bash) :

```bash
mutagen sync monitor
```

- Windows (Powershell) :

```powershell
.\mutagen.exe sync monitor
```

If not, remove `mutagen.yml.lock` first, then run this command to get its identifier (an ID starting with `sync_` and
its name is `frankenphp-sync`):

- macOS, Linux (Shell/Bash) :

```bash
mutagen sync list
```

- Windows (Powershell) :

```powershell
.\mutagen.exe sync list
```

Then run this command to remove its sync file:

- macOS, Linux (Shell/Bash) :

```bash
mutagen sync terminate <sync_id>
```

- Windows (Powershell) :

```powershell
.\mutagen.exe sync terminate <sync_id>
```

Finally, re-run "Synchronisation code".
