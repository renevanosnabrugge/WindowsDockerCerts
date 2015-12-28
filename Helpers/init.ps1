netsh advfirewall firewall add rule name="Open Port 80" dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name="Open Port 5000" dir=in action=allow protocol=TCP localport=5000
netsh advfirewall firewall add rule name="Open Port 6000" dir=in action=allow protocol=TCP localport=6000
netsh advfirewall firewall add rule name="Open Port 7000" dir=in action=allow protocol=TCP localport=7000
netsh advfirewall firewall add rule name="Open Port 7050" dir=in action=allow protocol=TCP localport=7050
netsh advfirewall firewall add rule name="Docker Secure Port" dir=in action=allow protocol=TCP localport=2376

Copy-Item "$PSScriptRoot\ca.pem" "C:\ProgramData\Docker\certs.d\"
Copy-Item "$PSScriptRoot\server-cert.pem" "C:\ProgramData\Docker\certs.d\"
Copy-Item "$PSScriptRoot\server-key.pem" "C:\ProgramData\Docker\certs.d\"

Restart-Service Docker