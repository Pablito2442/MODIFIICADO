# DES: Pregunta si se desean guardar los rangos
datos_pregunta_guardar_rangos() {

    local guardarProcesos
    preguntar "Guardar rangos" \
              "¿Dónde quieres guardar los rangos?" \
              guardarProcesos \
              "En el fichero de rangos de última ejecución (datosrangos.txt)" \
              "Otro fichero de rangos"
    
    case $guardarProcesos in
         2)

            echo -e -n "Introduce el nombre para el ${ft[0]}${cl[re]}fichero de rangos${rstf} con extensión: "
            while leer_nombre_archivo archivoRangos;do
                
                
                # Si el archivo ya existe pregunta si sobreescribir
                if [[ -f "${carpetaDatos}/${archivoRangos}" ]] \
                    && ! preguntar_si_no "${ft[0]}${cl[$av]}AVISO${rstf}. El archivo ya existe. ¿Sobreescribirlo?";then

                    echo -e -n "Introduce otro nombre para el ${ft[0]}${cl[re]}fichero de rangos${rstf}: "
                else
                    break
                fi
            done
            
            # Informar donde se guardarán los procesos.
            informar_plano "Carpeta de rangos: ${carpetaRangos}"
            informar_plano "Archivo de rangos: ${archivoRangos}"
            informar_plano ""

            informar_color "Carpeta de procesos: ${ft[0]}${cl[re]}${carpetaRangos}${rstf}"
            informar_color "Archivo de procesos: ${ft[0]}${cl[re]}${archivoRangos}${rstf}"
            informar_color ""

            # Pasa el archivo de procesos a ruta absoluta
            archivoRangos="${carpetaRangos}/${archivoRangos}"
            
        ;;
    esac

}

# DES: Guardar los datos a archivo
datos_rango_guardar() {

    # Si la carpeta de datos no existe, crearla
    [ ! -d "${carpetaRangos}" ] \
        && mkdir "${carpetaRangos}"

    # Se crea una cadena que luego se guarda en los archivos respectivos
    local cadena=""
	
	cadena+="# RANGOS PARA LA MEMORIA:\n"
	cadena+="# Rango mínimo para el numero de marcos de página:\n"
    cadena+="${numMarcosMinimo}\n"
	cadena+="# Rango máximo para el numero de marcos de página:\n"
    cadena+="${numMarcosMaximo}\n"
    cadena+="# Rango mínimo para el tamaño de marco de página:\n"
    cadena+="${tamanoPaginaMinimo}\n"
	cadena+="# Rango máximo para el tamaño de marco de página:\n"
    cadena+="${tamanoPaginaMaximo}\n"
    cadena+="# Rango mínimo para el número max de uds. para la reubicación:\n"
    cadena+="${minimoReubicacionMinimo}\n"
	cadena+="# Rango máximo para el número max de uds. para la reubicación:\n"
    cadena+="${minimoReubicacionMaximo}\n"
    cadena+="# RANGOS PARA LOS PROCESOS:\n"
    cadena+="# Rango mínimo para el numero de procesos:\n"
	cadena+="${numeroProcesosMinimo}\n"
	cadena+="# Rango máximo para el numero de procesos:\n"
	cadena+="${numeroProcesosMaximo}\n"
	cadena+="# Rango mínimo para el tiempo de llegada:\n"
	cadena+="${tiempoLlegadaMinimo}\n"
	cadena+="# Rango máximo para el tiempo de llegada:\n"
	cadena+="${tiempoLlegadaMaximo}\n"
	cadena+="# Rango mínimo para el tiempo de ejecución:\n"
	cadena+="${tiempoEjecucionMinimo}\n"
	cadena+="# Rango máximo para el tiempo de ejecución:\n"
	cadena+="${tiempoEjecucionMaximo}\n"
	cadena+="# Rango mínimo para el mínimo estructural:\n"
	cadena+="${minimoEstructuralMinimo}\n"
	cadena+="# Rango máximo para el mínimo estructural:\n"
	cadena+="${minimoEstructuralMaximo}\n"
	cadena+="# Rango mínimo para las direcciones:\n"
	cadena+="${direccionMinima}\n"
	cadena+="# Rango máximo para las direcciones:\n"
	cadena+="${direccionMaxima}\n"

    # for p in ${procesos[*]};do

        # cadena+="${tiempoLlegada[$p]},"
        # cadena+="${minimoEstructural[$p]}"

        # for (( d=0; d<${tiempoEjecucion[$p]}; d++ ));do
            # cadena+=",${procesoDireccion[$p,$d]}"
        # done
        # cadena+="\n"
    # done

    # Guardar los datos en el archivo de última ejecución
    echo -e -n "${cadena}" > "$archivoUltimaEjecucionRango"

    # Si se ha dado un archivo de datos
    if [[ $archivoRangos ]];then
        echo -e -n "${cadena}" > "$archivoRangos"
    fi

}

# DES: Pregunta si se desean guardar los procesos
datos_pregunta_guardar() {

    local guardarProcesos
    preguntar "Guardar datos" \
              "¿Donde quieres guardar los datos?" \
              guardarProcesos \
              "En el fichero de datos de última ejecución (datos.txt)" \
              "Otro fichero de datos"
    
    case $guardarProcesos in
        2 )

            echo -e -n "Introduce el nombre para el ${ft[0]}${cl[re]}archivo de datos${rstf} con extensión: "
            while leer_nombre_archivo archivoDatos;do
                
                
                # Si el archivo ya existe pregunta si sobreescribir
                if [[ -f "${carpetaDatos}/${archivoDatos}" ]] \
                    && ! preguntar_si_no "${ft[0]}${cl[$av]}AVISO${rstf}. El archivo ya existe. ¿Sobreescribirlo?";then

                    echo -e -n "Introduce otro nombre para el ${ft[0]}${cl[re]}archivo de datos${rstf}: "
                else
                    break
                fi
            done
            
            # Informar donde se guardarán los procesos.
            informar_plano "Carpeta de datos: ${carpetaDatos}"
            informar_plano "Archivo de datos: ${archivoDatos}"
            informar_plano ""

            informar_color "Carpeta de datos: ${ft[0]}${cl[re]}${carpetaDatos}${rstf}"
            informar_color "Archivo de datos: ${ft[0]}${cl[re]}${archivoDatos}${rstf}"
            informar_color ""

            # Pasa el archivo de procesos a ruta absoluta
            archivoDatos="${carpetaDatos}/${archivoDatos}"
            
        ;;
    esac

}

# DES: Guardar los datos a archivo
datos_guardar() {

    # Si la carpeta de datos no existe, crearla
    [ ! -d "${carpetaDatos}" ] \
        && mkdir "${carpetaDatos}"

    # Se crea una cadena que luego se guarda en los archivos respectivos
    local cadena=""

    cadena+="# número de direcciones:\n"
    cadena+="${tamanoMemoria}\n"
    cadena+="# tamaño de página:\n"
    cadena+="${tamanoPagina}\n"
    cadena+="# mínimo reubicación:\n"
    cadena+="${mNUR}\n"
    cadena+="# procesos:\n"
    cadena+="# Tll,Nm,dir1,dir2,dir3,...\n"

    for p in ${procesos[*]};do

        cadena+="${tiempoLlegada[$p]},"
        cadena+="${minimoEstructural[$p]}"

        for (( d=0; d<${tiempoEjecucion[$p]}; d++ ));do
            cadena+=",${procesoDireccion[$p,$d]}"
        done
        cadena+="\n"
    done

    # Guardar los datos en el archivo de última ejecución
    echo -e -n "${cadena}" > "$archivoUltimaEjecucion"

    # Si se ha dado un archivo de datos
    if [[ $archivoDatos ]];then
        echo -e -n "${cadena}" > "$archivoDatos"
    fi

}

