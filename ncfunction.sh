#!/bin/bash

## 		Module name: ncfunction.sh
##		Author: Alif Amzari Mohd Azamee
##		Date: 2019-12-25
##		Dependencies: mainNcBackup.sh
##		Job retention: n/a
##		Job type: Manual
##		Version: 0.1
##		Version Control: Git
##################################

## OCC Function
function EnableMaintenanceMode() {
	echo "${currentTime} ${infoStrF} Set maintenance mode for Nextcloud.."  >> $logPath/ncbackup.log
	sudo -u ${webserverUser} php ${nextcloudWebDir}/occ maintenance:mode --on
	echo "${currentTime} ${infoStrF} Maintenance mode enabled"  >> $logPath/ncbackup.log
	echo
	}

function DisableMaintenanceMode() {
	echo "${currentTime} ${infoStrF} Switching off maintenance mode.." >> $logPath/ncbackup.log
	sudo -u ${webserverUser} php ${nextcloudWebDir}/occ maintenance:mode --off
	echo "${currentTime} ${infoStrF} Maintenance mode disabled" >> $logPath/ncbackup.log
	}


## webSvcUnit Function
function StopwebSvcUnit() {
	echo "${currentTime} ${infoStrF} Stopping ${webSvcUnit} service" >> $logPath/ncbackup.log
	if sudo systemctl stop ${webSvcUnit}.service &> /dev/null; then
		sudo systemctl stop ${webSvcUnit}.service
		echo "${currentTime} ${infoStrF} ${webSvcUnit} service stopped" >> $logPath/ncbackup.log
		else
			echo "${currentTime} ${errorStrF} ${webSvcUnit} service failed to stop. See journalctl for more details" | tee -a $logPath/ncbackup.log
			echo "${currentTime} ${infoStrF} [INFO] Restoring main services.."  | tee -a $logPath/ncbackup.log
			DisableMaintenanceMode
			echo "${currentTime} ${errorStrF} NC backup aborted" | tee -a $logPath/ncbackup.log
			echo "${currentTime} $red[ERROR]$rst See $logPath/ncbackup.log for more details"
			exit 1
	fi
	}

function StartwebSvcUnit() {
	echo "${currentTime} ${infoStrF} Starting ${webSvcUnit} service" >> $logPath/ncbackup.log
	if sudo systemctl start ${webSvcUnit}.service &> /dev/null; then
		sudo systemctl start ${webSvcUnit}.service
		echo "${currentTime} ${infoStrF} ${webSvcUnit} service Started" >> $logPath/ncbackup.log
		else
			echo "${currentTime} ${errorStrF} ${webSvcUnit} service failed to start" | tee -a $logPath/ncbackup.log
			echo "${currentTime} ${errorStrF} See journalctl for more details" | tee -a $logPath/ncbackup.log
	fi
	}

## trapping Ctrl C from user
function CtrlC() {
	read -p "Backup interupted by user. Disable maintenance mode? [y/n] " -n 1 -r
	echo
	if [[ $yesNo =~ ^[Yy]$ ]]; then
		DisableMaintenanceMode
		echo "${currentTime} ${errorStrF} Interrupted by user. Backup aborted" | tee -a $logPath/ncbackup.log
		echo "${currentTime} $red[ERROR]$rst See $logPath/ncbackup.log for more details"
		else
			echo "${currentTime} Warning. Maintenance mode still enabled." tee -a $logPath/ncbackup.log
			echo "${currentTime} $red[ERROR]$rst See $logPath/ncbackup.log for more details"
	fi
	exit 1
}