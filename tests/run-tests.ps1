<#
.SYNOPSIS
  Semantic Test Kit runner. Drives tools/mu-validate.ps1 over the fixtures and
  asserts the expected pass/fail outcome (and the expected failing check).

.DESCRIPTION
  Each fixture has a declared expectation. The kit asserts that valid fixtures
  pass (exit 0) and that each invalid fixture fails (exit 1) on the specific
  Abstract Test Procedure it is designed to break. Exit 0 iff all expectations
  are met.

.EXAMPLE
  pwsh tests/run-tests.ps1
#>
[CmdletBinding()]
param()

$root = Split-Path -Parent $PSScriptRoot
$validate = Join-Path $root 'tools/mu-validate.ps1'

# fixture (relative to tests/) -> expectation
$expect = @(
  @{ file = 'fixtures/valid/minimal.json';            pass = $true;  check = $null },
  @{ file = 'fixtures/valid/with-fingerprint.json';   pass = $true;  check = 'V2-05' },
  @{ file = 'fixtures/invalid/bad-version.json';       pass = $false; check = 'V0-02' },
  @{ file = 'fixtures/invalid/missing-provenance.json';pass = $false; check = 'V1-02' },
  @{ file = 'fixtures/invalid/duplicate-id.json';      pass = $false; check = 'V2-01' },
  @{ file = 'fixtures/invalid/bad-csn.json';           pass = $false; check = 'V2-03' },
  @{ file = 'fixtures/invalid/wrong-fingerprint.json'; pass = $false; check = 'V2-05' }
)

$failures = 0
foreach ($e in $expect) {
  $path = Join-Path $PSScriptRoot $e.file
  $out = & $validate $path
  $code = $LASTEXITCODE
  $rep = $out | ConvertFrom-Json
  $actualPass = ($code -eq 0)

  $ok = ($actualPass -eq $e.pass)
  $checkOk = $true
  if ($e.check) {
    $checks = @(); foreach ($lv in $rep.levels) { $checks += $lv.checks }
    $c = $checks | Where-Object { $_.checkId -eq $e.check } | Select-Object -First 1
    if ($e.pass) { $checkOk = ($c -and $c.status -eq 'pass') }
    else { $checkOk = ($c -and $c.status -eq 'fail') }
  }

  if ($ok -and $checkOk) {
    Write-Output ("PASS  {0,-40} (highest={1})" -f $e.file, $rep.highestLevelAchieved)
  } else {
    $failures++
    Write-Output ("FAIL  {0,-40} expected pass={1} check={2}; got pass={3} highest={4}" -f $e.file, $e.pass, $e.check, $actualPass, $rep.highestLevelAchieved)
  }
}

Write-Output ""
if ($failures -eq 0) { Write-Output ("ALL {0} TESTS PASSED" -f $expect.Count); exit 0 }
else { Write-Output ("{0} TEST(S) FAILED" -f $failures); exit 1 }
