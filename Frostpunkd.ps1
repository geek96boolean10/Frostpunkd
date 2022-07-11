# Quietly maintains a backlog of Frostpunk autosaves.
param(
    $SaveLocation = "",
    [int]$NumberToKeep = 5,
    $SessionName = "auto",
    [int]$Period = 30,
    [switch]$Verbose
)

# SaveLocation = Directory were autosaves are kept. If not provided, will attempt to search for it.
# NumberToKeep = Number of files matching 'SessionName' that should be kept
if ($NumberToKeep -le 1) { throw "Invalid NumberToKeep. Provide an integer greater than 1." }
# SessionName = Allows for grouping of autosaves; can be any nonempty string not containing '.'".
if ($SessionName -eq "") { Write-Output "Empty string for SessionName. Using 'unnamed' instead."; $SessionName = "unnamed" }
# Period = Number of seconds between checks for new autosaves
if ($Period -lt 0) { throw "Invalid period. Provide a positive integer in seconds." }
# Verbose = Will print additional info during runtime.

$SearchDirectory = ""
if ($SaveLocation -eq "")
{
    # None given, try and find.
    $Default = "C:\Program Files (x86)\Steam\userdata"
    if (-not (Test-Path $Default)) { throw "Steam was not found at the default location. Provide a SaveLocation." }
    if ((Get-ChildItem $Default -Directory).Count -gt 1) { throw "Multiple users detected. Provide a SaveLocation." }
    $User = (GCI $Default -Directory)[0].FullName
    $SearchDirectory = "$User\323190\remote\saves"
    if (-not (Test-Path $SearchDirectory)) { Write-Warning "Expected default save directory not found, continuing.." }
    if (((GCI $SearchDirectory -File) -match 'autosave.save').Count -lt 1) { Write-Warning "No autosave found at this location, continuing.." }
}
else
{
    if (-not (Test-Path $SaveLocation)) { throw "SaveLocation is invalid. Provide a valid, fully-qualified directory path containing autosaves." }
    $SearchDirectory = $SaveLocation
}
Write-Output "Using path '$SearchDirectory' as session directory."

# Take a look for existing autosaves
$Existing = (GCI $SearchDirectory -File -Filter "*.save") |? {$_.Name.Split(".")[0] -eq "$SessionName"}
Write-Output "Found $($Existing.Count) existing saves for session '$SessionName'"

function DeleteOldest {
    param(
        $Current
    )
    # Searches for all matching the session name, and deletes the one that is considered oldest by filename
    $Sorted = $Current | Sort-Object -Property { [int]($_.Name.Split(".")[1]) }
    $Oldest = $Sorted[0]
    if ($Verbose) { Write-Host "Deleting stale $($Oldest.Name)." }
    Remove-Item $Oldest.FullName
}

function ReturnNewest {
    param(
        $Current
    )
    # Searches for all matching the session name, and picks the one that is considered newest by filename
    $Sorted = $Current | Sort-Object -Property { [int]($_.Name.Split(".")[1]) } -Descending
    $Newest = $Sorted[0]
    return $Newest
}

Write-Output "Backlog starting. Exit with Ctrl+C."

while ($true)
{
    $Current = (GCI $SearchDirectory -File -Filter "*.save") |? {$_.Name.Split(".")[0] -eq "$SessionName"}
    # Clear excess saves
    while ($Current.Count -ge $NumberToKeep)
    {
        DeleteOldest -Current $Current
        $Current = (GCI $SearchDirectory -File -Filter "*.save") |? {$_.Name.Split(".")[0] -eq "$SessionName"}
    }
    $Newest = ReturnNewest -Current $Current
    # Backup if new
    if ($Newest.FullName -ne $null)
    {
        $NewestHash = (Get-FileHash -Path $Newest.FullName -Algorithm SHA1).Hash
        if ($Verbose) { Write-Output "LastHash: $NewestHash" }
    }
    $AutoHash = (Get-FileHash -Path "$SearchDirectory\autosave.save" -Algorithm SHA1).Hash
    if ($Verbose) { Write-Output "AutoHash: $AutoHash" }
    if ($Newest.FullName -ne $null -and $NewestHash -eq $AutoHash) 
    {
        if ($Verbose) { Write-Output "Save was not updated in last $Period seconds, skipping." }
    }
    else
    {
        [int]$Seconds = [int][System.Double]::Parse((Get-Date -UFormat "%s"))
        $NewFileName = "$SessionName.$Seconds.save"
        Write-Output "Backing up to $NewFileName"
        Copy-Item -Path "$SearchDirectory\autosave.save" -Destination "$SearchDirectory\$NewFileName"
    }
    # Wait
    Sleep -Seconds $Period
}