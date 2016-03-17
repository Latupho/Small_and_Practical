<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.80
	 Created on:   	17-07-2017 17:17 ;-)
	 Created by:   	Daniel Lindegaard (@Lindegaard13) : Why 13 some ask...¿ I like! the number 13, thats why :-D
	 Source:		https://github.com/Latupho/Small_and_Practical/[UPDATE THIS PLEASE!]
	 Licence:		GNU licence - http://www.gnu.org/licenses/licenses.html
	 Filename:     	New-DLZip.ps1
	 Credets to:	Don Jones (@concentrateddon) for all the GREAT work he do for the Powershell community
					The Scripting guy (@ScriptingGuys), for sparking the idead to this little project of mine 
	===========================================================================
	.DESCRIPTION
		Create one or servial zip files.
	.Todo
		-[] Give this cmdlet a Source and a Destination for where the files will need to be saved at
		-[] The user will need to be able to pipe folders, files or mixet items it this cmdlet, and it will create zip files for the user.
		-[] The user will need to be able to deside, if she/he want one zip pr. folder.
		-[] The user will need to be able to deside, if she/he want one zip pr. file
		-[] The user will need to be able to deside, if she/he want to have an alternativ distanation for the files, then the root of the files/folders.
			-[] What if the files that is pipet in from diffrent locations? How will the cmdlet Handlet that?
		-[] The user will need to be able to deside, if she/he
		-[] This cmdlet will need to support Microsoft Windows 7 and lather
		-[] This cmdlet will need to support latest Microsoft .NET framwork for windows 7 and lather
		-[] This cmd let will need to support Microsoft Powershell 3

#>

$path = "C:\backup"

$source = Get-ChildItem -Path c:\backup -Filter "*test*" -Directory

Add-Type -assembly "system.io.compression.filesystem"

Foreach ($s in $source)
{
	$destination = Join-path -path $path -ChildPath "$($s.name).zip"
	
	If (Test-path $destination) { Remove-item $destination }
	
	[io.compression.zipfile]::CreateFromDirectory($s.fullname, $destination)
}

