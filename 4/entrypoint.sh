#!/bin/bash
#set -e

TRACKER_BASE_PATH="/fastdfs/tracker"
TRACKER_LOG_FILE="$TRACKER_BASE_PATH/logs/trackerd.log"

STORAGE_BASE_PATH="/fastdfs/storage"
STORAGE_LOG_FILE="$STORAGE_BASE_PATH/logs/storaged.log"

TRACKER_CONF_FILE="/etc/fdfs/tracker.conf"
STORAGE_CONF_FILE="/etc/fdfs/storage.conf"

NGINX_CONF_FILE="/nginx-conf.sh"
MOD_FASTDFS_CONF_FILE="/etc/fdfs/mod_fastdfs.conf"

CLIENT_CONF_FILE="/etc/fdfs/client.conf"

if [  -f "/fastdfs/tracker/logs/trackerd.log" ]; then 
	rm -rf "$TRACKER_LOG_FILE"
fi

if [  -f "/fastdfs/storage/logs/storaged.log" ]; then 
	rm -rf "$STORAGE_LOG_FILE"
fi

if [ "$1" = 'sh' ]; then
	/bin/bash
fi

if [ "$1" = 'tracker' ]; then
	echo "start  fdfs_trackerd..."

	if [ ! -d "/fastdfs/tracker/logs" ]; then 
		mkdir "/fastdfs/tracker/logs" 
	fi 


####### tracker.conf

	array=()
        n=0
	while read line
	do
	    array[$n]="${line}";
	    ((n++));
	done < /fdfs_conf/tracker.conf

	rm "$TRACKER_CONF_FILE"

	for i in "${!array[@]}"; do 
	    if [ ${STORE_GROUP} ]; then
	        [[ "${array[$i]}" =~ "store_group=" ]] && array[$i]="store_group=${STORE_GROUP}"
	    fi
	    echo "${array[$i]}" >> "$TRACKER_CONF_FILE"
	done


        
#####   mod_fastdfs.conf
        
       	mod_arr=()
        p=0
        while read line
        do
            mod_arr[$p]="${line}";
            ((p++));
        done < /usr/local/fastdfs-nginx-module/src/mod_fastdfs.conf

        rm "$MOD_FASTDFS_CONF_FILE"

        for i in "${!mod_arr[@]}"; do   
            if [ ${GROUP_NAME} ]; then
                [[ "${array[$i]}" =~ "group_name=" ]] && mod_arr[$i]="group_name=${GROUP_NAME}"
            fi


                [[ "${mod_arr[$i]}" =~ "store_path0=" ]] && mod_arr[$i]="store_path0=/fastdfs/store_path"
                [[ "${mod_arr[$i]}" =~ "url_have_group_name = " ]] && mod_arr[$i]="url_have_group_name = true"
                [[ "${mod_arr[$i]}" =~ "tracker_server=" ]] && mod_arr[$i]="tracker_server=${TRACKER_SERVER}"
            echo "${mod_arr[$i]}" >> "$MOD_FASTDFS_CONF_FILE"
        done


##### client.conf

	client_arr=()
        k=0
        while read line
        do
            client_arr[$k]="${line}";
            ((k++));
        done < /fdfs_conf/client.conf

        rm "$CLIENT_CONF_FILE"

        for i in "${!client_arr[@]}"; do   
              	[[ "${client_arr[$i]}" =~ "base_path=" ]] && client_arr[$i]="base_path=/tmp"
                [[ "${client_arr[$i]}" =~ "tracker_server=" ]] && client_arr[$i]="tracker_server=${TRACKER_SERVER}"
            echo "${client_arr[$i]}" >> "$CLIENT_CONF_FILE"
        done
		
#####
        sed -i '/^TR_NGX_PORT=/d' $NGINX_CONF_FILE
        sed -i "/^NGINX_CONF_FILE/i\TR_NGX_PORT=\"${TR_NGX_PORT}\"" $NGINX_CONF_FILE
        sed -i '/^ST_NGX_PORT=/d' $NGINX_CONF_FILE
        sed -i "/^NGINX_CONF_FILE/i\ST_NGX_PORT=\"${ST_NGX_PORT}\"" $NGINX_CONF_FILE

	touch  "$TRACKER_LOG_FILE"
	ln -sf /dev/stdout "$TRACKER_LOG_FILE"

	fdfs_trackerd $TRACKER_CONF_FILE
	sleep 3s  #delay wait for pid file
	# tail -F --pid=`cat /fastdfs/tracker/data/fdfs_trackerd.pid`  /fastdfs/tracker/logs/trackerd.log
	# wait `cat /fastdfs/tracker/data/fdfs_trackerd.pid`

        sleep 5s 
        sh /nginx-conf.sh

	tail -F --pid=`cat /fastdfs/tracker/data/fdfs_trackerd.pid`  /dev/null
        

 fi

