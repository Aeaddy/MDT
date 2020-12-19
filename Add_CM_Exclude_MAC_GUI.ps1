[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Exlude MAC Address in Configuration Manager"
$objForm.Size = New-Object System.Drawing.Size(460,200) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$x=$objTextBox.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please enter the Mac Address in the space below:"
$objForm.Controls.Add($objLabel) 

$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Location = New-Object System.Drawing.Size(10,40) 
$objTextBox.Size = New-Object System.Drawing.Size(260,20) 
$objForm.Controls.Add($objTextBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$x

$key = "hklm:\SOFTWARE\Microsoft\SMS\Components\SMS_DISCOVERY_DATA_MANAGER"

$OLDMACS=(Get-ItemProperty $key).ExcludeMACAddress

$NEWMACS = $OLDMACS + ($objTextBox.Text.Split(", ",[System.StringSplitOptions]::RemoveEmptyEntries))

if ($OLDMACS -contains $objTextBox.Text){
[System.Windows.Forms.MessageBox]::Show("This registry value " + $objTextBox.Text + " already exists" , "Error") 
}ELSE{

If (Test-Path $key){

Set-itemProperty $key ExcludeMACAddress -value $NEWMACS -type MultiString
[System.Windows.Forms.MessageBox]::Show("Successfully added MAC address " + $objTextBox.Text , "Success") 

}ELSE{

[System.Windows.Forms.MessageBox]::Show("Cannot find registry key. " + $env:COMPUTERNAME + " is not a Configuration Manager Primary Site Server, or you do not have access to the registry" , "Error") 

}
}