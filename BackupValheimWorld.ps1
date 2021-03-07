# Valheim Backup and Restore Tool
# Author: Etcha-Sketch
# https://github.com/etcha-sketch

function BackupValheimWolrds
{
    clear-host
    Write-host "$("-"*60)`n$(" "*20)Backup Wolrds`n$("-"*60)"
    
    Push-location "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\worlds"
    
    if (!(Test-Path 'Backups'))
    {
        New-Item -ItemType directory 'Backups' | Out-Null
        Write-host "`nWorld Backup directory created.`n"
    }
    else
    {
        Write-host "`n`nWorld Backup directory already exists.`n"
    }
    
    $backuppath = (gci "Backups*").FullName
    
    $worldnames = ((gci "*.db").Name).Replace('.db','')
    
    foreach ($world in $worldnames)
    {
        $filestobackup = gci "$($world).*"
        if (!(Test-Path "$($backuppath)\$($world)"))
        {
            Write-host "$($world) Backup directory does not exist, creating now."
            New-item -ItemType Directory -Path "$($backuppath)\$($world)" | Out-Null 
        }
            
        $backupdir = "$($backuppath)\$($world)\$('{0:yyyy-MM-dd-HH-mm}' -f ((($filestobackup | Sort-Object -Property LastWriteTime -Descending)[0]).LastWriteTime))\"
        if (!(Test-path $backupdir))
        {
            New-item -ItemType Directory -Path $backupdir | Out-null
            copy-item $filestobackup $backupdir
            Write-host "$($world) backed up."
        }
        else
        {
            Write-host "$($world) already backed up."
        }
    }
    
    
    Write-host "`n`nAll Worlds successfully backed up." -ForegroundColor Green
    
   
    
    Pop-Location


}


function BackupValheimChars
{
    clear-host
    Write-host "$("-"*60)`n$(" "*20)Backup Characters`n$("-"*60)"
    Push-location "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\characters"
    
    if (!(Test-Path 'Backups'))
    {
        New-Item -ItemType directory 'Backups' | Out-Null
        Write-host "`nCharacter Backup directory created.`n"
    }
    else
    {
        Write-host "`n`nCharacter Backup directory already exists.`n"
    }
    
    $backuppath = (gci "Backups*").FullName
    
    $charnames = ((gci "*.fch").Name).Replace('.fch','')
    
    foreach ($char in $charnames)
    {
        $filestobackup = gci "$($char).*"
        if (!(Test-Path "$($backuppath)\$($char)"))
        {
            Write-host "$($char) Backup directory does not exist, creating now."
            New-item -ItemType Directory -Path "$($backuppath)\$($char)" | Out-Null 
        }
            
        $backupdir = "$($backuppath)\$($char)\$('{0:yyyy-MM-dd-HH-mm}' -f ((($filestobackup | Sort-Object -Property LastWriteTime -Descending)[0]).LastWriteTime))\"
        if (!(Test-path $backupdir))
        {
            New-item -ItemType Directory -Path $backupdir | Out-null
            copy-item $filestobackup $backupdir
            Write-host "$($char) backed up."
        }
        else
        {
            Write-host "$($char) already backed up."
        }
    }
    
    
    Write-host "`n`nAll Characters successfully backed up." -ForegroundColor Green
    
   
    
    Pop-Location


}

