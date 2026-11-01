$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 3107
$prefix = "http://127.0.0.1:$port/"
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($prefix)

function Get-ContentType([string]$path) {
    switch ([System.IO.Path]::GetExtension($path).ToLowerInvariant()) {
        ".html" { "text/html; charset=utf-8"; break }
        ".js" { "text/javascript; charset=utf-8"; break }
        ".css" { "text/css; charset=utf-8"; break }
        ".png" { "image/png"; break }
        ".jpg" { "image/jpeg"; break }
        ".jpeg" { "image/jpeg"; break }
        ".svg" { "image/svg+xml"; break }
        default { "application/octet-stream" }
    }
}

try {
    $listener.Start()
} catch {
    Write-Host "No pude abrir el puerto $port. Cierra otro panel abierto o cambia de red." -ForegroundColor Red
    throw
}

Write-Host "Panel de Keys abierto en $prefix#keys" -ForegroundColor Green
Start-Process "$prefix#keys"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        try {
            $relative = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart("/"))
            if ([string]::IsNullOrWhiteSpace($relative)) { $relative = "index.html" }
            $candidate = Join-Path $root $relative
            $fullPath = [System.IO.Path]::GetFullPath($candidate)
            $rootPath = [System.IO.Path]::GetFullPath($root)

            if (-not $fullPath.StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
                $context.Response.StatusCode = 404
                $body = [System.Text.Encoding]::UTF8.GetBytes("No encontrado")
                $context.Response.OutputStream.Write($body, 0, $body.Length)
            } else {
                $bytes = [System.IO.File]::ReadAllBytes($fullPath)
                $context.Response.ContentType = Get-ContentType $fullPath
                $context.Response.Headers["Cache-Control"] = "no-store"
                $context.Response.ContentLength64 = $bytes.Length
                $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
        } catch {
            $context.Response.StatusCode = 500
            $body = [System.Text.Encoding]::UTF8.GetBytes($_.Exception.Message)
            $context.Response.OutputStream.Write($body, 0, $body.Length)
        } finally {
            $context.Response.OutputStream.Close()
        }
    }
} finally {
    $listener.Stop()
}
