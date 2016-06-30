<###############################################################################################
 # Author: Ryan Ermert
 # Version: 1.3
 # Last Updated: 06/28/2016
 #
 # Filename: CompInfo.ps1
 #
 # Description: Gathers and outputs general computer information. Works with local 
 #              and network (RPC) computers.
 #
 # Notes: 
 #   - Only compatible with Windows Machines.
 #   - Will not work if network computers are not connected to the RPC server.
 #   - May not work if network computer is not logged into.
 #   - All acquired values should be of type string
 #
 # TODO: 
 #   - Give option to output to file?
 #   - Add parameters?
 #   - Fix multiple MAC address issue
 #     - Splitting single address (1 char at a time)
 ###############################################################################################>

# Set program optional parameters
param (
    [Parameter(Mandatory = $false)][string]$computername, 
    [Parameter(Mandatory = $false)][string]$outpath
)

# Time the program to help debug
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

# To prompt user
$arrayYes = "yes", "y", "ok"
$arrayNo = "no", "n"
$valid = 0

# Determine which machine to inventory
if (!($computername)) {
    do
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
    } while ($valid -eq 0)
}
else {
    $compName = $computername
}

# Output processing message
Write-Output ("`n" + "Processing information from $compName..." + "`n")

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

    # Exit program on failure
    Exit
}

# Gather machine information
$output = "Machine Name: " + $compName + "`n" + "CPU: " + $cpuName + "`n" + "MAC" + ": " + $macAddress 
$output += "`n" + "IPAddress1: " + $ipAddress + "`n" + "Model: " + $modelName + "`n" + "OS: " + $osVersion
$output += "`n" + "RAM: " + $ramCapacity + "`n" + "ServiceTag: " + $serialNumber
$output += "`n" + "OSInstallDate: " + $osInstallDate + "`n" + "LastLoginBy: " + $userName 
$output += "`n" + "DiskDrive: " + $diskDrive

# Print machine information
Write-Output ($output + "`n")

# Save info to file
if (!($outpath)) {
    do
    {
        $thisCompYN = read-host -prompt "Would you like to save this to a file?"
        If ($arrayYes.Contains($thisCompYN))
        {
            [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
            $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
            $SaveFileDialog.Filter = "Text files (*.txt)|*.txt"
            $SaveFileDialog.initialDirectory = $PSScriptRoot
            $SaveFileDialog.FileName = $compName + " - " + (Get-Date).ToString('MM-dd-yyyy') 
            if ($SaveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { 
                $output > $SaveFileDialog.FileName

                # Output file saved message
                Write-Output ("`n" + $SaveFileDialog.FileName + " saved." + "`n")
            }

            $valid = 1
        }
        ElseIf ($arrayNo.Contains($thisCompYN))
        {
            $valid = 1
        }
        Else
        {
            Write-Output ("Please enter 'yes' or 'no'")
            $valid = 0
        }
    } while ($valid -eq 0)
}
else {
    $output > $outpath

    # Output file saved message
    Write-Output ("`n" + $outpath + " saved." + "`n")
}

# Output end program message
Write-Output ("`n" + "Program ending...")