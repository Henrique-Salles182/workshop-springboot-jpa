param(
    [switch]$Force
)

Write-Host "Checking for process listening on port 8080..."

$pidList = @()

# Try to use Get-NetTCPConnection (modern PowerShell). Fallback to netstat parsing if not available.
try {
    $conns = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction Stop
    $pidList = $conns | Select-Object -ExpandProperty OwningProcess -Unique
} catch {
    Write-Host "Get-NetTCPConnection not available or failed, falling back to netstat parsing..."
    $net = & netstat -aon | findstr ":8080"
    if ($net) {
        $lines = $net -split "\r?\n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        foreach ($line in $lines) {
            $parts = $line -split '\s+' | Where-Object { $_ -ne '' }
            if ($parts.Length -gt 0) {
                $pid = $parts[-1]
                if ($pid -match '^[0-9]+$') { $pidList += [int]$pid }
            }
        }
        $pidList = $pidList | Select-Object -Unique
    }
}

if (-not $pidList -or $pidList.Count -eq 0) {
    Write-Host "No process found listening on port 8080. Starting application..."
    & .\mvnw.cmd spring-boot:run
    exit $LASTEXITCODE
}

foreach ($targetPid in $pidList) {
    $proc = Get-Process -Id $targetPid -ErrorAction SilentlyContinue
    if ($null -eq $proc) {
        Write-Host "Found PID $targetPid but process not found via Get-Process. Attempting to kill PID $targetPid..."
        cmd /c "taskkill /PID $targetPid /F" | Out-Null
        continue
    }
    $name = $proc.Name
    Write-Host "Found process '$name' (PID $targetPid) listening on port 8080."
    if ($name -match 'java' -or $name -match 'tomcat') {
        Write-Host "Killing $name (PID $targetPid)..."
        cmd /c "taskkill /PID $targetPid /F" | Out-Null
    } else {
        if ($Force) {
            Write-Host "-Force specified: killing $name (PID $targetPid)..."
            cmd /c "taskkill /PID $targetPid /F" | Out-Null
        } else {
            Write-Host "Skipping kill for $name (PID $targetPid)."
            Write-Host "If you want to force-kill this process, re-run with: .\run-dev.ps1 -Force"
            Write-Host "Press Enter to continue and try to start the app (may still fail), or Ctrl+C to abort."
            Read-Host > $null
        }
    }
}

Write-Host "Starting application (mvnw spring-boot:run)..."
& .\mvnw.cmd spring-boot:run
exit $LASTEXITCODE
