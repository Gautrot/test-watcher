[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [Console]::OutputEncoding

Write-Host (Get-Location).Path

Write-Host "Waiting for Docker command to be available..."
while (-not (Get-Command docker -ErrorAction SilentlyContinue))
{
    Start-Sleep -Seconds 2
}
Write-Host "Docker is available."

Write-Host "Waiting for ‘frankenphp-test’ container to run..."
while ($true)
{
    $container = docker ps --format "{{.Names}}" | Where-Object { $_ -eq "frankenphp-test" }
    if ($container)
    {
        Write-Host "Container 'frankenphp-test' is running."
        break
    }
    Start-Sleep -Seconds 2
}

$PROJECT_NAME = "frankenphp-sync"
$PROJECT_CONFIG = "./mutagen.yml"
if (Test-Path "./mutagen.yml.lock")
{
    Write-Host ".lock file found, resuming project '$PROJECT_NAME'..."
    ./mutagen.exe project resume --project-file=$PROJECT_CONFIG
}
else
{
    Write-Host "No .lock file found, running project '$PROJECT_NAME'..."
    ./mutagen.exe project start --project-file=$PROJECT_CONFIG
}
