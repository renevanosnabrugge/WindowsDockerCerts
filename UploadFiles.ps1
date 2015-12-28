param 
(
[string]$ResourceGroupName,
[string]$VMName,
[string]$Location,
[string]$StorageAccountName
)



Write-Host "Create Storage Account"
$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Type Standard_LRS -Location $Location 

Write-Host "Get Storage Account"
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

Write-Host "Retrieve Key"
$key = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

Write-Host "Create Storage Container"
New-AzureStorageContainer -Name scripts -Context $StorageAccount.Context

Write-Host "Upload Certificates + Init Script"
Set-AzureStorageBlobContent -File ".\Helpers\Init.ps1" -Container scripts -BlobType Block -Context $storageAccount.Context
Set-AzureStorageBlobContent -File ".\certs\ca.pem" -Container scripts -BlobType Block -Context $storageAccount.Context
Set-AzureStorageBlobContent -File ".\certs\server-cert.pem" -Container scripts -BlobType Block -Context $storageAccount.Context
Set-AzureStorageBlobContent -File ".\certs\server-key.pem" -Container scripts -BlobType Block -Context $storageAccount.Context

Write-Host "Push into VM and execute Init.ps1 Script"
Set-AzureRmVMCustomScriptExtension -Name CSEDocker  -Location $Location -containername scripts -ResourceGroupName $ResourceGroupName -VMName $VMName -StorageAccountName $StorageAccountName -FileName 'ca.pem','server-cert.pem','server-key.pem', 'Init.ps1' -StorageAccountKey $key.Key1 -Run 'Init.ps1'

