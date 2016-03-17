<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.117
	 Created on:   	13-03-2016 17:40
	 Created by:   	 
	 Organization: 	 
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		For this Function to work, you will need the Avd. Function from the
		Scripting guy. You can find the Avd. Function here:
		https://gallery.technet.microsoft.com/scriptcenter/get-file-meta-data-function-f9e8d804
#>

#Put in the path to the function Get-FileMetaDataReturnObject.ps1 here.

<#
	.SYNOPSIS
		A brief description of the Get-Something function.

	.DESCRIPTION
		A detailed description of the Get-Something function.

	.PARAMETER  ParameterA
		The description of a the ParameterA parameter.

	.PARAMETER  ParameterB
		The description of a the ParameterB parameter.

	.EXAMPLE
		PS C:\> Get-Something -ParameterA 'One value' -ParameterB 32
		'This is the output'
		This example shows how to call the Get-Something function with named parameters.

	.EXAMPLE
		PS C:\> Get-Something 'One value' 32
		'This is the output'
		This example shows how to call the Get-Something function with positional parameters.

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
function Sort-Files {
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[System.String]
		$SourcePath,
		[Parameter(Position=1)]
		[System.String]
		$DestinationPath
	)
	begin {
		try
		{
			Test-Path -LiteralPath $SourcePath -ErrorAction Stop
			Test-Path -LiteralPath $DestinationPath -ErrorAction Stop
			#Edit this path to where you have your Get-FileMetaDataReturnObject.ps1 file located.
			. ".\..\..\MTH-IT-Drift-Tools\Release\Advanced Functions\Get-FileMetaDataReturnObject.ps1"
		}
		catch {
		}
	}
	process {
		try {
			
			$FilesData = Get-FileMetaData -folder $SourcePath
			Write-Output $FilesData
						
		}
		catch {
		}
	}
	end {
		try {
		}
		catch {
		}
	}
}

