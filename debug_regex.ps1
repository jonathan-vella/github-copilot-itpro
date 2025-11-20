$Id = "S01"
$FileContent = "| **S01** | Bicep Baseline | 🔴 Not Started | 🔴 | 🔴 | 🔴 | - | |"
$Pattern = "\| \*\*$Id\*\* \| (.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \| (.*?) \|"

if ($FileContent -match $Pattern) {
    Write-Host "Match found!"
    Write-Host "Name: $($matches[1])"
    Write-Host "Status: $($matches[2])"
}
else {
    Write-Host "No match."
}
