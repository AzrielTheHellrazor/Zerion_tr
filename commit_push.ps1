# Auto-incrementing "commit N" script for Windows PowerShell
# Usage:
#   - Double-click commit_push.cmd (recommended), or
#   - Run in PowerShell: ./commit_push.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    # Always operate from the directory this script resides in
    Set-Location -LiteralPath $PSScriptRoot

    # Ensure git is available
    $null = git --version 2>$null
} catch {
    Write-Host "git bulunamadı. Lütfen Git'i kurun ve PATH'e ekleyin." -ForegroundColor Red
    exit 1
}

# Ensure we are inside a git repo
$isRepo = (git rev-parse --is-inside-work-tree 2>$null) -eq 'true'
if (-not $isRepo) {
    Write-Host "Bu klasör bir git deposu değil." -ForegroundColor Red
    exit 1
}

# Check for changes
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "Commitlenecek değişiklik yok." -ForegroundColor Yellow
    exit 0
}

function Get-NextCommitNumber {
    # Look back through recent commit subjects and find the max N for pattern "commit N"
    $subjects = git log --pretty=%s -n 100 2>$null
    $max = 0
    foreach ($s in $subjects) {
        if ($s -match '^commit\s+(\d+)$') {
            $n = [int]$Matches[1]
            if ($n -gt $max) { $max = $n }
        }
    }
    return ($max + 1)
}

$next = Get-NextCommitNumber

Write-Host "commit $next hazırlanıyor..." -ForegroundColor Cyan

# Stage all and commit
git add -A

# If commit fails (e.g., hooks), surface the error
git commit -m "commit $next"

# Push current branch
$currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()
Write-Host "Push ediliyor: $currentBranch" -ForegroundColor Cyan
git push -u origin $currentBranch

Write-Host "Bitti: commit $next pushlandı." -ForegroundColor Green
exit 0

