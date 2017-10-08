#!/bin/bash

isClean="no";
current_path=$(pwd);
image_link="https://dl.google.com/dl/android/aosp/bullhead-opr4.170623.009-factory-b9f20abf.zip";
downCommand="curl -O $image_link";


while getopts "t:l:c" arg
			do
				case $arg in
					c)	isClean="yes";;
					t)
						case $OPTARG in
							aria2)
								echo "Use aria2 to download";
								downCommand="aria2c $image_link";;
							wget)
								echo "Use wget to download";
								downCommand="wget --passive-ftp -c $image_link";;
							curl)
								echo "Use curl  to download";;
							*)
								echo "incorrect argument, please use: -t { aria2 | curl | wget }";
								exit 1;;
							esac
						;;
					l)
						echo "Set image link to $OPTARG";
						image_link=$OPTARG;;
					?)
						echo "unknow argument";
						exit 1;;
				esac
			done


cleanup(){	
			"${current_path}/cleanup.sh";
			rm -rf $(ls | egrep -v '(apply_patch.sh|authors.txt|bin|cleanup.sh|repackimg.sh|unpackimg.sh|5x_fix_BLOD.patch)');
			}

unpack(){	"${current_path}/unpackimg.sh" boot.img; }

extract(){	
			zfile_path=$(unzip -l $(ls | grep bullhead- ) | grep image-bullhead- | head -n1 | awk '{print $4}');
			zfile_dir="${current_path}/dir_temp/";
			unzip -j "$(ls | grep bullhead- )" $zfile_path -d $zfile_dir;
			
			cd $zfile_dir;
			zbootimg_path=$(unzip -l $(ls | grep image-bullhead- ) | grep boot.img | head -n1 | awk '{print $4}');
			unzip -j "$(ls | grep image-bullhead- )" $zbootimg_path -d $current_path;
			cd $current_path;
}

download(){
			$downCommand;
}

apply_patch(){
			echo "now patch 5x_fix_BLOD.patch";
			patch -p1 < 5x_fix_BLOD.patch > pacthINFO.log 2>&1;
}

repack(){
			"${current_path}/repackimg.sh";
}

init(){	
			if [ $isClean = "yes" ];then
				echo "Will do clean first";
				cleanup;
			fi
			download;
			extract;
			unpack;
			apply_patch;
			repack;
		}

init;
