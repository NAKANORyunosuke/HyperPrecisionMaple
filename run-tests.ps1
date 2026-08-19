# SPDX-FileCopyrightText: 2026 NAKANO Ryuosuke and contributors
# SPDX-License-Identifier: GPL-3.0-only
param(
    [switch]$AGM,
    [switch]$Extended,
    [switch]$Monodromy,
    [switch]$Benchmarks
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path
$CMaple = (Get-Command cmaple -ErrorAction Stop).Source

function Invoke-MapleTest([string]$Script, [string]$Marker) {
    $TestDirectory = Join-Path $ProjectRoot "test"
    Push-Location $TestDirectory
    try {
        $Output = & $CMaple -q $Script 2>&1
        $ExitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
    $Output | ForEach-Object { Write-Host $_ }
    if ($ExitCode -ne 0 -or ($Output -join "`n") -notmatch [regex]::Escape($Marker)) {
        throw "Maple test failed: $Script"
    }
}

Invoke-MapleTest "runtests.mpl" "All regular tests passed."
Invoke-MapleTest "monodromy_engine.mpl" "All Pfaffian monodromy engine tests passed."
if ($AGM) {
    Invoke-MapleTest "agm.mpl" "AGM test passed."
}
if ($Extended) {
    Invoke-MapleTest "paper_example.mpl" "Paper example passed."
}
if ($Monodromy) {
    Invoke-MapleTest "monodromy_examples.mpl" "All known monodromy examples passed."
}
if ($Benchmarks) {
    Invoke-MapleTest "benchmark_pfaffian.mpl" "Pfaffian benchmark completed."
}
