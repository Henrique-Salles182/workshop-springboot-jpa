param(
    [string]$MarkdownPath = "docs/conversation-transcript.md",
    [string]$DocxPath = "docs/conversation-transcript.docx"
)

function Write-Info($msg) { Write-Host $msg -ForegroundColor Cyan }
function Write-ErrorAndExit($msg) { Write-Host $msg -ForegroundColor Red; exit 1 }

Write-Info "Checking for pandoc in PATH..."
$pandoc = (Get-Command pandoc -ErrorAction SilentlyContinue)
if (-not $pandoc) {
    Write-Host "pandoc não foi encontrado no PATH. Para instalar no Windows, visite: https://pandoc.org/installing.html" -ForegroundColor Yellow
    Write-Host "Ou instale via Chocolatey: choco install pandoc" -ForegroundColor Yellow
    Write-Host "Depois de instalar, rode este script novamente: .\tools\convert-md-to-docx.ps1" -ForegroundColor Yellow
    exit 0
}

if (-not (Test-Path $MarkdownPath)) {
    Write-ErrorAndExit "Arquivo markdown não encontrado: $MarkdownPath"
}

Write-Info "Converting $MarkdownPath -> $DocxPath using pandoc..."
$cmd = "pandoc -s -o `"$DocxPath`" `"$MarkdownPath`""
Write-Info "Running: $cmd"
& pandoc -s -o $DocxPath $MarkdownPath
if ($LASTEXITCODE -ne 0) {
    Write-ErrorAndExit "pandoc retornou código $LASTEXITCODE"
}

Write-Host "Conversão concluída: $DocxPath" -ForegroundColor Green
