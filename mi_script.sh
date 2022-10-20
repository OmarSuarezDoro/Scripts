#!/bin/bash

# sysinfo - Un script que informa del estado del sistema

##### Constantes

TITLE="Información del sistema para $HOSTNAME"

RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"

##### Estilos

TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

##### Funciones

system_info() {
   echo "${TEXT_ULINE}Versión del sistema${TEXT_RESET}"
   echo $(uname -a)
}


show_uptime() {
   echo "${TEXT_ULINE}Tiempo de encendido del sistema${TEXT_RESET}"
   echo $(uptime)
}


drive_space() {
   echo "${TEXT_ULINE}Espacio usado en las particiones${TEXT_RESET}"
   echo "$(df --human-readable | tr -s ' ' | cut -d ' ' -f 1,3| tail -n +2)"
}


home_space() {
   echo "${TEXT_ULINE}Espacio usado por usuarios${TEXT_RESET}"
    echo "USADO   DIRECTORIO"
    if [ "$USER" == root ]; then
      du --summarize --human-readable /home/*/ |tr -s ' '| sort -k'1' --field-separator ' ' --reverse --human-numeric-sort
    else
      du --summarize --human-readable /home/"$USER"/ |tr -s ' '| sort -k'1' --field-separator ' ' --reverse --human-numeric-sort
    fi 

}

##### Programa principal

cat << _EOF_

$TEXT_BOLD$TITLE$TEXT_RESET

$TEXT_GREEN$TIME_STAMP$TEXT_RESET

_EOF_

system_info
show_uptime
drive_space
home_space