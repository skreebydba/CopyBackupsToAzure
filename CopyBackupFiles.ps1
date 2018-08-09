#Connect-AzureRmAccount;

$backuppath = 'C:\Backup';

$databasename = 'wideworldimporters';
$backupfiles = Get-ChildItem "$backuppath\$databasename\FULL"; 
$maxdate = Get-ChildItem "$backuppath\$databasename\FULL" | Measure-Object -Property LastWriteTime -Maximum;
$rgname = 'fbgbackuprg';
$storageacctname = 'fbgbackupsa';

$stctxt = (Get-AzureRmStorageAccount -ResourceGroupName $rgname -Name $storageacctname).Context;

$backupfiles;
$maxdate.Maximum;

$containers = (Get-AzureStorageContainer -Context $stctxt).Name; 

$containers;

if(($containers.Contains($databasename)) -and ($containers -ne $null))
{
    Write-Output "Container $databasename exists.";
}
else
{
    New-AzureStorageContainer -Context $stctxt -Name $databasename;
} 
 
foreach($backupfile in $backupfiles)
{

    if($backupfile.LastWriteTime -eq $maxdate.Maximum)
    {
        $filepath = "$backuppath\$databasename\FULL\$backupfile";
        Set-AzureStorageBlobContent -File $filepath -Context $stctxt -Container $databasename -Force;
    }
}