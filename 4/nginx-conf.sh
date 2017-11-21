#!/bin/bash

TR_NGX_PORT="8090"
ST_NGX_PORT="8050"
NGINX_CONF_FILE="/usr/local/nginx/nginx.conf"


######var

group_count=$(fdfs_monitor /etc/fdfs/client.conf | grep 'group count' | grep -o '[0-9]\+' | head -1)
storage_count=$(fdfs_monitor /etc/fdfs/client.conf | grep 'storage server count' | grep -o '[0-9]\+' | head -1)
tracker_ip=$(fdfs_monitor /etc/fdfs/client.conf | grep 'tracker server is' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
ip_array=$(fdfs_monitor /etc/fdfs/client.conf | grep '		id =' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}') 
k=0
p=1
######remove old

sed -i '/upstream group/,/}/ d' "$NGINX_CONF_FILE"
sed -i '/location \/group/,/}/ d' "$NGINX_CONF_FILE"
if [  -f "/fastdfs/tracker/data/fdfs_trackerd.pid" ]; then

sed -i '/        listen/d' "$NGINX_CONF_FILE"
sed -i "/        server_name  localhost;/i\        listen       $(echo $TR_NGX_PORT);" "$NGINX_CONF_FILE"



######loop

for j in `seq $group_count`
do

    sed -i "/http {/a\    upstream group$(echo $j) {\n    }" "$NGINX_CONF_FILE"
    sed -i "/    server {/a\        location /group$(echo $j)/M00 {\n            proxy_pass http://group$(echo $j);\n        add_header Access-Control-Allow-Origin *;\n}" "$NGINX_CONF_FILE"

    for i in $ip_array
    do

       if [ $p -gt $(($k+$storage_count)) ] || [ $p -le $k ]; then
          p=$(($p+1))
          continue
       else

                sed -i "/upstream group$(echo $j) {/a\    server $(echo $i):$(echo $ST_NGX_PORT);" "$NGINX_CONF_FILE"
                p=$(($p+1))

       fi

    done

    p=1
    k=$(($k+$storage_count))

done
######


else
sed -i '/        listen/d' "$NGINX_CONF_FILE"
sed -i "/        server_name  localhost;/i\        listen       $(echo $ST_NGX_PORT);" "$NGINX_CONF_FILE"

for j in `seq $group_count`
do

    sed -i "/    server {/a\        location /group$(echo $j)/M00 {\n             root   /fastdfs/store_path/data;\n            ngx_fastdfs_module;\n       }" "$NGINX_CONF_FILE"


done

fi

###### load nginx

info=$(ps -A | grep nginx)

if [ "$info" = "" ]; then

    /usr/local/nginx/sbin/nginx

else

    /usr/local/nginx/sbin/nginx -s reload

fi

