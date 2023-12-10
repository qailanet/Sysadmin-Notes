#!/bin/bash
# Shell script to backup public_html & databases
# Original Created By ArieL FX - www.arielfx.com
# 
#
# This Script Managed To www.gemaroprek.com
#
# use empty file ".DONT_BACKUP" to exclude any directory
#
#ls -1 /var/www/ | sed 's/22222//g; s/html//g;' | sed '/^\s*$/d' > /root/userdir.txt
mysql -Bse 'show databases' | sed 's/information_schema//g; s/mysql//g; s/performance_schema//g' | sed '/^\s*$/d' > /root/listdb.txt 
##########################
# CONFIGURATION
##########################
DESTDIR="/backup"
date=$(date +"%d-%b-%Y")
WEBDIR="/var/www"
#NAMAWEB=$(cat /root/userdir.txt)
 
# EOF CONFIGURATION
 
cd ${WEBDIR}
TODAY=`date`
BU_FILE_COUNT=0
suffix=$(date +%m-%d-%Y)
printf "\n\n********************************************\n\tSite Backup r Log for:\n\t" | tee -a $LOGFILE
echo $TODAY | tee -a $LOGFILE
printf "********************************************\n" $TODAY | tee -a $LOGFILE
echo "see ${LOGFILE} for details"
 
for DIR in $(ls | grep ^[a-z.]*$) 
#for DIR in `cat /root/userdir.txt`
#for DIR in $(ls | grep ^[a-z.]*$ | sed 's/cache//g;' | sed 's/tmp//g;' | sed 's/backup//g;' | sed '/^\s*$/d');
do
	echo $DIR
	#tar the current directory
	if [ -f $DIR/.DONT_BACKUP ]
	then
 
		printf "\tSKIPPING $DIR as it contains ignore file\n" | tee -a $LOGFILE
 
	else
		cpath=${DESTDIR}/${DIR}
		#
		#check if we need to make path
		#
		if [ -d $cpath ]
		then
			# direcotry exists, we're good to continue
			filler="umin"
		else
			echo Creating $cpath
			mkdir -p $cpath
			echo $DEF_RETAIN > $cpath/.RETAIN_RULE
		fi
		#
 
		tar -zcf ${DESTDIR}/${DIR}/${DIR}_$suffix.tar.gz ./$DIR
		BU_FILE_COUNT=$(( $BU_FILE_COUNT + 1 ))
	fi
 
done
printf "\n\n********************************************\n" | tee -a $LOGFILE
echo $BU_FILE_COUNT sites were backed up
printf "********************************************\n" $TODAY | tee -a $LOGFILE



# Create backup www or public_html directory
#cat /root/userdir.txt  | while read line
#do
#tar cvzfP $DESTDIR/$userdir-homedir-$date.tar.gz /var/www/$userdir/htdocs/
#done

#create dir MYSQL
cd ${DESTDIR} && mkdir MYSQL

# Get list of databases
#databases=$(mysql --user=$user --password=$password -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)")

# Create dump daabases
echo "All Database Dumped!";
cat /root/listdb.txt | while read line
do
dbname=$line
if [ $line != "information_schema" ] ;
then
mysqldump $dbname > $DESTDIR/MYSQL/$dbname-$date.sql
fi
done

 
# upload your backup to destination server with rsync (don't forget to create public keys)
# rsync -avz -e 'ssh -p port' $DESTDIR/* user@host.or.ip:destinationfolder/ 


# upload your backup to destination server with ftp (ftp configuration)
#ftp_user=""
#ftp_password=""
#ftp_host=""


# upload to ftp server with ncftp
#ncftp -u "$ftp_user" -p "$ftp_password" $ftp_host <<EOF
#cd /
#rm -f $y_backup_file
#lcd $backup_folder
#put $t_backup_file
#quit
#EOF


# Delete files older than 60 days
#find $DESTDIR -mtime +60 -exec rm -f {} \;