#!/bin/bash

# filesysteminfo - Un script que informa del estado del sistema

##### Constantes
TITLE="Información del sistema para $HOSTNAME"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"
##### Variables
op=0
values=0
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
  Su modo de ejecución es: ${TEXT_BOLD}${TEXT_GREEN}./filesysteminfo [parametro] ${TEXT_RESET}
 ${TEXT_ULINE}Parametros${TEXT_RESET}
   -h|--help - Muestra esta ventana de ayuda.
    -inv - Invierte la salida del comando.
_EOF_
}

function MountDevices() {
  counter=0
  mounted_devices=
  if [ $# == 0 ];then
    mounted_devices=$(mount|cut -d ' ' -f 5|sort|uniq)
  elif [ $1 == "-inv" ];then
    mounted_devices=$(mount|cut -d ' ' -f 5|sort -r|uniq)
  elif [ $1 == "-devicefiles" ];then
    mounted_devices=$(mount|cut -d ' ' -f 5|sort|uniq)
    for device in $mounted_devices;do
      aux_var=$(stat --format="%t %T" $(df --all --human-readable -t $device --output=source| tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1) 2>/dev/null)
      if [ "$?" == "0" ];then 
        echo -n "$(df --all --human-readable -t $device --output=source,used,target|tail -n +2|wc -l) "
        echo -n "$(df --all --human-readable -t $device --output=source,used,target | tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1) "
        echo "$aux_var "
      fi
    done
    exit 0
  fi 
    echo -n "${TEXT_BOLD}${TEXT_GREEN}NºDEVICES TYPE DEVICE USED MOUNT-POINT MINOR MAYOR${TEXT_RESET}"
    echo ""
  for device in $mounted_devices;do
    n_devices=$(df --all --human-readable -t $device --output=source,used,target|tail -n +2|wc -l)
    list=$(df --all --human-readable -t $device --output=source,used,target | tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1)
    minor_major_number=$(stat --format="%t %T" $(df --all --human-readable -t $device --output=source| tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1) 2>/dev/null || echo "* *")
    values=$(df --all -t $device --output=used| tail -n +2)
    for value in $values;do
      counter=$(($counter + $value))
    done
    print_var="$n_devices $device $list $counter $minor_major_number" 
    echo "$print_var"
  done
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
      -devicefiles)
		    MountDevices $1
        exit 0
        ;;
      *)
        cat << _EOF_
          ${TEXT_RED}${TEXT_BOLD}[-]OPCIÓN NO VÁLIDA${TEXT_RESET}
_EOF_
        Usage
        exit 1
        ;;
  esac
  shift
done
MountDevices 