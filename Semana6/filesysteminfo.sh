#!/bin/bash

# filesysteminfo - Un script que informa del estado del sistema

##### Constantes
TITLE="Información del sistema para $HOSTNAME"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"
##### Variables
mounted_devices=$(mount|cut -d ' ' -f 5|sort|uniq)
mounted_devices_r=$(mount|cut -d ' ' -f 5|sort -r|uniq)

##### Estilos

TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
# TEXT_BLUE=$(tput setaf 69)
# TEXT_PINK=$(tput setaf 200)
TEXT_BLUE=$(tput setaf 32)
TEXT_RED=$(tput setaf 1)
TEXT_RESET=$(tput sgr0)

##### Funciones
function Usage() {
cat << _EOF_
   ${TEXT_BOLD}${TEXT_BLUE}Este es un script que muestra información del sistema${TEXT_RESET}
 ${TEXT_ULINE}Parametros${TEXT_RESET}
   --help - Muestra esta ventana de ayuda.
_EOF_
}

function MountDevices() {
  if [ $# == 0 ];then
    for device in $mounted_devices;do
      df --all --human-readable -t $device --output=source,used,target | tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1
    done
  elif [ $1 == "-inv" ];then
    for device in $mounted_devices_r;do
      df --all --human-readable -t $device --output=source,used,target | tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1
    done
  fi 

}

##### Programa principal
while [ "$1" != "" ];do
  case "$1" in
     -h | --help)
		    Usage
        exit 0
        ;;
     -inv)
		    MountDevices $1
        exit 0
        ;;
      *)
        cat << _EOF_
          ${TEXT_RED}${TEXT_BOLD}[-]OPCIÓN NO VÁLIDA${TEXT_RESET}
Terminando ejecución...
_EOF_

        exit 0
        ;;
  esac
  shift
done

MountDevices