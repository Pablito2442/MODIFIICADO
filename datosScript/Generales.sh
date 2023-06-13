
# ------------FUNCIONES DE INTRODUCCIÓN DE DATOS-------------

# DES: Lee la variable dada en raw. Se usa para que el input solo se interprete como texto
# RET: devuelve 0
# USO: leer var
leer() {
    read -r $1
    return 0
}

# DES: Lee un número entre 0 y el número máximo
# RET: 0=Número válido 1=Tiene caracteres no numéricos (incluyendo "-") 2=No se ha introducido nada 3=Número demasiado grande
# USO: Se usa la siguiente estructura:
leer_numero() {

    # Variable temporal en la que se guarda el valor leido
    local val
    # Leer input del usuario
    leer val

    # Eliminar 0s del principio, porque dan problemas
    # Mientras val sea más largo que 1 y el primer caracter sea 0
    while [[ "${#val}" -gt "1" && "${val:0:1}" == "0" ]];do
        # Eliminar el primer caracter
        val="${val:1}"
    done

    # Asignar el valor a $1
    eval "$1=$val"

    # Si no se ha introducido nada
    if [ ${#val} -eq 0 ];then
        return 2
    # Si se introducen valores no numéricos. Incluyendo "-"
    elif [[ ! "${val}" =~ ^[0-9]+$ ]];then
        return 1
    # Si el número es demasiado grande
    # 9223372036854775807 es el valor máximo de entero que soporta BASH. Si es sobrepasado se
    # entra a valores negativos por overflow por lo que limitando la longitud y comprobando que
    # no se han entrado a valores negativos se asegura que el valor introducido no hace overflow.
    elif [[ "${#val}" -gt 19 || "$val" -lt 0 ]] || [ "$val" -gt "$numeroMaximo" ];then
        return 3
    fi

    return 0
}

# DES: Lee un número que debe estar entre 2 valores. Usa la función anterior. El valor máximo es opcional
# RET: 0=Número válido             1=Tiene caracteres no numéricos (incluyendo "-")
#      2=No se ha introducido nada 3=Número demasiado grande 4=Número demasiado pequeño
# USO: Se usa la siguiente estructura:
leer_numero_entre() {

    # Se establece el mínimo y el máximo
    local min=$2
    local max
    # Si se da máximo y si no.
    [ $# -eq 3 ] && max=$3 || max=$numeroMaximo

    # Leer número 
    leer_numero $1
    # Dependiendo del valor devuelto por la función inmediatamente anterior
    case $? in
        
        # Valor válido
        #0 )
            # No se hace nada porque hay que compararlo más adelante   
        #;;
        # Valor no número natural
        1 )
            return 1
        ;;
        # No se ha introducido nada
        2 )
            return 2
        ;;
        # No se ha introducido nada
        3 )
            return 3
        ;;
    esac

    # Si el número introducido se pasa del mínimo
    if [ ${!1} -lt $min ];then
        return 4
    # Si el número introducido se pasa del máximo
    elif [ ${!1} -gt $max ];then
        return 3
    fi

    return 0

}

