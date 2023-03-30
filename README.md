PowerShell WSUS_LastReportedStatusTime Script
This PowerShell script is designed to perform cleanup actions on a WSUS (Windows Server Update Services) server. It does the following:

Gets a list of computers from WSUS that have not reported their status in the last hour and have a valid OS description
Separates the list into two hash tables, one for servers and one for workstations
Defines a function called Test-Array that takes a hash table as a parameter and attempts to ping each computer in the hash table and then execute a command on each reachable computer to start a Windows update scan. It logs the output of the command to a file and adds any failed hosts to an array.
Calls the Test-Array function on the hash tables and adds any failed hosts to the main array.
Builds an email body with a list of failed hosts and sends an email if there are any failed hosts.
To use this script, modify the following variables at the beginning of the script to fit your environment:

$logFile: the path to the log file that will be created to store command output
$From: the email address that the email will be sent from
$To: the email address that the email will be sent to
$Subject: the subject line of the email
$SMTPServer: the SMTP server that will be used to send the email
Save the script to a file with a .ps1 extension and run it from a PowerShell console or schedule it to run on a regular basis using Windows Task Scheduler.

Note: This script requires that the WSUS PowerShell module is installed on the system running the script. If the module is not already installed, it can be installed by running the following command in a PowerShell console with administrative privileges: Install-WindowsUpdate.
