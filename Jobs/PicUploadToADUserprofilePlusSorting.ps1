<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v4.2.99
	 Created on:   	10-03-2016 08:55
	 Created by:   	Daniel Lindegaard
	 Organization: 	MT Højgaard
	 Filename:     	PicUploadToADUserprofilePlusSorting.ps1
	===========================================================================
	.DESCRIPTION
		This job wil do the followig as it's ordered below.
	
	-- [Function] Config File
		- If no Config File Create a default one, at "ProgramData - C:\ProgramData\PicUploadToADUserprofilePlusSorting\"
		- Import Config file to memory.
	-- [Function] Check to see if the file name standart is currect.
		- Ex. on image standart, [Username]_[ImageSizePixelxPixel].jpg, ex. scr_800x768.jpg
	-- [Function] Image_check_PreAD_Upload. Will need to check if the files meet the requirement for the image, before it's uploaded to AD.
		- Check ok:			Copy the Image to "Ready for upload"
		- Check not ok:
			- Are all okey but file size, Compress the image to the currect file size. (Nice to have, need some .Net for this)
			- Are other then the file size not okey, move to "Need review" AND send a mail to Servicesdesk@mth.dk with a message
			  here about, and say it's att Jonas @ Rapro.
	-- [Function] Uploac the image to the profile.
		- Match the image in "Ready for upload" to the urrect user in AD.
			- If no match, send mail to IT-Operation, about the issue.
		- Check if the User allready have a image.
		- If the user allready have a image in "uploaded images", Copy the old Image to a "Old Image folder"
		- Copy to "Ready for upload"
	-- Image_check_PostAD_Upload:
		- 

## Can't see any value in this step, taking it out. The soring of Images, will happen in the filtering under "[Function] Image_check_PreAD_Upload".
	- Sort(copy the files) all the images in to folders that is named, by image pixel size, Ex. 1024x768
#>
#region ConfigInformation

$PathToPictures = "$env:ProgramData\Pictures\To PNG"
$ConfigFile = "$env:ProgramData\PicUploadToADUserprofilePlusSorting\Config.xml"

#endregion

## Don't edit below, no need. Edit the variables in ConfigInformation
#region Default Config file

[Hashtable]$ConfigHashTable = @{
	PathToPictures = $PathToPictures;
	MaxPixSizeHight = "96";
	MaxPixSizewide = "96";
	MaxPixFileSizeKB = "10";
}

#endregion

#region Deploying Config file, of loading config file to memory.



#endregion

#region Functions

###Dot Sourcing, the function Get-FileMetaDataReturnObject.ps1.
#. .\Get-FileMetaDataReturnObject.ps1
###This below is here for me to test, change path to what fit your config, or as showend as above.
. ("$(Get-Content -Path ".\Work_LocalTest.Config")\Get-FileMetaDataReturnObject.ps1")

function SortingImagesByPixSize ($Path, $parameter2) {
	$FilesMetadata = Get-FileMetaData -folder (Get-childitem $path -Recurse -Directory).FullName
	
}

function FilenameStandartCheck ($parameter1, $parameter2)
{
	
}

function UploadImageToADUser ($Username, $PhotoPath)
{
	$FPhoto = [byte[]](Get-Content $PhotoPath -Encoding byte)
	#Will need to remove this(Below line -Credential (Get-Credential)) when all is done.
	
	$DestinationPathUserNotInAD = $($((Get-Item -Path $PhotoPath).DirectoryName) + "\UserNotInAD\")
	$DestinationPathUserImageUploaded = $($((Get-Item -Path $PhotoPath).DirectoryName) + "\UserImageUploaded\")
	
#region Destination Path Check
	# THis Cheks if the DestinationPath is there, if not, then it will create it.
	if (Test-Path -Path $DestinationPathUserNotInAD)
	{}
	Else
	{
		New-Item -Path $DestinationPathUserNotInAD -ItemType Directory -Verbose
	}
	
	if (Test-Path -Path $DestinationPathUserImageUploaded)
	{ }
	Else
	{
		New-Item -Path $DestinationPathUserImageUploaded -ItemType Directory -Verbose
	}
#endregion
	
	if ((Get-ADUser -Filter { Name -eq $username }))
	{
		Set-ADUser $Username -Replace @{ thumbnailPhoto = $FPhoto } -WhatIf -Verbose
		Move-Item -Path $PhotoPath -Destination $DestinationPathUserImageUploaded -Force -Verbose
	}
	else
	{
		Move-Item -Path $PhotoPath -Destination $DestinationPathUserNotInAD -Force -Verbose
	}
}

function WidthAndHeightPixelsCheck ($Pattern) {
	$Widthpixels = Select-String -Pattern $Pattern -AllMatches -InputObject $_.Width |
	Select-Object -ExpandProperty Matches
	
	$Heightpixels = Select-String -Pattern $Pattern -AllMatches -InputObject $_.Height |
	Select-Object -ExpandProperty Matches
	
	[int16]$Width = $Widthpixels.Value
	[int16]$Heigh = $Heightpixels.Value
	
	[System.Boolean]$Result = ($Width -le $($ConfigHashTable.MaxPixSizewide)) -and ($Heigh -le $($ConfigHashTable.MaxPixSizeHight))
	
	Write-Output $Result
}

#endregion

#region Controller

try
{
	Get-FileMetaData -folder $($ConfigHashTable.PathToPictures) |
	ForEach-Object -Process {
        if ($_.Type -ne 'File folder') {
		        [System.String]$RegEx 		= '\d{1,}'
		        [System.String]$RegExNmae_ 	= '(\w{1,})_'
		        [System.String]$RegExNmaeAT = '(\w{1,})@'
		        [System.string]$SizeString 	= $_.Size
		
	
		        [System.Int16]$FileSize2Dic = Select-String -Pattern $RegEx -AllMatches -InputObject $SizeString |
									          Select-Object -ExpandProperty Matches |
									          Select-Object -ExpandProperty Value -First 1

		        if (($FileSize2Dic -le $($ConfigHashTable.MaxPixFileSizeKB))) {
		            if ($_.name -like "*@*")
		            {
			            $Username = (Select-String -Pattern $RegExNmaeAT -AllMatches -InputObject $_.Name |
			            Select-Object -ExpandProperty Matches).Groups[1].Value
		            }
		            Else
		            {
			            $Username = (Select-String -Pattern $RegExNmae_ -AllMatches -InputObject $_.Name |
			            Select-Object -ExpandProperty Matches).Groups[1].Value
		            }
		
		            if (WidthAndHeightPixelsCheck -Pattern $RegEx)
		            {
			            $Username
                        UploadImageToADUser -Username $Username -PhotoPath $_.Path
		            }
		            else
		            {
			            Write-Output "Not ok - $($_.name)"
		            }
		        }
                else {
                    #Write-Verbose -Message "Filesize $($_.Size)" -Verbose
                }
	        }
        }
}
# Catch specific types of exceptions thrown by one of those commands
catch [System.IO.IOException] {
}
# Catch all other exceptions thrown by one of those commands
catch {
}
# Execute these commands even if there is an exception thrown from the try block
finally {
}

#endregion
##

##