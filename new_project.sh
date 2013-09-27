#!/bin/bash
part_dir=/var/www/partners
makes_dir=/home/ideath/makes
def_make=awd_default.make
gitignore=/home/ideath/drupal/.gitignore
git_repos=/home/git/repositories
if [ ${#} -eq 0 ]; then
	echo Input PARTNER, PROJECT, MAKEFILE
	exit 1
fi

if [ ! -d "${part_dir}/${1}" ]; then
	echo Partner doesn\'t exists. Please create directory for him.
	exit 1
fi

echo Partner: ${1}

if [ -d "${part_dir}/${1}/${1}_${2}" ]; then
	echo This project has been created. Nothing to do...
	exit 1
fi

echo Project: ${2}

if [ -z "${3}" ]; then
	if [ -f "${makes_dir}/${3}" ]; then
		def_make="${3}"
		echo Using Make: ${def_make}
	fi 
fi 

echo Using Make: ${def_make}
echo Creating dirs...
mkdir ${part_dir}/${1}/${1}_${2}
proj_dir=${part_dir}/${1}/${1}_${2}
#mkdir ${proj_dir}/repository
mkdir ${proj_dir}/backups
mkdir ${proj_dir}/develop
mkdir ${proj_dir}/scripts
mkdir ${proj_dir}/temp
mkdir ${proj_dir}/logs
touch ${proj_dir}/logs/error.log
cd ${proj_dir}/develop
echo In Develop
echo Installing drupal
#drush dl --drupal-project-rename=develop -y
cp ${makes_dir}/${def_make} ./
drush make ${def_make} -y #-v
drush cc all
drush site-install minimal --db-url=mysql://${1}:${1}dbpass@localhost/${1}_${2} --account-pass=testpass -y
echo "drush si minimal --db-url=mysql://${1}:${1}dbpass/${1}_${2} -y"

cp -f ${gitignore} ./
git init
git branch develop
git add .
git commit -a -m "Init"

mv .git ../repository
echo Moving ./.git to ../repository
cd ..
echo Creating simlink ${git_repos}/${1}_${2}.git on ${proj_dir}/repository
ln -s ${proj_dir}/repository ${git_repos}/${1}_${2}.git
echo Setting permisions to ${proj_dir}/repository 
chown -R git ${proj_dir}/repository
chgrp -R git ${proj_dir}/repository

echo Crating Vhost
touch vhost.conf
echo "
<VirtualHost *:80>
        #ServerAdmin webmaster@localhost
	ServerName ${2}.dev${1}.altwd.com
        DocumentRoot ${proj_dir}/develop/
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory ${proj_dir}/develop/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

        #ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        #<Directory /usr/lib/cgi-bin>
        #        AllowOverride None
        #        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        #        Order allow,deny
        #        Allow from all
        #</Directory>

        ErrorLog ${proj_dir}/logs/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel debug

        CustomLog ${proj_dir}/logs/access.log combined
</VirtualHost>
" > vhost.conf
echo In project folder

ln -s ${proj_dir}/vhost.conf /etc/apache2/sites-enabled/${1}_${2}

echo Server restarting
service apache2 restart
service mysql reload

echo Create config file
touch ${proj_dir}/scripts/config.sh
echo "!#/bin/bash
PROJECT_DIR=${proj_dir}
PROJECT_NAME=${2}
PARTNER=${1}
ENVIRONMENTS=( develop )
#end" > ${proj_dir}/scripts/config.sh

echo Project has been created successfully
