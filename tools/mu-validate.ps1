<#
.SYNOPSIS
  Reference MUIF validator. Runs the machine-checkable Abstract Test Procedures
  (V0-V2) from 02-architecture/Validation.md and emits a Validation Report.

.DESCRIPTION
  Implements the checks a structural validator can perform without runtime data:
    V0-01 parse, V0-02 muif.version
    V1-02 required primitive fields (muifType + required fields)
    V2-01 id uniqueness, V2-03 CSN pattern + namespace declared,
    V2-05 self-declared fingerprint matches the computed Semantic Fingerprint
  V1-01 (full JSON-Schema), and V3/V4 (constitutional/federation) are reported as
  "skipped" here; a full validator (roadmap WS6/CI) runs JSON Schema + those.

  Exit code 0 when no Error-severity check fails, else 1.

.PARAMETER Path
  Path to a MUIF manifest document.

.EXAMPLE
  pwsh tools/mu-validate.ps1 examples/minimal-person/person.muif.json
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Path
)

$csnPattern = '^[a-z][a-zA-Z0-9]*(\.[a-z][a-zA-Z0-9]*)*$'
$levels = [ordered]@{}
function Add-Check($level, $checkId, $status, $severity, $enforces, $message) {
  if (-not $levels.Contains($level)) { $levels[$level] = New-Object System.Collections.Generic.List[object] }
  $levels[$level].Add([pscustomobject]@{ checkId = $checkId; status = $status; severity = $severity; enforces = $enforces; message = $message })
}

$errors = 0; $warnings = 0

# ---- V0-01 parse ----
$doc = $null
try { $doc = Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json }
catch {
  Add-Check 'V0' 'V0-01' 'fail' 'error' @('MUIF-R02','MUIF-R03') ("Parse error: " + $_.Exception.Message)
  $report = [pscustomobject]@{ reportId = "urn:mu:validation:adhoc"; target = @{ id = $Path }; validator = @{ id = 'urn:mu:validator:mu-validate'; version = 'ws13' }; validatedAt = '1970-01-01T00:00:00Z'; highestLevelAchieved = 'none'; levels = @(@{ level = 'V0'; status = 'fail'; checks = $levels['V0'] }); summary = @{ errors = 1; warnings = 0; info = 0 } }
  $report | ConvertTo-Json -Depth 12
  exit 1
}
Add-Check 'V0' 'V0-01' 'pass' 'error' @('MUIF-R02','MUIF-R03') $null

# ---- V0-02 muif.version ----
if ($doc.muif -and $doc.muif.version -eq '1.0') { Add-Check 'V0' 'V0-02' 'pass' 'error' @('MUIF-R01') $null }
else { Add-Check 'V0' 'V0-02' 'fail' 'error' @('MUIF-R01') "muif.version must be '1.0'"; $errors++ }

# ---- gather primitives ----
$required = @{
  Object       = @('muifType','id','csn','kind','provenance')
  Relationship = @('muifType','id','kind','source','target')
  Event        = @('muifType','id','type','subject','occurrenceTime','provenance')
  Contract     = @('muifType','id','kind','purpose','parties')
  Projection   = @('muifType','id','subject','context','purpose')
}
$prims = @()
foreach ($coll in @('objects','relationships','events','contracts','projections')) {
  if ($doc.$coll) { $prims += $doc.$coll }
}

# ---- V1-02 required fields ----
$v1ok = $true
foreach ($p in $prims) {
  $t = $p.muifType
  if (-not $t -or -not $required.ContainsKey($t)) { $v1ok = $false; continue }
  foreach ($f in $required[$t]) {
    if (-not $p.PSObject.Properties.Name.Contains($f)) { $v1ok = $false; Add-Check 'V1' 'V1-02' 'fail' 'error' @('MUIF-R01') ("$t missing required field '$f'"); $errors++ }
  }
}
Add-Check 'V1' 'V1-01' 'skipped' 'error' @('MUIF-R01') 'Full JSON Schema validation runs in CI (ajv).'
if ($v1ok) { Add-Check 'V1' 'V1-02' 'pass' 'error' @('MUIF-R01') $null }