# DES: Lee un nombre de archivo válido
# USO: leer_nombre_archivo var
leer_nombre_archivo() {
    # Variable donde se guarda el valor dado mientras se procesa.
    local temp

    # Va leyendo la variable hasta que se salga del loop.
    while leer temp;do

        # Si la cadena está vacía.
        if [ ${#temp} -eq 0 ];then
            echo -e -n "${ft[0]}${cl[$av]}AVISO${rstf}. Debes introducir algo: ${rstf}"
        
        # Si se han introducido más de los caracteres permitidos. Ext4 soporta un máximo de 256 bytes
        elif [ "$(echo "$temp" | wc -c)" -gt 256 ];then
            echo -e -n "${ft[0]}${cl[$av]}AVISO${rstf}. Nombre demasiado largo: ${rstf}"

        # Si se han introducido caracteres no permitidos
        elif [[ "$temp" =~ [\/\|\<\>:\&\\] ]];then
            echo -e -n "${ft[0]}${cl[$av]}AVISO${rstf}. No uses los caracteres '${ft[0]}${cl[$re]}/${rstf}', '${ft[0]}${cl[$re]}\\"
            echo -e -n "${rstf}', '${ft[0]}${cl[$re]}<${rstf}', '${ft[0]}${cl[$re]}>${rstf}', '${ft[0]}${cl[$re]}|${rstf}', '${ft[0]}${cl[$re]}&${rstf}' o '${ft[0]}${cl[$re]}:${rstf}': ${rstf}"
        
        # Si pasa las condiciones, salir del loop.
        else
            break
        fi

    done

    # Tras salir del loop se guarda el valor en la variable dada.
    eval "$1=$temp"
}

# DES: Muestra una pantalla de pregunta genérica con los parámetros dados
# USO: preguntar "Cabecera" \
#                "Pregunta por tiempo" \
#                variable   
preguntar_segundos() {

    local titulo=$1
    local pregunta=$2

    # Elimina los caracteres especiales para guardarla en el informe a color.
    local preguntaPlano="$(echo -e "${pregunta}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"

    cabecera "$titulo"
    echo -e "$pregunta"
    echo

    local temp
    local encontrado
	local min1=1
	local max1=30
	
    echo -n "Selección ("$min1"-"$max1"): "
    # Leer el valor introducido con un mínimo de 0
    while :;do

        leer_numero_entre temp min1 max1
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

    # Muestra la pantalla tras seleccionar una respuesta valida y genera los informes
    cabecera $titulo
    echo -e $pregunta
    informar_color "$pregunta"
    informar_plano "$preguntaPlano"
    echo

    echo
    informar_color ""
    informar_plano ""
    # Asigna el valor a la variable
    eval "$3=$temp"
    sleep 0.5

}

# DES: Muestra una pantalla de pregunta genérica con los parámetros dados
# USO: preguntar "Cabecera" \
#                "Pregunta" \
#                variable   \
#                "Opción 1" \ # Var=1
#                "Opción 2" \ # Var=2
#                   ....
#                "Opción n"   # Var=n
preguntar() {

    local titulo=$1
    local pregunta=$2

    # Elimina los caracteres especiales para guardarla en el informe a color.
    local preguntaPlano="$(echo -e "${pregunta}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"

    # Vector donde se almacenan todas las opciones
    local opciones=()
    local numOpciones=$(( $# - 3 ))

    # Loop sobre los parámetros restantes para ir guardandolos en opciones
    for (( i=4; i <= $#; i++ ));do
        opciones+=("${!i}")
    done

    cabecera "$titulo"
    echo -e "$pregunta"
    echo

    # Por cada índice se muestra la opción correspondiente
    for i in ${!opciones[*]};do
        echo -e "    ${cl[$re]}${ft[0]}[$(( $i + 1 ))]$rstf <- ${opciones[i]}"
    done

    echo

    local temp
    local encontrado
    echo -n "Selección: "
    while leer temp;do
        # Va comprobando si el valor dado es válido
        for (( i=1; i <= $numOpciones; i++ ));do
            if [[ "$i" == "$temp" ]];then
                
                encontrado=1
                break
            fi
        done
        
        # si se ha dado una opción válida salir
        [ $encontrado ] && break

        # Si no se ha encontrado valor válido volver a preguntar.
        echo -n -e "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce "

        # Crea un aviso con tantas opciones como se han dado.
        for i in ${!opciones[*]};do
            if [[ "$i" == 0 ]];then
                echo -n -e "${cl[$re]}${ft[0]}$(( $i + 1 ))${rstf}"
            elif [[ "$i" == $((${#opciones[*]} - 1)) ]];then
                echo -n -e " o ${cl[$re]}${ft[0]}$(( $i + 1 ))${rstf}: "
            else
                echo -n -e ", ${cl[$re]}${ft[0]}$(( $i + 1 ))${rstf}"
            fi
        done
    done

    # Muestra la pantalla tras seleccionar una respuesta valida y genera los informes
    cabecera $titulo
    echo -e $pregunta
    informar_color "$pregunta"
    informar_plano "$preguntaPlano"
    echo

    # Muestra las opciones, con la seleccionada resaltada
    for i in ${!opciones[*]};do
        if [ $(( $i + 1 )) -eq $temp ];then
            echo -e "    ${cl[1]}${ft[0]}${cf[2]}[$(( $i + 1 ))] <- ${opciones[i]}$rstf"
            informar_color "    ${cl[1]}${ft[0]}${cf[2]}[$(( $i + 1 ))] <- ${opciones[i]}$rstf"
            informar_plano "--->[$(( $i + 1 ))] <- ${opciones[i]}"
        else
            echo -e "    ${cl[$re]}${ft[0]}[$(( $i + 1 ))]$rstf <- ${opciones[i]}"
            informar_color "    ${cl[$re]}${ft[0]}[$(( $i + 1 ))]$rstf <- ${opciones[i]}"
            informar_plano "    [$(( $i + 1 ))] <- ${opciones[i]}"
        fi
    done

    echo
    informar_color ""
    informar_plano ""
    # Asigna el valor a la variable
    eval "$3=$temp"
    sleep 0.5

}

# DES: Pregunta de respuesta sí o no. No se guarda en informes
# RET: 0=Sí 1=No
# USO: preguntar_si_no pregunta
preguntar_si_no() {
    local pregunta=$1
    local temp
    echo -n -e "${pregunta} [S/n] "
    while leer temp;do
        case $temp in
            # Si se ha introducido S o s
            S | s )
                return 0
            ;;
            # Si se ha introducido N o n
            N | n )
                return 1
            ;;
            # Valor inválido
            * )
                echo -e -n "${ft[0]}${cl[$av]}AVISO${rstf}. Introduce ${cl[$re]}${ft[0]}S${rstf} o ${cl[$re]}${ft[0]}n${rstf}: "
            ;;
        esac
    done
}

# ------------FUNCIONES DE INFORME-------------

# DES: Añade cadena a la cadena de informe plano. Se usa como si de un printf se tratara.
# USO: informar_plano "Palabrejas %s" $variable
informar_plano() {
    local temp
    printf -v temp -- "$@"
    cadenaInformeBW+="$temp\n"
}

# DES: Añade cadena a la cadena de informe plano. Se usa como si de un printf se tratara.
# USO: informar_color "Palabrejas %s" $variable
informar_color() {
    local temp
    printf -v temp -- "$@"
    cadenaInformeCOLOR+="$temp\n"
}

# Guarda las cadenas de informe a sus archivos respectivos y las vacía.
guardar_informes() {

    echo -e -n "${cadenaInformeBW}" >> "${archivoInformeBW}"

    echo -e -n "${cadenaInformeCOLOR}" >> "${archivoInformeCOLOR}"

    # Vacia las variables de informe
    cadenaInformeBW=""
    cadenaInformeCOLOR=""

}

# ------------MISC-------------

# DES: Muestra una cabecera general
# USO: cabecera "Texto a mostrar"
cabecera() {
    clear
    echo -e                "${cf[$ac]}                                                 ${rstf}"
    echo -e                 "${cf[17]}                                                 ${rstf}"
            echo -e "${cf[17]}${cl[1]}${ft[0]}  SRPT - Pag - FIFO - NC - R                     ${rstf}"
    printf          "${cf[17]}${cl[1]}  %s%*s${rstf}\n" "${1}" $((47-${#1})) "" # Mantiene el ancho de la cabecera
    echo -e                 "${cf[17]}                                                 ${rstf}"
    echo -e                "${cf[$ac]}                                                 ${rstf}"
    echo
}

# DES: Crea un número pseudoaleatorio y lo asigna a la variable.
# USO: aleatorio_entre var min max
aleatorio_entre() {
    eval "${1}=$( shuf -i ${2}-${3} -n 1 )"
}

# DES: Espera a que se pulse una tecla para continuar el programa
pausa_tecla() {
    echo -e " Pulsa ${ft[0]}${cl[$re]}ENTER${rstf} para continuar."
    read -r
}

# DES: Muestra una barra tan ancha como la terminal con la proporción $1 / $2
# USO: barra_loading actual total
barra_loading() {
    
    local ancho=$(( $(tput cols) - 4 ))
    local anchoCompleto=$(( $ancho * $1 / $2 ))
    local anchoRestante=$(( $ancho - $anchoCompleto ))
    local porcentaje=$(( 100 * $1 / $2 ))

    printf "\r${cf[ac]}%${anchoCompleto}s${cf[2]}%${anchoRestante}s${rstf}%4s" "" "" "${porcentaje}%"

}