#!/bin/bash

#########################################
#					 #
#   	请按要求修改注释内容!		  #
#	脚本需要安装zip/screen才可运行	  #
#	请在名为mc的screen窗口下运行本脚本	#
#					#
#########################################

serverDir=/home/diamond/mc/				#服务端路径
backupDir=/home/diamond/bp/				#地图备份路径
backupTime=305						#备份时间(格式:小时+分钟,305:3点05分备份)
days=5							#备份地图保存时间(N天前的备份将被删除)
trap "pkill run.sh; exit 2" SIGINT

{
	while true
	do
	timeH=$(date +%-H)
	timeM=$(date +%M)
	time=$timeH$timeM
	time=$(echo -e $time | sed -r 's/0*([0-9])/\1/')
	if [[ "$time" == "$backupTime" ]]
	then
		screen -D -r mc -X stuff stop
		screen -D -r mc -X eval "stuff \015"
		echo ok!
		sleep 5m
		{
			cd $backupDir
			dt=$(date -d "- $days day" "+%Y%m%d%H%M%S")
			if [[ ! -d old-file ]]; then
				mkdir old-file
			fi
			ls > temp.${dt}
			while read line; do
				file=$line
				if [[ "$file"x == "old-file"x || "$file"x == "old_file.sh"x ]]; then
					continue
				fi
				ftime=$(stat "$file"|grep -i Modify | awk -F. '{print $1}' | awk '{print $2$3}'| awk -F- '{print $1$2$3}' | awk -F: '{print $1$2$3}')

				if [[ "$ftime" < "$dt" ]]; then
					echo "file:"$file" time:$ftime has moved to old-file"
					mv "$file" old-file/
				fi
			done < temp.${dt}
			rm temp.${dt}
			rm -rf old-file
			echo rmok!
			sleep 1s
		} &
	fi
	sleep 1s
	done
} &

cd $serverDir
while true
do
	WINEDEBUG=-all wine bedrock_server.exe
	timeH=$(date +%-H)
	timeM=$(date +%M)
	time=$timeH$timeM
	time=$(echo -e $time | sed -r 's/0*([0-9])/\1/')
	tday=$(date +%F)
	if [[ "$((time))" == "$((backupTime))" ]]
	then
		zip -q -r ${backupDir}/earth_${tday}.zip ${serverDir}/worlds
		echo ok!
	fi
	echo "Restart Server After 5 Seconds!"
	sleep 5s
done

