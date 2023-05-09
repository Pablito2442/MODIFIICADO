# DES: Da a elegir si se desea cambiar los informes por defecto
opciones_informes() {
    local cambiarInformes
    preguntar "Selección de informes" \
              "Los informes por defecto son ${ft[0]}${cl[re]}${archivoInformeBW}${rstf} y ${ft[0]}${cl[re]}${archivoInformeCOLOR}${rstf}.\n¿Quieres cambiarlos?" \
              cambiarInformes \
              "Sí" \
              "No"

    # Si se ha decidido cambiar los informes
    case $cambiarInformes in
        1 )
            cabecera "Cambio de informes"

            # Pide el nombre del informe plano
            echo -e -n "Introduce el nombre para el ${ft[0]}${cl[re]}informe en blanco y negro${rstf} con extensión: "
            leer_nombre_archivo archivoInformeBW

            # Pide el nombre del informe color
            echo -e -n "Introduce el nombre para el ${ft[0]}${cl[re]}informe a color${rstf} con extensión: "
            # Se asegura de que no sea igual al nombre del informe plano.
            while leer_nombre_archivo archivoInformeCOLOR;do
                [[ "$archivoInformeBW" == "$archivoInformeCOLOR" ]] \
                && echo -e -n "${ft[0]}${cl[$av]}AVISO${rstf}. El nombre no puede ser el mismo.\nIntroduce otro nombre para el ${ft[0]}${cl[re]}informe a color${rstf}: " \
                || break
            done
        ;;
    esac

    # Hace las variables de informe
    informar_plano "Los informes se guardarán en la carpeta: ${carpetaInformes}"
    informar_plano "Archivo de informe en texto plano: ${archivoInformeBW}"
    informar_plano "Archivo de informe en color: ${archivoInformeCOLOR}"
    informar_plano ""

    informar_color "Los informes se guardarán en la carpeta: ${ft[0]}${cl[re]}${carpetaInformes}${rstf}"
    informar_color "Archivo de informe en texto plano: ${ft[0]}${cl[re]}${archivoInformeBW}${rstf}"
    informar_color "Archivo de informe en color: ${ft[0]}${cl[re]}${archivoInformeCOLOR}${rstf}"
    informar_color ""

    # Si la carpeta informes no existe crearla
    [ ! -d "${carpetaInformes}" ] \
        && mkdir "${carpetaInformes}"

    # Pasa las variables a ruta absoluta
    archivoInformeBW="${carpetaInformes}/${archivoInformeBW}"
    archivoInformeCOLOR="${carpetaInformes}/${archivoInformeCOLOR}"

    # Crea o vacía los archivos de informe
    > $archivoInformeBW
    > $archivoInformeCOLOR
}

# DES: Muestra la ayuda del fichero de ayuda si este existe
opciones_menu_ayuda() {
    clear
    cat "$archivoAyuda"
    informar_color "$( cat $archivoAyuda )"
    informar_plano "$( cat $archivoAyuda )"
    guardar_informes
    echo
    echo
    pausa_tecla
    opciones_menu
}

# DES: Elige si mostrar la ayuda o ejecutar el algoritmo
opciones_menu() {
    local menu
    preguntar "Menu" \
              "¿Qué quieres hacer?" \
              menu \
              "Ejecutar el programa" \
              "Ver la ayuda"
    
    case $menu in
        2 )
            opciones_menu_ayuda
        ;;
    esac
}

# DES: Función principar de opciones
opciones() {
    opciones_informes
    opciones_menu
}