$password = ConvertTo-SecureString ".NJbxzvKSoi*ZBnEfUWM(G;?-c94xr=;" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("Administrator", $password )
$s = New-PSSession -computername 18.156.2.72 -credential $cred

invoke-command -session $s {Start-Sleep -s 5}
invoke-command -session $s {Remove-IISSite -Name "Test"}
invoke-command -session $s {Start-Sleep -s 5}
invoke-command -session $s {exit}