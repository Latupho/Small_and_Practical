function set-filenamenumber {
    [CmdletBinding()]
    param (
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory=$true,
                Position=0,
                ParameterSetName="ParameterSetName",
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage="Path to one or more locations.")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Path,
        [Parameter(Mandatory=$false)]
        [int32]
        $StartingNumber = 1,
        [Parameter(Mandatory=$false)]
        [string]
        $Splitter = '_',
        [Parameter(Mandatory=$false)]
        [string]
        $Basename = "*"
    )
    
    begin {

        $Files = Get-ChildItem -LiteralPath $Path -Name "$Basename"

        $LastFile = $Files | ForEach-Object -Process {
            Get-ChildItem -LiteralPath $Path -Name * |
            Sort-Object -Property BaseName |
            Select-Object -Last 1 | Get-Item

            if ( $Files.count -le 1 ) {
                    [Int16]$HigestNumber = $StartingNumber
                }
            else {
    #            [Int16]$HigestNumber = $LastFile | select            
            }
        }

        $Regex = '\d\.' + $Extension

        $Basename = $LastFile.Basename
        $Extension = $LastFile.Extension
        $srar

        $NewFileName = $Basename + $Splitter + $StartingNumber + $Extension
    }
    process {
        $NewFileName
        $LastFile
    }
    
    end {
        $FileInformation = $null
        $NewFileName = $null
    }
}

$Path = '/home/daniel/code/code-snippets/DLD/TopDesk/I190807-050-Job00-filetransfer/Scheduled Task - Virk_Taeller_FileTransfer/PoC/test_data/'

set-filenamenumber -Path $Path

#Move-Item -Path $Path -Destination $( set-filenamenumber -Path $Path  )

#set-filenamenumber -Path $path -Basename 'IndberetningsForloebsData'