function RestoreValheimWolrd
{
    clear-host
    Write-host "$("-"*60)`n$(" "*20)Restore Worlds`n$("-"*60)`n`n"
    $wbackup = Read-host "Would you like to make backups of all of your worlds first? [y]/n"
    if (!($wbackup -ieq "n"))
    {
        BackupValheimWolrds; start-sleep -seconds 3
    }

    
    clear-host
    Write-host "$("-"*60)`n$(" "*20)Restore Worlds`n$("-"*60)"
    if (Test-path "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\worlds\Backups")
    {
        Push-Location "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\worlds\Backups"
        $restoreworldoptions = gci *
        $op = 0
        Write-host "`n`nChoose a World to restore"
        foreach ($restoreworld in $restoreworldoptions)
        {
            Write-host "$($op + 1)>   $($restoreworld.Name)"
            $op ++
        }

        Write-host "`n0>   Main Menu"

        $userchoice = Read-host "Restore which world?"
        if (($userchoice -gt ($op+1)) -or ($userchoice -lt 0))
        {
            Write-host "Invalid Choice, exiting now." -ForegroundColor Red
            
        }
        elseif ($userchoice -eq 0)
        {
            Showmenu
        }
        else
        {
            Write-host "`n`nRestoring the $(($restoreworldoptions[$userchoice-1]).Name) world.`n"
            Push-Location $($restoreworldoptions[$op-1]).FullName
            $restorepoints = gci *
            if ($restorepoints.count -gt 1)
            {
                Write-host "More than one restore point exists, chose one:"
                $rp = 0
                foreach ($restorepoint in $restorepoints)
                {
                    write-host "$($rp+1)>   $(((get-childitem "$($restorepoint.FullName)\*" | Sort-Object -Property LastWriteTime -Descending)[0]).LastWriteTime)"
                    $rp ++
                }

               $worldrp = Read-host "Choose a restore point"
               if (($worldrp -gt $rp) -or ($worldrp -le 0)) { Write-host "`nInvalid Choice" -ForegroundColor red; start-sleep -Seconds 2; showmenu }               
               $confirm = Read-host "Would you like to restore to $(((gci "$(($restorepoints[$worldrp-1]).FullName)\*" | Sort-object -Property LastWriteTime -Descending)[0]).LastWriteTime)? y/[n]"
               if ($confirm -ieq 'y')
               {
                   #perform backup now.
                   gci "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\worlds\$($restoreworld.name).*" -ErrorAction SilentlyContinue | remove-item -Force -ErrorAction SilentlyContinue
                   Start-Sleep -Seconds 2
                   copy-item "$(($restorepoints[$worldrp-1]).FullName)\*" "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\worlds\"
                   Write-host "`n`nRestore completed to $((gci "$(($restorepoints[$worldrp-1]).FullName)\*.db").LastWriteTime)`n`n" -ForegroundColor Green

               }
               else
               {
                   Write-host "OK, no changes will be made."
               }


            }
            else
            {
                Write-host "Only one backup exists: $(((gci "$($restorepoints.FullName)\*" | Sort-object -Property LastWriteTime -Descending)[0]).LastWriteTime)"
                $confirm = Read-host "Would you like to restore to this time? y/[n]"
                if ($confirm -ieq 'y')
                {
                    #perform backup now.
                    gci "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\worlds\$($restoreworld.name).*" -ErrorAction SilentlyContinue | remove-item -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2
                    copy-item "$($restorepoints.FullName)\*" "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\worlds\"
                    Write-host "`n`nRestore completed to $((gci "$($restorepoints.FullName)\*.db").LastWriteTime)`n`n" -ForegroundColor Green

                }
                else
                {
                    Write-host "OK, no changes will be made."
                }


            }


            Pop-Location
        }
        start-sleep -seconds 2
        Pop-Location
    }
    else
    {
        Write-host "No World Backup Folder Detected, you must have a backup to perform a restore." -ForegroundColor Red

    }
    
}

