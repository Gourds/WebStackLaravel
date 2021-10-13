#!/bin/sh

cd ${INSTALL_DIR}
sed -i -e "s/DB_HOST=.*/DB_HOST=${DB_HOST}/; \
            s/DB_PORT=.*/DB_PORT=${DB_PORT}/; \
            s/APP_URL=.*/APP_URL=/;
            s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/; \
            s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/; \
            s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env
sed -i "/login-captcha/{n;s/'enable.*/'enable' => ${LOGIN_COPTCHA}/}"  config/admin.php


##php artisan key:generate
if [ $1 == 'server' ];then
   grep -qxF APP_STATE=active .env
   if [ $? -eq 0 ]; then
       php artisan serve --host=0.0.0.0 --port=8000
       exit
   php artisan key:generate
   result=1
   while [ $result -ne 0 ];do
       php artisan migrate:refresh --seed
       result=$?
       sleep 3
   done
   grep -qxF APP_STATE= .env || sed -i "s/APP_STATE=.*/APP_STATE=active/" .env
   php artisan serve --host=0.0.0.0 --port=8000
elif [ $1 == 'regresh' ];then
   php artisan migrate:refresh --seed
elif [ $1 == 'generate' ];then
   php artisan key:generate
fi
