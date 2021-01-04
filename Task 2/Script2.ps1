$password = ConvertTo-SecureString ".NJbxzvKSoi*ZBnEfUWM(G;?-c94xr=;" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("Administrator", $password )
$s = New-PSSession -computername 18.156.2.72 -credential $cred

invoke-command -session $s {Start-Sleep -s 5}
invoke-command -session $s {$myAppPool = Get-WmiObject -Namespace root\WebAdministration -Class ApplicationPool -Filter "Name = 'DefaultAppPool'"}
invoke-command -session $s {$myAppPool.Recycle()}
invoke-command -session $s {Start-Sleep -s 5}
invoke-command -session $s {exit}