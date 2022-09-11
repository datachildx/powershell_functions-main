Add-Type -assemblyName "System.Windows.Forms"
$CSVFile = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter           = 'CSV-file (*.csv)|*.csv'
}
$null = $CSVFile.ShowDialog()