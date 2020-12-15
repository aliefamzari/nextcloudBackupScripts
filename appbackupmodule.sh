#!/bin/bash

## 		Module name: appbackupmodule.sh	
##		Author: Alif Amzari Mohd Azamee
##		Date: 2019-12-25
##		Dependencies: mainNcBackup.sh
##		Job retention: n/a
##		Job type: Manual
##		Version Control: Git
##################################################
fileName="nextcloud-appbkp"	
# Backing up Web App
echo "$(currentTime) $infostrA Creating backup of Nextcloud webapp directory..." | tee -a $logPath/ncbackup.log

if [ -w $backupAppDir ]; then
	echo "$(currentTime) $infostrA Tarballing ${nextcloudWebDir} to ${backupAppDir}" >> $logPath/ncbackup.log
	tar -zcpf "${backupAppDir}/${fileName}_${currentDate}.tar.gz" -C "${nextcloudWebDir}" . 
	echo "$(currentTime) $infostrA ${fileName}_${currentDate}.tar.gz created" | tee -a $logPath/ncbackup.log
	else
		echo "$(currentTime) ${errorStrA} Destination directory ${backupAppDir} inaccesible. Backup aborted" | tee -a $logPath/ncbackup.log
		echo "$(currentTime) ${infostrA} Restoring main services.." | tee -a $logPath/ncbackup.log
		StartwebSvcUnit
		DisableMaintenanceMode
		echo "$(currentTime) ${infostrA} See $logPath/ncbackup.log for more details"
                sendmail
		exit 1
fi

# Delete old backup if required
nrOfApBAckups=$(ls -l ${backupAppDir} | grep -c 'nextcloud-appbkp.*gz')
nAbackupToRemove=$(( ${nrOfApBAckups} - ${maxNrOfAppBackups} ))

echo "$(currentTime) $infostrA Checking number of backup(s) available..." >> $logPath/ncbackup.log

if [ ${maxNrOfAppBackups} != 0 ]; then	
	echo "$(currentTime) $infostrA Current no of backup(s) available ${nrOfApBAckups}" >> $logPath/ncbackup.log
	if [ ${nrOfApBAckups} -gt ${maxNrOfAppBackups} ]; then		
		echo "$(currentTime) $infostrA Max number of backup(s) is set to ${maxNrOfAppBackups}. Removing ${nAbackupToRemove} old backup(s)" >> $logPath/ncbackup.log		
		ls -t ${backupAppDir} | grep 'nextcloud-appbkp.*gz' | tail -$nAbackupToRemove |while read -r aBkpToRemove; do
			rm "${backupAppDir}/${aBkpToRemove}"
			echo "$(currentTime) $infostrA ${aBkpToRemove} - Remove" >> $logPath/ncbackup.log
			done
		else
			echo "$(currentTime) $infostrA Max number of backup(s) is set to ${maxNrOfAppBackups} to keep. 0 backup(s) removed" >> $logPath/ncbackup.log
	fi
	elif [ ${maxNrOfAppBackups} = 0 ]; then
		echo "$(currentTime) $infostrA Current no of backup(s) available ${nrOfApBAckups}" >> $logPath/ncbackup.log
		echo "$(currentTime) $infostrA Max number of backup(s) is set to \"Unlimited\". 0 backup(s) removed" >> $logPath/ncbackup.log
fi
echo "$(currentTime) $infostrA Nextcloud webapp backup completed" | tee -a $logPath/ncbackup.log
