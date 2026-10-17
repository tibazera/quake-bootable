# Copies your Windows unezQuake install (cfgs, pk3s, maps, textures...) into
# quake-user/, which create_image.sh copies over quake-base inside the image.
# Executables, logs and other junk are skipped. quake-user/ is gitignored
# because it contains personal files (e.g. tiba.apikey).
param([string]$Source = "C:\unezquake")

$dest = Join-Path $PSScriptRoot "quake-user"
foreach ($dir in "ezquake", "qw", "id1", "fortress", "ktx") {
    if (Test-Path "$Source\$dir") {
        robocopy "$Source\$dir" "$dest\$dir" /MIR /NFL /NDL /NJH /NP `
            /XD logs temp matchinfo `
            /XF *.exe *.log .ezquake_history *.bak* | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy failed for $dir" }
    }
}
Write-Host "synced $Source -> $dest"
