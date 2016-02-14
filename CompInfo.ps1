# ALL acquired values should be of type string

# Time the program to help debug
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

# To prompt user
$arrayYes = "yes", "y", "ok"
$arrayNo = "no", "n"
$valid = 0

# Prompting user to determine which machine to inventory
DO
{
    $thisCompYN = read-host -prompt "Would you like to inventory this machine?"
    If ($arrayYes.Contains($thisCompYN))
    {
        $compName = $env:computername
        $valid = 1
    }
    ElseIf ($arrayNo.Contains($thisCompYN))
    {
        $compName = read-host -prompt "Please enter machine name"
        $valid = 1
    }
    Else
    {
        Write-Output ("Please enter 'yes' or 'no'")
        $valid = 0
    }
} While ($valid -eq 0)

# Processing...
Write-Output ("")
Write-Output ("Processing...")
Write-Output ("")

# Perform queries and convert results to strings
Try
{
    $ErrorActionPreference = "Stop"

    $cpuName = get-wmiobject -ComputerName $CompName -class win32_processor | select-object -expand name
    $cpuName = $cpuName -replace '\s+', ' '

    $macAddress = get-wmiobject -ComputerName $CompName -class win32_networkadapterconfiguration | select-object -expand macaddress
    $macArray = $macAddress -split " " | select -unique

    $ipAddress = get-wmiobject -ComputerName $CompName -class win32_networkadapterconfiguration | select-object -expand ipaddress
    $ipAddress = $ipAddress[0]

    $modelName = get-wmiobject -ComputerName $CompName -class win32_computersystem | select-object -expand model 

    $osVersion = get-wmiobject -ComputerName $CompName -class win32_operatingsystem | select-object -expand version

    $ramCapacity = get-wmiobject -ComputerName $CompName -class win32_computersystem | select-object -expand totalphysicalmemory 
    $ramCapacity = [math]::floor($ramCapacity / 1000000000)
    $ramCapacity = [string]$ramCapacity + "GB"

    $serialNumber = get-wmiobject -ComputerName $CompName -class win32_bios | select-object -expand serialnumber 
    $serialNumber = [string]$serialNumber

    $osInstallDate = ([WMI]'').ConvertToDateTime((Get-wmiobject -ComputerName $CompName win32_operatingsystem).InstallDate)
    $osInstallDate = [string]$osInstallDate

    $userName = get-wmiobject -ComputerName $CompName -class win32_computersystem | select-object -expand username
    $userName = $userName.Split("\")[1]

    $diskDrive = get-wmiobject -ComputerName $CompName -class win32_diskdrive | select-object -expand model
    $diskDrive = $diskDrive#[0]
}

# One or more queries failed, inform user
Catch [system.exception]
{
    Write-Output ("There was a problem fetching the data. Please make sure the following is true:
    1) You are querying a windows machine
    2) The machine is currently on and a user is logged in
    3) The machine is connected to the RPC server")

    Write-Output ("")

    If ($elapsed.Elapsed.Seconds -gt 30)
    {
        Write-Output ("Because this process was relatively slow and failed, it's likely that the machine was not found or is turned off.")
    }
    Else
    {
        Write-Output ("Because this process was relatively fast and failed, it's likely that the machine is not a windows machine or is not connected to the RPC server.")
    }

}

# Print machine information
Write-Output ("Machine Name: " + $compName)
Write-Output ("CPU: " + $cpuName)

# Print all mac addresses if multiple found
If ($macArray.length -gt 0)
{
    for ($i = 1; $i -le $macArray.length; $i++)
    {
        Write-Output ("MAC" + $i + ": " + $macArray[$i - 1])
    }
}
Else
{
    Write-Output ("MAC" + "1" + ": " + $macArray[0])
}
Write-Output ("IPAddress1: " + $ipAddress)
Write-Output ("Model: " + $modelName)
Write-Output ("OS: " + $osVersion)
Write-Output ("RAM: " + $ramCapacity)
Write-Output ("ServiceTag: " + $serialNumber)
Write-Output ("OSInstallDate: " + $osInstallDate)
Write-Output ("LastLoginBy: " + $userName)
Write-Output ("DiskDrive: " + $diskDrive)