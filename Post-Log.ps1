Param(
    [Parameter(Mandatory = $false)][String]$file = "C:\temp\DevOps_data_set.txt",
    [Parameter(Mandatory = $false)][String[]]$server = @("BBAOMACBOOKAIR2"),
    [Parameter(Mandatory = $false)][String[]]$months = @("May"),
    [Parameter(Mandatory = $false)][String]$uri = "https://foo.com/bar"
)

$table = @()

# load log data
$lines = Get-Content -Path $file 
foreach ($line in $lines) {
    $row = "" | Select-Object deviceName, processId, processName, description, timeWindow
    $month = $line.substring(0, 3)
    if($months -contains $month) {
        $row.timeWindow = "00" + $line.substring(7, 2) + "-" `
            + ("0000" + [string]([int]$line.substring(7, 2) + 1)).substring(("0000" + [string]([int]$line.substring(7, 2) + 1)).Length-4, 4)
        $deviceName = $line.substring(16, 15)
        if($server -contains $deviceName) {
            $row.deviceName = $deviceName
            $row.processId = $line.substring($line.IndexOf("[") + 1, $line.IndexOf("]")-$line.IndexOf("[")-1)
            $row.processName = $line.substring(32, $line.IndexOf("[")-32)
            $row.description = $line.substring($line.IndexOf("]")+2, $line.length-$line.IndexOf("]")-2).trim()
            #$row.description = [regex]::Replace($line.substring($line.IndexOf("]")+2, $line.length-$line.IndexOf("]")-2).trim(),":\d{3}", ":xxx")
        }
        else {
            $row.deviceName = ""
            $row.description = $line.substring(16, $line.length-16).trim()
            #$line | Out-File -FilePath "C:\temp\exception.txt" -Append
        } 
        $table += $row  
    }
    else {
        $table[-1].description += $line
    }
}

# aggregate log data
$json = $table | Group-Object deviceName, processId, processName, description, timeWindow `
    | Select-Object @{Name="deviceName"; Expression={$_.Values[0]}}, `
        @{Name="processId"; Expression={$_.Values[1]}}, `
        @{Name="processName"; Expression={$_.Values[2]}}, `
        @{Name="description"; Expression={$_.Values[3]}}, `
        @{Name="timeWindow"; Expression={$_.Values[4]}}, `
        @{Name="numberOfOccurrence"; Expression={$_.Count}} `
    | ConvertTo-Json

# post log data
Invoke-WebRequest -Uri $uri -Method POST -Body $json