# ---- V2-01 id uniqueness ----
$ids = @{}; $dup = $false
foreach ($p in $prims) { if ($p.id) { if ($ids.ContainsKey($p.id)) { $dup = $true; Add-Check 'V2' 'V2-01' 'fail' 'error' @('MUC-R03') ("duplicate id: " + $p.id); $errors++ } else { $ids[$p.id] = $true } } }
if (-not $dup) { Add-Check 'V2' 'V2-01' 'pass' 'error' @('MUC-R03') $null }

# ---- V2-03 CSN pattern + namespace declared ----
$declaredNs = @(); if ($doc.namespaces) { $declaredNs = $doc.namespaces }
$csnOk = $true
$csnVals = New-Object System.Collections.Generic.List[string]
foreach ($o in @($doc.objects)) { if ($o.csn) { $csnVals.Add($o.csn) }; foreach ($pr in @($o.properties)) { if ($pr.name) { $csnVals.Add($pr.name) } } }
foreach ($c in $csnVals) {
  if ($c -notmatch $csnPattern) { $csnOk = $false; Add-Check 'V2' 'V2-03' 'fail' 'error' @('NAME') ("invalid CSN: " + $c); $errors++ }
  else { $ns = ($c -split '\.')[0]; if ($declaredNs.Count -gt 0 -and $declaredNs -notcontains $ns) { Add-Check 'V2' 'V2-03' 'warning' 'warning' @('NAME') ("namespace not declared: " + $ns); $warnings++ } }
}
if ($csnOk) { Add-Check 'V2' 'V2-03' 'pass' 'error' @('NAME') $null }

# ---- V2-05 fingerprint match (if self-declared) ----
$declaredFp = $null
if ($doc.metaModel -and $doc.metaModel.PSObject.Properties.Name.Contains('fingerprint')) { $declaredFp = $doc.metaModel.fingerprint }
if ($declaredFp) {
  $computed = (& (Join-Path $PSScriptRoot 'mu-fingerprint.ps1') $Path).Trim()
  if ($computed -eq $declaredFp) { Add-Check 'V2' 'V2-05' 'pass' 'error' @('MUIF-R12','MUIF-R18') "fingerprint matches" }
  else { Add-Check 'V2' 'V2-05' 'fail' 'error' @('MUIF-R12','MUIF-R18') ("declared $declaredFp != computed $computed"); $errors++ }
} else {
  Add-Check 'V2' 'V2-05' 'skipped' 'error' @('MUIF-R12') 'no self-declared fingerprint'
}

# ---- assemble report ----
$order = @('V0','V1','V2')
$highest = 'none'
$levelArr = @()
foreach ($lv in $order) {
  if (-not $levels.Contains($lv)) { continue }
  $checks = $levels[$lv]
  $hasErr = @($checks | Where-Object { $_.severity -eq 'error' -and $_.status -eq 'fail' }).Count -gt 0
  $st = if ($hasErr) { 'fail' } else { 'pass' }
  if (-not $hasErr) { $highest = $lv }
  $levelArr += [pscustomobject]@{ level = $lv; status = $st; checks = $checks }
  if ($hasErr) { break }
}
# V3/V4 skipped (out of scope for a structural validator)
foreach ($lv in @('V3','V4')) { $levelArr += [pscustomobject]@{ level = $lv; status = 'skipped'; checks = @() } }

$target = [ordered]@{ id = if ($doc.metaModel) { $doc.metaModel.id } else { $Path } }
if ($doc.metaModel.version) { $target.version = $doc.metaModel.version }
if ($declaredFp) { $target.fingerprint = $declaredFp }

$report = [pscustomobject]@{
  reportId = "urn:mu:validation:adhoc"
  target = [pscustomobject]$target
  validator = [pscustomobject]@{ id = 'urn:mu:validator:mu-validate'; version = 'ws13' }
  validatedAt = '1970-01-01T00:00:00Z'
  highestLevelAchieved = $highest
  levels = $levelArr
  summary = [pscustomobject]@{ errors = $errors; warnings = $warnings; info = 0 }
}
$report | ConvertTo-Json -Depth 12
if ($errors -gt 0) { exit 1 } else { exit 0 }
