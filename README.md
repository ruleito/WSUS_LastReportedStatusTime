Documentation for WSUS Cleanup PowerShell Script

This PowerShell script is designed to perform a cleanup of the WSUS server by detecting the last reported status time of the connected computers. The script will then attempt to execute a command on each computer to initiate a check for updates. If the command fails, an email will be sent to the IT support team with a list of the failed computers.

Variables

The script uses several variables to configure the email settings and server hostname. These variables must be changed to match the specific environment where the script will be run.

* $From - The email address that will be used as the sender of the email notifications.
* $To - The email address(es) that will receive the email notifications.
* $Subject - The subject line of the email notifications.
* $SMTPServer - The hostname or IP address of the SMTP server used to send the email notifications.
* $SMTPPort - The port number of the SMTP server used to send the email notifications.
* $encoding - The encoding format used for the email notifications.
* $logFile - The location of the log file where the script output is stored.

Execution

The script begins by retrieving a list of all computers that have not reported their status to the WSUS server in the last 2 hours. The list is then split into two separate tables for servers and workstations. The function Test-Array is called to execute a command on each computer and check for connectivity. If the command fails, the computer is added to a list of failed hosts.

If there are any failed servers, an email notification is sent to the IT support team. If there are any failed workstations, a separate email notification is sent to the IT support team.

The script can be scheduled to run automatically using the Windows Task Scheduler or other scheduling software.

Languages

This documentation is provided in English and Russian.

Документация для PowerShell-скрипта очистки WSUS

Этот PowerShell-скрипт предназначен для очистки сервера WSUS путем определения времени последнего отчета о состоянии подключенных компьютеров. Затем скрипт попытается выполнить команду на каждом компьютере, чтобы инициировать проверку обновлений. Если команда не выполнится, электронное письмо будет отправлено в службу поддержки IT с перечислением отказавших компьютеров.

Переменные

Для настройки параметров отправки электронной почты и имени хоста скрипт использует несколько переменных. Эти переменные должны быть изменены, чтобы соответствовать конкретной среде, где будет выполняться скрипт.

* $From - адрес электронной почты, который будет использоваться в качестве отправителя уведомлений электронной почты.
* $To - адрес(а) электронной почты, на который будут отправляться уведомления электронной почты.
* $Subject - тема уведомлений электронной почты.
* $SMTPServer - имя хоста или IP-адрес SMTP-сервера, используемого для отправки уведомлений электронной почты.
* $SMTPPort - номер порта SMTP-сервера, используемого для отправки уведомлений электронной почты.
* $encoding - формат кодировки, используемый для уведомлений электронной почты.
* $logFile - местоположение файла журнала, где хранится вывод скрипта.

Выполнение

Скрипт начинается с получения списка всех компьютеров, которые не отправляли свое состояние на сервер WSUS в течение последних 2 часов. Затем список разделяется на две отдельные таблицы для серверов и рабочих станций. Вызывается функция Test-Array для выполнения команды на каждом компьютере и проверки подключения. Если команда не выполнена, компьютер добавляется в список отказавших хостов.

Если есть отказавшие серверы, в службу поддержки IT отправляется уведомление электронной почты. Если есть отказавшие рабочие станции,отдельное уведомление электронной почты отправляется в службу поддержки IT.

Скрипт может быть запланирован для автоматического выполнения с помощью Планировщика задач Windows или другого программного обеспечения для планирования.

Языки

Эта документация предоставляется на английском и русском языках.
