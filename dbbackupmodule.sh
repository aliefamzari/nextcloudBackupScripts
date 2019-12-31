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
# Directory write permission check
if [ ! -x $backupDbDir ]; then
	echo "${currentTime} ${errorStrdb} No write permission to destination directory. Backup aborted" | tee -a $logPath/ncbackup.log
	echo "${currentTime} ${infoStrDb} Restoring main services.." | tee -a $logPath/ncbackup.log
	DisableMaintenanceMode
	StartwebSvcUnit
	echo "${currentTime} ${infoStrDb} See $logPath/ncbackup.log for more details"
	exit 1
fi

# Backing up mysql or mariadb
if [ ${databaseType} = "mariadb" ] || [ ${databaseType} = "mysql" ]; then
	echo "${currentTime} ${infoStrDb} Database type is $databaseType" >> $logPath/ncbackup.log
		if [ ! -x "$(command -v mysqldump)" ]; then
			echo "${currentTime} ${errorStrdb} Command 'mysqldump' not found. Backup aborted" | tee -a $logPath/ncbackup.log
			echo "${currentTime} ${infoStrDb} Restoring main services.." | tee -a $logPath/ncbackup.log
			DisableMaintenanceMode
			StartwebSvcUnit
			echo "${currentTime} ${infoStrDb} See $logPath/ncbackup.log for more details"
			exit 1
			else
				echo "${currentTime} ${infoStrDb} Backing up Database named ${dbName} to this directory ${backupDbDir}" >> $logPath/ncbackup.log
				mysqldump --single-transaction -h localhost -u ${dbUserName} -p${dbPasswd} ${dbName} > ${backupDbDir}/${fileNameDb}_${currentDate}.sql
				echo "${currentTime} ${infoStrDb} Backup ${fileNameDb}_${currentDate}.sql created." >> $logPath/ncbackup.log
		fi
		

# Backing up postgresql
	elif [ ${databaseType} = "postgresql" ]; then
		echo "${currentTime} ${infoStrDb} Database type is $databaseType" >> $logPath/ncbackup.log
			if [ ! -x $(command -v pg_dump) ]; then
				echo "${currentTime} ${errorStrdb} Command 'pg_dump' not found. Backup aborted" | tee -a $logPath/ncbackup.log
				echo "${currentTime} ${errorStrdb} Restoring main services.." | tee -a $logPath/ncbackup.log
				DisableMaintenanceMode
				StartwebSvcUnit
				echo "${currentTime} ${infoStrDb} See $logPath/ncbackup.log for more details"
				exit 1
				else
					echo "${currentTime} ${infoStrDb} Backing up Database named ${dbName} to this directory ${backupDbDir}" >> $logPath/ncbackup.log
					PGPASSWORD=${dbPasswd} pg_dump ${dbName} -h localhost -U ${dbUserName} -f ${{backupDbDir}}/${fileNameDb}_${currentDate}.sql
					echo "${currentTime} ${infoStrDb} Backup ${fileNameDb}_${currentDate}.sql created." >> $logPath/ncbackup.log
		 	fi
fi				


# Delete old backup if required
nrOfDbBackups=$(ls -l ${{backupDbDir}} | grep -c 'nextcloud-sqlbkp.*sql')
nDbBkToRemove=$(( ${nrOfDbBackups} - ${maxNrOfDbBackups} ))

echo "${currentTime} ${infoStrDb} Checking number of backups available..."  >> $logPath/ncbackup.log

if [ ${maxNrOfDbBackups} != 0 ]; then	
	echo "${currentTime} ${infoStrDb} Current number of backup available $nrOfDbBackups" >> $logPath/ncbackup.log
		if [ ${nrOfDbBackups} -gt ${maxNrOfDbBackups} ]; then		
			echo "${currentTime} ${infoStrDb} Max number of backups is set to $maxNrOfDbBackups. Removing $nDbBkToRemove old backups" >> $logPath/ncbackup.log
			ls -t ${{backupDbDir}} | grep 'nextcloud-sqlbkp.*sql' | tail -$nDbBkToRemove |while read -r dbBkToRemove; do
				rm "${{backupDbDir}}/${dbBkToRemove}"
				echo "${currentTime} ${infoStrDb} ${dbBkToRemove} - Remove" >> $logPath/ncbackup.log
				done
			else
				echo "${currentTime} ${infoStrDb} Max number of backups is set to ${maxNrOfDbBackups} to keep. 0 backup removed" >> $logPath/ncbackup.log
		fi
	elif [ ${maxNrOfDbBackups} = 0]; then
		echo "${currentTime} ${infoStrDb} Current no of backups available ${nrOfDbBackups}" >> $logPath/ncbackup.log
		echo "${currentTime} ${infoStrDb} Max number of backups is set to \"Unlimited\". 0 backup removed" >> $logPath/ncbackup.log
fi
echo "${currentTime} ${infoStrDb} Nextcloud Database backup completed" >> $logPath/ncbackup.log

