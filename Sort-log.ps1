$lines = Get-Content -Path "c:\temp\log.txt"
$lines 
$table = @()
foreach ($line in $lines) {
    #Select-Object @{Name="col1"; Expression={$line.Split(" ")[0]}}, @{Name="col1"; Expression={$line.Split(" ")[1]}}
    $table += $line | select-object @{Name="col1"; Expression={$line.Split(" ")[0]}}, @{Name="col2"; Expression={$line.Split(" ")[1]}}
}
$table | Sort-Object col2 
