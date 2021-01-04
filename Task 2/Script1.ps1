$password = ConvertTo-SecureString ".NJbxzvKSoi*ZBnEfUWM(G;?-c94xr=;" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("Administrator", $password )
$s = New-PSSession -computername 18.156.2.72 -credential $cred

    invoke-command -session $s {Start-Sleep -s 5}
    invoke-command -session $s {$LogPath = "C:\inetpub\logs\LogFiles"}
	invoke-command -session $s {$maxDaystoKeep = -1}
 
	invoke-command -session $s {Set-Location -Path $LogPath}
 
	invoke-command -session $s {$itemsToDelete = Get-ChildItem $LogPath -Filter *.log -Recurse | Where LastWriteTime -lt ((get-date).AddDays($maxDaystoKeep))}

	invoke-command -session $s {If ($itemsToDelete.Count -gt 0){ 
    	ForEach ($item in $itemsToDelete){ 
       		Get-item $item.FullName | Remove-Item -Verbose
   		}
     
    		Write-Output "IIS Log Retention: Cleanup of log files older than $((get-date).AddDays($maxDaystoKeep)) completed..."
		} 
		Else { 
    	Write-Output "IIS Log Retention: No items to be deleted today $($(Get-Date).DateTime)"
		}}
  
	invoke-command -session $s {Start-Sleep -s 5}
	invoke-command -session $s {exit}