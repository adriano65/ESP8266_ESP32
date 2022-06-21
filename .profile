alias ll="ls -la"
#xhost +localhost
# bash -c 'xhost +localhost; sudo -i -u name /usr/bin/hp-setup; xhost -localhost'

export LC_ALL="en_US.UTF-8"
#export LC_ALL="en_US"
#export LANG="en_US.UTF-8"
export PATH=$PATH:/home/name/scripts:/home/name/.local/bin
#export LESS=eFRX

export QT_PLUGIN_PATH=/opt/hexinator/plugins
export QTLIBDIR=/opt/hexinator/lib
export QT_DEBUG_PLUGINS=1

CONF=esp8266
#CONF=ESP32
#CONF=BCM
#CONF=Goke

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
			export PATH=/home/name/.espressif/tools/xtensa-esp32-elf/esp-2020r2-8.2.0/xtensa-esp32-elf/bin:$PATH
			export IDF_PATH=/home/name/esp-idf
			export IDF_PYTHON_ENV_PATH=/usr/bin/python3
			#export IDF_PYTHON_ENV_PATH=/home/name/.espressif/python_env/idf4.3_py3.6_env
			#export IDF_PYTHON_ENV_PATH=/home/name/.espressif/python_env/idf4.2_py3.7_env
			#export IDF_PYTHON_ENV_PATH=/home/name/.espressif/python_env/idf4.2_py2.7_env
			. $HOME/esp-idf/export.sh
			alias get_idf='. $HOME/esp-idf/export.sh'
			#cd ~/esp32
			;;
			
        ESP32-test)
			export PATH=$PATH:/home/name/.espressif/tools/xtensa-esp32-elf/esp-2020r2-8.2.0/xtensa-esp32-elf/bin
			export IDF_PATH=/home/name/esp/esp-idf
			#export IDF_PYTHON_ENV_PATH=/usr/bin/python3
			export IDF_PYTHON_ENV_PATH=/home/name/.espressif/python_env/idf4.3_py3.6_env
			#export IDF_PYTHON_ENV_PATH=/usr/bin/python
			. $HOME/esp/esp-idf/export.sh
			alias get_idf='. $HOME/esp/esp-idf/export.sh'
			cd esp32
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
        BCM)
			#export PATH=~/nandreader/asuswrt-merlin.ng/brcm-arm-toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/bin:$PATH
			export PATH=/opt/hndtools-mipsel-uclibc-4.3.5/bin:$PATH
			;;
		
        *)
        	echo "BAD option"
		;;
esac
