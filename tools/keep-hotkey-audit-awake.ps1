param(
    [Parameter(Mandatory=$true)][string]$ManifestPath,
    [Parameter(Mandatory=$true)][string]$StatusPath,
    [int]$MaximumHours = 4,
    [int]$StartGraceMinutes = 15
)
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class HotkeyAuditPower {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint flags);
}
'@
$auditDeadline = [DateTime]::UtcNow.AddHours($MaximumHours)
$auditWaitDeadline = [DateTime]::UtcNow.AddMinutes($StartGraceMinutes)
$auditRunSeen = $false
try {
    # ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED
    if ([HotkeyAuditPower]::SetThreadExecutionState([uint32]2147483651) -eq 0) {
        throw 'Windows rejected the temporary keep-awake request.'
    }
    "awake; pid=$PID; expires=$($auditDeadline.ToString('o'))" | Set-Content -LiteralPath $StatusPath
    while ([DateTime]::UtcNow -lt $auditDeadline) {
        if (Test-Path -LiteralPath $ManifestPath) {
            try {
                $auditReportText = Get-Content -LiteralPath $ManifestPath -Raw
                if ($auditReportText -match '\|state\|testing') { $auditRunSeen = $true }
                if ($auditRunSeen -and $auditReportText -match '\|state\|(complete|control-inconclusive)') { break }
                if ($auditRunSeen -and $auditReportText -match '\|state\|ended') {
                    # Allow a map/build restart without losing the power request.
                    $auditRunSeen = $false
                    $auditWaitDeadline = [DateTime]::UtcNow.AddMinutes($StartGraceMinutes)
                }
            } catch {
                # The game can briefly replace the report while writing it.
            }
        }
        if (-not $auditRunSeen -and [DateTime]::UtcNow -ge $auditWaitDeadline) { break }
        Start-Sleep -Seconds 15
    }
} catch {
    "error: $($_.Exception.Message)" | Set-Content -LiteralPath $StatusPath
    throw
} finally {
    # Release only this process's temporary request, not global power settings.
    [void][HotkeyAuditPower]::SetThreadExecutionState([uint32]2147483648)
    'released' | Add-Content -LiteralPath $StatusPath
}
