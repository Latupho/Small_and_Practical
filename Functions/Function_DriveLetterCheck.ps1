<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.80
	 Created on:   	04-03-2015 17:17
	 Created by:   	Daniel Lindegaard
	 Source:	https://github.com/Latupho/Small_and_Practical/blob/master/Functions/Function_DriveLetterCheck.ps1
	 Licence:	GNU licence - http://www.gnu.org/licenses/licenses.html
	 Filename:     	Function_DriveLetterCheck.ps1
	===========================================================================
	.DESCRIPTION
		Check if a driver letter is there or not and will return a $true or $false.
		You can put as meney drives letters you like in -Driveletter, as long its comma(,) separated.
	.Todo
		- When a Network drive is mapped, but disconnected, it's showend in the GUI explore, but under PSdrives it's not there. Need to make a check for to.
[Done]	- Only get Map drives... Don't need to get Env: or Reg... only filesystem
		- WIll need to put in a "function/ Parameter" for avealible drive letters
#>

function DriveLetterCheck ($DriveLetter)
{
	$count = 1
	foreach ($Letter in $DriveLetter)
	{
		$DriveLetterCheck = Get-PSDrive -PSProvider Filesystem | Where-Object -FilterScript { $_.Name -eq "$Letter" }
        [PSCustomObject]@{
            "Exists"       = ($DriveLetterCheck -ne $null);
            "DriveLetter"  = $Letter;
            "Count Number" = $count
            }
        $count++
	}
}

DriveLetterCheck -DriveLetter r, c

###This is from http://www.powershellmagazine.com/2012/01/12/find-an-unused-drive-letter/
###Will need to do this line a part of the function above, and I need to make the function to a Adv function, as this command below, need to be a switch. aveliable drive letters
#Get-ChildItem function:[d-z]: -Name | Where-Object { !(test-path $_) }