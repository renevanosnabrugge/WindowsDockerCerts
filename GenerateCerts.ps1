
Param(
  [string] $CertificatePassword,
  [string] $OpenSSLExePath,
  [string] $OpenSSLConfigPath,
  [string] $ResourceGroupLocation
)




function GenerateCertificates($directory, $opensslExePath, $opensslConfigPath, $password, $location)
{
    
    $GenerationPath = [System.IO.Path]::Combine($PSScriptRoot, "certs")
    if (!(Test-Path $GenerationPath))
    {
        # Creates the .docker certificate directory
        New-Item $GenerationPath -type directory
    }

    $PreviousLocation = Get-Location
    Set-Location $GenerationPath

    if ((Test-Path ca.pem) -And (Test-Path server-cert.pem) -And (Test-Path server-key.pem) -And (Test-Path cert.pem) -And (Test-Path key.pem))
    {
        # Certs already there, skip generation
        Set-Location $PreviousLocation
        return;
    }

    Write-Verbose "Generating Docker certificates in $directory ..."

    # Set openssl config file path
    $env:OPENSSL_CONF=$opensslConfigPath

    # Set random seed file to be generated in current folder to avoid permission issue
    $env:RANDFILE=".rnd"

    # Generate certificates
    & $opensslExePath genrsa -aes256 -out ca-key.pem -passout pass:$password 2048 2>&1>$null
    & $opensslExePath req -new -x509 -passin pass:$password -subj "/C=US/ST=WA/L=Redmond/O=Microsoft" -days 365 -key ca-key.pem -sha256 -out ca.pem 2>&1>$null
    & $opensslExePath genrsa -out server-key.pem 2048 2>&1>$null
    & $opensslExePath req -subj "/C=US/ST=WA/L=Redmond/O=Microsoft" -new -key server-key.pem -out server.csr 2>&1>$null

    # Generate certificate with multiple domain names
    "subjectAltName = IP:10.10.10.20,IP:127.0.0.1,DNS.1:*.cloudapp.net,DNS.2:*.westeurope.cloudapp.azure.com" | Out-File extfile.cnf -Encoding ASCII 2>&1>$null
    & $opensslExePath x509 -req -days 365 -in server.csr -passin pass:$password -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf 2>&1>$null
    & $opensslExePath genrsa -out key.pem 2048 2>&1>$null
    & $opensslExePath req -subj "/CN=client" -new -key key.pem -out client.csr 2>&1>$null
    "extendedKeyUsage = clientAuth" | Out-File extfile.cnf -Encoding ASCII 2>&1>$null
    & $opensslExePath x509 -req -days 365 -in client.csr -passin pass:$password -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf 2>&1>$null

    # Clean up
    Remove-Item *.csr,.rnd
    Set-Location $PreviousLocation

    Write-Verbose "Generation completed."
}


GenerateCertificates $PSScriptRoot $OpenSSLExePath $OpenSSLConfigPath $CertificatePassword $ResourceGroupLocation