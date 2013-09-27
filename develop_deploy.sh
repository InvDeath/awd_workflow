#!/bin/bash
. "config.sh"
git --git-dir=${PROJECT_DIR}/repository archive --format=tar.gz develop > ${PROJECT_DIR}/temp/develop.tar.gz

tar -xzvf ${PROJECT_DIR}/temp/develop.tar.gz --directory=${PROJECT_DIR}/develop/

drush --root=${PROJECT_DIR}/develop/ cc all
## from github
path=${PROJECT_DIR}/develop
user=ideath
group="www-data"
 
if [ -z "${path}" ] || [ ! -d "${path}/sites" ] || [ ! -f "${path}/modules/system/system.module" ]; then
	echo "Please provide a valid drupal path"
	echo -e $help
	exit
fi
 
if [ -z "${user}" ] || [ "`id -un ${user} 2> /dev/null`" != "${user}" ]; then
	echo "Please provide a valid user"
	echo -e $help
	exit
fi
 
cd $path;
 
echo -e "Changing ownership of all contents of "${path}" :n user => "${user}" t group => "${group}"n"
#chown -R ${user}:${group} .
echo "Changing permissions of all directories inside "${path}" to "750"..."
find . -type d -exec chmod u=rwx,g=rx,o= {} ;
echo -e "Changing permissions of all files inside "${path}" to "640"...n"
find . -type f -exec chmod u=rw,g=r,o= {} ;
 
cd $path/sites;
 
echo "Changing permissions of "files" directories in "${path}/sites" to "770"..."
find . -type d -name files -exec chmod ug=rwx,o= '{}' ;
#echo "Changing permissions of all files inside all "files" directories in "${path}/sites" to "660"..."
#find . -name files -type d -exec find '{}' -type f ; | while read FILE; do chmod ug=rw,o= "$FILE"; done
#echo "Changing permissions of all directories inside all "files" directories in "${path}/sites" to "770"..."
#find . -name files -type d -exec find '{}' -type d ; | while read DIR; do chmod ug=rwx,o= "$DIR"; done
## end lib

rm ${PROJECT_DIR}/temp/develop.tar.gz
