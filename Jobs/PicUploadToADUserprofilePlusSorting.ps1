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

$PathToPictures = "$env:ProgramData\Pictures\DLI_96x96 (0007O7).png"
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
	$FPhoto = [byte[]](Get-Content "$PhotoPath" -Encoding byte)
	#Will need to remove this(Below line -Credential (Get-Credential)) when all is done.
	Set-ADUser "$Username" -Replace @{ thumbnailPhoto = $FPhoto } -Credential (Get-Credential)
}



#endregion

#region Controller

<#
	For more information on the try, catch and finally keywords, see:
		Get-Help about_try_catch_finally
#>

# Try one or more commands
try {
	$FilesMetadata = Get-FileMetaData -folder (Get-childitem $path -Recurse -Directory).FullName
	UploadImageToADUser -Username "dli" -PhotoPath $ConfigHashTable.PathToPictures
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