function RestoreValheimChar
{
    clear-host
    Write-host "$("-"*60)`n$(" "*20)Restore Characters`n$("-"*60)`n`n"
    $cbackup = Read-host "Would you like to make backups of all of your characters first? [y]/n"
    if (!($cbackup -ieq "n"))
    {
        BackupValheimChars; start-sleep -seconds 3
    }

    clear-host
    Write-host "$("-"*60)`n$(" "*20)Restore Characters`n$("-"*60)"
    if (Test-path "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\characters\Backups")
    {
        Push-Location "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\characters\Backups"
        $restorecharoptions = gci *
        $charop = 0
        Write-host "`n`nChoose a char to restore"
        foreach ($restorechar in $restorecharoptions)
        {
            Write-host "$($charop + 1)>   $($restorechar.Name)"
            $charop ++
        }
        Write-host "`n0>   Main Menu"
        $usercharchoice = Read-host "Restore which char?"
        if (($usercharchoice -gt ($charop+1)) -or ($usercharchoice -lt 0))
        {
            Write-host "Invalid Choice, exiting now." -ForegroundColor Red
            
        }
        elseif ($usercharchoice -eq 0)
        {
            ShowMenu
        }
        else
        {
            Write-host "`n`nRestoring the $(($restorecharoptions[$usercharchoice-1]).Name) character.`n`n"
            Push-Location $($restorecharoptions[$usercharchoice-1]).FullName
            $restorecharpoints = gci *
            if ($restorecharpoints.count -gt 1)
            {
                Write-host "More than one restore point exists, chose one:"
                $rp = 0
                foreach ($restorecharpoint in $restorecharpoints)
                {
                    write-host "$($rp+1)>   $(((get-childitem "$($restorecharpoint.FullName)\*" | Sort-Object -Property LastWriteTime -Descending)[0]).LastWriteTime)"
                    $rp ++

                }

                
                $charrp = Read-host "Choose a restore point"
                
                if (($charrp -gt $rp) -or ($charrp -le 0)) { Write-host "`nInvalid Choice" -ForegroundColor red; start-sleep -Seconds 2; showmenu }
                
                $confirm = Read-host "Would you like to restore to $(((gci "$(($restorecharpoints[$charrp-1]).FullName)\*" | Sort-object -Property LastWriteTime -Descending)[0]).LastWriteTime)? y/[n]"
                
                if ($confirm -ieq 'y')
                {
                    #perform backup now.
                    gci "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\characters\$(($restorecharoptions[$usercharchoice-1]).Name).*" -ErrorAction SilentlyContinue | remove-item -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2
                    copy-item "$(($restorecharpoints[$charrp-1]).FullName)\*" "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\characters\"
                    Write-host "`n`nRestore of $(($restorecharoptions[$usercharchoice-1]).Name) completed to $((gci "$(($restorecharpoints[$charrp-1]).FullName)\*.fch").LastWriteTime)`n`n" -ForegroundColor Green

                }
                else
                {
                    Write-host "OK, no changes will be made."
                }

            }
            else
            {
                Write-host "Only one backup exists: $(((gci "$($restorecharpoints.FullName)\*" | Sort-object -Property LastWriteTime -Descending)[0]).LastWriteTime)"
                $confirm = Read-host "Would you like to restore to this time? y/[n]"
                if ($confirm -ieq 'y')
                {
                    #perform backup now.
                    gci "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\characters\$(($restorecharoptions[$usercharchoice-1]).Name).*" -ErrorAction SilentlyContinue | remove-item -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2
                    copy-item "$($restorecharpoints.FullName)\*" "$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim\characters\"
                    Write-host "`n`nRestore of $(($restorecharoptions[$usercharchoice-1]).Name) completed to $((gci "$($restorecharpoints.FullName)\*.fch").LastWriteTime)`n`n" -ForegroundColor Green

                }
                else
                {
                    Write-host "OK, no changes will be made."
                }


            }


            Pop-Location
        }

        Pop-Location
    }
    else
    {
        Write-host "No Character Backup Folder Detected, you must have a backup to perform a restore." -ForegroundColor Red

    }
    
}


function ShowMenu
{

    Clear-Host
    Write-Host '---------------------------------------------------------'
    Write-Host '          etcha-sketch`s Valheim Backup Tool'
    Write-Host 'No warranties expressed or implied. Use at your own risk.' -ForegroundColor Red
    Write-Host "---------------------------------------------------------"
    
    
    Write-host "`n`n1) Backup All Worlds and Characters"
    Write-host "2) Backup All Worlds"
    Write-host "3) Backup All Characters"
    Write-host "4) Restore a World"
    Write-host "5) Restore a Character"
    Write-host "6) Open Valheim save folder in Windows Explorer"
    Write-host "`n0) Exit Tool`n"
    $option = read-host "What would you like to do?"
    
    if ($option -eq 0)
    {
        Pop-Location; Pop-Location; Pop-Location; Pop-Location; Pop-Location
    }
    elseif($option -eq 1) { BackupValheimWolrds; start-sleep -seconds 2; BackupValheimChars; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 2) { BackupValheimWolrds; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 3) { BackupValheimChars; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 4) { RestoreValheimWolrd; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 5) { RestoreValheimChar; start-sleep -seconds 2; ShowMenu }
    elseif ($option -eq 6) { Start-process 'C:\Windows\explorer.exe' -ArgumentList @("$(($env:APPDATA).Replace('Roaming','LocalLow'))\IronGate\Valheim") ; start-sleep -seconds 2; ShowMenu }
    else { Write-host "`n`nPlease make a valid selection" -foregroundcolor red;  start-sleep -seconds 2; ShowMenu }
}
ShowMenu
Write-Host "`n`nThanks for using etcha-sketch`s Valheim Backup Tool!"
Write-host "Visit https://github.com/etcha-sketch for more useful tools."
Start-Sleep -Seconds 5