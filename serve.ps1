$port = 8080
$path = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Localhost server ishga tushirildi! => http://localhost:$port/"
Write-Host "To'xtatish uchun: Ctrl+C bosing."

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrEmpty($localPath)) {
            $localPath = "index.html"
        }
        
        $filePath = Join-Path $path $localPath
        
        if (Test-Path $filePath -PathType Leaf) {
             # Read file
             $content = [System.IO.File]::ReadAllBytes($filePath)
             
             # Set mime type
             if ($filePath.EndsWith(".css")) {
                $response.ContentType = "text/css"
             } elseif ($filePath.EndsWith(".js")) {
                $response.ContentType = "application/javascript"
             } elseif ($filePath.EndsWith(".png")) {
                $response.ContentType = "image/png"
             } else {
                $response.ContentType = "text/html; charset=utf-8"
             }
             
             $response.StatusCode = 200
             $response.ContentLength64 = $content.Length
             $response.OutputStream.Write($content, 0, $content.Length)
        } else {
             $response.StatusCode = 404
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
