
function Get-MSPatch ($KB,$Quiet) {
    $Quiet = $false
    #$KBs are for when I need to ask WMI(Win32_QuickFixEngineering/Get-hotfix) for the KB's.
    $Count = 0
    $QueryStringAssembly = ""

    #This part is to create there FilterScript String, we need to search for KB patches in the Registry.
    $FilterScript = @() 
    $KBObj = $kb -split ","
    $KBObjwStart = $KBObj | ForEach-Object -Process { '$_.displayname -like ' + ('"*' + $_ + '*"')}
    $WhereString = $KBObjwStart -join " -or "
    $FilterScript = [scriptblock]::Create( $WhereString )

    #Search the Reg.
    $Reg = @("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")
    $InstalledApps = Get-ItemProperty $Reg -EA 0
    $Run = 0

    $OfficeKBs = $InstalledApps |
    Where-Object -FilterScript {
        ($FilterScript.invoke())
    } |
	Add-Member -MemberType NoteProperty -Name 'Original Source' -Value 'Registry Database' -PassThru

    foreach ($Item in $KBObj) {
        $QueryStringAssembly += if ($Count -eq '0') {"where HotFixID='$Item'"} else { " OR HotFixID='$Item'"}
        $Count++
    }
    $WMIQuery =  "select * from Win32_QuickFixEngineering " + "$QueryStringAssembly"
	
	$WinKBs = Get-WmiObject -Query $WMIQuery |
	Select-Object -Property * |
	Add-Member -MemberType NoteProperty -Name 'Original Source' -Value 'Win32_QuickFixEngineering' -PassThru

#########################################################################################################################

    if ($Quiet)  {
        If ($OfficeKBs -eq $null -and $WinKBs -eq $null) {
            Write-Output $false
        }
        else {
            Write-Output $true
        }
    }
    Else {
		$ObjKB = @()
		$ObjKB += $WinKBs
		$ObjKB += $OfficeKBs
				
			foreach ($KBPatch in $ObjKB) {
			if ($KBPatch.'Original Source' -eq "Win32_QuickFixEngineering") {
				$object = [pscustomobject]@{
					DisplayName = 'N\A';
					KBNumber = $KBPatch.HotFixID;
					InstalledOn = $KBPatch.InstalledOn;
					UninstallString = 'N\A';
					Description = $KBPatch.Description;
					FullObject = $KBPatch #This all the will Object, if it's needed.
				}
			}
			elseif ($KBPatch.'Original Source' -eq "Registry Database") {
				$object = [pscustomobject]@{
					DisplayName = $KBPatch.DisplayName;
					KBNumber = $KBPatch.'(default)';
					InstalledOn = $KBPatch.InstalledOn;
					UninstallString = $KBPatch.UninstallString;
					Description = $KBPatch.Comments;
					FullObject = $KBPatch #This all the will Object, if it's needed.
				}
			}
			Write-Output $object
			}
		
		}
}

Get-MSPatch -KB "KB3054886,KB3055034,KB3101521,KB3097877,KB3074230,KB3097996,KB3024995" -Quiet $false
