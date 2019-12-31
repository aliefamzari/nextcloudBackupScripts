#!/bin/bash

## Full backup for Nextcloud. Work In progress.
##		Author: Alif Amzari Mohd Azamee
##		Date: 2019-12-25
##		Job retention: n/a
##		Job type: Manual
##		Version: 0.1
##		Version Control: Git
##		Modules: -
##			appbackupmodule.sh
##			dbbackupmodule.sh
##			userdatabackupmodule.sh
##			ncfunction.sh
##		Requirement: -
##			SystemD Unit: Apache2 or nginx
##			Database type: mariadb/mysql/postgresql
#######################################################################################################################

# TODO : Usage: "enable" or "disable" the module below. If "disable" is selected, the module will be skipped
applicationBackup="enable"	# enable/disable Application Backup		# appbackupmodule.sh
databaseBackup="enable"		# enable/disable Database Backup		# dbbackupmodule.sh
userDataBackup="disable"	# enable/disable UserData Backup		# userdatabackupmodule.sh

# TODO: Path Variables
modulePath="/opt/custom/scripts"					# This is where all the modules should be placed
logPath="/opt/log"									# Change to fit your environment

# TODO: appbackupmodule.sh variables
webSvcUnit="apache2"								# Usage "apache2" "apache" or "nginx". Change to fit your environment
nextcloudWebDir="/var/www/html/nextcloud"						# Change to fit your environment
backupAppDir="/opt/nextcloud/data/Backup/APP"		# Destination directory where backup will be saved. Change to fit your environment
fileNameApp="nextcloud-appbkp"						# DO NOT CHANGE!! Unless you know what your are doing, it will break maxNrofAppBackups
maxNrOfAppBackups=2 								# Specify how many of backups to keep. 0 means Unlimited backup.
webserverUser="www-data" 							# Change to fit your environment

# TODO: dbbackupmodule.sh variables
databaseType="mariadb"								# Usage "mariadb" "mysql" "postgresql". Change to fit your environment
backupDbDir="/opt/nextcloud/data/Backup/DATABASE"	# Destination directory where backup will be saved. Change to fit your environment
dbUserName="nextcloud"								# Change to fit your environment
dbPasswd="databasepassword"									# Change to fit your environment
dbName="nextclouddb"								# Change to fit your environment
fileNameDb="nextcloud-sqlbkp"						# DO NOT CHANGE!! Unless you know what your are doing, it will break maxNrofDbBackups
maxNrOfDbBackups=2									# Specify how many of backups to keep. 0 means Unlimited backup.

# TODO: userdatabackupmodule.sh variables
sourceUdDir="/opt/nextcloud/data"					# Change to fit your environment
backupUdDir="somedirectory/UD"						# Destination directory where backup will be saved. Change to fit your environment
filenameUd="nextcloud-udbkp"						# DO NOT CHANGE!! Unless you know what your are doing, it will break maxNrofUdBackups
maxNrOfUdBackups=1									# Specify how many of backups to keep. 0 means Unlimited backup.

#######################################################################################################################

# tput for color highlight
red=`tput setaf 1`
green=`tput setaf 2`
cyan=`tput setaf 6`
rst=`tput sgr0`

# Global and log variables
# currentTime=`date +"%Y%m%d %H:%M:%S"`
currentDate=`date +"%Y%m%d_%H%M"`
infoStrgM="[MAIN] [INFO]"
infostrA="[APP] [INFO]"
infoStrDb="[DB] [INFO]"
infoStrUd="[USERDATA] [INFO]"
infoStrF="[FUNCTION] [INFO]"
errorStrM="[MAIN] $red[ERROR]$rst"
errorStrA="[APP] $red[ERROR]$rst"
errorStrDb="[DB] $red[ERROR]$rst"
errorStrUd="[USERDATA] $red[ERROR]$rst"
errorStrF="[FUNCTION] $red[ERROR]$rst"

#######################################################################################################################

