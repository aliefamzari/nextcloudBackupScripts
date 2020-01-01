#!/bin/bash

##		Module name: userdatabackupmodule.sh
##		Author: Alif Amzari Mohd Azamee
##		Date: 2019-12-25
##		Dependencies: mainNcBackup.sh
##		Job retention: n/a
##		Job type: Manual
##		Version: 0.1
##		Version Control: Git
##################################################

# Backing up UserData
fileName="nextcloud-udbkp"


echo "$(currentTime) ${infoStrUd} Creating backup of Nextcloud Userdata..." | tee -a $logPath/ncbackup.log

if [ -w ${backupUdDir} ] || ; then 
	totalsize=`du -skh ${sourceUdDir} 2>/dev/null |awk '{print $1}'`
	echo "$(currentTime) ${infoStrUd} Total size of source directory is $totalsize. This will take awhile depending on the size..." | tee -a $logPath/ncbackup.log
	tar -cpzf "${backupUdDir}/${fileName}_${currentDate}.tar.gz" -C "${sourceUdDir}" .
	echo "$(currentTime) ${infoStrUd} ${fileName}_${currentDate}.tar.gz created" | tee -a $logPath/ncbackup.log
	else
		echo "$(currentTime) ${errorStrUd} No write permission to destination directory. Backup aborted" | tee -a $logPath/ncbackup.log
		echo "$(currentTime) ${errorStrUd} Restoring main services.." | tee -a $logPath/ncbackup.log
		StartwebSvcUnit
		DisableMaintenanceMode
		echo "$(currentTime) ${infoStrUd} See $logPath/ncbackup.log for more details"
    	exit 1
fi

# Delete old backup if required
nrOfUdBackups=$(ls -l ${backupUdDir} | grep -c 'nextcloud-udbkp.*gz')
nUdbkToRemove=$(( $nrOfUdBackups - $maxNrOfUdBackups ))

echo "$(currentTime) ${infoStrUd} Checking number of backups available..."  >> $logPath/ncbackup.log

if [ ${maxNrOfUdBackups} != 0 ]; then
	echo "$(currentTime) ${infoStrUd} Current number of backup available $nrOfUdBackups" >> $logPath/ncbackup.log
	if [ ${nrOfUdBackups} -gt ${maxNrOfUdBackups} ]; then		
		echo "$(currentTime) ${infoStrUd} Max number of backup(s) is set to ${maxNrOfUdBackups}. Removing ${nUdbkToRemove} old backup(s)" >> $logPath/ncbackup.log
		ls -t ${backupUdDir} | grep 'nextcloud-udbkp.*gz' | tail -$nUdbkToRemove |while read -r udFileToRemove; do
			rm "${backupUdDir}/${udFileToRemove}"
			echo "$(currentTime) ${infoStrUd} ${udFileToRemove} - Remove" >> $logPath/ncbackup.log
			done
		else
			echo "$(currentTime) ${infoStrUd} Max number of backups is set to ${maxNrOfUdBackups} to keep. 0 backup removed"
	fi
		elif [ ${maxNrOfUdBackups} = 0 ]; then
			echo "$(currentTime) ${infoStrUd} Current no of backups available ${nrOfUdBackups}" >> $logPath/ncbackup.log
			echo "$(currentTime) ${infoStrUd} Max number of backups is set to \"Unlimited\". 0 backup removed" >> $logPath/ncbackup.log
fi
echo "$(currentTime) ${infoStrUd} Nextcloud UserData backup completed" | tee -a $logPath/ncbackup.log
