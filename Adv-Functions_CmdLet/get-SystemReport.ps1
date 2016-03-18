<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.99
	 Created on:   	22-12-2015 13:40
	 Created by:   	 Daniel Lindegaard
	 Organization: 	 MT Højgaard
	 Filename:     	get-SystemReport
	===========================================================================
	.DESCRIPTION
		gather usefull information from computers. Not yet a Adv. Function, but it will be in time.

#>

Function Get-SystemReport
{
	$OS = Get-CimInstance -Class Win32_OperatingSystem
	$CS = Get-CimInstance -Class Win32_ComputerSystem
	$StoppedServices = Get-CimInstance -Class Win32_Service -Filter "StartMode='Auto' AND State!='Running'"
	$Disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType='3'"
	$PerfCounters = (Get-Counter "\processor(_total)\% processor time", "\Memory\Available Bytes" |
	Select -Expand CounterSamples)
	[pscustomobject]@{
		Computername = $env:COMPUTERNAME
		OSCaption = $OS.Caption
		OSVersion = $OS.Version
		Model = $CS.Model
		Manufacture = $CS.Manufacturer
		TotalRAMGB = [math]::Round($CS.TotalPhysicalMemory /1GB, 2)
		AvailableRAMGB = [math]::Round(($PerfCounters[1].CookedValue / 1GB), 2)
		'CPU usage' = [math]::Round($PerfCounters[0].CookedValue, 2)
		RunningProcesses = (Get-Process).Count
		LastBootUp = $OS.LastBootUpTime
		Drives = $Disk | Select DeviceID, VolumeName,
								@{ L = 'Size'; E = { [math]::Round($_.Size/1GB, 2) } },
								@{ L = 'FreeSpace'; E = { [math]::Round($_.FreeSpace/1GB, 2) } }
		StoppedServices = $StoppedServices | Select Name, DisplayName, State
	}
}

get-SystemReport

