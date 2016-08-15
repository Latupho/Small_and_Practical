<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.119
	 Created on:   	26-05-2016 08:19
	 Created by:   	 Daniel Lindegaard
	 Organization: 	 MT Højgaard
	 Filename:     	Get-UserORComputerlastlogon.PS1
	===========================================================================
	.DESCRIPTION
		At times you will need to know when a user or a devise have last logon to a Domain Controller.
		It's not all that only have one DC, but servial, and as you know, if you use Get-ADcomputer or
		Get-aduser, it's not allways the DC it ask, where the user last on to.
		
		This Adv. Function will ask all the DC that you have in your domain and output
#>

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
function Get-UserORComputerlastlogon {
	[CmdletBinding()]
	param(
		[Parameter(Position = 0, Mandatory = $true)]
		[System.String]
		$Name,
		
		[Parameter(Position = 1, ParameterSetName = "Computers", Mandatory = $true)]
		[Switch]
		$Computername,
		
		[Switch]
		[Parameter(Position = 2, ParameterSetName = "Users", Mandatory = $true)]
		$Username
	)
	begin {
		try
		{
			$DCs = get-addomaincontroller -filter * | Sort-Object -Property name | Select-Object -Property name
		}
		catch {
			Write-Output $Error
		}
	}
	process {
		try
		{
			if ($Computername)
			{
				foreach ($DC in $DCs)
				{
					Write-Verbose -Verbose -Message "Looking on DC: $DC"
					$Computer = get-adcomputer -Identity $Name -properties lastLogon -server $($dc.name) |
					Select-Object -Property name, lastlogon -ErrorAction Stop
					
					$Obj = [PSCustomObject]@{
						"Domain Controller" = $($dc.name);
						"Computername" = $Computer.name;
						"Lastlogon" = try { $(Get-Date $($Computer.lastlogon) -ErrorAction Stop) }
									  catch { [datetime]::MinValue }
					}
					Write-Output $Obj
				}
			}
			elseif ($Username)
			{
				foreach ($DC in $DCs)
				{
					$User = get-aduser -Identity $Name -properties lastLogon ,PasswordLastSet -server $($dc.name) |
					Select-Object -Property name, lastlogon , PasswordLastSet -ErrorAction Stop
					
					$Obj = [PSCustomObject]@{
						"Domain Controller" = $($dc.name);
						"Username" = $User.name;
						"Lastlogon" = try { $(Get-Date $($User.lastlogon) -ErrorAction Stop) }
									  catch { [datetime]::MinValue };
                        "PasswordLastSet" = $User.PasswordLastSet
					}
					Write-Output $Obj
				}
			}		
		}
		catch
		{
			Write-Output $Error
		}
	}
	end {
		try {
		}
		catch
		{
			Write-Output $Error
		}
	}
}

