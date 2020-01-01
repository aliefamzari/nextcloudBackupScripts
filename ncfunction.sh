#!/bin/bash

## 		Module name: ncfunction.sh
##		Author: Alif Amzari Mohd Azamee
##		Date: 2019-12-25
##		Dependencies: mainNcBackup.sh
##		Job retention: n/a
##		Job type: Manual
##		Version: 0.5
##		Version Control: Git
##################################

## OCC Function
function EnableMaintenanceMode() {
	echo "$(currentTime) ${infoStrF} Set maintenance mode for Nextcloud.."  >> $logPath/ncbackup.log
	sudo -u ${webserverUser} php ${nextcloudWebDir}/occ maintenance:mode --on 1> /dev/null
	echo "$(currentTime) ${infoStrF} Maintenance mode enabled"  | tee -a $logPath/ncbackup.log
}

function DisableMaintenanceMode() {
	echo "$(currentTime) ${infoStrF} Switching off maintenance mode.." >> $logPath/ncbackup.log
	sudo -u ${webserverUser} php ${nextcloudWebDir}/occ maintenance:mode --off 1> /dev/null
	echo "$(currentTime) ${infoStrF} Maintenance mode disabled" | tee -a $logPath/ncbackup.log
}


## webSvcUnit Function
function StopwebSvcUnit() {
	echo "$(currentTime) ${infoStrF} Stopping ${webSvcUnit} service" >> $logPath/ncbackup.log
	if sudo systemctl stop ${webSvcUnit}.service &> /dev/null; then
		sudo systemctl stop ${webSvcUnit}.service
		echo "$(currentTime) ${infoStrF} ${webSvcUnit} service stopped" | tee -a $logPath/ncbackup.log
		else
			echo "$(currentTime) ${errorStrF} ${webSvcUnit} service failed to stop. See journalctl for more details. Backup aborted" | tee -a $logPath/ncbackup.log
			echo "$(currentTime) ${infoStrF} [INFO] Restoring main services.."  | tee -a $logPath/ncbackup.log
			DisableMaintenanceMode
			echo "$(currentTime) $red[ERROR]$rst See $logPath/ncbackup.log for more details"
			exit 1
	fi
}

function StartwebSvcUnit() {
	echo "$(currentTime) ${infoStrF} Starting ${webSvcUnit} service" >> $logPath/ncbackup.log
	if sudo systemctl start ${webSvcUnit}.service &> /dev/null; then
		sudo systemctl start ${webSvcUnit}.service
		echo "$(currentTime) ${infoStrF} ${webSvcUnit} service started" | tee -a $logPath/ncbackup.log
		else
			echo "$(currentTime) ${errorStrF} ${webSvcUnit} service failed to start" | tee -a $logPath/ncbackup.log
			echo "$(currentTime) ${errorStrF} See journalctl for more details" | tee -a $logPath/ncbackup.log
	fi
}

## trapping Ctrl C from user
function CtrlC() {
	echo "$(currentTime) ${errorStrF} Interrupted by user. Backup aborted" | tee -a $logPath/ncbackup.log
	echo "$(currentTime) ${infoStrF} Restoring main services.." | tee -a $logPath/ncbackup.log
	DisableMaintenanceMode
	StartwebSvcUnit
	echo "$(currentTime) ${infoStrF} See $logPath/ncbackup.log for more details"
	exit 0
}