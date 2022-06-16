#!/bin/bash

cp /var/www/html/config/config.php.example /var/www/html/config/config.php

sed -i '$d' /var/www/html/config/config.php

echo "\$servers->setValue('server','host','$LDAP_HOST');" >> /var/www/html/config/config.php
echo "\$servers->setValue('server','port','$LDAP_PORT');" >> /var/www/html/config/config.php
echo "\$servers->setValue('server','base',array('$LDAP_BASE_DN'));" >> /var/www/html/config/config.php
echo "\$servers->setValue('login','bind_id','$LDAP_BIND_ID');" >> /var/www/html/config/config.php
echo "\$servers->setValue('login','bind_pass','$LDAP_BIND_PASSWORD');" >> /var/www/html/config/config.php
echo "\$servers->setValue('login','auth_type','config');" >> /var/www/html/config/config.php