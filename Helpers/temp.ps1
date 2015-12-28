$key = (Get-AzureRmStorageAccountKey -ResourceGroupName xp-win-docker -StorageAccountName xpwindockstor).Key1
Write-Host $key