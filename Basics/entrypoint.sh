#!/bin/sh

cd ${INSTALL_DIR}
sed -i -e  "s/DB_HOST=.*/DB_HOST=${DB_HOST}/; \
            s/DB_PORT=.*/DB_PORT=${DB_PORT}/; \
            s/APP_URL=.*/APP_URL=/; \
            s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/; \
            s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/; \
            s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env
sed -i "/login-captcha/{n;s/'enable.*/'enable' => ${LOGIN_COPTCHA}/}"  config/admin.php


##php artisan key:generate
if [ $1 == 'server' ];then
   if grep -qxF APP_STATE=active .env; then
       echo "not first ..."
       php artisan serve --host=0.0.0.0 --port=8000
   else
       php artisan key:generate
       result=1
       while [ $result -ne 0 ];do
           php artisan migrate:refresh --seed
           result=$?
           sleep 3
       done
       grep -q "APP_STATE=" .env && sed -i  "s/APP_STATE=.*/APP_STATE=active/" .env || echo APP_STATE=active >> .env
       echo "is first ..."
       php artisan serve --host=0.0.0.0 --port=8000
   fi
elif [ $1 == 'regresh' ];then
   php artisan migrate:refresh --seed
elif [ $1 == 'generate' ];then
   php artisan key:generate
elif [ $1 == 'debug' ];then
   top
else
   echo "Usage: $0 server|regresh|generate|debug"
fi
