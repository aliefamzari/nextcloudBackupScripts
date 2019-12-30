#!/bin/bash

######   Module for mainNcBackup.sh       #####
## 		Module name: userdatabackupmodule.sh    ##
##      Author: Alif Amzari Mohd Azamee         ##
##		Date: 2019-12-25 				        ##
##		Job retention: n/a				        ##
##		Job type: Manual				        ##
##		Version: 0.1					        ##
##		Version Control: notGit			        ##
##################################################

# Backing up UserData
echo "${currentTime} ${infoStrUd} Creating backup of Nextcloud Userdata..." >> $logPath/ncbackup.log

if [ -w ${backupUdDir} ]; then 
    tar -cpzf "${sourceUdDir}/${filenameUd}_${currentDate}.tar.gz" -C "${backupUdDir}" .
    echo "${currentTime} ${infoStrUd} Nextcloud Userdata backup completed" >> $logPath/ncbackup.log
    else
    	echo "${currentTime} ${errorStrUd} Destination directory ${backupUdDir} inaccesible. Backup aborted" | tee -a $logPath/ncbackup.log
    	echo "${currentTime} ${errorStrUd} See $logPath/ncbackup.log for more details"
    	exit 1
fi

# Delete old backup if required
nrOfUdBackups=$(ls -l ${backupUdDir} | grep -c 'nextcloud-udbkp.*gz')
nUdbkToRemove=$(( $nrOfUdBackups - $maxNrOfUdBackups ))

echo "${currentTime} ${errorStrUd} Checking number of backups available..."  >> $logPath/ncbackup.log

if [ ${maxNrOfUdBackups} != 0 ]; then
	echo "${currentTime} ${infoStrUd} Current number of backup available $nrOfUdBackups" >> $logPath/ncbackup.log
	if [ ${nrOfUdBackups} -gt ${maxNrOfUdBackups} ]; then		
		echo "${currentTime} ${infoStrUd} Max number of backup(s) is set to ${maxNrOfUdBackups}. Removing ${nUdbkToRemove} old backup(s)" >> $logPath/ncbackup.log
		ls -t ${backupUdDir} | grep 'nextcloud-udbkp.*gz' | tail -$nUdbkToRemove |while read -r udFileToRemove; do
			rm "${backupUdDir}/${udFileToRemove}"
			echo "${currentTime} ${infoStrUd} ${udFileToRemove} - Remove" >> $logPath/ncbackup.log
			done
		else
			echo "Max number of backups is set to ${maxNrOfUdBackups} to keep. 0 backup removed"
	fi
		elif [ ${maxNrOfUdBackups} = 0 ]; then
			echo "${currentTime} ${infoStrUd} Current no of backups available ${nrOfUdBackups}" >> $logPath/ncbackup.log
			echo "${currentTime} ${infoStrUd} Max number of backups is set to \"Unlimited\". 0 backup removed" >> $logPath/ncbackup.log
fi
echo "${currentTime} ${infoStrUd} Nextcloud UserData backup completed" >> $logPath/ncbackup.log
