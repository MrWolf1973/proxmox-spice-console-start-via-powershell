# proxmox-spice-console-start-via-powershell

## Task   
Start on a windows 10 client the spice console from a virtual machine hosted by proxmox installation   
   
## Assumption  
* Proxmox is running  
* Virtual machines are created  
* VirtViewer / remote-viewer is installed  
* Spice console is working start via administration UI  

## Preperation steps  
* If you have a self singed certificate copy the pem file from the proxmox server to your client and install it. see https://pve.proxmox.com/wiki/Import_certificate_in_browser  
* (optional) Create a special user to not expose your admin password to a local script  
  
## Usage  
* Update the script header with your environment specific data  
    # environment specific variables
    $node = '-- Host name FQN --'
    $nodename = '-- Node name on the left of your admin ui (default pve) --'
    $vmid = '-- ID of your VM (e.g. 100) --'
    $username = '-- Username including (@pam or @pve) --'
    $password = '-- password --'
    $remoteviewer = '-- Path to remote-viewer.exe (e.g. C:\Program Files\VirtViewer v7.0-256\bin\remote-viewer.exe) --'
	
