<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.118
	 Created on:   	02-04-2016 13:28
	 Created by:   	[Unknown] - Please contact me, if you know.
	 Organization: 	[Unknown]
	 Filename:     	Convert-JPGtoPNG
	===========================================================================
#>


<#
	.SYNOPSIS
		Convert-JPGtoPNG convert a image, or images with a foreatch loop to PNG.

	.DESCRIPTION
		This Adv. function will convert images from JPG to PNG with some setting to set quality, CanvasWidth and CanvasHeight.
		This is a script I found on the web, and have not been able to find the orginal owner off. I found a lot a versions of this,
		and can see it's witly used.

	.PARAMETER  ImageSource
		Where the file that neede to be converted to PNG

	.PARAMETER  ImageTarget
		Where the file that neede to be converted to PNG, need to be placed and named.

	.PARAMETER  Quality
		Quality of the image, 1 to 100%.

	.PARAMETER  CanvasWidth
		The Width of the image, 1 to 5000.

	.PARAMETER  CanvasHeight
		The Height of the image, 1 to 5000.

	.EXAMPLE
	$PathToPictures = "$env:ProgramData\Pictures\"
    $DestinationPNGPath = "$PathToPictures\to PNG"

   	if (Test-Path -Path $DestinationPNGPath)
	{ }
	Else
	{
		New-Item -Path $DestinationPNGPath -ItemType Directory -Verbose
	}

    Get-ChildItem -path $PathToPictures -Filter "*.jpg" -File |
    Foreach-Object -Process {
       $newName = $_.FullName.Substring(0, $_.FullName.Length - 4) + "_resized.png"
       Convert-JPGtoPNG -imageSource $_.FullName -imageTarget $newName -quality 80 -canvasWidth 96 -canvasHeight 96

       move-Item -Path $newName -Destination $DestinationPNGPath -Verbose -Force
    }

	.EXAMPLE

	.INPUTS		

	.OUTPUTS
		

	.NOTES
		For more information about advanced functions, call Get-Help with any
		of the topics in the links listed below.

	.LINK
		Link to GitHub Repo, and this file.
#>
function Convert-JPGtoPNG
{
	Param ([Parameter(Mandatory = $True)]
        [ValidateScript({[System.IO.Path]::IsPathRooted($_)})]
		[ValidateNotNull()]
		$imageSource,

		[Parameter(Mandatory = $True)]
        [ValidateScript({[System.IO.Path]::IsPathRooted($_)})]
        [ValidateNotNull()]
		$imageTarget,

		[Parameter(Mandatory = $true)]
		[ValidateRange(1,100)]
		[ValidateNotNull()]
		$quality,

		[Parameter(Mandatory = $true)]
		[ValidateRange(1,5000)]
        [ValidateNotNull()]
		$canvasWidth,

		[Parameter(Mandatory = $true)]
        [ValidateRange(1,5000)]
		[ValidateNotNull()]
		$canvasHeight
	)
	
	Begin
	{
	}
	Process
	{
<#      Part of the orginal code. Removed as I use ValidateRange and ValidateScript in the Paramaters.		
		if (!(Test-Path $imageSource))
		{
			throw ("Cannot find the source image")
		}
		if (!([System.IO.Path]::IsPathRooted($imageSource)))
		{
			throw ("please enter a full path for your source path")
		}
		if (!([System.IO.Path]::IsPathRooted($imageTarget)))
		{
			throw ("please enter a full path for your target path")
		}
		if (!([System.IO.Path]::IsPathRooted($canvasWidth)))
		{
			throw ("please enter your maximum width")
		}
		if (!([System.IO.Path]::IsPathRooted($canvasHeight)))
		{
			throw ("please enter your maximum height")
		}
		if ($quality -lt 0 -or $quality -gt 100)
		{
			throw ("quality must be between 0 and 100.")
		}
		#>
		[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
		$bmp = [System.Drawing.Image]::FromFile($imageSource)
		
		#hardcoded canvas size...
		$canvasWidth = 96
		$canvasHeight = 96
		
		#Encoder parameter for image quality
		$myEncoder = [System.Drawing.Imaging.Encoder]::Quality
		$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
		$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, $quality)
		# get codec
		$myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
							Where-Object {
								$_.MimeType -eq 'image/jpeg'
							}
		
		#compute the final ratio to use
		$ratioX = $canvasWidth / $bmp.Width;
		$ratioY = $canvasHeight / $bmp.Height;
		$ratio = $ratioY
		if ($ratioX -le $ratioY)
		{
			$ratio = $ratioX
		}
		
		#create resized bitmap
		$newWidth = [int] ($bmp.Width * $ratio)
		$newHeight = [int] ($bmp.Height * $ratio)
		$bmpResized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
		$graph = [System.Drawing.Graphics]::FromImage($bmpResized)
		
		$graph.Clear([System.Drawing.Color]::White)
		$graph.DrawImage($bmp, 0, 0, $newWidth, $newHeight)
		
		#save to file
		$bmpResized.Save($imageTarget, $myImageCodecInfo, $($encoderParams))
		$bmpResized.Dispose()
		$bmp.Dispose()
	}
	End
	{
	}
}