# Logpath validation
echo "$(date +"%Y%m%d %H:%M:%S") ${infoStrgM} Starting script mainNcBackup.sh"
sleep 1
echo "$(date +"%Y%m%d %H:%M:%S") ${infoStrgM} Validating $cyan$logPath$rst path for logging"
if [ -w ${logPath} ]; then
    echo "$(date +"%Y%m%d %H:%M:%S") ${infoStrgM} $cyan$logPath$rst validation success"
    else
        echo "$(date +"%Y%m%d %H:%M:%S") ${errorStrM} $cyan$logPath$rst validation failed. No write permission. Backup aborted"
        exit 1
fi
sleep 1

echo "$(date +"%Y%m%d %H:%M:%S") ${infoStrgM} Validating $cyan${modulePath}$rst path"


# Module validation
moduleList=(\
${modulePath}/appbackupmodule.sh \
${modulePath}/dbbackupmodule.sh \
${modulePath}/userdatabackupmodule.sh \
${modulePath}/ncfunction.sh)

for i in ${moduleList[@]}; do
    if [ -x $i ]; then
    echo "$(date +"%Y%m%d %H:%M:%S") ${infoStrgM} $cyan$i$rst ....$green[OK]$rst"
    else
        echo "$(date +"%Y%m%d %H:%M:%S") ${errorStrM} $cyan$i$rst ....$red[FAILED]$rst"
		echo "$(date +"%Y%m%d %H:%M:%S") ${infoStrgM} Please check your module path"
        exit 1
    fi
done


## Head of log file
echo "$(date +"%Y%m%d %H:%M:%S") ${infoStrgM} NC backup started..." | tee $logPath/ncbackup.log

# Load function
echo "$(date +"%Y%m%d %H:%M:%S") ${infoStrgM} Loading function ${cyan}ncfunction.sh$rst" >> $logPath/ncbackup.log
. ${modulePath}/ncfunction.sh  # Function disable/enable maintenance mode
echo "${currentTime} ${infoStrgM} Function loaded" >> $logPath/ncbackup.log
sleep 1

# Capture Ctrl+C from user in case of premature interruption
trap CtrlC INT

# Enabling maintenance mode
echo "${currentTime} ${infoStrgM} Attempting to enable maintenance mode" >> $logPath/ncbackup.log
EnableMaintenanceMode
sleep 1

# Stopping webSvcUnit service
echo "${currentTime} ${infoStrgM} Attempting to stop $webSvcUnit service" >> $logPath/ncbackup.log
StopwebSvcUnit
sleep 1

# Application Backup Module
echo "${currentTime} ${infoStrgM} Invoking App backup module" >> $logPath/ncbackup.log
if [ ${applicationBackup} = "disable" ]; then
    echo "${currentTime} ${infoStrgM} App backup module disabled. Omitting App backup procedure" >> $logPath/ncbackup.log
    elif [ ${applicationBackup} = "enable" ]; then
        . ${modulePath}/appbackupmodule.sh # Executing application backup module
fi
sleep 1

# Database Backup Module
echo "${currentTime} ${infoStrgM} Invoking Database backup module" >> $logPath/ncbackup.log
if [ ${databaseBackup} = "disable" ]; then
    echo "${currentTime} ${infoStrgM} Database backup module disabled. Omitting Database backup procedure" >> $logPath/ncbackup.log
    elif [ ${databaseBackup} = "enable" ]; then
        . /${modulePath}/dbbackupmodule.sh # Executing database backup module
fi
sleep 1

# User Data Backup Module
echo "${currentTime} ${infoStrgM} Invoking UserData backup module" >> $logPath/ncbackup.log
if [ ${userDataBackup} = "disable" ]; then
    echo "${currentTime} ${infoStrgM} Data backup disabled. Omitting User Data backup procedure" >> $logPath/ncbackup.log
    elif [ ${userDataBackup} = "enable" ]; then
        . ${modulePath}/userdatabackupmodule.sh # Executing User Data backup module
fi
sleep 1
echo "${currentTime} ${infoStrgM} NC Backup completed" | tee -a $logPath/ncbackup.log

# Restoring Services
echo "${currentTime} ${infoStrgM} Restoring main services.." | tee -a $logPath/ncbackup.log
StartwebSvcUnit
DisableMaintenanceMode
echo "${currentTime} ${infoStrgM} End of script execution" | tee -a $logPath/ncbackup.log
echo "${currentTime} ${infoStrgM} See $logPath/ncbackup.log for more details"

exit 0
## End of file
