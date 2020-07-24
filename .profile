alias ll="ls -la"
#xhost +localhost
# bash -c 'xhost +localhost; sudo -i -u name /usr/bin/hp-setup; xhost -localhost'
export PATH=$PATH:/home/name/scripts

CONF=esp8266

case $CONF in
        fonera)
			export PATH=$PATH:/opt/FONERA_and_more/Fonera2.0g-2202/backfire_10.03.1-rc4/staging_dir/toolchain-mips_r2_gcc-4.3.3+cs_uClibc-0.9.30.1/usr/bin
			;;
			
        Overo)
			cd /mnt/landrive/opt/Overo
			. poky/oe-init-build-env
			export EXTRA_OEMAKE="-j 1"
			;;
			
        esp8266)
			export PATH=/home/name/esp-open-sdk/xtensa-lx106-elf/bin:$PATH
			#--------------------------------------
			#read -t 5 -p "Hit 'd' letter and <ret> in 5 seconds to configure for ESP32..." answ
			#if [ "$answ" != "d" ];then
			#  return
			#fi
			echo "*******************************************"
			echo "remember to setMIT.sh the first login!!!!!"
			echo "*******************************************"
			#scripts/setMIT.sh
			echo 
			echo "*******************************************"
			echo " --- git -c http.sslVerify=false push "
			cd sonoff
			;;
			
        ESP32)
			export PATH=$PATH:/home/name/.espressif/tools/xtensa-esp32-elf/esp-2020r2-8.2.0/xtensa-esp32-elf/bin
			export IDF_PATH=/home/name/esp-idf
			#export IDF_PYTHON_ENV_PATH=/usr/bin/python3
			#export IDF_PYTHON_ENV_PATH=/home/name/.espressif/python_env/idf4.3_py3.6_env
			. /home/name/esp-idf/export.sh
			;;
			
        AVR-GCC)
			# ------------------------------------------------------------
			# AVR-GCC - 4.7.2 (from atmel)
			# ------------------------------------------------------------
			export PATH="$PATH:/usr/local/avr8-gnu-toolchain-linux_x86_64/bin"
			#PREFIX=/usr/local/avr8-gnu-toolchain-linux_x86_64
			#export PREFIX

			#export SDL_VIDEODRIVER=x11
			unset CPLUS_INCLUDE_PATH
			;;
			
        Goke)
			#export PATH=~/x-tools/arm-goke-linux-uclibcgnueabi/bin:$PATH
			export PATH=~/x-tools/arm-unknown-linux-uclibcgnueabi/bin:$PATH
			export ARCH=arm
			#export CROSS_COMPILE=arm-goke-linux-uclibcgnueabi-
			export CROSS_COMPILE=arm-unknown-linux-uclibcgnueabi-
			;;
		
        *)
        	echo "BAD option"
		;;
esac
