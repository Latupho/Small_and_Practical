<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.80
	 Created on:   	27-02-2015 13:49
	 Created by:   	Daniel Lindegaard
	 Licence:	 	GNU licence - http://www.gnu.org/licenses/licenses.html
	 Filename:      Get-USBDevices.ps1
	===========================================================================
	.DESCRIPTION
		Will get a list of all USB devices on your local computer, or at remote computeres.
#>

<# Quistions to all
Q: What is the best and most efficient way to get all USB devices on a computer? Using [Get-CimInstance win32_diskdrive -ComputerName $Computername | Where-Object { $_.InterfaceType –eq ‘USB’ }] takes some secunds to get the list.
	A: 
#>

<#
	.SYNOPSIS
		A brief description of the Get-USBDevices function.

	.DESCRIPTION
		A detailed description of the Get-USBDevices function.

	.PARAMETER  ParameterA
		The description of a the ParameterA parameter.

	.PARAMETER  ParameterB
		The description of a the ParameterB parameter.

	.EXAMPLE
		PS C:\> Get-USBDevices -ParameterA 'One value' -ParameterB 32
		'This is the output'
		This example shows how to call the Get-USBDevices function with named parameters.

	.EXAMPLE
		PS C:\> Get-USBDevices 'One value' 32
		'This is the output'
		This example shows how to call the Get-USBDevices function with positional parameters.

	.INPUTS
		System.String,System.Int32

	.OUTPUTS
		System.String

	.NOTES
		For more information about advanced functions, call Get-Help with any
		of the topics in the links listed below.

	.LINK
		about_modules

	.LINK
		about_functions_advanced

	.LINK
		about_comment_based_help

	.LINK
		about_functions_advanced_parameters

	.LINK
		about_functions_advanced_methods
#>
function Get-USBDevices {
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$False)]
		[System.String]
		$DeviceName, #$ParameterA
		[Parameter(Position=1, Mandatory = $False)]
		[System.String]
		$Computername = $env:COMPUTERNAME #$ParameterB
	)
	begin {
		try
		{
			Import-Module -Name CimCmdlets
			$USBDevices = Get-CimInstance win32_diskdrive -ComputerName $Computername | Where-Object { $_.InterfaceType –eq ‘USB’ }
		}
		catch
		{
		}
	}
	process {
		try
		{
			
			foreach ($Computer in $Computername)
			{				
				if ($USBDevices -eq $null)
				{
					Write-Output "WMI is stating that there is no USB devices detected"
				}
				else
				{					
					If ($Computername.Count -ne '1') {
						Write-Verbose -Message "Getting USB devices for computer: $Computer"
					}
					Write-Output $USBDevices
				}
			}
		}
		catch
		{
		}
	}
	end {
		try {
		}
		catch {
		}
	}
}

Get-USBDevices -Verbose | Select-Object -Property *