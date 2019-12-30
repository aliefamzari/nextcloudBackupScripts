#!/bin/bash

##	Module for mainNcBackup.sh
## 		Module name: appbackupmodule.sh	
##		Author: Alif Amzari Mohd Azamee
##		Date: 2019-12-25
##		Job retention: n/a
##		Job type: Manual
##		Version: 0.1
##		Version Control: Git
##################################################

# Backing up Web App
echo "${currentTime} ${infoStrA} Creating backup of Nextcloud webapp directory..." >> $logPath/ncbackup.log

if [ -w $backupAppDir ]; then
	tar -zcpf "${backupAppDir}/${fileNameApp}_$currentDate.tar.gz" -C "${nextcloudWebDir}" . 
	echo "${currentTime} ${infoStrA} Webapp directory backup completed." >> $logPath/ncbackup.log
	echo "${currentTime} ${infoStrA} ${fileNameApp}_$currentDate.tar.gz created." >> $logPath/ncbackup.log
	else
		echo "${currentTime} ${errorStrA} Destination directory ${backupAppDir} inaccesible. Backup aborted" | tee -a $logPath/ncbackup.log
		echo "${currentTime} ${errorStrA} Restoring main services.." | tee -a $logPath/ncbackup.log
		DisableMaintenanceMode
		StartwebSvcUnit
		echo "${currentTime} ${errorStrA} See $logPath/ncbackup.log for more details"
		exit 1
fi

# Delete old backup if required
nrOfApBAckups=$(ls -l ${backupAppDir} | grep -c 'nextcloud-appbkp.*gz')
nAbackupToRemove=$(( ${nrOfApBAckups} - ${maxNrOfAppBackups} ))

echo "${currentTime} ${infoStrA} Checking number of backups available..."  >> $logPath/ncbackup.log

if [ ${maxNrOfAppBackups} != 0 ]; then	
	echo "${currentTime} ${infoStrA} Current no of backups available ${nrOfApBAckups}"   >> $logPath/ncbackup.log
	if [ ${nrOfApBAckups} -gt ${maxNrOfAppBackups} ]; then		
		echo "${currentTime} ${infoStrA} Max number of backup(s) is set to ${maxNrOfAppBackups}. Removing ${nAbackupToRemove} old backup(s)" >> $logPath/ncbackup.log		
		ls -t ${backupAppDir} | grep 'nextcloud-appbkp.*gz' | tail -$nAbackupToRemove |while read -r aBkpToRemove; do
			rm "${backupAppDir}/${aBkpToRemove}"
			echo "${currentTime} ${infoStrA} ${aBkpToRemove} - Remove" >> $logPath/ncbackup.log
			done
		else
			echo "${currentTime} ${infoStrA} Max number of backups is set to ${maxNrOfAppBackups} to keep. 0 backup removed" >> $logPath/ncbackup.log
	fi
	elif [ ${maxNrOfAppBackups} = 0 ]; then
		echo "${currentTime} ${infoStrA} Current no of backups available ${nrOfApBAckups}" >> $logPath/ncbackup.log
		echo "${currentTime} ${infoStrA} Max number of backups is set to \"Unlimited\". 0 backup removed" >> $logPath/ncbackup.log
fi
echo "${currentTime} ${infoStrA} Nextcloud webapp backup completed" >> $logPath/ncbackup.log
