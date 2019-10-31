Add-Type -AssemblyName System.Windows.Forms
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Set-Location $env:TEMP

if(-Not (Test-Path "vridge-preview-installer"))
{
    mkdir "vridge-preview-installer"
}

Set-Location vridge-preview-installer

if(-Not (Test-Path vridge.apk))
{
    Write-Output "Downloading vridge.apk. This should take less than a minute."
    $latestURL = (Invoke-WebRequest -Uri "https://go.riftcat.com/VRidgeQuestBeta" -MaximumRedirection 0 -ErrorAction SilentlyContinue).Headers.Location
    Start-BitsTransfer $latestURL -Destination vridge.apk
}

if(-Not (Test-Path adb.zip))
{
    Write-Output "Downloading ADB. This should take less than a minute."
    Start-BitsTransfer "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -Destination adb.zip
}

if(-Not (Test-Path .\platform-tools\adb.exe))
{
    Write-Output "Unpacking."
    Expand-Archive adb.zip -DestinationPath .
}

Write-Output "Testing if Quest is connected."
$deviceStatus = .\platform-tools\adb.exe devices -l | Out-String    

if($deviceStatus.Contains("Quest"))
{

    if((.\platform-tools\adb.exe shell pm list packages com.riftcat.vridgeoculus.beta.beta | Out-String).Length -gt 0)
    {
        Write-Output "Unnstalling current version."
        .\platform-tools\adb.exe uninstall com.riftcat.vridgeoculus.beta.beta
    }

    Write-Output "Installing."
    $installResult = .\platform-tools\adb.exe install vridge.apk | Out-String

    if($installResult.Contains("Success"))
    {
        [System.Windows.Forms.MessageBox]::Show("VRidge for Quest preview installed.", "Success", "Ok", "Information");    
    }
    else
    {
        [System.Windows.Forms.MessageBox]::Show("Unexpected error during installation. Please contact support@riftcat.com.", "Error", "Ok", "Error");    
    }
    
}
elseif($deviceStatus.Contains("unauthorized"))
{
    [System.Windows.Forms.MessageBox]::Show("Your device is connected but you need to confirm the developer prompt inside the headset first. Please put on your headset while the device is connected and confirm the connecion in VR, then paste this script again.", "Error", "Ok", "Warning");    
}
else
{
    [System.Windows.Forms.MessageBox]::Show("Quest connection not found. Please make sure it's connected properly through USB, then paste this script again.", "Error", "Ok", "Warning");    
}
