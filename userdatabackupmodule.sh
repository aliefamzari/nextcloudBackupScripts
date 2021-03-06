#!/bin/bash

##		Module name: userdatabackupmodule.sh
##		Author: Alif Amzari Mohd Azamee
##		Date: 2019-12-25
##		Dependencies: mainNcBackup.sh
##		Job retention: n/a
##		Job type: Manual
##		Version Control: Git
##################################################

# Backing up UserData
fileName="nextcloud-udbkp"
totalsize=`du -skh ${sourceUdDir} 2>/dev/null |awk '{print $1}'`

echo "$(currentTime) ${infoStrUd} Creating backup of Nextcloud Userdata..." | tee -a $logPath/ncbackup.log
if [ ! -w $backupUdDir ]; then
	echo "$(currentTime) ${errorStrUd} Destination directory ${backupUdDir} inaccessible. Backup aborted" | tee -a $logPath/ncbackup.log
	echo "$(currentTime) ${infoStrUd} Restoring main services.." | tee -a $logPath/ncbackup.log
	StartwebSvcUnit
	DisableMaintenanceMode
	echo "$(currentTime) ${infoStrUd} See $logPath/ncbackup.log for more details"
        sendmail
    exit 1
fi

case $backupType in 
	tarball)
		echo "backupType selected is $backupType" tee -a $logPath/ncbackup.log
		echo "$(currentTime) ${infoStrUd} Total size of source directory is $totalsize. This will take awhile depending on the size..." | tee -a $logPath/ncbackup.log
		tar -cpzf "${backupUdDir}/${fileName}_${currentDate}.tar.gz" -C "${sourceUdDir}" .
                tarerror=$(echo $?)
		echo "$(currentTime) ${infoStrUd} ${fileName}_${currentDate}.tar.gz created" | tee -a $logPath/ncbackup.log

		# Delete old backup if required
		nrOfUdBackups=$(ls -l ${backupUdDir} | grep -c 'nextcloud-udbkp.*gz')
		nUdbkToRemove=$(( $nrOfUdBackups - $maxNrOfUdBackups ))

		echo "$(currentTime) ${infoStrUd} Checking number of backup(s) available..."  >> $logPath/ncbackup.log

		if [ ${maxNrOfUdBackups} != 0 ]; then
		echo "$(currentTime) ${infoStrUd} Current number of backup(s) available $nrOfUdBackups" >> $logPath/ncbackup.log
		if [ ${nrOfUdBackups} -gt ${maxNrOfUdBackups} ]; then		
			echo "$(currentTime) ${infoStrUd} Max number of backup(s) is set to ${maxNrOfUdBackups}. Removing ${nUdbkToRemove} old backup(s)" >> $logPath/ncbackup.log
			ls -t ${backupUdDir} | grep 'nextcloud-udbkp.*gz' | tail -$nUdbkToRemove |while read -r udFileToRemove; do
				rm "${backupUdDir}/${udFileToRemove}"
                                rmerror=$(echo $?)
				echo "$(currentTime) ${infoStrUd} ${udFileToRemove} - Remove" >> $logPath/ncbackup.log
				done
			else
				echo "$(currentTime) ${infoStrUd} Max number of backup(s) is set to ${maxNrOfUdBackups} to keep. 0 backup(s) removed" >> $logPath/ncbackup.log
		fi
			elif [ ${maxNrOfUdBackups} = 0 ]; then
				echo "$(currentTime) ${infoStrUd} Current no of backup(s) available ${nrOfUdBackups}" >> $logPath/ncbackup.log
				echo "$(currentTime) ${infoStrUd} Max number of backup(s) is set to \"Unlimited\". 0 backup(s) removed" >> $logPath/ncbackup.log
		fi
		echo "$(currentTime) ${infoStrUd} Nextcloud UserData backup completed" | tee -a $logPath/ncbackup.log
	;;

	rsync)
		echo "$(currentTime) ${infoStrUd} backupType selected is $backupType"  | tee -a $logPath/ncbackup.log
		echo "$(currentTime) ${infoStrUd} Total size of source directory is $totalsize. This will take awhile depending on the size..." | tee -a $logPath/ncbackup.log
		if [ -x $(command -v rsync) ]; then
			echo "$(currentTime) ${infoStrUd} Rsyncing with options [-aq --no-o --no-g] from ${sourceUdDir} to ${backupUdDir}" >> $logPath/ncbackup.log
			rsync -aq --no-o --no-g ${sourceUdDir} ${backupUdDir} 2>> $logPath/ncbackup.log 
                        rsyncerror=$(echo $?)
			echo "Rsync complete" >> $logPath/ncbackup.log
			echo "$(currentTime) ${infoStrUd} Nextcloud UserData backup completed" | tee -a $logPath/ncbackup.log
			else
				echo "Command 'rsync' not found. Backup aborted" 
				echo "$(currentTime) ${infoStrUd} Restoring main services.." | tee -a $logPath/ncbackup.log
				StartwebSvcUnit
				DisableMaintenanceMode
				echo "$(currentTime) ${infoStrUd} See $logPath/ncbackup.log for more details"
                                sendmail
				exit 1
		fi
	;;
esac
outval=$((tarerror+rmerror+rsyncerror))
if [ $outval != 0 ]; then
        sendmail
fi


