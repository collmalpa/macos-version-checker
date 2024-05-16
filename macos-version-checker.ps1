# Load configuration from config.json
$configFilePath = "config.json"
if (-not (Test-Path -Path $configFilePath)) {
    Write-Error "Configuration file not found: $configFilePath"
    exit 1
}

$config = Get-Content -Raw -Path $configFilePath | ConvertFrom-Json

# Variables for script operation
$wordToSearch = $config.wordToSearch
$emailSettings = $config.emailSettings
$recipients = $config.recipients

# Function to send an email
function send_email($Subject, $recipients, $body, $emailSettings) {
    $password = ConvertTo-SecureString $emailSettings.password -AsPlainText -Force
    $encoding = [System.Text.Encoding]::UTF8
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $emailSettings.username, $password
    [System.Net.ServicePointManager]::SecurityProtocol = 'TLS12'
    
    Send-MailMessage -SmtpServer $emailSettings.smtpServer -Port $emailSettings.port -To $recipients -From $emailSettings.username -Subject $Subject -BodyAsHtml -Body $body -Encoding $encoding -UseSsl -Credential $cred
}

# Ensure the file 'macOSVersions.txt' exists
if (-not (Test-Path -Path macOSVersions.txt)) { 
    New-Item -Path macOSVersions.txt -ItemType File 
}

# Read the existing macOS versions from the file
$AllRemindersOfmacOSOld = Get-Content macOSVersions.txt

# Search for the specified macOS version in the old data
$matchesold = Select-String -InputObject $AllRemindersOfmacOSOld -Pattern $wordToSearch -AllMatches
$countold = ($matchesold | ForEach-Object { $_.Matches.Count } | Measure-Object -Sum).Sum

# Email subject
$Subject = "New macOS version available"

# Fetch the current macOS version data from the Apple support page
$AllRemindersOfMacOSNew = (Invoke-WebRequest -Uri 'https://support.apple.com/en-us/HT201222').Links | Select-String -Pattern $wordToSearch

# Search for the specified macOS version in the new data
$matchesnew = Select-String -InputObject $AllRemindersOfMacOSNew -Pattern $wordToSearch -AllMatches 
$countnew = ($matchesnew | ForEach-Object { $_.Matches.Count } | Measure-Object -Sum).Sum

# Compare old and new macOS version counts
if ($countnew -ne $countold) {
    $tempString = $AllRemindersOfMacOSNew[0].ToString()
    $linkAboutUpdate = $tempString.Substring($tempString.IndexOf('<a href="') + 9, 37)
    $StringWithLastMacOS = $tempString.Substring($tempString.IndexOf('@{innerHTML=') + 13).Split(';')[0]
    
    $body = @(
        '----------------------------------------------'
        "Website has changed. Date of detected changes:`n" 
        (Get-Date)
        '----------------------------------------------'
        "Link to update changes:`n" 
        $linkAboutUpdate
        '----------------------------------------------'
        "Latest available version of macOS:`n" 
        $StringWithLastMacOS
        '----------------------------------------------'
    )
    $bod = [string]::Join("<br>", $body)

    # Ensure the file 'LastMacOS.txt' exists
    if (-not (Test-Path -Path LastMacOS.txt)) { 
        New-Item -Path LastMacOS.txt -ItemType File 
    }

    # Read the last known macOS version
    $LastMacOSOld = Get-Content -Path LastMacOS.txt -Raw

    # If the last known macOS version is different from the new one, send an email
    if ($LastMacOSOld -ne $StringWithLastMacOS) {
        send_email $Subject $recipients $bod $emailSettings
    }

    # Update the files with the new data
    Set-Content -Path macOSVersions.txt -Value $AllRemindersOfMacOSNew -Force
    Set-Content -Path LastMacOS.txt -Value $StringWithLastMacOS -Force
}