if [ "$1" = 'storage' ]; then
	echo "start  fdfs_storgaed..."
#######   
	array=()
        n=0
	while read line
	do
	    array[$n]="${line}";
	    ((n++));
	done < /fdfs_conf/storage.conf

	rm "$STORAGE_CONF_FILE"

	for i in "${!array[@]}"; do 
	    if [ ${GROUP_NAME} ]; then
	        [[ "${array[$i]}" =~ "group_name=" ]] && array[$i]="group_name=${GROUP_NAME}"
	    fi
           
	        [[ "${array[$i]}" =~ "store_path0=" ]] && array[$i]="store_path0=/fastdfs/store_path"

	    if [ ${TRACKER_SERVER} ]; then
 	            [[ "${array[$i]}" =~ "tracker_server=" ]] && array[$i]="tracker_server=${TRACKER_SERVER}"
	    fi
	    echo "${array[$i]}" >> "$STORAGE_CONF_FILE"
	done

#####   mod_fastdfs.conf

        mod_arr=()
        p=0
        while read line
        do
            mod_arr[$p]="${line}";
            ((p++));
        done < /usr/local/fastdfs-nginx-module/src/mod_fastdfs.conf

        rm "$MOD_FASTDFS_CONF_FILE"

        for i in "${!mod_arr[@]}"; do

            if [ ${GROUP_NAME} ]; then
                [[ "${array[$i]}" =~ "group_name=" ]] && array[$i]="group_name=${GROUP_NAME}"
            fi

                [[ "${mod_arr[$i]}" =~ "store_path0=" ]] && mod_arr[$i]="store_path0=/fastdfs/store_path"
                [[ "${mod_arr[$i]}" =~ "url_have_group_name = " ]] && mod_arr[$i]="url_have_group_name = true"
                [[ "${mod_arr[$i]}" =~ "tracker_server=" ]] && mod_arr[$i]="tracker_server=${TRACKER_SERVER}"
            echo "${mod_arr[$i]}" >> "$MOD_FASTDFS_CONF_FILE"
        done

##### client.conf
 
	client_arr=()
        k=0
        while read line
        do
            client_arr[$k]="${line}";
            ((k++));
        done < /fdfs_conf/client.conf

        rm "$CLIENT_CONF_FILE"

        for i in "${!client_arr[@]}"; do   
              	[[ "${client_arr[$i]}" =~ "base_path=" ]] && client_arr[$i]="base_path=/tmp"
                [[ "${client_arr[$i]}" =~ "tracker_server=" ]] && client_arr[$i]="tracker_server=${TRACKER_SERVER}"
            echo "${client_arr[$i]}" >> "$CLIENT_CONF_FILE"
        done
		
#####
       sed -i '/^TR_NGX_PORT=/d' $NGINX_CONF_FILE
       sed -i "/^NGINX_CONF_FILE/i\TR_NGX_PORT=\"${TR_NGX_PORT}\"" $NGINX_CONF_FILE
       sed -i '/^ST_NGX_PORT=/d' $NGINX_CONF_FILE
       sed -i "/^NGINX_CONF_FILE/i\ST_NGX_PORT=\"${ST_NGX_PORT}\"" $NGINX_CONF_FILE


	if [ ! -d "/fastdfs/storage/logs" ]; then 
		mkdir "/fastdfs/storage/logs" 
	fi 

	touch  "$STORAGE_LOG_FILE"
	ln -sf /dev/stdout "$STORAGE_LOG_FILE"

	fdfs_storaged "$STORAGE_CONF_FILE"
	sleep 3s  #delay wait for pid file
	# tail -F --pid=`cat /fastdfs/storage/data/fdfs_storaged.pid`  /fastdfs/storage/logs/storaged.log
	#wait -n `cat /fastdfs/storage/data/fdfs_storaged.pid`

        sleep 5s 
        sh /nginx-conf.sh

	tail -F --pid=`cat /fastdfs/storage/data/fdfs_storaged.pid`  /dev/null

fi


