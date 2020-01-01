FEATURES:
1. Disable/enable desire module to backup (database, application, user data)
2. Choose how many backups needed, independently for each module
3. Fully log for troubleshooting
4. Support nginx or apache web server
5. Support postgresql, mariadb or mysql database type
6. Auto rollback service in case of failure

USAGE:
1. Change variable settings in the main script mainNcBackup.sh to suit your needs and environment
2. Execute the main script

INSTALLATION:
1. git clone https://github.com/aliefamzari/nextcloudBackupScripts.git
2. cd nextcloudBackupScripts
3. chmod +x *.sh
4. Edit mainNcBackup.sh variables to your environment
5. Execute ./mainNcBackup.sh

or

1. wget https://github.com/aliefamzari/nextcloudBackupScripts/archive/master.zip
2. unzip master.zip
3. cd nextcloudBackupScripts
4. chmod +x *.sh
5. Edit mainNcBackup.sh variables to your environment
6. Execute ./mainNcBackup.Sh

**Note**
sudo need to be set to never ask password

NOT SUPPORTED:
1. External data backup

Issues:
Trap CTRLC INT is not working at the moment.  

*Feel free comment, use, distribute and modify. Code is not POSIX compliant.   

