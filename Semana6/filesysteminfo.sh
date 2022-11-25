#!/bin/bash

# filesysteminfo - Un script que informa del estado del sistema

##### Constantes
TITLE="Información del sistema para $HOSTNAME"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"
##### Variables
op=0
values=0
usuarios=""
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
  invertir_auxiliar=""
  variable_auxiliar=""
  # En el caso de que se vaya a invertir
  if [ $invertir == "1" ];then
    invertir_auxiliar="-r"
  fi
  # Imprimimos titulo, e inicializamos la variable sobre la que iterar
  echo -n "${TEXT_BOLD}${TEXT_GREEN}NºDEVICES TYPE DEVICE USED MOUNT-POINT SUM MINOR MAYOR${TEXT_RESET}"
  if [ $device_files == "1" ];then
    echo -n "${TEXT_BOLD}${TEXT_GREEN} NºOPENED-DEVICES${TEXT_RESET}"
  fi
  echo ""
  mounted_devices=$(mount|cut -d ' ' -f 5|sort $invertir_auxiliar |uniq)
  for device in $mounted_devices;do
    echo -n ""
    # En el caso de querer imprimir solo los archivos
    if [ $device_files == "1" ];then
      aux_var=$(stat --format="%T %t" $(df --all --human-readable -t $device --output=source| tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1) 2>/dev/null)
    fi
    if [ $? == "0" ];then
      n_devices=$(df --all --human-readable -t $device --output=source,used,target|tail -n +2|wc -l)
      list=$(df --all --human-readable -t $device --output=source,used,target | tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1)
      minor_number=$(stat --format="%T" $(df --all --human-readable -t $device --output=source| tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1) 2>/dev/null || echo "*")
      major_number=$(stat --format="%t" $(df --all --human-readable -t $device --output=source| tail -n +2 | sort -k'2' --human-numeric-sort -r | head -n +1) 2>/dev/null || echo "*")
      values=$(df --all -t $device --output=used| tail -n +2)
      for value in $values;do
        counter=$(($counter + $value))
      done
      print_var="$n_devices $device $list $counter $minor_number $major_number" 
      # En caso de emplear la opcion devicefiles, añadirá un nuevo campo que será el número de dispositivos abiertos
      if [ "$device_files" == "1" ];then      
        minor_number=$(echo "obase=10; ibase=16;$minor_number;"|bc)
        major_number=$(echo "obase=10; ibase=16;$major_number;"|bc )
        if [ "$usuarios_op" == "1"];then
          variable_auxiliar="-u $usuarios" 
        fi
        number_of_opened_devices=$(lsof $variable_auxiliar | grep "$minor_number,$major_number"|wc -l)
        print_var="$print_var $number_of_opened_devices"
      fi
      echo "$print_var"
      counter=0
    fi
  done
}

## Variables de control ##
device_files=0
invertir=0
consume_campos=0
usuarios_op=0


##### Programa principal
while [ "$1" != "" ];do
  case "$1" in
     -h | --help)
		    Usage
        exit 0
        ;;
     -inv)
        invertir=1
        consume_campos=0
        ;;
      -devicefiles)
		    device_files=1
        consume_campos=0
        ;;
      -u)
        consume_campos=1
        usuarios_op=1
        ;;
      *)
        if [ "$consume_campos" == "1" ];then
          usuarios="$usuarios $1"
        else
          cat << _EOF_
            ${TEXT_RED}${TEXT_BOLD}[-]OPCIÓN NO VÁLIDA${TEXT_RESET}
_EOF_
          Usage
          exit 1
        fi
        ;;
  esac
  shift
done
MountDevices |column -t