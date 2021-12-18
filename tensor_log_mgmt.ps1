param([string]$tensor_log = "C:\Users\abc\Desktop\EDFE Tensor\log", [string]$tensor_log_backup = "C:\Users\abc\Desktop\EDFE Tensor\BackUp")
#param([string]$tensor_log_backup = "C:\Users\abc\Desktop\EDFE Tensor\BackUp")

#check any file, subfolder are exist or not in log backup directory
function check_files_exist($dir){
    $is_exist = (Get-ChildItem $dir | Measure-Object).Count
    return $is_exist 
}

# if log backup is not empty, delete all the files from log backup
function remove_files($dir){
    echo "===============Start Tarashing from $dir================="
    Get-ChildItem $dir -Recurse | foreach{$_.Delete()}
    $is_files_remove = check_files_exist $dir
    if($is_files_remove -eq 0)
    {
        echo "===============Trasing Completed================="
    }else
    {
        echo "Something wrong!....Please check your script log from event manager"
    }
}

#copy files from tensor_log to log_backup
function copy_files($sdir, $disdir) {
    
    echo "===============Start Copy from $sdir to $disdir=================" 

    get-childitem -path $tensor_log -recurse | copy-item -destination $tensor_log_backup
    
    echo "===============Copy activity has been completed================"
}


#send mail with script performance 
function send_notification(){

    $EmailFrom = “looking.lodestar07@gmail.com”

    $EmailTo = “tamaldassurja@gmail.com”

    $EmailCC = "kunaldas9735@gmail.com"

    $Subject = “Notification: Log Back Up Successful”

    $Body = “Daily Back up on server has completed successfully”

    $SMTPServer = “smtp.gmail.com”

    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)

    $SMTPClient.EnableSsl = true

    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential(“looking.lodestar07@gmail.com”, “Ts@d22sd”);

    Send-MailMessage -From EmailFrom -To EmailTo -Cc $EmailCC -Subject 'Sending the Attachment' -Body "Forgot to send the attachment. Sending now." -Attachments .\data.csv -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer $SMTPClient

}

#main => checking old files are exist or not in log backup
function main_activity(){
    $is_file_exist = check_files_exist $tensor_log_backup 

    #if exist, then 1st clear all files and then copy the previous month logfiles from tensor_log
    if($is_file_exist -ne 0){
        echo "file found! in $tensor_log_backup"
        remove_files $tensor_log_backup 
    }

    #copy files from tensor log directory to backup_log directory 
    copy_files $tensor_log $tensor_log_backup

    # remove previous month log files from tensor_log
    remove_files $tensor_log

    send_notification
}

main_activity