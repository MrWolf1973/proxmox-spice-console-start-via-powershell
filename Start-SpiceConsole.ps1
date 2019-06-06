
# environment specific variables
$node = '-- Host name FQN --'
$nodename = '-- Node name on the left of your admin ui (default pve) --'
$vmid = '-- ID of your VM (e.g. 100) --'
$username = '-- Username including (@pam or @pve) --'
$password = '-- password --'
$remoteviewer = '-- Path to remote-viewer.exe (e.g. C:\Program Files\VirtViewer v7.0-256\bin\remote-viewer.exe) --'

#uris
$uri = 'https://' + $node + ':8006/api2/json'
$ticketuri = $uri + '/access/ticket'
$statusuri = $uri + '/nodes/' + $nodename + '/qemu/' + $vmid + '/status/current'
$starturi = $uri + '/nodes/' + $nodename + '/qemu/' + $vmid + '/status/start'
$spiceuri = $uri + '/nodes/' + $nodename + '/qemu/' + $vmid + '/spiceproxy'

# get ticket and build websession (header, cookie)  for subsequent request
$ticketbody = 'username=' + $username + '&password=' + $password
$ticketresp = Invoke-RestMethod -Method Post -uri $ticketuri -body $ticketbody

$ticket = $ticketresp.data.ticket
$csrf = $ticketresp.data.CSRFPreventionToken

$cookie = New-Object System.Net.Cookie
$cookie.Name = "PVEAuthCookie"
$cookie.Value = $ticket
$cookie.Domain = $node
$WebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$WebSession.Cookies.Add($cookie)
$WebSession.Headers.Add('CSRFPreventionToken',$csrf)

#check status and start VM if necessary
$statusresp = Invoke-RestMethod -Method Get -uri $statusuri -WebSession $WebSession

if ($statusresp.data.qmpstatus -eq 'stopped' -And $statusresp.data.status -eq 'stopped') {
    "Trying to start VM and sleeping for 10 seconds"
    $spiceresp = Invoke-RestMethod -Uri $starturi -Method Post -WebSession $WebSession
    Start-Sleep -Seconds 10
}

#create local spice config file and start remote-viewer
$spiceresp = Invoke-RestMethod -Uri $spiceuri -Method Post -WebSession $WebSession

$file = New-TemporaryFile

"[virt-viewer]" | set-content $file
"secure-attention=" + $spiceresp.data.'secure-attention' | Add-content $file
"delete-this-file=" + $spiceresp.data.'delete-this-file' | Add-content $file
"proxy=" + $spiceresp.data.proxy | Add-content $file
"type=" + $spiceresp.data.type | Add-content $file
"ca=" + $spiceresp.data.ca | Add-content $file
"toggle-fullscreen=" + $spiceresp.data.'toggle-fullscreen' | Add-content $file
"title=" + $spiceresp.data.title | Add-content $file
"host=" + $spiceresp.data.host | Add-content $file
"password=" + $spiceresp.data.password | Add-content $file
"host-subject=" + $spiceresp.data.'host-subject' | Add-content $file
"release-cursor=" + $spiceresp.data.'release-cursor' | Add-content $file
"tls-port=" + $spiceresp.data.'tls-port' | Add-content $file

Start-Process -FilePath $remoteviewer -ArgumentList $file

