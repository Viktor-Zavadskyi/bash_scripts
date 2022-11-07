#!/bin/bash
# Location to place backups.

backup_dir="/srv/files_backups/"
#String to append to the name of the backup files
backup_date=`date +%d-%m-%Y`
#Numbers of days you want to keep copie of your databasess
number_of_days=10

# postgres backup
#databases=`sudo  -u postgres psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`
databases=`psql -l -t | cut -d'|' -f1 | sed -e 's/ //g' -e '/^$/d'`
#for i in $databases; do  if [ "$i" != "postgres" ] && [ "$i" != "template0" ] && [ "$i" != "template1" ]; then
for i in $databases; do  if [ "$i" = "base_production" ]; then
    echo Dumping $i to $backup_dir$i\_$backup_date.dump
#    sudo  -u postgres pg_dump $i > $backup_dir$i\_$backup_date.dump
    pg_dump $i > $backup_dir$i\_$backup_date.dump
    tar --remove-files -cvzf $backup_dir$i\_$backup_date.tar.gz $backup_dir$i\_$backup_date.dump
fi
done

# бекапимо базу кейтерінга з докера:
docker exec -t 5255606c73d4 pg_dump -c -U base_catering_db_user base-katering_production > $backup_dir$i\_$backup_date.base-katering_production.dump

# архівуємо файли сайту:
/bin/tar -h -czf $backup_dir/$backup_date.base.tar.gz /home/deployer/apps/project/current
# картинки кейтерінга
/bin/tar -h -czf $backup_dir/$backup_date.project-catering.tar.gz /home/deployer/apps/catering/project-catering/storage


# архівуємо файли nginx:
/bin/tar -h -czf $backup_dir/$backup_date.nginx.tar.gz /etc/nginx

#delete old backups
find $backup_dir -type f -prune -mtime +$number_of_days -exec rm -f {} \;

# сінхронізуємо файли архівної директорії з віддаленим сховищем:
rsync --recursive --delete-after --progress -a /srv/files_backups deployer@111.111.111.111:project_family_backupsroot@vmiUser:/home/deployer#
