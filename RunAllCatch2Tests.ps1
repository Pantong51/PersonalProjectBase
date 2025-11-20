<#
  RunAllCatch2Tests.ps1
  ---------------------
  Looks in  <root>\Artifacts\  for every *-Tests.exe, runs them in
  parallel, excludes Catch2 benchmarks (~[benchmark]~[Benchmark]), and
  MIRRORS their live output to the host.  Exits 0 only if all pass.
#>

param(
    [string]$Root = $PSScriptRoot
)

$filter      = '~[benchmark]~[Benchmark]'
$artifactDir = Join-Path $Root 'Artifacts'
$exePattern  = '*-Tests.exe'

if (-not (Test-Path -LiteralPath $artifactDir)) {
    Write-Host "Artifacts folder not found: $artifactDir"
    exit 1
}

$tests = Get-ChildItem -Path $artifactDir -Filter $exePattern -File -Recurse |
         Sort-Object FullName

if (-not $tests) {
    Write-Host "No $exePattern found under '$artifactDir'"
    exit 1
}

Write-Host "=== Running $($tests.Count) test suites (skip $filter) ==="

$jobs   = @()
$codes  = @()

foreach ($t in $tests) {
    Write-Host "  queued  $($t.FullName)"
    $jobs += Start-Job -Name $t.Name -ArgumentList $t.FullName,$filter -ScriptBlock {
        param($exe, $flt)
        & $exe $flt
        exit $LASTEXITCODE
    }
}

# --- live streaming loop ----------------------------------------------------
$results = @{}     # map exe name -> exit code

while ($jobs) {
    $ready = Wait-Job -Job $jobs -Any -Timeout 1
    if (-not $ready) { continue }

    foreach ($j in $ready) {
        Receive-Job -Job $j -Keep

        if ($j.State -match '^(Completed|Failed|Stopped)$') {

            $code = $j.ChildJobs[0].JobStateInfo.ExitCode
            if ($null -eq $code) { $code = 0 }      # ← fix

            $results[$j.Name] = $code
            if ($code -eq 0) {
                Write-Host ("---- {0,-30}  PASSED ----" -f $j.Name) -ForegroundColor Green
            } else {
                Write-Host ("---- {0,-30}  FAILED (exit {1}) ----" -f $j.Name, $code) -ForegroundColor Red
            }

            Remove-Job -Job $j
            $jobs = $jobs | Where-Object { $_.Id -ne $j.Id }
        }
    }
}


# ----- summary table --------------------------------------------------------
Write-Host "`n================= SUMMARY ================="
"{0,-35} {1,5}" -f "Test Suite", "Code"
"{0,-35} {1,5}" -f "----------", "----"

$allZero = $true
foreach ($kvp in $results.GetEnumerator() | Sort-Object Name) {
    "{0,-35} {1,5}" -f $kvp.Key, $kvp.Value
    if ($kvp.Value -ne 0) { $allZero = $false }
}

if ($allZero) {
    Write-Host "`n=== ALL TEST SUITES PASSED ===" -ForegroundColor Green
    exit 0
}
Write-Host "`n=== ONE OR MORE SUITES FAILED ===" -ForegroundColor Red
exit 1