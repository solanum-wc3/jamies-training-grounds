# Read installed melee data without modifying the game installation.
param([string]$GamePath = 'C:/Program Files (x86)/Warcraft III', [string]$IconManifest)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Add-Type -Path (Join-Path $projectRoot 'work/CascLib-modern/lib/net7.0/CascLib.dll')
$storage = [CASCLib.CASCHandler]::OpenLocalStorage($GamePath, 'w3', $null)
try {
    if ($IconManifest) {
        $icons = Get-Content -LiteralPath $IconManifest -Raw | ConvertFrom-Json
        $results = foreach ($icon in $icons) {
            $stream = $null
            $resolved = $null
            try {
                foreach ($prefix in @('war3.w3mod\_sd.w3mod\','war3.w3mod\','war3.w3mod\_hd.w3mod\')) {
                    foreach ($variant in @($icon, [System.IO.Path]::ChangeExtension($icon, '.dds'))) {
                        try { $stream = $storage.OpenFile($prefix + $variant); if ($stream) { $resolved=$prefix+$variant; break } } catch { }
                    }
                    if ($stream) { break }
                }
                [pscustomobject]@{path=$icon; found=($null -ne $stream -and $stream.Length -gt 0); resolved=$resolved}
            } catch { [pscustomobject]@{path=$icon; found=$false} }
            finally { if ($stream) { $stream.Dispose() } }
        }
        $results | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $projectRoot 'work/hotkey-icons-verified.json') -Encoding utf8
    } else {
        $names = @('scripts/common.j', 'scripts/blizzard.j', 'units/upgradeData.slk', 'units/upgradeSkin.txt', 'units/itemSkin.txt', 'units/itemstrings.txt')
        $names += 'units/unitdata.slk', 'units/unitui.slk', 'units/UnitAbilities.slk', 'units/abilitydata.slk', 'units/itemdata.slk', 'units/unitskin.txt', 'units/abilityskin.txt', 'units/itemfunc.txt'
        foreach ($race in @('human','orc','nightelf','undead','neutral')) {
            $names += "units/${race}unitstrings.txt", "units/${race}abilitystrings.txt", "units/${race}upgradefunc.txt", "units/${race}upgradestrings.txt", "units/${race}unitfunc.txt", "units/${race}abilityfunc.txt"
        }
        $dataDirectory = Join-Path $projectRoot 'work/hotkey-native'
        $null = New-Item -ItemType Directory -Path $dataDirectory -Force
        foreach ($name in $names) {
            $stream = $null
            foreach ($prefix in @('war3.w3mod\','war3.w3mod\_locales\enus.w3mod\')) {
                try { $stream = $storage.OpenFile($prefix + $name.Replace('/','\')); if ($stream) { break } } catch { }
            }
            if ($null -eq $stream) { throw "Missing $name" }
            try {
                $output = [System.IO.File]::Create((Join-Path $dataDirectory (Split-Path $name -Leaf).ToLower()))
                try { $stream.CopyTo($output) } finally { $output.Dispose() }
            } finally { $stream.Dispose() }
        }
    }
} finally { try { $storage.Clear() } catch { } }
