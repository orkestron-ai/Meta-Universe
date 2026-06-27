<#
.SYNOPSIS
  Reference implementation of the Meta-Universe Semantic Fingerprint.

.DESCRIPTION
  Computes the Semantic Fingerprint of a MUIF (Meta-Universe Interchange Format)
  document, as defined in 02-architecture/MMAS-Interchange.md.

  The fingerprint is serialization-independent: two documents that differ only in
  key order, insignificant whitespace, non-semantic fields (displayName,
  description, assertedAt, the fingerprint field itself, x-ui*/_ keys) or in the
  ordering of set-valued arrays MUST produce an identical fingerprint.

  Algorithm:
    1. Parse the document (JSON).
    2. Project to the semantic core (drop non-semantic keys; drop null/empty).
    3. Normalize: NFC strings; sort object keys (ordinal); sort arrays as sets.
    4. Emit canonical JSON (UTF-8, minimal whitespace, sorted keys).
    5. fingerprint = "sha256:" + lowercase-hex( sha256( canonical-bytes ) ).

  NOTE: This is the WS1 reference implementation. Number canonicalization is a
  pragmatic subset of RFC 8785 (JCS); the core model uses strings/integers.

.PARAMETER Path
  Path to a MUIF JSON document.

.PARAMETER ShowCanonical
  Also print the canonical JSON to stderr (for debugging).

.EXAMPLE
  pwsh tools/mu-fingerprint.ps1 examples/minimal-person/person.muif.json
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Path,
  [switch]$ShowCanonical
)

$NonSemantic = @(
  'displayName', 'description', 'documentation', 'comment',
  'label', 'labels', 'ui', 'assertedAt', 'assertionTime',
  'generatedAt', 'lastModified', 'fingerprint', 'examples',
  '$schema', '$comment'
)

function Test-NonSemantic([string]$name) {
  if ($NonSemantic -contains $name) { return $true }
  if ($name.StartsWith('x-ui')) { return $true }
  if ($name.StartsWith('_')) { return $true }
  return $false
}

function ConvertTo-JsonString([string]$s) {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('"')
  foreach ($ch in $s.ToCharArray()) {
    $c = [int][char]$ch
    if ($ch -eq '"') { [void]$sb.Append('\"') }
    elseif ($ch -eq '\') { [void]$sb.Append('\\') }
    elseif ($c -eq 8) { [void]$sb.Append('\b') }
    elseif ($c -eq 12) { [void]$sb.Append('\f') }
    elseif ($c -eq 10) { [void]$sb.Append('\n') }
    elseif ($c -eq 13) { [void]$sb.Append('\r') }
    elseif ($c -eq 9) { [void]$sb.Append('\t') }
    elseif ($c -lt 32) { [void]$sb.Append(('\u{0:x4}' -f $c)) }
    else { [void]$sb.Append($ch) }
  }
  [void]$sb.Append('"')
  return $sb.ToString()
}

function Get-Canonical($v) {
  if ($null -eq $v) { return $null }

  if ($v -is [string]) {
    return (ConvertTo-JsonString ($v.Normalize([Text.NormalizationForm]::FormC)))
  }
  if ($v -is [bool]) {
    if ($v) { return 'true' } else { return 'false' }
  }
  if ($v -is [int] -or $v -is [long] -or $v -is [int16] -or $v -is [int64] -or $v -is [uint32] -or $v -is [uint64]) {
    return ([int64]$v).ToString([Globalization.CultureInfo]::InvariantCulture)
  }
  if ($v -is [double] -or $v -is [single] -or $v -is [decimal]) {
    return ([double]$v).ToString('R', [Globalization.CultureInfo]::InvariantCulture)
  }

  # Array -> canonicalize elements, drop empties, sort as a set
  if ($v -is [System.Collections.IEnumerable] -and -not ($v -is [string])) {
    $items = New-Object System.Collections.Generic.List[string]
    foreach ($e in $v) {
      $ce = Get-Canonical $e
      if ($null -eq $ce) { continue }
      if ($ce -eq '{}' -or $ce -eq '[]') { continue }
      $items.Add($ce)
    }
    if ($items.Count -eq 0) { return '[]' }
    $arr = $items.ToArray()
    [Array]::Sort($arr, [System.StringComparer]::Ordinal)
    return '[' + ($arr -join ',') + ']'
  }

  # Object (PSCustomObject) -> drop non-semantic/null/empty, sort keys ordinal
  $map = @{}
  $names = New-Object System.Collections.Generic.List[string]
  foreach ($p in $v.PSObject.Properties) {
    $n = $p.Name
    if (Test-NonSemantic $n) { continue }
    $cv = Get-Canonical $p.Value
    if ($null -eq $cv) { continue }
    if ($cv -eq '{}' -or $cv -eq '[]') { continue }
    $map[$n] = $cv
    $names.Add($n)
  }
  if ($names.Count -eq 0) { return '{}' }
  $na = $names.ToArray()
  [Array]::Sort($na, [System.StringComparer]::Ordinal)
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('{')
  $first = $true
  foreach ($n in $na) {
    if (-not $first) { [void]$sb.Append(',') }
    $first = $false
    [void]$sb.Append((ConvertTo-JsonString ($n.Normalize([Text.NormalizationForm]::FormC))))
    [void]$sb.Append(':')
    [void]$sb.Append($map[$n])
  }
  [void]$sb.Append('}')
  return $sb.ToString()
}

if (-not (Test-Path -LiteralPath $Path)) {
  Write-Error "File not found: $Path"
  exit 2
}

$raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
$doc = $raw | ConvertFrom-Json
$canonical = Get-Canonical $doc

if ($ShowCanonical) { [Console]::Error.WriteLine($canonical) }

$bytes = [Text.Encoding]::UTF8.GetBytes($canonical)
$sha = [System.Security.Cryptography.SHA256]::Create()
$hash = $sha.ComputeHash($bytes)
$hex = -join ($hash | ForEach-Object { $_.ToString('x2') })
Write-Output ("sha256:" + $hex)
