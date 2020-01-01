#!/bin/bash

##		Module name: dbbackupmodule.sh	
##		Author: Alif Amzari Mohd Azamee 
##		Date: 2019-12-25
##		Dependencies: mainNcBackup.sh 		
##		Job retention: n/a	
##		Job type: Manual	
##		Version: 0.1				
##		Version Control: Git			 
##################################################
fileName="nextcloud-sqlbkp"
# Directory write permission check
if [ ! -x $backupDbDir ]; then
	echo "$(currentTime) ${errorStrDb} No write permission to destination directory. Backup aborted" | tee -a $logPath/ncbackup.log
	echo "$(currentTime) ${infoStrDb} Restoring main services.." | tee -a $logPath/ncbackup.log
	StartwebSvcUnit
	DisableMaintenanceMode
	echo "$(currentTime) ${infoStrDb} See $logPath/ncbackup.log for more details"
	exit 1
fi

# Case for mysql, mariadb or postgresql
case ${databaseType} in
	mysql|mariadb) 
	echo "$(currentTime) ${infoStrDb} Database type is ${databaseType}" >> $logPath/ncbackup.log
		mysql --user=$dbUserName --password=$dbPasswd -e exit 2>> $logPath/ncbackup.log
		dpasswdStat=$(echo $?)	
		if [ $dpasswdStat != 0 ]; then
			echo "$(currentTime) $errorStrDb Your dbpassword or dbusername is incorrect. Backup aborted" | tee -a $logPath/ncbackup.log 
			echo "$(currentTime) ${infoStrDb} Restoring main services.." | tee -a $logPath/ncbackup.log
			StartwebSvcUnit
			DisableMaintenanceMode
			echo "$(currentTime) ${infoStrDb} See $logPath/ncbackup.log for more details"
			exit 1
		fi
			if [ ! -x "$(command -v mysqldump)" ]; then
				echo "$(currentTime) ${errorStrDb} Command 'mysqldump' not found. Backup aborted" | tee -a $logPath/ncbackup.log
				echo "$(currentTime) ${infoStrDb} Restoring main services.." | tee -a $logPath/ncbackup.log
				StartwebSvcUnit
				DisableMaintenanceMode
				echo "$(currentTime) ${infoStrDb} See $logPath/ncbackup.log for more details"
				exit 1
				else
					echo "$(currentTime) ${infoStrDb} mysqldump database ${dbName} to ${backupDbDir}" >> $logPath/ncbackup.log
					mysqldump --single-transaction -h localhost -u ${dbUserName} -p${dbPasswd} ${dbName} > ${backupDbDir}/${fileName}_${currentDate}.sql #> >(tee -a $logPath/ncbackup.log) 2> >(tee -a $logPath/ncbackup.log >&2)
					echo "$(currentTime) ${infoStrDb} ${fileName}_${currentDate}.sql created." >> $logPath/ncbackup.log
			fi
	;;
	postgresql) 
	echo "$(currentTime) ${infoStrDb} Database type is ${databaseType}" >> $logPath/ncbackup.log
		if [ ! -x "$(command -v pg_dump)" ]; then
			echo "$(currentTime) ${errorStrDb} Command 'pg_dump' not found. Backup aborted" | tee -a $logPath/ncbackup.log
			echo "$(currentTime) ${errorStrDb} Restoring main services.." | tee -a $logPath/ncbackup.log
			StartwebSvcUnit
			DisableMaintenanceMode
			echo "$(currentTime) ${infoStrDb} See $logPath/ncbackup.log for more details"
			exit 1
			else
				echo "$(currentTime) ${infoStrDb} pg_dump database ${dbName} to this directory ${backupDbDir}" >> $logPath/ncbackup.log
				PGPASSWORD=${dbPasswd} pg_dump ${dbName} -h localhost -U ${dbUserName} -f ${backupDbDir}/${fileName}_${currentDate}.sql #> >(tee -a $logPath/ncbackup.log) 2> >(tee -a $logPath/ncbackup.log >&2)
				echo "$(currentTime) ${infoStrDb} ${fileName}_${currentDate}.sql created." >> $logPath/ncbackup.log
		fi
	;;
	*) 
	echo "$(currentTime) ${errorStrDb} Something not quite right. Check databaseType \"${databaseType}\" in main script. Backup aborted" | tee -a $logPath/ncbackup.log
	echo "$(currentTime) ${infoStrDb} Restoring main services.." | tee -a $logPath/ncbackup.log
	StartwebSvcUnit
	DisableMaintenanceMode
	echo "$(currentTime) ${infoStrDb} See $logPath/ncbackup.log for more details" | tee -a $logPath/ncbackup.log
	exit 1
	;;
esac		


# Delete old backup if required
nrOfDbBackups=$(ls -l ${backupDbDir} | grep -c 'nextcloud-sqlbkp.*sql')
nDbBkToRemove=$(( ${nrOfDbBackups} - ${maxNrOfDbBackups} ))

echo "$(currentTime) ${infoStrDb} Checking number of backups available..."  >> $logPath/ncbackup.log

if [ ${maxNrOfDbBackups} != 0 ]; then	
	echo "$(currentTime) ${infoStrDb} Current number of backup available $nrOfDbBackups" >> $logPath/ncbackup.log
		if [ ${nrOfDbBackups} -gt ${maxNrOfDbBackups} ]; then		
			echo "$(currentTime) ${infoStrDb} Max number of backups is set to $maxNrOfDbBackups. Removing $nDbBkToRemove old backups" >> $logPath/ncbackup.log
			ls -t ${backupDbDir} | grep 'nextcloud-sqlbkp.*sql' | tail -$nDbBkToRemove |while read -r dbBkToRemove; do
				rm "${backupDbDir}/${dbBkToRemove}"
				echo "$(currentTime) ${infoStrDb} ${dbBkToRemove} - Remove" >> $logPath/ncbackup.log
				done
			else
				echo "$(currentTime) ${infoStrDb} Max number of backups is set to ${maxNrOfDbBackups} to keep. 0 backup removed" >> $logPath/ncbackup.log
		fi
	elif [ ${maxNrOfDbBackups} = 0]; then
		echo "$(currentTime) ${infoStrDb} Current no of backups available ${nrOfDbBackups}" >> $logPath/ncbackup.log
		echo "$(currentTime) ${infoStrDb} Max number of backups is set to \"Unlimited\". 0 backup removed" >> $logPath/ncbackup.log
fi
echo "$(currentTime) ${infoStrDb} Nextcloud Database backup completed" | tee -a $logPath/ncbackup.log