# DES: Crea los nombre de los procesos ej 1 -> P01
generar_nombre_proceso() {

    nombreProceso[$p]=$(
        printf "P%0${anchoNumeroProceso}d" "$p"
    )

    local color=${colorProceso[$p]}

    nombreProcesoColor[$p]=$(
        printf "${cl[$color]}${ft[0]}P%0${anchoNumeroProceso}d${cl[0]}${ft[1]}" "$p"
    )

}

# DES: Muestra una tabla con todos los procesos introducidos hasta el momento
datos_tabla_procesos() {

    # Color del proceso que se está imprimiendo
    local color

    local ancho=$(( $anchoColRef + $anchoColTll + $anchoColTej + $anchoColNm ))
    local anchoRestante
    local anchoCadena

    # Mostrar cabecera
    printf "${ft[0]}%-${anchoColRef}s%${anchoColTll}s%${anchoColTej}s%${anchoColNm}s%s${rstf}\n"  " Ref" "Tll" "Tej" "nMar" " Dirección - Página"

    for proc in ${listaLlegada[*]};do

        # Poner la fila con el color del proceso
        color=${colorProceso[$proc]}
        printf "${cl[$color]}${ft[0]}"
        # Ref
        printf "%-${anchoColRef}s" " ${nombreProceso[$proc]}"
        # Tll
        printf "%${anchoColTll}s" "${tiempoLlegada[$proc]}"
        # Tej
        printf "%${anchoColTej}s" "${tiempoEjecucion[$proc]}"
        # Nm
        printf "%${anchoColNm}s" "${minimoEstructural[$proc]}"

        anchoRestante=$(( $anchoTotal - $ancho ))

        # Dirección - Página
        for (( i=0; ; i++ ));do

            anchoCadena=$(( ${#procesoDireccion[$proc,$i]} + ${#procesoPagina[$proc,$i]} + 2 ))

            if [ $anchoRestante -lt $anchoCadena ];then
                printf "\n"
                anchoRestante=$anchoTotal
            fi

            # Si ya no quedan páginas
            [[ -z "${procesoDireccion[$proc,$i]}" ]] \
                && break

            printf " ${ft[1]}${procesoDireccion[$proc,$i]}-${ft[0]}${procesoPagina[$proc,$i]}"

            anchoRestante=$(( $anchoRestante - $anchoCadena ))

        done

        printf "${rstf}\n"
    done

    echo

}

# DES: Almacena los limites asociados a un proceso en un solo argumento
datos_almacena_marcos(){
    marcoIni=$1
    marcoFin=$2
	proceso=$3
    marcos[${proceso}]="${marcoIni} ${marcoFin}"
    
}

datos_obtiene_marcos(){
    eleccion=$1
	proceso=$2
    IFS=" "
    read -a strarr <<< ${marcos[${proceso}]}
	
	if [ $eleccion -eq 0 ]; then
    Mini="${strarr[${eleccion}]}"
	fi
	
	if [ $eleccion -eq 1 ]; then
    Mfin="${strarr[${eleccion}]}"
	fi
	
	

}

# DES: Ordena los procesos segun llegada en la lista de llegada
datos_ordenar_llegada() {

    # EXPLICACIÓN
    # Se hace echo a cadenas del tipo "tLl.nPr&Pr" ej. "12.02&2"
    # Estas cadenas son ordenadas numericamente por el comando sort -n , que
    # interpreta la primera parte como un número decimal.
    # grep -o "&.*$" coge lo que hay desde el "&" hasta el final ej "&2"
    # tr -d "&" elimina el "&" quedando solo el "2"
    # El output se introduce en la lista de llegada

    listaLlegada=($(
        for pro in ${procesos[*]};do
            printf "${tiempoLlegada[$pro]}.%0${anchoNumeroProceso}d&${pro}\n" "${pro}"
        done | sort -n | grep -o "&.*$" | tr -d "&"
    ))

}


# --------- DATOS MEMORIA -----------

# DES: Muestra una tabla con las características de la memoria según se van dando.
datos_memoria_tabla() {
    clear
    echo -e        "${cf[$ac]}                                                 ${rstf}"
    echo -e         "${cf[17]}                                                 ${rstf}"
    printf  "${cf[17]}${cl[1]}  Tamaño memoria : %-30s${rstf}\n" "${tamanoMemoria}"
    printf  "${cf[17]}${cl[1]}   Tamaño página : %-30s${rstf}\n" "${tamanoPagina}"
    printf  "${cf[17]}${cl[1]}   Número marcos : %-30s${rstf}\n" "${numeroMarcos}"
    printf  "${cf[17]}${cl[1]}            mNUR : %-30s${rstf}\n" "${mNUR}"
    echo -e         "${cf[17]}                                                 ${rstf}"
    echo -e        "${cf[$ac]}                                                 ${rstf}"
    echo
}

# DES: Introducir número de direcciones de la memoria
datos_memoria_tamaño() {

    # Para que se muestr un guión en el dato que se introduce
    tamanoMemoria="_"

    # Mostrar la tabla
    datos_memoria_tabla

    echo -e -n "Número de ${ft[0]}${cl[re]}direcciones${rstf} (tamaño): "
    # Leer el tamaño de la memoria con un mínimo de 1
    while :;do

        leer_numero_entre tamanoMemoria 1
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o nada
            1 | 2 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un número natural: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El número de ${ft[0]}${cl[re]}direcciones${rstf} debe ser mayor a ${ft[0]}${cl[re]}0${rstf}: "
            ;;

        esac
    done

}

# DES: Introducir tamaño de página
datos_memoria_tamaño_pagina() {

    # Para que se muestr un guión en el dato que se introduce
    tamanoPagina="_"

    # Mostrar la tabla
    datos_memoria_tabla

    echo -e -n "Tamaño de ${ft[0]}${cl[re]}página${rstf}: "
    # Leer el número de marcos con un mínimo de 1 y máx del tamaño de la memoria
    while :;do

        leer_numero_entre tamanoPagina 1 $tamanoMemoria
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o nada
            1 | 2 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un número natural: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El tamaño de ${ft[0]}${cl[re]}página${rstf} no puede ser mayor al número de direcciones (${ft[0]}${cl[re]}${tamanoMemoria}${rstf}): "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El tamaño de ${ft[0]}${cl[re]}página${rstf} debe ser mayor a ${ft[0]}${cl[re]}0${rstf}: "
            ;;

        esac
    done

}

# DES: Calcular número de marcos
datos_memoria_numero_marcos() {
    numeroMarcos=$(( $tamanoMemoria / $tamanoPagina ))
}

# DES: Introducir mínimo para que se produzca reubicación (Solo NC - R)
datos_memoria_mNur() {

    # Para que se muestr un guión en el dato que se introduce
    mNUR="_"

    # Mostrar la tabla
    datos_memoria_tabla

    echo -e -n "Mínimo para que haya ${ft[0]}${cl[re]}reubicación${rstf}: "
    # Leer el tamaño de la memoria con un mínimo de 0 y máx del tamaño de la memoria
    while :;do

        leer_numero_entre mNUR 0 $numeroMarcos
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o nada
            1 | 2 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un número natural: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El ${ft[0]}${cl[re]}mNur${rstf} no puede ser mayor al número de marcos (${ft[0]}${cl[re]}${numeroMarcos}${rstf}): "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El ${ft[0]}${cl[re]}mNur${rstf} debe ser al menos ${ft[0]}${cl[re]}0${rstf}: "
            ;;

        esac
    done

}

# DES: Introducir características de la memoria
datos_memoria() {

    # Introducir número de direcciones de la memoria
    datos_memoria_tamaño
    # Introducir tamaño de página
    datos_memoria_tamaño_pagina
    # Calcular número de marcos
    datos_memoria_numero_marcos
    # Introducir mínimo para que se produzca reubicación (Solo NC - R)
    datos_memoria_mNur

    # Mostrar los datos introducidos
    datos_memoria_tabla
    pausa_tecla

}

# ------------------------------------
# --------- DATOS POR TECLADO --------
# ------------------------------------

# DES: Pide el tiempo de llegada del proceso
datos_teclado_llegada() {

    clear
    # Mostrar tabla de procesos
    datos_tabla_procesos

    echo -n -e "Introduce el tiempo de ${ft[0]}${cl[$re]}llegada${rstf} de ${nombreProcesoColor[$p]}: "
    # while true
    while :;do

        leer_numero tiempoLlegada[$p]
        # Dependiendo del valor devuelto por la función anterior
        case $? in

            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural
            1 | 2 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un número natural: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;

        esac
    done

    # Calcular ancho columna tiempo llegada
    [ $(( ${#tiempoLlegada[$p]} + 2 )) -gt ${anchoColTll} ] \
        && anchoColTll=$(( ${#tiempoLlegada[$p]} + 2 ))

}

# DES: Pide el mínimo estructural del proceso
datos_teclado_nm() {
    
    clear
    # Mostrar tabla de procesos
    datos_tabla_procesos

    echo -n -e "Introduce el ${ft[0]}${cl[$re]}mínimo estructural${rstf} de ${nombreProcesoColor[$p]}: "
    # while true
    while :;do

        leer_numero_entre minimoEstructural[$p] 1 ${numeroMarcos}
        # Dependiendo del valor devuelto por la función anterior
        case $? in

            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural
            1 | 2 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un número natural: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El ${ft[0]}${cl[$re]}mínimo estructural${rstf} no puede ser mayor al número de marcos (${ft[0]}${cl[$re]}${numeroMarcos}${rstf}): "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El ${ft[0]}${cl[re]}mínimo estructural${rstf} debe ser mayor a ${ft[0]}${cl[re]}0${rstf}: "
            ;;

        esac
    done

    # Calcular ancho columna minimo estructural
    [ $(( ${#minimoEstructural[$p]} + 2 )) -gt ${anchoColNm} ] \
        && anchoColNm=$(( ${#minimoEstructural[$p]} + 2 ))

}

# DES: Va pidiendo las direcciones del proceso
datos_teclado_direcciones() {

    # dirección introducida se usa como variable de paso para el valor de escape de la introducción
    local direc

    # Empezando con la dirección 0
    for (( d=0; ; d++ ));do

        clear
        # Mostrar tabla de procesos
        datos_tabla_procesos

        echo -n -e "Introduce la dirección número ${ft[0]}${cl[$re]}$(( ${d}+1 ))${rstf} [${ft[0]}${cl[$re]}no${rstf}=no introducir más]: "
        # while true
        while :;do

            leer_numero direc
            # Dependiendo del valor devuelto por la función anterior
            case $? in

                # Valor válido
                0 )
                    # Asignar la dirección
                    procesoDireccion[$p,$d]=$direc
                    # Calcular la página
                    procesoPagina[$p,$d]=$(( $direc / $tamanoPagina ))

                    # Actualizar anchoGen si la dirección de página es muy grande
                    [ ${#procesoPagina[$p,$d]} -gt $anchoGen ] && anchoGen=${#procesoPagina[$p,$d]}

                    break
                ;;
                # Valor no número natural
                1 | 2 )
                    # Si se ha introducido "no"
                    if [ "${direc}" = "no" ];then
                        if [ $d -eq 0 ];then
                            echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Tienes que introducir al menos una dirección: "
                        else
                            # Si el mínimo estructural el menor al número de direcciones introducidas o si se acepta el desperdicio
                            if [ ${minimoEstructural[$p]} -le $d ] || preguntar_si_no "Has introducido menos direcciones que el mínimo estructural del proceso.\nEsto es un desperdicio. ¿Seguro?";then
                                # calcular tiempo de ejecución
                                tiempoEjecucion[$p]=$d
                                # Calcular ancho columna tiempo llegada
                                [ $(( ${#tiempoEjecucion[$p]} + 2 )) -gt ${anchoColTej} ] \
                                    && anchoColTej=$(( ${#tiempoEjecucion[$p]} + 2 ))
                                return 0
                            fi
                            echo -n -e "Introduce la dirección ${ft[0]}${cl[$re]}${d}${rstf}: "
                        fi
                    else
                        echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un número natural: "
                    fi
                ;;
                # Valor demasiado grande
                3 )
                    echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
                ;;

            esac
        done
    done
}


# DES: Introducir los datos por teclado
datos_teclado() {
    
    # Preguntar si guardar a archivo custom
    datos_pregunta_guardar

    # Introducir datos de la memoria
    datos_memoria

    # Introducir datos de los procesos
    # Empezando con el proceso nº1
    for (( p=1; ; p++ ));do

        # Añadir número de proceso a la lista con todos los procesos y de llegada
        procesos+=($p)
        listaLlegada+=($p)

        # Establecer variables a "-"
        tiempoLlegada[$p]="-"
        tiempoEjecucion[$p]="-"
        minimoEstructural[$p]="-"

        # Calcular el color del proceso. Se basa en mis variables de color.
        # Si usas otras no va a funcionar correctamente.
        colorProceso[$p]=$(( (${p} % 12) + 5 ))

        # Se genera la cadena de nombre del proceso ej 1 -> P01
        generar_nombre_proceso

        # Introducir el tiempo de llegada del proceso
        datos_teclado_llegada

        # Introducir el mínimo estructural del proceso
        datos_teclado_nm

        # Introducir las direcciones del proceso y calcular el tiempo de ejecución
        datos_teclado_direcciones

        # Ordenar los procesos según llegada
        datos_ordenar_llegada

        # Mostrar la tabla de procesos
        clear
        datos_tabla_procesos
        
        # Si se alcanza el máximo de procesos
        if [ $p -eq $maximoProcesos ];then
            echo -e "${ft[0]}${cl[$av]}AVISO${rstf}. Se ha llegado al máximo de procesos (${ft[0]}${cl[$re]}${maximoProcesos}${rstf}): "
            pausa_tecla
            break
        fi

        # Pregunta si se quiren añadir más procesos
        if ! preguntar_si_no "¿Seguir añadiendo procesos?";then
            break
        fi

    done

}


# ------------------------------------
# --------- DATOS POR ARCHIVO --------
# ------------------------------------

# DES: Comprueba que la carpeta existe y que hay archivos dentro.
#      Tambien crea la lista con los archivos que hay dentro
datos_archivo_comprobar() {

    # Si no existe la carpeta
    if [ ! -d "${carpetaDatos}" ];then
        mkdir "${carpetaDatos}"
        echo -e "${cl[av]}${ft[0]}AVISO.${rstf} No se ha encontrado ningún archivo en la carpeta ${ft[0]}${cl[re]}${carpetaDatos}${rstf}. Saliendo..."
        exit
    fi

    for arch in "$carpetaDatos"/*;do
        lista+=("${arch##*/}")
    done

    # Si no hay archivos en la carpeta
    if [ "${lista[0]}" == "*" ];then
        echo -e "${cl[av]}${ft[0]}AVISO.${rstf} No se ha encontrado ningún archivo en la carpeta ${ft[0]}${cl[re]}${carpetaDatos}${rstf}. Saliendo..."
        exit
    fi

}

# DES: Comprueba que la carpeta existe y que hay archivos dentro.
#      Tambien crea la lista con los archivos que hay dentro
datos_archivo_rangos_comprobar() {

    # Si no existe la carpeta
    if [ ! -d "${carpetaRangos}" ];then
        mkdir "${carpetaRangos}"
        echo -e "${cl[av]}${ft[0]}AVISO.${rstf} No se ha encontrado ningún archivo en la carpeta ${ft[0]}${cl[re]}${carpetaRangos}${rstf}. Saliendo..."
        exit
    fi

    for arch in "$carpetaRangos"/*;do
        lista+=("${arch##*/}")
    done

    # Si no hay archivos en la carpeta
    if [ "${lista[0]}" == "*" ];then
        echo -e "${cl[av]}${ft[0]}AVISO.${rstf} No se ha encontrado ningún archivo en la carpeta ${ft[0]}${cl[re]}${carpetaRangos}${rstf}. Saliendo..."
        exit
    fi

}

# DES: Muestra una lista con todos los archivos de la que se puede seleccionar el que se quiera
datos_archivo_seleccionar() {
    
    cabecera "Selección archivo de datos"
    echo "¿Que archivo quieres usar?"
    echo
    # Por cada archivo en la carpeta imprime una linea
    for archivo in ${!lista[*]};do
        echo -e "    ${cl[$re]}${ft[0]}[$(( $archivo + 1 ))]${rstf} <- ${lista[$archivo]}"
    done
    echo
    echo -n "Selección: "

    while :;do
        leer_numero_entre seleccion 1 ${#lista[*]}
        # En caso de que el valor devuelto por la función anterior
        case $? in
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural
            * )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf} Introduce un número entre ${ft[0]}${cl[$re]}1${rstf} y ${ft[0]}${cl[$re]}${#lista[*]}${rstf}: "
            ;;
        esac
    done


    ((seleccion--))

    cabecera "Selección archivo de datos"
    echo "¿Que archivo quieres usar?"
    echo
    # Por cada archivo en la carpeta imprime una linea
    for archivo in ${!lista[*]};do
        if [ $archivo -eq $seleccion ];then
            echo -e "    ${cl[1]}${ft[0]}${cf[2]}[$(( $archivo + 1 ))] <- ${lista[$archivo]}${rstf}"
        else
            echo -e "    ${cl[$re]}${ft[0]}[$(( $archivo + 1 ))]${rstf} <- ${lista[$archivo]}"
        fi
    done
    echo

    # Haya nombre del archivo seleccionado
    seleccion=${lista[$seleccion]}
    

    sleep 0.5

}

# DES: Añade a los informes el archivos que se va a usar
datos_archivo_informes() {
    # Informar el archivo que se usa.
    informar_plano "El archivo de datos usado es: ${seleccion}\n"
    informar_color "El archivo de datos usado es: ${cl[re]}${ft[0]}${seleccion}${rstf}\n"
}

# DES: Leer los datos del archivo seleccionado
datos_archivo_leer() {

    local linea=""
    # número de linea
    local n=0
    # número de proceso
    local p=1
    # número de dirección
    local d=0

    # Datos del proceso que se está leyendo
    local datosProceso=()

    # Hayar path completa del archivo seleccionado
    seleccion="${carpetaDatos}/$seleccion"

    # se va leyendo cada linea del archivo
    while read linea;do
        case $n in
            # Número de direcciones
            1 )
                tamanoMemoria=$linea
            ;;
            # Tamaño de página
            3 )
                tamanoPagina=$linea
                numeroMarcos=$(( $tamanoMemoria / $tamanoPagina ))
            ;;
            # mNUR
            5 )
                mNUR=$linea
            ;;
        esac

        if [ $n -ge 8 ];then

            # Se divide la linea con "," como delimitador y la guarda en datosProceso
            IFS=',' read -ra datosProceso <<< "$linea"

            procesos+=($p)
            colorProceso[$p]=$(( (${p} % 12) + 5 ))
            generar_nombre_proceso
            tiempoLlegada[$p]=${datosProceso[0]}
            tiempoEjecucion[$p]=$(( ${#datosProceso[*]} - 2 ))
            minimoEstructural[$p]=${datosProceso[1]}

            # anchos
            # Calcular ancho columna tiempo llegada
            [ $(( ${#tiempoLlegada[$p]} + 2 )) -gt ${anchoColTll} ] \
                && anchoColTll=$(( ${#tiempoLlegada[$p]} + 2 ))
            # Calcular ancho columna minimo estructural
            [ $(( ${#minimoEstructural[$p]} + 2 )) -gt ${anchoColNm} ] \
                && anchoColNm=$(( ${#minimoEstructural[$p]} + 2 ))
            # Calcular ancho columna tiempo llegada
            [ $(( ${#tiempoEjecucion[$p]} + 2 )) -gt ${anchoColTej} ] \
                && anchoColTej=$(( ${#tiempoEjecucion[$p]} + 2 ))


            for (( i=2; i<${#datosProceso[*]};i++ ));do

                d=$(( $i - 2 ))
                procesoDireccion[$p,$d]=${datosProceso[$i]}

                procesoPagina[$p,$d]=$(( ${procesoDireccion[$p,$d]} / $tamanoPagina ))

                # Actualizar anchoGen si la dirección de página es muy grande
                [ ${#procesoPagina[$p,$d]} -gt $anchoGen ] && anchoGen=${#procesoPagina[$p,$d]}

            done

            ((p++))

        fi

        ((n++))
        
    done < "$seleccion"

}

# DES: Leer los datos del archivo de rangos seleccionado
datos_archivo_rangos_leer() {

    local linea=""
    # número de linea
    local n=0
    # número de proceso
    local p=1
    # número de dirección
    local d=0

    # Datos del proceso que se está leyendo
    local datosProceso=()

    # Hayar path completa del archivo seleccionado
    seleccion="${carpetaRangos}/$seleccion"

	while IFS= read -r line
	do
		case $n in
            2 )
                numMarcosMinimo=$line
            ;;
            4 )
                numMarcosMaximo=$line	
            ;;
            6 )
                tamanoPaginaMinimo=$line
            ;;
            8 )
				tamanoPaginaMaximo=$line
            ;;
            10 )
				minimoReubicacionMinimo=$line
            ;;
            12 )
                minimoReubicacionMaximo=$line
            ;;
            15 )
                numeroProcesosMinimo=$line
            ;;
			17 )
                numeroProcesosMaximo=$line
            ;;
			19 )
                tiempoLlegadaMinimo=$line
            ;;
			21 )
                tiempoLlegadaMaximo=$line
            ;;
			23 )
                tiempoEjecucionMinimo=$line
            ;;
			25 )
                tiempoEjecucionMaximo=$line
            ;;
			27 )
                minimoEstructuralMinimo=$line
            ;;
			29 )
                minimoEstructuralMaximo=$line
            ;;
			31 )
                direccionMinima=$line
            ;;
			33 )
                direccionMaxima=$line
            ;;
        esac

        ((n++))
        
    done < "$seleccion"
}

# DES: Introducir los datos de la ultima ejecución
datos_archivo_ultima_ejecucion() {
    # Archivo datos.txt es el fichero de ultima ejecución.
    local seleccion=datos.txt

    # Hacer los informes
    datos_archivo_informes

    # Interpreta los datos que hay en el archivos seleccionado
    # y crea todas las demás variables a partir de ellos
    datos_archivo_leer
    
    # Ordenar los procesos
    datos_ordenar_llegada
    
    # Mostrar la información de la memoria
    datos_memoria_tabla

    

    pausa_tecla

}

# DES: Introducir los datos de la ultima ejecución
datos_archivo_ultima_ejecucion_random() {
    # Archivo datos.txt es el fichero de ultima ejecución.
    local seleccion=datosrangos.txt

    # Hacer los informes
    datos_archivo_informes

    # Interpreta los datos que hay en el archivos seleccionado
    # y crea todas las demás variables a partir de ellos
    datos_archivo_rangos_leer
	
	# Mostrar la información de la memoria
	clear
    datos_random_tabla1
	pausa_tecla
	
	#Calcula nuevos datos a partir de los rangos
	aleatorio_entre numeroMarcos ${numMarcosMinimo} ${numMarcosMaximo}
	aleatorio_entre tamanoPagina ${tamanoPaginaMinimo} ${tamanoPaginaMaximo}
    datos_random_memoria
	aleatorio_entre mNUR ${minimoReubicacionMinimo} ${minimoReubicacionMaximo}
	aleatorio_entre numeroProcesos ${numeroProcesosMinimo} ${numeroProcesosMaximo}
	
	# GENERAR LOS PROCESOS    
    for (( p=0; p < ${numeroProcesos}; p++ ));do

        clear
        echo "Generando procesos..."
        barra_loading "$(( $p + 1 ))" "${numeroProcesos}"

        # Añadir proceso a lista de procesos
        procesos+=($p)
        # Asignar color al proceso.
        colorProceso[$p]=$(( (${p} % 12) + 5 ))
        # Dar nombre al proceso 1 -> P01
        generar_nombre_proceso
        
        aleatorio_entre tiempoLlegada[$p] ${tiempoLlegadaMinimo} ${tiempoLlegadaMaximo}
        aleatorio_entre tiempoEjecucion[$p] ${tiempoEjecucionMinimo} ${tiempoEjecucionMaximo}
        
        # Si se aceptan desperdicios cambiar como se calcula el mínimo estructural
        if [[ $desperdicios -eq 1 ]];then
            aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimo} ${minimoEstructuralMaximo}
        else
            # tiempo de ejecución es menor al mínimo máximo se escoge como máximo el tiempo de ejecución
            if [[ ${tiempoEjecucion[$p]} -lt ${minimoEstructuralMaximo} ]];then
                aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimo} ${tiempoEjecucion[$p]}
            # Si no se coge el mínimo máximo
            else
                aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimo} ${minimoEstructuralMaximo}
            fi
        fi

        # calcular las direcciones y páginas
        for (( d=0; d < ${tiempoEjecucion[$p]}; d++ ));do
            aleatorio_entre procesoDireccion[$p,$d] ${direccionMinima} ${direccionMaxima}
            procesoPagina[${p},${d}]=$(( procesoDireccion[${p},${d}] / $tamanoPagina ))

            # Actualizar anchoGen si la dirección de página es muy grande
            [ ${#procesoPagina[$p,$d]} -gt $anchoGen ] && anchoGen=${#procesoPagina[$p,$d]}

        done

        # calcular anchos
        # Calcular ancho columna tiempo llegada
        [ $(( ${#tiempoLlegada[$p]} + 2 )) -gt ${anchoColTll} ] \
            && anchoColTll=$(( ${#tiempoLlegada[$p]} + 2 ))
        # Calcular ancho columna minimo estructural
        [ $(( ${#minimoEstructural[$p]} + 2 )) -gt ${anchoColNm} ] \
            && anchoColNm=$(( ${#minimoEstructural[$p]} + 2 ))
        # Calcular ancho columna tiempo llegada
        [ $(( ${#tiempoEjecucion[$p]} + 2 )) -gt ${anchoColTej} ] \
            && anchoColTej=$(( ${#tiempoEjecucion[$p]} + 2 ))

    done
	
	# Ordenar los procesos
    datos_ordenar_llegada
	# Hacer los informes
	datos_random_informes1
    # Mostrar la información de la memoria
	clear
    datos_random_tabla1

    pausa_tecla

}

# DES: Introducir los datos mediante archivo
datos_archivo() {

    # Lista con los archivos de la carpeta de datos
    local lista=()
    # Archivo que se ha seleccionado de la lista
    local seleccion=""

    # comprobaciones previas
    datos_archivo_comprobar

    # Seleccionar archivo
    datos_archivo_seleccionar

    # Hacer los informes
    datos_archivo_informes

    # Interpreta los datos que hay en el archivos seleccionado
    # y crea todas las demás variables a partir de ellos
    datos_archivo_leer
    
    # Ordenar los procesos
    datos_ordenar_llegada
    
    # Mostrar la información de la memoria
    datos_memoria_tabla

    

    pausa_tecla

}

# DES: Introducir los datos mediante archivo de rangos
datos_archivo_rangos() {

    #Parametros para la memoria
	local tamanoPaginaMinimo="-"
	local tamanoPaginaMaximo="-"
	
	local numMarcosMinimo="-"
	local numMarcosMaximo="-"
	
	local minimoReubicacionMinimo="-"
	local minimoReubicacionMaximo="-"
	# Lista con los archivos de la carpeta de datos
    local lista=()
    # Archivo que se ha seleccionado de la lista
    local seleccion=""
	

    # comprobaciones previas
    datos_archivo_rangos_comprobar

    # Seleccionar archivo
    datos_archivo_seleccionar

    # Hacer los informes
    datos_archivo_informes

    # Interpreta los datos que hay en el archivos seleccionado
    # y crea todas las demás variables a partir de ellos
    datos_archivo_rangos_leer

	# Mostrar la información de los rangos de memoria
	clear
    datos_random_tabla1
	pausa_tecla    
	
	#Calcula nuevos datos a partir de los rangos
	aleatorio_entre numeroMarcos ${numMarcosMinimo} ${numMarcosMaximo}
	aleatorio_entre tamanoPagina ${tamanoPaginaMinimo} ${tamanoPaginaMaximo}
    datos_random_memoria
	aleatorio_entre mNUR ${minimoReubicacionMinimo} ${minimoReubicacionMaximo}
	aleatorio_entre numeroProcesos ${numeroProcesosMinimo} ${numeroProcesosMaximo}
	
	# GENERAR LOS PROCESOS    
    for (( p=0; p < ${numeroProcesos}; p++ ));do

        clear
        echo "Generando procesos..."
        barra_loading "$(( $p + 1 ))" "${numeroProcesos}"

        # Añadir proceso a lista de procesos
        procesos+=($p)
        # Asignar color al proceso.
        colorProceso[$p]=$(( (${p} % 12) + 5 ))
        # Dar nombre al proceso 1 -> P01
        generar_nombre_proceso
        
        aleatorio_entre tiempoLlegada[$p] ${tiempoLlegadaMinimo} ${tiempoLlegadaMaximo}
        aleatorio_entre tiempoEjecucion[$p] ${tiempoEjecucionMinimo} ${tiempoEjecucionMaximo}
        
        # Si se aceptan desperdicios cambiar como se calcula el mínimo estructural
        if [[ $desperdicios -eq 1 ]];then
            aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimo} ${minimoEstructuralMaximo}
        else
            # tiempo de ejecución es menor al mínimo máximo se escoge como máximo el tiempo de ejecución
            if [[ ${tiempoEjecucion[$p]} -lt ${minimoEstructuralMaximo} ]];then
                aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimo} ${tiempoEjecucion[$p]}
            # Si no se coge el mínimo máximo
            else
                aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimo} ${minimoEstructuralMaximo}
            fi
        fi

        # calcular las direcciones y páginas
        for (( d=0; d < ${tiempoEjecucion[$p]}; d++ ));do
            aleatorio_entre procesoDireccion[$p,$d] ${direccionMinima} ${direccionMaxima}
            procesoPagina[${p},${d}]=$(( procesoDireccion[${p},${d}] / $tamanoPagina ))

            # Actualizar anchoGen si la dirección de página es muy grande
            [ ${#procesoPagina[$p,$d]} -gt $anchoGen ] && anchoGen=${#procesoPagina[$p,$d]}

        done

        # calcular anchos
        # Calcular ancho columna tiempo llegada
        [ $(( ${#tiempoLlegada[$p]} + 2 )) -gt ${anchoColTll} ] \
            && anchoColTll=$(( ${#tiempoLlegada[$p]} + 2 ))
        # Calcular ancho columna minimo estructural
        [ $(( ${#minimoEstructural[$p]} + 2 )) -gt ${anchoColNm} ] \
            && anchoColNm=$(( ${#minimoEstructural[$p]} + 2 ))
        # Calcular ancho columna tiempo llegada
        [ $(( ${#tiempoEjecucion[$p]} + 2 )) -gt ${anchoColTej} ] \
            && anchoColTej=$(( ${#tiempoEjecucion[$p]} + 2 ))

    done
	
	# Mostrar la información de los rangos de memoria
	clear
    datos_random_tabla1
	# Hacer los informes
	datos_random_informes1
	
    # Ordenar los procesos
    datos_ordenar_llegada
	
	# Guarda los datos de ultima ejecución o el fichero seleccionado
	datos_rango_guardar
    
    pausa_tecla

}


# ------------------------------------
# --------- DATOS RANDOM -------------
# ------------------------------------

# DES: Muestra los parámetros para la generación de datos de memoria
datos_random_tabla1() {
    echo -e         "${cf[ac]}                                                                                ${rstf}"
    echo -e         "${cf[17]}                                                                                ${rstf}"
    printf  "${cf[17]}${cl[1]}    Número de marcos de página : %-45s  ${rstf}\n" "[ ${numMarcosMinimo} - ${numMarcosMaximo} ] : ${numeroMarcos}"
	printf  "${cf[17]}${cl[1]}     Tamaño de marco de página : %-45s  ${rstf}\n" "[ ${tamanoPaginaMinimo} - ${tamanoPaginaMaximo} ] : ${tamanoPagina}"
	printf  "${cf[17]}${cl[1]}          Tamaño de la memoria : %-45s  ${rstf}\n" "${tamanoMemoria}"
    printf  "${cf[17]}${cl[1]}    Número máx de uds. para la reubicación : %-33s  ${rstf}\n" "[ ${minimoReubicacionMinimo} - ${minimoReubicacionMaximo} ] : ${mNUR}"
    echo -e         "${cf[17]}                                                                                ${rstf}"
    printf  "${cf[17]}${cl[1]}            Número de procesos : %-45s  ${rstf}\n" "[ ${numeroProcesosMinimo} - ${numeroProcesosMaximo} ] : ${numeroProcesos}"
    printf  "${cf[17]}${cl[1]}             Tiempo de llegada : %-45s  ${rstf}\n" "[ ${tiempoLlegadaMinimo} - ${tiempoLlegadaMaximo} ]"
    printf  "${cf[17]}${cl[1]}           Tiempo de ejecución : %-45s  ${rstf}\n" "[ ${tiempoEjecucionMinimo} - ${tiempoEjecucionMaximo} ]"
    printf  "${cf[17]}${cl[1]}            Mínimo estructural : %-45s  ${rstf}\n" "[ ${minimoEstructuralMinimo} - ${minimoEstructuralMaximo} ]"
    printf  "${cf[17]}${cl[1]}                   Direcciones : %-45s  ${rstf}\n" "[ ${direccionMinima} - ${direccionMaxima} ]"
    echo -e         "${cf[17]}                                                                                ${rstf}"
    echo -e         "${cf[ac]}                                                                                ${rstf}"
    echo
}

# DES: Añade la tabla con los parámetros a los informes de datos de memoria
datos_random_informes1() {
    # Informe color
    informar_color         "${cf[ac]}                                                                                ${rstf}"
    informar_color         "${cf[17]}                                                                                ${rstf}"
    informar_color "${cf[17]}${cl[1]}    Número de marcos de página : %-45s  ${rstf}\n" "[ ${numMarcosMinimo} - ${numMarcosMaximo} ] : ${numeroMarcos}"
	informar_color "${cf[17]}${cl[1]}     Tamaño de marco de página : %-45s  ${rstf}\n" "[ ${tamanoPaginaMinimo} - ${tamanoPaginaMaximo} ] : ${tamanoPagina}"
	informar_color "${cf[17]}${cl[1]}          Tamaño de la memoria : %-45s  ${rstf}\n" "${tamanoMemoria}"
    informar_color "${cf[17]}${cl[1]}    Número máx de uds. para la reubicación : %-33s  ${rstf}\n" "[ ${minimoReubicacionMinimo} - ${minimoReubicacionMaximo} ] : ${mNUR}"
    informar_color         "${cf[17]}                                                                                ${rstf}"
    informar_color "${cf[17]}${cl[1]}            Número de procesos : %-45s  ${rstf}\n" "[ ${numeroProcesosMinimo} - ${numeroProcesosMaximo} ] : ${numeroProcesos}"
    informar_color "${cf[17]}${cl[1]}             Tiempo de llegada : %-45s  ${rstf}\n" "[ ${tiempoLlegadaMinimo} - ${tiempoLlegadaMaximo} ]"
    informar_color "${cf[17]}${cl[1]}           Tiempo de ejecución : %-45s  ${rstf}\n" "[ ${tiempoEjecucionMinimo} - ${tiempoEjecucionMaximo} ]"
    informar_color "${cf[17]}${cl[1]}            Mínimo estructural : %-45s  ${rstf}\n" "[ ${minimoEstructuralMinimo} - ${minimoEstructuralMaximo} ]"
    informar_color "${cf[17]}${cl[1]}                   Direcciones : %-45s  ${rstf}\n" "[ ${direccionMinima} - ${direccionMaxima} ]"
    informar_color         "${cf[17]}                                                                                ${rstf}"
    informar_color         "${cf[ac]}                                                                                ${rstf}"
    informar_color ""

    # Informe plano
    informar_plano "██████████████████████████████████████████████████████████████████████"
    informar_plano "█                                                                    █"
    informar_plano "█    Número de marcos de página : %-34s █" "[ ${numMarcosMinimo} - ${numMarcosMaximo} ] : ${numeroMarcos}"
    informar_plano "█     Tamaño de marco de página : %-34s █" "[ ${tamanoPaginaMinimo} - ${tamanoPaginaMaximo} ] : ${tamanoPagina}"
    informar_plano "█          Tamaño de la memoria : %-34s █" "${tamanoMemoria}"
    informar_plano "█    Número máx de uds. para la reubicación : %-22s █" "[ ${minimoReubicacionMinimo} - ${minimoReubicacionMaximo} ] : ${mNUR}"
    informar_plano "█                                                                    █"
	informar_plano "█            Número de procesos : %-34s █" "[ ${numeroProcesosMinimo} - ${numeroProcesosMaximo} ] : ${numeroProcesos}"
    informar_plano "█             Tiempo de llegada : %-34s █" "[ ${tiempoLlegadaMinimo} - ${tiempoLlegadaMaximo} ]"
	informar_plano "█           Tiempo de ejecución : %-34s █" "[ ${tiempoEjecucionMinimo} - ${tiempoEjecucionMaximo} ]"
	informar_plano "█            Mínimo estructural : %-34s █" "[ ${minimoEstructuralMinimo} - ${minimoEstructuralMaximo} ]"
	informar_plano "█                   Direcciones : %-34s █" "[ ${direccionMinima} - ${direccionMaxima} ]"
	informar_plano "█                                                                    █"
	informar_plano "██████████████████████████████████████████████████████████████████████"
    informar_plano ""
}


# DES: Introducir número de procesos a crear
datos_random_procesos() {

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}mínimo${rstf} del ${ft[0]}${cl[$re]}número de procesos${rstf}: "
    while :;do

        leer_numero numeroProcesosMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;

        esac
    done

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}máximo${rstf} del ${ft[0]}${cl[$re]}número de procesos${rstf}: "
    while :;do

        leer_numero_entre numeroProcesosMaximo $numeroProcesosMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El máximo no puede ser menor al mínimo (${ft[0]}${cl[$re]}${tamanoPaginaMinimo}${rstf}): "
            ;;

        esac
    done

}

# DES: Introducir tamaños de memoria
datos_random_memoria() {

    clear
    datos_random_tabla1
	tamanoMemoria=$(( $numeroMarcos * $tamanoPagina ))

}

# DES: Introducir tamaño de páginas
datos_random_pagina() {

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}mínimo${rstf} para el ${ft[0]}${cl[$re]}tamaño de marco de página${rstf}: "
    while :;do

        leer_numero tamanoPaginaMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;

        esac
    done

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}máximo${rstf} para el ${ft[0]}${cl[$re]}tamaño de marco de página${rstf}: "
    while :;do

        leer_numero_entre tamanoPaginaMaximo $tamanoPaginaMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El máximo no puede ser menor al mínimo (${ft[0]}${cl[$re]}${tamanoPaginaMinimo}${rstf}): "
            ;;

        esac
    done

}

# DES: Introducir el numero de marcos
datos_random_marcos() {

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}mínimo${rstf} para el ${ft[0]}${cl[$re]}número de marcos de página${rstf}: "
    while :;do

        leer_numero numMarcosMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;

        esac
    done

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}máximo${rstf} para el ${ft[0]}${cl[$re]}número de marcos de página${rstf}: "
    while :;do

        leer_numero_entre numMarcosMaximo $numMarcosMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El máximo no puede ser menor al mínimo (${ft[0]}${cl[$re]}${numMarcosMinimo}${rstf}): "
            ;;

        esac
    done

}

# DES: Introducir minimos para la reubicacion
datos_random_reubicacion() {

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}mínimo${rstf} del ${ft[0]}${cl[$re]}número máximo de uds. para la reubicación${rstf}: "
    while :;do

        leer_numero minimoReubicacionMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;

        esac
    done

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}máximo${rstf} del ${ft[0]}${cl[$re]}número máximo de uds. para la reubicación${rstf}: "
    while :;do

        leer_numero_entre minimoReubicacionMaximo $minimoReubicacionMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El máximo no puede ser menor al mínimo (${ft[0]}${cl[$re]}${minimoReubicacionMinimo}${rstf}): "
            ;;

        esac
    done

}

# DES: Introducir tiempos de llegada
datos_random_llegada() {

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}mínimo${rstf} para el ${ft[0]}${cl[$re]}tiempo de llegada${rstf} de los procesos: "
    while :;do

        leer_numero tiempoLlegadaMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;

        esac
    done

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}mánimo${rstf} para el ${ft[0]}${cl[$re]}tiempo de llegada${rstf} de los procesos: "
    while :;do

        leer_numero_entre tiempoLlegadaMaximo $tiempoLlegadaMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El máximo no puede ser menor al mínimo (${ft[0]}${cl[$re]}${tiempoLlegadaMinimo}${rstf}): "
            ;;

        esac
    done

}

# DES: Introducir tiempos de ejecución
datos_random_ejecucion() {

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}mínimo${rstf} para el ${ft[0]}${cl[$re]}tiempo de ejecución${rstf} de los procesos: "
    while :;do

        leer_numero_entre tiempoEjecucionMinimo 1
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El tiempo de ejecución mínimo es ${ft[0]}${cl[$re]}1${rstf}: "
            ;;

        esac
    done

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}máximo${rstf} para el ${ft[0]}${cl[$re]}tiempo de ejecución${rstf} de los procesos: "
    while :;do

        leer_numero_entre tiempoEjecucionMaximo $tiempoEjecucionMinimo
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El máximo no puede ser menor al mínimo (${ft[0]}${cl[$re]}${tiempoEjecucionMinimo}${rstf}): "
            ;;

        esac
    done

}

# DES: Introducir mínimos estructurales
datos_random_nm() {
    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}mínimo${rstf} del ${ft[0]}${cl[$re]}mínimo estructural${rstf} de los procesos: "
    while :;do

        desperdicios=-1
        leer_numero_entre minimoEstructuralMinimo 1 $numeroMarcos
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                # Casos de desperdicios
                # Si el mínimo estructural mínimo es mayor al tiempo de ejecución máximo
                if [[ ${minimoEstructuralMinimo} -gt ${tiempoEjecucionMaximo} ]];then
                    preguntar_si_no "${ft[0]}${cl[4]}AVISO${rstf}. El mínimo estructural mínimo es mayor al tiempo de ejecución máximo.\nVan a haber desperdicios en todos los procesos. ¿Continuar?" \
                        && desperdicios=1 \
                        || desperdicios=0

                # Si el mínimo estructural mínimo es mayor al tiempo de ejecución mínimo
                elif [[ ${minimoEstructuralMinimo} -gt ${tiempoEjecucionMinimo} ]];then
                    preguntar_si_no "${ft[0]}${cl[4]}AVISO${rstf}. El mínimo estructural mínimo es mayor al tiempo de ejecución mínimo.\nPodrían haber desperdicios. ¿Continuar?" \
                        && desperdicios=1 \
                        || desperdicios=0
                fi

                case ${desperdicios} in
                    0 )
                        # resetear la pregunta
                        minimoEstructuralMinimo="-"
                        clear
                        datos_random_tabla1
                        echo -e -n "Rango ${ft[0]}${cl[$re]}mínimo${rstf} del ${ft[0]}${cl[$re]}mínimo estructural${rstf} de los procesos: "
                        ;;
                    * )
                        # salir
                        break
                        ;;
                esac
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El mínimo estructural no puede ser mayor al número de marcos (${ft[0]}${cl[$re]}$numeroMarcos${rstf}): "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El mínimo estructural mínimo es ${ft[0]}${cl[$re]}1${rstf}: "
            ;;

        esac
    done

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}máximo${rstf} del ${ft[0]}${cl[$re]}mínimo estructural${rstf} de los procesos: "
    while :;do

        leer_numero_entre minimoEstructuralMaximo $minimoEstructuralMinimo $numeroMarcos
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El mínimo estructural no puede ser mayor al número de marcos (${ft[0]}${cl[$re]}$numeroMarcos${rstf}): "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El máximo no puede ser menor al mínimo (${ft[0]}${cl[$re]}${minimoEstructuralMinimo}${rstf}): "
            ;;

        esac
    done

}

# DES: Introducir rango de direcciones
datos_random_direcciones() {

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}mínimo${rstf} para el valor de las ${ft[0]}${cl[$re]}direcciones${rstf} de los procesos: "
    while :;do

        leer_numero direccionMinima
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;

        esac
    done

    clear
    datos_random_tabla1

    echo -n -e "Rango ${ft[0]}${cl[$re]}máximo${rstf} para el valor de las ${ft[0]}${cl[$re]}direcciones${rstf} de los procesos: "
    while :;do

        leer_numero_entre direccionMaxima $direccionMinima
        # En caso de que el valor devuelto por la función anterior
        case $? in
            
            # Valor válido
            0 )
                break
            ;;
            # Valor no número natural o No se introduce nada
            1 | 2)
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce un ${ft[0]}${cl[$re]}número natural${rstf}: "
            ;;
            # Valor demasiado grande
            3 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Valor demasiado grande: "
            ;;
            # Valor demasiado pequeño
            4 )
                echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. El máximo no puede ser menor al mínimo (${ft[0]}${cl[$re]}${direccionMinima}${rstf}): "
            ;;

        esac
    done

}


# DES: Generar los procesos de forma pseudo-aleatoria
datos_random() {
	# Parámetros
    local tiempoLlegadaMinimo="-"
    local tiempoLlegadaMaximo="-"

    local tiempoEjecucionMinimo="-"
    local tiempoEjecucionMaximo="-"
	
	local numeroProcesosMinimo="-"
    local numeroProcesosMaximo="-"
	
	#Parametros para la memoria
	local tamanoPaginaMinimo="-"
	local tamanoPaginaMaximo="-"
	
	local numMarcosMinimo="-"
	local numMarcosMaximo="-"
	
	local minimoReubicacionMinimo="-"
	local minimoReubicacionMaximo="-"

    # Para saber si da igual que hayan desperdicios
    local desperdicios=""
    local minimoEstructuralMinimo="-"
    local minimoEstructuralMaximo="-"

    local direccionMinima="-"
    local direccionMaxima="-"
	
	# Preguntar si guardar el archivo de rangos
    datos_pregunta_guardar_rangos
	
	# Preguntar si guardar a archivo custom
    datos_pregunta_guardar

    # Introducir valores de la memoria
    # datos_memoria
	
	# Introducir el numero de marcos
    datos_random_marcos
	aleatorio_entre numeroMarcos ${numMarcosMinimo} ${numMarcosMaximo}
	
	# Introducir el tamaño de marcos de paginas
    datos_random_pagina
	aleatorio_entre tamanoPagina ${tamanoPaginaMinimo} ${tamanoPaginaMaximo}
	
	# Calcula el tamaño de la memoria
    datos_random_memoria
	
	# Introducir el minimo para reubicación
    datos_random_reubicacion
	aleatorio_entre mNUR ${minimoReubicacionMinimo} ${minimoReubicacionMaximo}

    # Introducir número de procesos a crear
    datos_random_procesos
	aleatorio_entre numeroProcesos ${numeroProcesosMinimo} ${numeroProcesosMaximo}

    # Introducir tiempos de llegada
    datos_random_llegada

    # Introducir tiempos de ejecución
    datos_random_ejecucion

    # Introducir minimos estructurales
    datos_random_nm

    # Introducir rango de direcciones
    datos_random_direcciones

    # Mostrar la tabla antes de generar los procesos
    clear
	datos_random_tabla1
    # Informar de la tabla
    datos_random_informes1
    pausa_tecla


    # GENERAR LOS PROCESOS    
    for (( p=0; p < ${numeroProcesos}; p++ ));do

        clear
        echo "Generando procesos..."
        barra_loading "$(( $p + 1 ))" "${numeroProcesos}"

        # Añadir proceso a lista de procesos
        procesos+=($p)
        # Asignar color al proceso.
        colorProceso[$p]=$(( (${p} % 12) + 5 ))
        # Dar nombre al proceso 1 -> P01
        generar_nombre_proceso
        
        aleatorio_entre tiempoLlegada[$p] ${tiempoLlegadaMinimo} ${tiempoLlegadaMaximo}
        aleatorio_entre tiempoEjecucion[$p] ${tiempoEjecucionMinimo} ${tiempoEjecucionMaximo}
        
        # Si se aceptan desperdicios cambiar como se calcula el mínimo estructural
        if [[ $desperdicios -eq 1 ]];then
            aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimo} ${minimoEstructuralMaximo}
        else
            # tiempo de ejecución es menor al mínimo máximo se escoge como máximo el tiempo de ejecución
            if [[ ${tiempoEjecucion[$p]} -lt ${minimoEstructuralMaximo} ]];then
                aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimo} ${tiempoEjecucion[$p]}
            # Si no se coge el mínimo máximo
            else
                aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimo} ${minimoEstructuralMaximo}
            fi
        fi

        # calcular las direcciones y páginas
        for (( d=0; d < ${tiempoEjecucion[$p]}; d++ ));do
            aleatorio_entre procesoDireccion[$p,$d] ${direccionMinima} ${direccionMaxima}
            procesoPagina[${p},${d}]=$(( procesoDireccion[${p},${d}] / $tamanoPagina ))

            # Actualizar anchoGen si la dirección de página es muy grande
            [ ${#procesoPagina[$p,$d]} -gt $anchoGen ] && anchoGen=${#procesoPagina[$p,$d]}

        done

        # calcular anchos
        # Calcular ancho columna tiempo llegada
        [ $(( ${#tiempoLlegada[$p]} + 2 )) -gt ${anchoColTll} ] \
            && anchoColTll=$(( ${#tiempoLlegada[$p]} + 2 ))
        # Calcular ancho columna minimo estructural
        [ $(( ${#minimoEstructural[$p]} + 2 )) -gt ${anchoColNm} ] \
            && anchoColNm=$(( ${#minimoEstructural[$p]} + 2 ))
        # Calcular ancho columna tiempo llegada
        [ $(( ${#tiempoEjecucion[$p]} + 2 )) -gt ${anchoColTej} ] \
            && anchoColTej=$(( ${#tiempoEjecucion[$p]} + 2 ))

    done

    datos_ordenar_llegada
	
	# Guardar a archivo custom los rangos introducidos
	datos_rango_guardar

}


# ------------------------------------
# --------- INFORMES -----------------
# ------------------------------------

# DES: Añade informes sobre características de la memoria y los procesos
datos_informar() {

    # TABLA DE MEMORIA
    # Informe a color
    informar_color        "${cf[$ac]}                                                 ${rstf}"
    informar_color         "${cf[17]}                                                 ${rstf}"
    informar_color "${cf[17]}${cl[1]}  Tamaño memoria : %-30s${rstf}" "${tamanoMemoria}"
    informar_color "${cf[17]}${cl[1]}   Tamaño página : %-30s${rstf}" "${tamanoPagina}"
    informar_color "${cf[17]}${cl[1]}   Número marcos : %-30s${rstf}" "${numeroMarcos}"
    informar_color "${cf[17]}${cl[1]}            mNUR : %-30s${rstf}" "${mNUR}"
    informar_color         "${cf[17]}                                                 ${rstf}"
    informar_color        "${cf[$ac]}                                                 ${rstf}"
    informar_color ""
    # Informe plano
    informar_plano "█████████████████████████████████████████████████"
    informar_plano "█                                               █"
    informar_plano "█  Tamaño memoria : %-28d█" "${tamanoMemoria}"
    informar_plano "█   Tamaño página : %-28d█" "${tamanoPagina}"
    informar_plano "█   Número marcos : %-28d█" "${numeroMarcos}"
    informar_plano "█            mNUR : %-28d█" "${mNUR}"
    informar_plano "█                                               █"
    informar_plano "█████████████████████████████████████████████████"
    informar_plano ""

    # TABLA DE PROCESOS
    # Informe a color (Output de la función)
    informar_color "$( datos_tabla_procesos )"
    informar_color ""
    # Informe plano (Output de la función quitando caracteres de color)
    anchoTotal=$anchoInformeBW
    informar_plano "$( datos_tabla_procesos | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" )"
    informar_plano ""

    # Guardar los informes a archivo
    guardar_informes

}

# DES: Se introducen datos sobre memoria y procesos
datos() {

    local metodo
    preguntar "Método de introducción de datos" \
              "¿Cómo quieres introducir los datos?" \
              metodo \
              "Por teclado" \
              "Por fichero de datos de última ejecución (datos.txt)" \
			  "Por otro fichero de datos" \
              "Aleatoriamente Manual" \
			  "Por fichero de rangos de última ejecución (datosrangos.txt)" \
			  "Por otro fichero de rangos"
			  

    anchoTotal=$( tput cols )

    # Dependiendo de la respuesta dada se ejecuta la función correspondiente.
    case $metodo in
        1 )
            # Introducir los datos por teclado
            datos_teclado
        ;;
		2 )
            # Introducir los ultimos datos
            datos_archivo_ultima_ejecucion
        ;;
        3 )
            # Introducir los datos por archivo
            datos_archivo
        ;;
        4 )
            # Introducir los datos aleatoriamente
            datos_random
        ;;
		5 )
            # Introducir los ultimos datos
            datos_archivo_ultima_ejecucion_random
        ;;
		6 )
            # Introducir los datos archivo de rangos
            datos_archivo_rangos
        ;;
    esac

    # Si el número de páginas es muy grande, actualizar el anchoGen
    local temp=$(( $numeroMarcos - 1 ))
    [ ${#temp} -gt $anchoGen ] && anchoGen=${#temp}

    # Mostrar la tabla de procesos final
    clear
    datos_tabla_procesos

    # Guardar a archivo custom y datos de última ejecución
    datos_guardar

    # Hacer los informes
    datos_informar

    pausa_tecla

}