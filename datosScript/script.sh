#!/usr/bin/env bash

# ███████████████████████████████
# █                             █
# █     FUNCIONES GENERALES     █
# █                             █
# ███████████████████████████████


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
    local rango=0
    local random_number=0
    if (( $2 <= 0 )) && (( $3 >= 0 )); then
        rango=$(( -$2 + $3 ))
        random_number=$(( $(shuf -i 0-$rango -n 1) + $2 ))
    elif (( $2 >= 0 )) && (( $3 <= 0 )); then
        rango=$(( $2 - $3 ))
        random_number=$(( $(shuf -i 0-$rango -n 1) + $3 ))
    elif (( $2 <= 0 )) && (( $3 <= 0 )); then
        rango=$(( -$2-$3 ))
        random_number=$(( $(shuf -i 0-$rango -n 1) + $2 + $3 ))
    elif (( $2 > 0 )) && (( $3 > 0 )) && (( $2 > $3 )); then
        random_number=$(shuf -i $3-$2 -n 1)
    else
        random_number=$(shuf -i $2-$3 -n 1)
    fi

    eval "${1}=$random_number"

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


# ███████████████████████████████
# █                             █
# █            INIT             █
# █                             █
# ███████████████████████████████

# Establece las variable globales.
 init_globales() {

    # Directorio donde se encuentra el script. Por si se ejecuta desde otro lugar
    readonly DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    # Variables que se pueden cambiar
    readonly maximoProcesos=99                      # Número máximo de procesos que acepta el script. (El primer proceso el el 1)
    readonly archivoAyuda="$DIR/ayuda.txt"          # Fichero de ayuda.
    readonly carpetaInformes="$DIR/informes"        # Carpeta donde se guardan los informes
    archivoInformeBW="informeBW.txt"          # Archivo de informes sin color por defecto
    archivoInformeCOLOR="informeCOLOR.txt"          # Archivo de informes con color por defecto
    readonly carpetaDatos="$DIR/FDatos"           # Carpeta donde se guardan los datos de las ejecuciones
    readonly carpetaUltimasEjecuciones="$DIR/FLast"           # Carpeta donde se guardan las ultimas ejecutaciones
    readonly carpetaRangos="$DIR/FRangos"           # Carpeta donde se guardan los rangos de las ejecuciones
    readonly carpetaRangosTotal="$DIR/FRangosAleTotal"           # Carpeta donde se guardan los rangos de las ejecuciones
	readonly archivoUltimaEjecucion="$carpetaUltimasEjecuciones/DatosLast.txt" # Archivo con los datos de la última ejecución. Siempre se guarda
	readonly archivoUltimaEjecucionRango="$carpetaUltimasEjecuciones/DatosRangosLast.txt" # Archivo con los datos de la última ejecución. Siempre se guarda
	readonly archivoRangoTotal="$carpetaRangosTotal/DatosRangosAleatorioTotal.txt" # Archivo con los datos de la última ejecución. Siempre se guarda
    readonly anchoInformeBW=95                   # Ancho del infome en texto plano

    readonly anchoNumeroProceso=${#maximoProcesos}  # Se usa para nombrar a los procesos y rellenar el nombre con 0s ej P01

    readonly numeroMaximo=$(( 9223372036854775807 / (1 + $maximoProcesos) ))
                                                    # El número máximo que soporta Bash es 9223372036854775807
                                                    # Esta variable calcula el número máximo soportado por el script despejando NM de la ecuación:
                                                    # NM      + P                  * NM                  = 9223372036854775807
                                                    # TLegada + Número de procesos * Tiempo de ejecución = 9223372036854775807
                                                    # Así nunca se va a producir overflow. Da igual lo grandes que se intenten hacer los números.
                                                    # Aunque probablemente nadie intente meter números tan grandes -_-
    
    

    # VARIABLES DE INFORME
    cadenaInformeBW=""                           # Variables de informe donde se van guardando las lineas de informe para luego
    cadenaInformeCOLOR=""                           # guardarlas a archivo
    
    # VARIABLES DE ARCHIVO DE DATOS
    archivoDatos=""                                 # Archivo en el que se guardarán los datos de la ejecución (dado por el usuario)
    archivoRangos=""                                 # Archivo en el que se guardarán los rangos de la ejecución (dado por el usuario)
	
    
    # CARACTERÍSTICAS DE LA MEMORIA
    tamanoMemoria="-"                                # Número de direcciones de la memoria
    tamanoPagina="-"                                 # Número de direcciones por página
    numeroMarcos="-"                                 # Número de páginas de la memoria ( tamanoMemoria / tamanoPagina )
    mNUR="-"                                         # Mínimo de marcos para que se produzca reubicación. (Solo NC-R)


    # DATOS DE LOS PROCESOS
    procesos=()                                     # Contiene el número de cada proceso.
    nombreProceso=()                                # Nombre del proceso (ej. proceso 0 -> P01)
    nombreProcesoColor=()                           # Nombre del proceso incluyendo variable de color
    listaLlegada=()                                 # Contiene los procesos ordenados segun llegada
    colorProceso=()                                 # Contiene los colores de cada proceso
    tiempoLlegada=()                                # Vector con todos los tiempos de llegada
    tiempoEjecucion=()                              # Vector con todos los tiempos de ejecución. Se calcula dependiendo del número de direcciones
    minimoEstructural=()                            # Mínimo estructural de todos los procesos
    declare -A -g procesoDireccion                  # Vector asociativo con todas las direcciones
    declare -A -g procesoPagina                     # Vector asociativo con todas las páginas del proceso
    declare -A -g marcos							# Vector asociativo con los marcosde cada proceso

    # ANCHO DE COLUMNAS DE TABLA
    anchoNombreProceso=${anchoNumeroProceso}        # Nombre de los procesos ej. P01
    anchoColRef=$(( ${anchoNombreProceso} + 1 ))    # Ancho de la columna Ref de la tabla
    anchoColTll=4                                   # Ancho de la columna Tll de la tabla
    anchoColTej=4                                   # Ancho de la columna Tej de la tabla
    anchoColNm=5                                    # Ancho de la columna Nm de la tabla
	anchoColMini=5                                  # Ancho de la columna Mini de la tabla
	anchoColMfin=5                                  # Ancho de la columna Mfin de la tabla

    anchoGen=$anchoNombreProceso                    # Ancho general que se usa el las barras de memoria y tiempo pequeñas.
                                                    # Puede cambiar si las direcciones de página son muy grandes o la memoria
                                                    # es muy grande o se alcanza un tiempo muy grande

}

# Establece las variables de color.
init_colores() {

    readonly cl=(
        "\e[39m"  #   Default  0
        "\e[30m"  #     Negro  1
        "\e[97m"  #    Blanco  2
        "\e[90m"  #     GrisO  3
        "\e[31m"  #      Rojo  4
        "\e[32m"  #     Verde  5
        "\e[33m"  #  Amarillo  6
        "\e[34m"  #      Azul  7
        "\e[35m"  #   Magenta  8
        "\e[36m"  #      Cian  9
        "\e[32m"  #      rojo 10
        "\e[91m"  #     RojoC 11
        "\e[92m"  #    VerdeC 12
        "\e[93m"  # AmarilloC 13
        "\e[94m"  #     AzulC 14
        "\e[95m"  #  MagentaC 15
        "\e[96m"  #     CianC 16
		"\e[37m"  #     GrisC 17
    )

    readonly cf=(
        "\e[49m"  #   Default  0
        "\e[40m"  #     Negro  1
        "\e[107m" #    Blanco  2
        "\e[100m" #     GrisO  3
        "\e[41m"  #      Rojo  4
        "\e[42m"  #     Verde  5
        "\e[43m"  #  Amarillo  6
        "\e[44m"  #      Azul  7
        "\e[45m"  #   Magenta  8
        "\e[46m"  #      Cian  9
        "\e[42m"  #      Rojo 10
        "\e[101m" #     RojoC 11
        "\e[102m" #    VerdeC 12
        "\e[103m" # AmarilloC 13
        "\e[104m" #     AzulC 14
        "\e[105m" #  MagentaC 15
        "\e[106m" #     CianC 16
		"\e[47m"  #     GrisC 17
        # "\e[100m" #    GrisO2 18
    )

    readonly ft=(
        "\e[1m"   #   Negrita 0
        "\e[22m"  # NoNegrita 1
        "\e[4m"   # Subrayado 2
        "\e[24m"  # NoSubraya 3
    )

    readonly coloresClaros=(
        2
        10
        12
        13
        14
        15
        16
    )

    # Index del color de acento, aviso y resalto
    readonly ac=7
    readonly av=4
    readonly re=13

    # Reset de formato
    readonly rstf="\e[0m"

}

# Se inicializan variables globales
 init() {
    init_globales
    init_colores
}


# ███████████████████████████████
# █                             █
# █           INTRO             █
# █                             █
# ███████████████████████████████

# Muestra la cabecera con datos relevantes
intro_cabecera_inicio() {
        # Cabecera que se muestra por pantalla
        clear
        echo -e         "${cf[ac]}                                                 ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Algoritmo de procesos  :  SRPT                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Tipo de algoritmo      :  PAGINACIÓN           ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Algoritmo de memoria   :  FIFO                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Memoria continua       :  NO                   ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Memoria reublicable    :  SÍ                   ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Autor: Maté Gómez, Pablo                       ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Autores anteriores:                            ${rstf}"
        echo -e "${cf[17]}${cl[1]}  RR-Pag-NRU-C-FI: Diego García Muñoz            ${rstf}"
        echo -e "${cf[17]}${cl[1]}  PriMayor-SN-NC-R: Iván Cortés                  ${rstf}"
        echo -e "${cf[17]}${cl[1]}  R-R-Pag-Reloj-C-FI: Ismael Franco Hernando     ${rstf}"
        echo -e "${cf[17]}${cl[1]}  FCFS-SJF-Pag-NFU-NC-R: Cacuci Catalin Andrei   ${rstf}"
        echo -e "${cf[17]}${cl[1]}  FCFS-SJF-Pag-NFU-NC-R: Jose Maria Santos       ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Asignatura: Sistemas Operativos                ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Profesor: Jose Manuel Saiz Diez                ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Este script se creó usando la versión          ${rstf}"
        echo -e "${cf[17]}${cl[1]}  5.2.2 de Bash si no se ejecuta con esta        ${rstf}"
        echo -e "${cf[17]}${cl[1]}  versión pueden surgir problemas.               ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  © Creative Commons                             ${rstf}"
        echo -e "${cf[17]}${cl[1]}  BY - Atribución (BY)                           ${rstf}"
        echo -e "${cf[17]}${cl[1]}  NC - No uso Comercial (NC)                     ${rstf}"
        echo -e "${cf[17]}${cl[1]}  SA - Compartir Igual (SA)                      ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e         "${cf[ac]}                                                 ${rstf}"

        # Informe texto plano
        informar_plano "#################################################"
        informar_plano "#                                               #"
        informar_plano "#  Algoritmo de procesos  :  SRPT               #"
        informar_plano "#  Tipo de algoritmo      :  PAGINACIÓN         #"
        informar_plano "#  Algoritmo de memoria   :  FIFO               #"
        informar_plano "#  Memoria continua       :  NO                 #"
        informar_plano "#  Memoria reublicable    :  SÍ                 #"
        informar_plano "#                                               #"
        informar_plano "#  Autor: Santos Romero, Jose Maria             #"
        informar_plano "#                                               #"
        informar_plano "#  Autores anteriores:                          #"
        informar_plano "#  RR-Pag-NRU-C-FI: Diego García Muñoz          #"
        informar_plano "#  PriMayor-SN-NC-R: Iván Cortés                #"
        informar_plano "#  R-R-Pag-Reloj-C-FI: Ismael Franco Hernando   #"
        informar_plano "#  FCFS-SJF-Pag-NFU-NC-R: Cacuci Catalin Andrei #"
        informar_plano "#  FCFS-SJF-Pag-NFU-NC-R: Jose Maria Santos     #"
        informar_plano "#                                               #"
        informar_plano "#  Asignatura: Sistemas Operativos              #"
        informar_plano "#  Profesor: Jose Manuel Saiz Diez              #"
        informar_plano "#                                               #"
        informar_plano "#  Este script se creó usando la versión        #"
        informar_plano "#  5.2.2 de Bash si no se ejecuta con esta      #"
        informar_plano "#  versión pueden surgir problemas.             #"
        informar_plano "#                                               #"
        informar_plano "#################################################"
        informar_plano "#                                               #"
        informar_plano "#  © Creative Commons                           #"
        informar_plano "#  BY - Atribución (BY)                         #"
        informar_plano "#  NC - No uso Comercial (NC)                   #"
        informar_plano "#  SA - Compartir Igual (SA)                    #"
        informar_plano "#                                               #"
        informar_plano "#################################################"
        informar_plano ""

        # Informe a color.
        informar_color         "${cf[ac]}                                                 ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Algoritmo de procesos  :  SRPT                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Tipo de algoritmo      :  PAGINACIÓN           ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Algoritmo de memoria   :  FIFO                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Memoria continua       :  NO                   ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Memoria reublicable    :  SÍ                   ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Autor: Maté Gómez, Pablo                       ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Autores anteriores:                            ${rstf}"
        informar_color "${cf[17]}${cl[1]}  RR-Pag-NRU-C-FI: Diego García Muñoz            ${rstf}"
        informar_color "${cf[17]}${cl[1]}  PriMayor-SN-NC-R: Iván Cortés                  ${rstf}"
        informar_color "${cf[17]}${cl[1]}  R-R-Pag-Reloj-C-FI: Ismael Franco Hernando     ${rstf}"
        informar_color "${cf[17]}${cl[1]}  FCFS-SJF-Pag-NFU-NC-R: Cacuci Catalin Andrei   ${rstf}"
        informar_color "${cf[17]}${cl[1]}  FCFS-SJF-Pag-NFU-NC-R: Jose Maria Santos       ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Asignatura: Sistemas Operativos                ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Profesor: Jose Manuel Saiz Diez                ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Este script se creó usando la versión          ${rstf}"
        informar_color "${cf[17]}${cl[1]}  5.2.2 de Bash si no se ejecuta con esta        ${rstf}"
        informar_color "${cf[17]}${cl[1]}  versión pueden surgir problemas.               ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  © Creative Commons                             ${rstf}"
        informar_color "${cf[17]}${cl[1]}  BY - Atribución (BY)                           ${rstf}"
        informar_color "${cf[17]}${cl[1]}  NC - No uso Comercial (NC)                     ${rstf}"
        informar_color "${cf[17]}${cl[1]}  SA - Compartir Igual (SA)                      ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color         "${cf[ac]}                                                 ${rstf}"
        informar_color ""

        pausa_tecla

}

# Muestra la cabecera con aviso sobre el tamaño de la terminal
intro_cabecera_tamano() {

        clear
        echo -e         "${cf[$ac]}                                                 ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}                      AVISO                      ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  Para visualizar correctamente la información   ${rstf}"
        echo -e "${cf[17]}${cl[1]}  es necesario poner la ventana del terminal en  ${rstf}"
        echo -e "${cf[17]}${cl[1]}  pantalla completa. Si no, hay elementos que    ${rstf}"
        echo -e "${cf[17]}${cl[1]}  no se van a ver correctamente.                 ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e "${cf[17]}${cl[1]}  También es recomendable tener la terminal      ${rstf}"
        echo -e "${cf[17]}${cl[1]}  con un tema oscuro.                            ${rstf}"
        echo -e         "${cf[17]}                                                 ${rstf}"
        echo -e        "${cf[$ac]}                                                 ${rstf}"

        # informe a color
        informar_color        "${cf[$ac]}                                                 ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}                      AVISO                      ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Para visualizar correctamente la información   ${rstf}"
        informar_color "${cf[17]}${cl[1]}  es necesario poner la ventana del terminal en  ${rstf}"
        informar_color "${cf[17]}${cl[1]}  pantalla completa. Si no, hay elementos que    ${rstf}"
        informar_color "${cf[17]}${cl[1]}  no se van a ver correctamente.                 ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  También es recomendable tener la terminal      ${rstf}"
        informar_color "${cf[17]}${cl[1]}  con un tema oscuro.                            ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color        "${cf[$ac]}                                                 ${rstf}"
        informar_color ""

        # informe texto plano
        informar_plano "#################################################"
        informar_plano "#                                               #"
        informar_plano "#                     AVISO                     #"
        informar_plano "#                                               #"
        informar_plano "# Para visualizar correctamente la información  #"
        informar_plano "# es necesario poner la ventana del terminal en #"
        informar_plano "# pantalla completa. Si no, hay elementos que   #"
        informar_plano "# no se van a ver correctamente.                #"
        informar_plano "#                                               #"
        informar_plano "# También es recomendable tener la terminal     #"
        informar_plano "# con un tema oscuro.                           #"
        informar_plano "#                                               #"
        informar_plano "#################################################"
        informar_plano ""
        
        pausa_tecla

}

# Se muestran las cabeceras
intro() {
    intro_cabecera_inicio
    intro_cabecera_tamano
}

# ███████████████████████████████
# █                             █
# █          OPCIONES           █
# █                             █
# ███████████████████████████████

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


# ███████████████████████████████
# █                             █
# █          DATOS              █
# █                             █
# ███████████████████████████████

# DES: Pregunta si se desean guardar los rangos
datos_pregunta_guardar_rangos() {

    local guardarProcesos
    preguntar "Guardar rangos" \
              "¿Dónde quieres guardar los rangos?" \
              guardarProcesos \
              "En el fichero de rangos de última ejecución (DatosRangosDefault.txt)" \
              "Otro fichero de rangos"
    
    case $guardarProcesos in
        1 )
            archivoRangos="DatosRangosDefault.txt"

            # Informar donde se guardarán los procesos.
            informar_plano "Carpeta de datos: ${carpetaRangos}"
            informar_plano "Archivo de datos: ${archivoRangos}"
            informar_plano ""

            informar_color "Carpeta de datos: ${ft[0]}${cl[re]}${carpetaRangos}${rstf}"
            informar_color "Archivo de datos: ${ft[0]}${cl[re]}${archivoRangos}${rstf}"
            informar_color ""

            # Pasa el archivo de procesos a ruta absoluta
            archivoRangos="${carpetaRangos}/${archivoRangos}"

        ;;

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
    [ ! -d "${carpetaUltimasEjecuciones}" ] \
        && mkdir "${carpetaUltimasEjecuciones}"

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

    # Guardar los datos en el archivo de última ejecución
    echo -e -n "${cadena}" > "$archivoUltimaEjecucionRango"

    # Si se ha dado un archivo de datos
    if [[ $archivoRangos ]];then
        echo -e -n "${cadena}" > "$archivoRangos"
    fi

}

# DES: Guardar los datos a archivo
datos_rango_total_guardar() {

    # Si la carpeta de datos no existe, crearla
    [ ! -d "${carpetaUltimasEjecuciones}" ] \
        && mkdir "${carpetaUltimasEjecuciones}"

    # Se crea una cadena que luego se guarda en los archivos respectivos
    local cadena=""
	
	cadena+="# RANGOS PARA LA MEMORIA:\n"
	cadena+="# Rango mínimo para el numero de marcos de página:\n"
    cadena+="${numMarcosMinimoInter}\n"
	cadena+="# Rango máximo para el numero de marcos de página:\n"
    cadena+="${numMarcosMaximoInter}\n"
    cadena+="# Rango mínimo para el tamaño de marco de página:\n"
    cadena+="${tamanoPaginaMinimo}\n"
	cadena+="# Rango máximo para el tamaño de marco de página:\n"
    cadena+="${tamanoPaginaMaximoInter}\n"
    cadena+="# Rango mínimo para el número max de uds. para la reubicación:\n"
    cadena+="${minimoReubicacionMinimoInter}\n"
	cadena+="# Rango máximo para el número max de uds. para la reubicación:\n"
    cadena+="${minimoReubicacionMaximoInter}\n"
    cadena+="# RANGOS PARA LOS PROCESOS:\n"
    cadena+="# Rango mínimo para el numero de procesos:\n"
	cadena+="${numeroProcesosMinimoInter}\n"
	cadena+="# Rango máximo para el numero de procesos:\n"
	cadena+="${numeroProcesosMaximoInter}\n"
	cadena+="# Rango mínimo para el tiempo de llegada:\n"
	cadena+="${tiempoLlegadaMinimoInter}\n"
	cadena+="# Rango máximo para el tiempo de llegada:\n"
	cadena+="${tiempoLlegadaMaximoInter}\n"
	cadena+="# Rango mínimo para el tiempo de ejecución:\n"
	cadena+="${tiempoEjecucionMinimoInter}\n"
	cadena+="# Rango máximo para el tiempo de ejecución:\n"
	cadena+="${tiempoEjecucionMaximoInter}\n"
	cadena+="# Rango mínimo para el mínimo estructural:\n"
	cadena+="${minimoEstructuralMinimoInter}\n"
	cadena+="# Rango máximo para el mínimo estructural:\n"
	cadena+="${minimoEstructuralMaximoInter}\n"
	cadena+="# Rango mínimo para las direcciones:\n"
	cadena+="${direccionMinimaInter}\n"
	cadena+="# Rango máximo para las direcciones:\n"
	cadena+="${direccionMaximaInter}\n"

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
              "En el fichero de Datos por defecto (DatosDefault.txt)" \
              "Otro fichero de datos"
    
    case $guardarProcesos in
        1 )
            archivoDatos="DatosDefault.txt"

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
    [ ! -d "${carpetaUltimasEjecuciones}" ] \
        && mkdir "${carpetaUltimasEjecuciones}"

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
    proceso=$1
    marcoIni=$2
    marcoFin=$3
    # Verificar si el proceso ya tiene valores almacenados
    if [[ -n ${marcos[${proceso}]} ]];then
        marcos[${proceso}]+=" ${marcoIni} ${marcoFin}"  
    else
        marcos[${proceso}]="${marcoIni} ${marcoFin}"  
    fi
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
    
    if [ $eleccion -eq 2 ]; then
    Mini="${strarr[${eleccion}]}"
	fi
	
	if [ $eleccion -eq 3 ]; then
    Mfin="${strarr[${eleccion}]}"
	fi

    if [ $eleccion -eq 4 ]; then
    Mini="${strarr[${eleccion}]}"
	fi
	
	if [ $eleccion -eq 5 ]; then
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

# DES: Comprueba que la carpeta existe y que hay archivos dentro.
#      Tambien crea la lista con los archivos que hay dentro
datos_archivo_rangos_totales_comprobar() {

    # Si no existe la carpeta
    if [ ! -d "${carpetaRangosTotal}" ];then
        mkdir "${carpetaRangosTotal}"
        echo -e "${cl[av]}${ft[0]}AVISO.${rstf} No se ha encontrado ningún archivo en la carpeta ${ft[0]}${cl[re]}${carpetaRangosTotal}${rstf}. Saliendo..."
        exit
    fi

    for arch in "$carpetaRangosTotal"/*;do
        lista+=("${arch##*/}")
    done

    # Si no hay archivos en la carpeta
    if [ "${lista[0]}" == "*" ];then
        echo -e "${cl[av]}${ft[0]}AVISO.${rstf} No se ha encontrado ningún archivo en la carpeta ${ft[0]}${cl[re]}${carpetaRangosTotal}${rstf}. Saliendo..."
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
    seleccion="${carpeta}/$seleccion"

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
    seleccion="${carpeta}/$seleccion"

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
    # Archivo DatosLast.txt es el fichero de ultima ejecución.
    local seleccion=DatosLast.txt
    local carpeta=$carpetaUltimasEjecuciones

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
    # Archivo DatosRangosLast.txt es el fichero de ultima ejecución.
    local seleccion=DatosRangosLast.txt
    local carpeta=$carpetaUltimasEjecuciones

    # Hacer los informes
    datos_pregunta_guardar

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
    local carpeta=$carpetaDatos

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
    local carpeta=$carpetaRangos
	

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

# DES: Introducir los datos mediante archivo de rangos
datos_archivo_rangos_total() {

    #Parametros para la memoria
	local tamanoPaginaMinimo="-"
	local tamanoPaginaMaximo="-"
	local tamanoPaginaMinimoInter="-"
	local tamanoPaginaMaximoInter="-"
	
	local numMarcosMinimo="-"
	local numMarcosMaximo="-"
    local numMarcosMinimoInter="-"
	local numMarcosMaximoInter="-"
	
	local minimoReubicacionMinimo="-"
	local minimoReubicacionMaximo="-"
    local minimoReubicacionMinimoInter="-"
	local minimoReubicacionMaximoInter="-"

    local tiempoLlegadaMinimoInter="-"
    local tiempoLlegadaMaximoInter="-"

    local tiempoEjecucionMinimoInter="-"
    local tiempoEjecucionMaximoInter="-"

    local minimoEstructuralMinimoInter="-"
    local minimoEstructuralMaximoInter="-"

    local direccionMinimaInter="-"
    local direccionMaximaInter="-"

	# Lista con los archivos de la carpeta de datos
    local lista=()
    # Archivo que se ha seleccionado de la lista
    local seleccion="DatosRangosAleatorioTotal.txt"
    local carpeta=$carpetaRangosTotal

    # Hacer los informes
    datos_archivo_informes

    # Interpreta los datos que hay en el archivos seleccionado
    # y crea todas las demás variables a partir de ellos
    datos_archivo_rangos_leer

	# Mostrar la información de los rangos de memoria
	clear
    datos_random_tabla1
	pausa_tecla   

	#Calcula nuevos rangos y datos a partir de los rangos del fichero de total
    while true; do
        aleatorio_entre numMarcosMinimoInter "${numMarcosMinimo}" "${numMarcosMaximo}"
        aleatorio_entre numMarcosMaximoInter ${numMarcosMinimo} ${numMarcosMaximo}
        aleatorio_entre numeroMarcos ${numMarcosMinimoInter} ${numMarcosMaximoInter}

        if [[ $numeroMarcos -gt 0 ]];then
            break
        elif [[ $numMarcosMinimo -le 0 ]];then
            numMarcosMinimo=1
            if [[ $numMarcosMaximo -le 0 ]];then
                numMarcosMaximo=1
            fi
        elif [[ $numMarcosMaximo -le 0 ]];then
            numMarcosMaximo=1
        fi

        # Mostrar la información de los rangos de memoria
        clear
        datos_random_total_tabla1
        printf "${ft[0]}${cl[4]} El numero de Marcos de pagina debe de ser mayor que 0 para funcionar, pulsa para recalcular los datos y poder continuar.${cl[0]}${ft[1]}\n"
        pausa_tecla
        # Hacer los informes
        datos_random_total_informes1
    done

    while true; do
        aleatorio_entre tamanoPaginaMinimoInter ${tamanoPaginaMinimo} ${tamanoPaginaMaximo}
        aleatorio_entre tamanoPaginaMaximoInter ${tamanoPaginaMinimo} ${tamanoPaginaMaximo}
        aleatorio_entre tamanoPagina ${tamanoPaginaMinimoInter} ${tamanoPaginaMaximoInter}

        if [[ $tamanoPagina -gt 0 ]];then
            break
        elif [[ $tamanoPaginaMinimo -le 0 ]];then
            tamanoPaginaMinimo=1
            if [[ $tamanoPaginaMaximo -le 0 ]];then
                tamanoPaginaMaximo=1
            fi
        elif [[ $tamanoPaginaMaximo -le 0 ]];then
            tamanoPaginaMaximo=1
        fi
            
        # Mostrar la información de los rangos de memoria
        clear
        datos_random_total_tabla1
        printf "${ft[0]}${cl[4]} El tamaño de Marco de pagina debe de ser mayor que 0 para funcionar, pulsa para recalcular los datos y poder continuar.${cl[0]}${ft[1]}\n"
        pausa_tecla
        # Hacer los informes
        datos_random_total_informes1
    done

    datos_random_memoria

    while true; do
        aleatorio_entre minimoReubicacionMinimoInter ${minimoReubicacionMinimo} ${minimoReubicacionMaximo}
        aleatorio_entre minimoReubicacionMaximoInter ${minimoReubicacionMinimo} ${minimoReubicacionMaximo}
        aleatorio_entre mNUR ${minimoReubicacionMinimoInter} ${minimoReubicacionMaximoInter}
        
        if [[ $mNUR -gt 0 ]];then
            break
        elif [[ $minimoReubicacionMinimo -le 0 ]];then
            minimoReubicacionMinimo=1
            if [[ $minimoReubicacionMaximo -le 0 ]];then
                minimoReubicacionMaximo=1
            fi
        elif [[ $minimoReubicacionMaximo -le 0 ]];then
            minimoReubicacionMaximo=1
        fi
            
        # Mostrar la información de los rangos de memoria
        clear
        datos_random_total_tabla1
        printf "${ft[0]}${cl[4]} El numero de Marco para la reubicacion debe de ser mayor que 0 para funcionar, pulsa para recalcular los datos y poder continuar.${cl[0]}${ft[1]}\n"
        pausa_tecla
        # Hacer los informes
        datos_random_total_informes1
    done

    while true; do
        aleatorio_entre numeroProcesosMinimoInter ${numeroProcesosMinimo} ${numeroProcesosMaximo}
        aleatorio_entre numeroProcesosMaximoInter ${numeroProcesosMinimo} ${numeroProcesosMaximo}
        aleatorio_entre numeroProcesos ${numeroProcesosMinimoInter} ${numeroProcesosMaximoInter}
                
        if [[ $numeroProcesos -gt 0 ]];then
            break
        elif [[ $numeroProcesosMinimo -le 0 ]];then
            numeroProcesosMinimo=1
            if [[ $numeroProcesosMaximo -le 0 ]];then
                numeroProcesosMaximo=1
            fi
        elif [[ $numeroProcesosMaximo -le 0 ]];then
            numeroProcesosMaximo=1
        fi
            
        # Mostrar la información de los rangos de memoria
        clear
        datos_random_total_tabla1
        printf "${ft[0]}${cl[4]} El numero de procesos debe de ser mayor que 0 para funcionar, pulsa para recalcular los datos y poder continuar.${cl[0]}${ft[1]}\n"
        pausa_tecla
        # Hacer los informes
        datos_random_total_informes1
    done

    while true; do
        aleatorio_entre tiempoLlegadaMinimoInter ${tiempoLlegadaMinimo} ${tiempoLlegadaMaximo}        
        aleatorio_entre tiempoLlegadaMaximoInter ${tiempoLlegadaMinimo} ${tiempoLlegadaMaximo}

        if [[ $tiempoLlegadaMinimoInter -ge 0 ]] && [[ $tiempoLlegadaMaximoInter -ge 0 ]];then
            break
        elif [[ $tiempoLlegadaMinimo -lt 0 ]];then
            tiempoLlegadaMinimo=0
            if [[ $tiempoLlegadaMaximo -lt 0 ]];then
                tiempoLlegadaMaximo=0
            fi
        elif [[ $tiempoLlegadaMaximo -lt 0 ]];then
            tiempoLlegadaMaximo=0
        fi
            
        # Mostrar la información de los rangos de memoria
        clear
        datos_random_total_tabla1
        printf "${ft[0]}${cl[4]} El tiempo de llegada debe de ser mayor que 0 para funcionar, pulsa para recalcular los datos y poder continuar.${cl[0]}${ft[1]}\n"
        pausa_tecla
        # Hacer los informes
        datos_random_total_informes1
    done

    while true; do
        aleatorio_entre tiempoEjecucionMinimoInter ${tiempoEjecucionMinimo} ${tiempoEjecucionMaximo}
        aleatorio_entre tiempoEjecucionMaximoInter ${tiempoEjecucionMinimo} ${tiempoEjecucionMaximo}

        if [[ $tiempoEjecucionMinimoInter -gt 0 ]] && [[ $tiempoEjecucionMaximoInter -gt 0 ]];then
            break
        elif [[ $tiempoEjecucionMinimo -le 0 ]];then
            tiempoEjecucionMinimo=1
            if [[ $tiempoEjecucionMaximo -le 0 ]];then
                tiempoEjecucionMaximo=1
            fi
        elif [[ $tiempoEjecucionMaximo -le 0 ]];then
            tiempoEjecucionMaximo=1
        fi
            
        # Mostrar la información de los rangos de memoria
        clear
        datos_random_total_tabla1
        printf "${ft[0]}${cl[4]} El tiempo de ejecucion debe de ser mayor que 0 para funcionar, pulsa para recalcular los datos y poder continuar.${cl[0]}${ft[1]}\n"
        pausa_tecla
        # Hacer los informes
        datos_random_total_informes1
    done

    while true; do
        aleatorio_entre minimoEstructuralMinimoInter ${minimoEstructuralMinimo} ${minimoEstructuralMaximo}
        aleatorio_entre minimoEstructuralMaximoInter ${minimoEstructuralMinimo} ${minimoEstructuralMaximo}

        if [[ $minimoEstructuralMinimoInter -gt 0 ]] && [[ $minimoEstructuralMaximoInter -gt 0 ]];then
            if [[ $minimoEstructuralMaximo -gt $numeroMarcos ]];then
                minimoEstructuralMaximo=$numeroMarcos
            fi
            if [[ $minimoEstructuralMaximoInter -ge $minimoEstructuralMinimoInter ]] && [[ $minimoEstructuralMaximoInter -le $numeroMarcos ]];then
                break
            elif [[ $minimoEstructuralMaximoInter -le $minimoEstructuralMinimoInter ]] && [[ $minimoEstructuralMinimoInter -lt $numeroMarcos ]];then
                break
            fi
        elif [[ $minimoEstructuralMinimo -le 0 ]];then
            minimoEstructuralMinimo=1
            if [[ $minimoEstructuralMaximo -le 0 ]];then
                minimoEstructuralMaximo=1
                if [[ $minimoEstructuralMaximo -gt $numeroMarcos ]];then
                minimoEstructuralMaximo=$numeroMarcos
            fi
            fi
        elif [[ $minimoEstructuralMaximo -le 0 ]];then
            minimoEstructuralMaximo=1
        fi
            
        # Mostrar la información de los rangos de memoria
        clear
        datos_random_total_tabla1
        printf "${ft[0]}${cl[4]} El Minimo Estructural debe de ser mayor que 0 y menor que el numero de marcos totales para funcionar, pulsa para recalcular los datos y poder continuar.${cl[0]}${ft[1]}\n"
        pausa_tecla
        # Hacer los informes
        datos_random_total_informes1
    done

    while true; do
        aleatorio_entre direccionMinimaInter ${direccionMinima} ${direccionMaxima}
        aleatorio_entre direccionMaximaInter ${direccionMinima} ${direccionMaxima}

        if [[ $direccionMinimaInter -gt 0 ]] && [[ $direccionMaximaInter -gt 0 ]];then
            break
        elif [[ $direccionMinima -le 0 ]];then
            direccionMinima=1
            if [[ $direccionMaxima -le 0 ]];then
                direccionMaxima=1
            fi
        elif [[ $direccionMaxima -le 0 ]];then
            direccionMaxima=1
        fi
            
        # Mostrar la información de los rangos de memoria
        clear
        datos_random_total_tabla1
        printf "${ft[0]}${cl[4]} El numero minimo de direcciones debe de ser mayor que 0 para funcionar, pulsa para recalcular los datos y poder continuar.${cl[0]}${ft[1]}\n"
        pausa_tecla
        # Hacer los informes
        datos_random_total_informes1
    done
       
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

        aleatorio_entre tiempoLlegada[$p] ${tiempoLlegadaMinimoInter} ${tiempoLlegadaMinimoInter}

        aleatorio_entre tiempoEjecucion[$p] ${tiempoEjecucionMinimoInter} ${tiempoEjecucionMaximoInter}
        
        aleatorio_entre minimoEstructural[$p] ${minimoEstructuralMinimoInter} ${minimoEstructuralMaximoInter}

        # calcular las direcciones y páginas
        for (( d=0; d < ${tiempoEjecucion[$p]}; d++ ));do
            aleatorio_entre procesoDireccion[$p,$d] ${direccionMinimaInter} ${direccionMaximaInter}
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
    datos_random_total_tabla1
    printf "${ft[0]}${cl[5]} La tabla tiene valores validos para funcionar, pulsa para continuar con la ejecucion.${cl[0]}${ft[1]}\n"
    pausa_tecla
	# Hacer los informes
	datos_random_total_informes1
	
    # Ordenar los procesos
    datos_ordenar_llegada
	
    # Preguntar si guardar el archivo de rangos
    datos_pregunta_guardar_rangos
    datos_rango_total_guardar

	# Preguntar si guardar a archivo custom
    datos_pregunta_guardar

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

# DES: Muestra los parámetros para la generación de datos de memoria
datos_random_total_tabla1() {
    echo -e         "${cf[ac]}                                                                                ${rstf}"
    echo -e         "${cf[17]}                                                                                ${rstf}"
    printf  "${cf[17]}${cl[1]}    Número de marcos de página : %-45s  ${rstf}\n" "[ ${numMarcosMinimo} - ${numMarcosMaximo} ] -> [ ${numMarcosMinimoInter} - ${numMarcosMaximoInter} ] : ${numeroMarcos} "
	printf  "${cf[17]}${cl[1]}     Tamaño de marco de página : %-45s  ${rstf}\n" "[ ${tamanoPaginaMinimo} - ${tamanoPaginaMaximo} ] -> [ ${tamanoPaginaMinimoInter} - ${tamanoPaginaMaximoInter} ] : ${tamanoPagina}"
	printf  "${cf[17]}${cl[1]}          Tamaño de la memoria : %-45s  ${rstf}\n" "${tamanoMemoria}"
    printf  "${cf[17]}${cl[1]}    Número máx de uds. para la reubicación : %-33s  ${rstf}\n" "[ ${minimoReubicacionMinimo} - ${minimoReubicacionMaximo} ] -> [ ${minimoReubicacionMinimoInter} - ${minimoReubicacionMaximoInter} ] : ${mNUR}"
    echo -e         "${cf[17]}                                                                                ${rstf}"
    printf  "${cf[17]}${cl[1]}            Número de procesos : %-45s  ${rstf}\n" "[ ${numeroProcesosMinimo} - ${numeroProcesosMaximo} ] -> [ ${numeroProcesosMinimoInter} - ${numeroProcesosMaximoInter} ] : ${numeroProcesos}"
    printf  "${cf[17]}${cl[1]}             Tiempo de llegada : %-45s  ${rstf}\n" "[ ${tiempoLlegadaMinimo} - ${tiempoLlegadaMaximo} ] -> [ ${tiempoLlegadaMinimoInter} - ${tiempoLlegadaMaximoInter} ]"
    printf  "${cf[17]}${cl[1]}           Tiempo de ejecución : %-45s  ${rstf}\n" "[ ${tiempoEjecucionMinimo} - ${tiempoEjecucionMaximo} ] -> [ ${tiempoEjecucionMinimoInter} - ${tiempoEjecucionMaximoInter} ]"
    printf  "${cf[17]}${cl[1]}            Mínimo estructural : %-45s  ${rstf}\n" "[ ${minimoEstructuralMinimo} - ${minimoEstructuralMaximo} ] -> [ ${minimoEstructuralMinimoInter} - ${minimoEstructuralMaximoInter} ]"
    printf  "${cf[17]}${cl[1]}                   Direcciones : %-45s  ${rstf}\n" "[ ${direccionMinima} - ${direccionMaxima} ] -> [ ${direccionMinimaInter} - ${direccionMaximaInter} ]"
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

# DES: Añade la tabla con los parámetros a los informes de datos de memoria
datos_random_total_informes1() {
    # Informe color
    informar_color         "${cf[ac]}                                                                                ${rstf}"
    informar_color         "${cf[17]}                                                                                ${rstf}"
    informar_color  "${cf[17]}${cl[1]}    Número de marcos de página : %-45s  ${rstf}\n" "[ ${numMarcosMinimo} - ${numMarcosMaximo} ] -> [ ${numMarcosMinimoInter} - ${numMarcosMaximoInter} ] : ${numeroMarcos} "
	informar_color  "${cf[17]}${cl[1]}     Tamaño de marco de página : %-45s  ${rstf}\n" "[ ${tamanoPaginaMinimo} - ${tamanoPaginaMaximo} ] -> [ ${tamanoPaginaMinimoInter} - ${tamanoPaginaMaximoInter} ] : ${tamanoPagina}"
	informar_color  "${cf[17]}${cl[1]}          Tamaño de la memoria : %-45s  ${rstf}\n" "${tamanoMemoria}"
    informar_color  "${cf[17]}${cl[1]}    Número máx de uds. para la reubicación : %-33s  ${rstf}\n" "[ ${minimoReubicacionMinimo} - ${minimoReubicacionMaximo} ] -> [ ${minimoReubicacionMinimoInter} - ${minimoReubicacionMaximoInter} ] : ${mNUR}"
    informar_color         "${cf[17]}                                                                                ${rstf}"
    informar_color  "${cf[17]}${cl[1]}            Número de procesos : %-45s  ${rstf}\n" "[ ${numeroProcesosMinimo} - ${numeroProcesosMaximo} ] -> [ ${numeroProcesosMinimoInter} - ${numeroProcesosMaximoInter} ] : ${numeroProcesos}"
    informar_color  "${cf[17]}${cl[1]}             Tiempo de llegada : %-45s  ${rstf}\n" "[ ${tiempoLlegadaMinimo} - ${tiempoLlegadaMaximo} ] -> [ ${tiempoLlegadaMinimoInter} - ${tiempoLlegadaMaximoInter} ]"
    informar_color  "${cf[17]}${cl[1]}           Tiempo de ejecución : %-45s  ${rstf}\n" "[ ${tiempoEjecucionMinimo} - ${tiempoEjecucionMaximo} ] -> [ ${tiempoEjecucionMinimoInter} - ${tiempoEjecucionMaximoInter} ]"
    informar_color  "${cf[17]}${cl[1]}            Mínimo estructural : %-45s  ${rstf}\n" "[ ${minimoEstructuralMinimo} - ${minimoEstructuralMaximo} ] -> [ ${minimoEstructuralMinimoInter} - ${minimoEstructuralMaximoInter} ]"
    informar_color  "${cf[17]}${cl[1]}                   Direcciones : %-45s  ${rstf}\n" "[ ${direccionMinima} - ${direccionMaxima} ] -> [ ${direccionMinimaInter} - ${direccionMaximaInter} ]"
    informar_color         "${cf[17]}                                                                                ${rstf}"
    informar_color         "${cf[ac]}                                                                                ${rstf}"
    informar_color ""

    # Informe plano
    informar_plano "██████████████████████████████████████████████████████████████████████"
    informar_plano "█                                                                    █"
    informar_plano "█    Número de marcos de página : %-34s █" "[ ${numMarcosMinimo} - ${numMarcosMaximo} ] -> [ ${numMarcosMinimoInter} - ${numMarcosMaximoInter} ] : ${numeroMarcos} "
    informar_plano "█     Tamaño de marco de página : %-34s █" "[ ${tamanoPaginaMinimo} - ${tamanoPaginaMaximo} ] -> [ ${tamanoPaginaMinimoInter} - ${tamanoPaginaMaximoInter} ] : ${tamanoPagina}"
    informar_plano "█          Tamaño de la memoria : %-34s █" "${tamanoMemoria}"
    informar_plano "█    Número máx de uds. para la reubicación : %-22s █" "[ ${minimoReubicacionMinimo} - ${minimoReubicacionMaximo} ] -> [ ${minimoReubicacionMinimoInter} - ${minimoReubicacionMaximoInter} ] : ${mNUR}"
    informar_plano "█                                                                    █"
	informar_plano "█            Número de procesos : %-34s █" "[ ${numeroProcesosMinimo} - ${numeroProcesosMaximo} ] -> [ ${numeroProcesosMinimoInter} - ${numeroProcesosMaximoInter} ] : ${numeroProcesos}"
    informar_plano "█             Tiempo de llegada : %-34s █" "[ ${tiempoLlegadaMinimo} - ${tiempoLlegadaMaximo} ] -> [ ${tiempoLlegadaMinimoInter} - ${tiempoLlegadaMaximoInter} ]"
	informar_plano "█           Tiempo de ejecución : %-34s █" "[ ${tiempoEjecucionMinimo} - ${tiempoEjecucionMaximo} ] -> [ ${tiempoEjecucionMinimoInter} - ${tiempoEjecucionMaximoInter} ]"
	informar_plano "█            Mínimo estructural : %-34s █" "[ ${minimoEstructuralMinimo} - ${minimoEstructuralMaximo} ] -> [ ${minimoEstructuralMinimoInter} - ${minimoEstructuralMaximoInter} ]"
	informar_plano "█                   Direcciones : %-34s █" "[ ${direccionMinima} - ${direccionMaxima} ] -> [ ${direccionMinimaInter} - ${direccionMaximaInter} ]"
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
              "Por fichero de datos de última ejecución (DatosLast.txt)" \
			  "Por otro fichero de datos" \
              "Aleatoriamente Manual" \
			  "Por fichero de rangos de última ejecución (DatosRangosLast.txt)" \
			  "Por otro fichero de rangos" \
              "Por fichero Aleatorio total (DatosRangosAleatorioTotal.txt)"

			  

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
        7 )
            # Introducir los datos archivo de rangos
            datos_archivo_rangos_total
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


# ███████████████████████████████
# █                             █
# █          EJECUCIÓN          █
# █                             █
# ███████████████████████████████

# ------------------------------------
# --------- EJECUCIÓN ----------------
# ------------------------------------

# DES: Calcular tiempo de espera y de ejecución para los procesos
ej_ejecutar_tesp_tret() {

    # Por cada proceso que está esperando a entrar a memoria o a ser ejecutado
    for p in ${colaMemoria[*]} ${colaEjecucion[*]};do

        # Incrementar su tiempo de espera y de retorno
        ((tEsp[$p]++))
        ((tRet[$p]++))

        # Calcular anchos para la tabla
        [ ${#tEsp[$p]} -gt $(( ${anchoColTEsp} - 2 )) ] \
            && anchoColTEsp=$(( ${#tEsp[$p]} + 2 ))
        [ ${#tRet[$p]} -gt $(( ${anchoColTRet} - 2 )) ] \
            && anchoColTRet=$(( ${#tRet[$p]} + 2 ))
    done

    # Si hay un proceso en ejecución
    if [[ -n "$enEjecucion" ]];then
        # Incrementar su tiempo de retorno
        ((tRet[$enEjecucion]++))

        # Calcular anchos para la tabla
        [ ${#tRet[$enEjecucion]} -gt $(( ${anchoColTRet} - 2 )) ] \
            && anchoColTRet=$(( ${#tRet[$enEjecucion]} + 2 ))
    fi

}

# DES: Finalizar la ejecución del proceso
ej_ejecutar_fin_ejecutar() {

    # Sacar el proceso de la memoria
    for mar in ${marcosActuales[*]};do

        unset memoriaProceso[$mar]
        unset memoriaPagina[$mar]
        unset memoriaFIFO[$mar]

        # Actualizar memoria libre y ocupada
        ((memoriaLibre++))
        ((memoriaOcupada--))

    done

    # Resetear el vector procesoMarcos.
    for (( pag=0; pag<${minimoEstructural[$enEjecucion]}; pag++ )) {
        unset procesoMarcos[$enEjecucion,$pag]
    }

    # Poner el tiempor restanter de ejecución a - para que no muestre 0
    tREj[$enEjecucion]="-"

    # Actualizar le estado del proceso
    estado[$enEjecucion]=4

    # Resetear los marcos actuales
    marcosActuales=()

    procesoFin[$enEjecucion]=$t

    # Poner el proceso que ha terminado para mostrarlo en pantalla
    fin=$enEjecucion
    # Mostrar la pantalla porque es un evento interesante
    mostrarPantalla=1

    # Liberar procesador
    unset enEjecucion

    ((numProcesosFinalizados++))

    siguienteMarco=""

}

# DES: Comprobar si se cumplen las condiciones para que se produzca reubicación
# RET: 0 -> puede ocurrir reubicaion 1 -> no se cumplen las condiciones
ej_ejecutar_comprobar_reubicacion() {
    # Cuenta el número de marcos vacíos seguidos
    local cont=0
    # Si hay un hueco en la memoria de mas de 1 marco vacio seguido
    local hueco=0

    if [[ -z $colaMemoria ]];then
        return 1
    else
        # Por cada marco
        for (( mar=0; mar <= $numeroMarcos; mar++ ));do

            # Si el marco está vacío y aun no se ha llegado al final de la memoria
            if [[ -z "${memoriaProceso[$mar]}" ]] && [ $mar -ne $numeroMarcos ];then
                # incrementar contador
                ((cont++))

            # Si el marco no está vacío o se ha llegado al final de la memoria
            else
                # Si no se alcanza el mínimo de marcos para la reubicaion y el contador es distinto de 0
                if [ $cont -ne 0 ] && [ $cont -le $mNUR ];then

                    # Si aun no se ha llegado al final de la memoria o el numero de marcos vacios es 1
                    if [ $hueco -eq 1 ] ||  [ $mar -ne $numeroMarcos ];then
                        return 0
                    fi
                # Si se alcanza el mínimo de marcos para la reubicaion
                elif [ $cont -ne 0 ];then
                    hueco=1
                fi

                cont=0
            fi

        done
    fi
    return 1

}

# DES: Reubicar la memoria
ej_ejecutar_reubicar() {
    # Mostrar la pantalla porque la reubicación es un evento importante
    mostrarPantalla=1
    reubicacion=1

    # Orden en el que están los procesos en memoria
    # Se eliminan los duplicados sin cambiar el orden.
    local ordenProcesos=($(echo "${memoriaProceso[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

    # Se guarda y vacia el estado de la memoria
    memoriaProcesoPrevia=()
    for mar in ${!memoriaProceso[*]};do
        memoriaProcesoPrevia[$mar]=${memoriaProceso[$mar]}
    done
    memoriaProceso=()

    memoriaPaginaPrevia=()
    for mar in ${!memoriaPagina[*]};do
        memoriaPaginaPrevia[$mar]=${memoriaPagina[$mar]}
    done
    memoriaPagina=()

    memoriaFIFOPrevia=()
    for mar in ${!memoriaFIFO[*]};do
        memoriaFIFOPrevia[$mar]=${memoriaFIFO[$mar]}
    done
    memoriaFIFO=()

    # marco siguiente que se va a asignar
    local mar=0

    # Por cada proceso en el orden en que aparecen
    for proc in ${ordenProcesos[*]};do
        for (( i=0; i<${minimoEstructural[$proc]}; i++ ));do
            # Marco que estaba asignado antes
            local marcoPrevio=${procesoMarcos[$proc,$i]}
            procesoMarcos[$proc,$i]=$mar

            memoriaProceso[$mar]=${memoriaProcesoPrevia[$marcoPrevio]}
            [[ -n "${memoriaPaginaPrevia[$marcoPrevio]}" ]] \
                && memoriaPagina[$mar]=${memoriaPaginaPrevia[$marcoPrevio]}
            [[ -n "${memoriaFIFOPrevia[$marcoPrevio]}" ]] \
                && memoriaFIFO[$mar]=${memoriaFIFOPrevia[$marcoPrevio]}

            ((mar++))
        done
    done

    # Estado final de la memoria para la comparación de reubicación
    memoriaProcesoFinal=()
    for mar in ${!memoriaProceso[*]};do
        memoriaProcesoFinal[$mar]=${memoriaProceso[$mar]}
    done

    memoriaPaginaFinal=()
    for mar in ${!memoriaPagina[*]};do
        memoriaPaginaFinal[$mar]=${memoriaPagina[$mar]}
    done


    # Actualizar los marcos actuales
    if [[ -n "${enEjecucion}" ]];then

        marcosActuales=($(
            for (( i=0; i<${minimoEstructural[$enEjecucion]}; i++ ));do
                echo "${procesoMarcos[$enEjecucion,$i]}"
            done
        ))

    fi
	
	# Actualizar los marcos en memoria
    if [[ estado[$proc] -eq 2 ]];then

        Mfin=($(
            for (( i=0; i<${minimoEstructural[$proc]}; i++ ));do
                echo "${procesoMarcos[$proc,$i]}"
            done
         ))

    fi

}

# DES: Atender la llegada de procesos
ej_ejecutar_llegada() {
    # Por cada proceso en la cola de llegada
    for p in ${colaLlegada[*]};do
        # Si su tiempo de llegada es igual al tiempo actual
        if [ ${tiempoLlegada[$p]} -eq $t ];then

            # Quitar proceso de la lista de llegada
            colaLlegada=("${colaLlegada[@]:1}")

            # Añadir proceso a la cola para entrar a memoria
            colaMemoria+=($p)

            # Cambiar el estado del proceso
            estado[$p]=1

            # Establecer el tiempo de espera del proceso a 0
            tEsp[$p]=0

            # Establecer tiempo de retorno a 0
            tRet[$p]=0

            # Añadir proceso a los que han llegada para mostrarlo
            llegada+=($p)
            # Mostrar pantalla porque es un evento importante
            mostrarPantalla=1

        else
            # Como están en orde de llegada, en cuanto nos topemos con un proceso
            # que aún no llega sabemos que no va a llegar ningún otro
            break
        fi
    done

}

# DES: Introducir procesos que han llegado a memoria si se puede
# RET: 0 -> han entrado procesos a memoria 1 -> no han entrado procesos
ej_ejecutar_memoria_proceso() {
    # Contador de cuantos procesos han entrado
    local cont=0

    # Por cada proceso en la cola de memoria
    for p in ${colaMemoria[*]};do

        # Si hay suficiente memoria libre (Porque es memoria no continua, si fuese continua habría que hacerlo diferente)
        if [ ${minimoEstructural[$p]} -le $memoriaLibre ];then

            # Quitar proceso del la cola de memoria
            colaMemoria=("${colaMemoria[@]:1}")

            # Añadir proceso a la memoria
            # pag -> Página del proceso por la que va (No es un buen nombre, pero no se me ocurre otra cosa)
            # mar -> Marco de memoria por el que va
            # hasta que se alcance el mínimo estructural
            for (( pag=0,mar=0; pag<${minimoEstructural[$p]}; mar++ ));do
                # Si el marco no está ya asignado
                if [[ -z ${memoriaProceso[$mar]} ]];then

                    # Asignar el marco al proceso
                    memoriaProceso[$mar]=$p
                    procesoMarcos[$p,$pag]=$mar

                    # Pasar a la siguiente página del proceso.
                    ((pag++))

                    # Actualizar memoria libre y ocupada.
                    ((memoriaLibre--))
                    ((memoriaOcupada++))

                fi
            done

            # Añadir proceso a la cola de ejecución
            colaEjecucion+=($p)

            # Cambiar estado del proceso.
            estado[$p]=2

            # Establecer el tiempo restante de ejecución del proceso a su tiempo de ejecución total
            tREj[$p]=${tiempoEjecucion[$p]}
            ej_ordenar_cola_ejecucion
            
            # Agregar proceso a la cola de memoria en orden creciente de tiempo restante de ejecución 

            # Añadir proceso a la lista de procesos que han entrado a memoria para la pantalla
            entrada+=($p)
            # Mostrar la pantalla porque es un evento importante
            mostrarPantalla=1

            # Incrementar contador
            ((cont++))

        else
            # Como la entrada a memoria es FIFO si un proceso no puede entrar, los siguientes
            # tampoco porque la lista está ordenasa según tiempo de llegada
            break
        fi
    done

    # Si no han entrado procesos devolver 1
    if [ $cont -eq 0 ];then
        return 1
    # Si han llegado devolver 0
    else
        return 0
    fi

}

# DES: Introducir procesos que han llegado a memoria si se puede
ej_ejecutar_empezar_ejecucion() {
    # Asignar procesador al proceso
    enEjecucion=${colaEjecucion[0]}

    # Quitar proceso de la cola de ejecución
    colaEjecucion=("${colaEjecucion[@]:1}")

    # Cambiar estado del proceso
    estado[$enEjecucion]=3

    # Hayar los marcos del proceso actual
    for (( i=0; i<${minimoEstructural[$enEjecucion]}; i++ ));do
        marcosActuales+=(${procesoMarcos[$enEjecucion,$i]})
    done

    # Establece el marco siguiente al primer marco del proceso en ejecución
    siguienteMarco=${marcosActuales[0]}

    # Poner el proceso que se ha inciado para mostrarlo en la pantalla
    inicio=$enEjecucion
    # Mostrar la pantalla porque es un evento importante
    mostrarPantalla=1

    procesoInicio[$enEjecucion]=$t

}

# DES: Ordenar procesos de la cola de memoria segun SRPT
ej_ordenar_cola_ejecucion() {
    # Ordena los procesos en la cola segun el que menos tiempo de ejecucion restante tenga
    for (( i=0; i<${#colaEjecucion[@]}; i++ )); do
        for (( j=$i+1; j<${#colaEjecucion[@]}; j++ )); do
            # Comprobar si el TRej de ambos procesos está inicializado
            if [[ ${tREj[${colaEjecucion[$i]}]+_} && ${tREj[${colaEjecucion[$j]}]+_} ]]; then
                if [ ${tREj[${colaEjecucion[$i]}]} -gt ${tREj[${colaEjecucion[$j]}]} ]; then
                    tmp=${colaEjecucion[$i]}
                    colaEjecucion[$i]=${colaEjecucion[$j]}
                    colaEjecucion[$j]=$tmp
                fi
            fi
        done
    done
}

# DES: Comprueba cual es el proceso en memoria que tenga el menor tiempo restante de ejecucion.
# RET: 0 -> puede entrar un nuevo proceos 1 -> no se cumplen las condiciones
ej_ejecutar_comprobar_algoritmo_SRTP() {
    # Comprueba si la cola tiene procesos
    if [[ ${#colaEjecucion[@]} -gt 0 ]]; then
    
        # Obtener el tiempo de ejecución del primer proceso en ejecucion
        tiempoRestante=${tREj[$enEjecucion]}

        tiempoCola=${tREj[${colaEjecucion[0]}]}

        # Si el tiempo restante del proceso en ejecución es menor que el de la cola, no cambiar el proceso en ejecución
        if [ $tiempoRestante -gt $tiempoCola ]; then
            algoritmo_srtp[$enEjecucion]=0
            return 0
        else
            return 1
        fi

    else   
        return 1
    fi

}

# DES: Saca los procesos del proceso de ejecucion y reordena la cola
# RET: 0=No ha salido un proceso 1=Ha sacado un proceso
ej_ejecutar_sacar_ejecucion(){
    # Poner el proceso que se ha salido de ejecucion para mostrarlo en la pantalla
    salida_ejecucion=($enEjecucion)

    # Para arreglarlo podemos en caso de proceso en pausa, simplemente reordenar la lista de marco fallo mandando todos aquellos marcos del proceso anterior al final.

    local corte=${tRet[$enEjecucion]}
    marcoFallo=(${marcoFallo[@]:$corte})

    # Cambiamos el estado
    estado[$enEjecucion]=5

    # Resta uno a los procesos restantes de ejecucion
    (( --tREj[$enEjecucion] ))

    # Resetear los marcos actuales
    marcosActuales=()

    # Lo introducimos de nuevo a la cola
    colaEjecucion+=($enEjecucion)
    ej_ordenar_cola_ejecucion

    # Mostrar la pantalla porque es un evento importante
    mostrarPantalla=1

}

# DES: Introducir siguiente página del proceso a memoria
# RET: 0=No ha habido fallo 1=Ha habido fallo
ej_ejecutar_memoria_pagina() {
    # Página que hay que introducir
    local pagina=${pc[$enEjecucion]}
    pagina=${procesoPagina[$enEjecucion,$pagina]}

    # Añadir proceso y página a la linea de tiempo
    tiempoProceso[$t]=$enEjecucion
    tiempoPagina[$t]=$pagina
    paginaTiempo[$enEjecucion,${pc[$enEjecucion]}]=$t

    # Comprobar cada marco de la memoria si la página ya está metida
    for ind in ${!marcosActuales[*]};do
        mar=${marcosActuales[$ind]}
        if [ -n ${memoriaPagina[$mar]} ] && [[ ${memoriaPagina[$mar]} -eq $pagina ]] ;then
            marcoFallo+=($ind)
            return 0
        fi
    done

    # Si la página no está en memoria
    # Marco en el que se va a introducir la página.
    local marco=""
    # Menor tiempo
    local pentrada=-1

    local marc=""
    # Si la página no está en memoria hay que buscar la página con menor tiempo de entrada.
    for ind in ${!marcosActuales[*]};do
        mar=${marcosActuales[$ind]}
        # Si el marco está vacío se usa siempre
        if [[ -z "${memoriaPagina[$mar]}" ]];then
            marco=$mar
            pentrada=0
            marc=$ind
            break
        
        # si el marco no está vacío, el contador con menor tiempo de entrada
        elif [[ -z "$marco" ]] || [ ${memoriaFIFO[$mar]} -lt $pentrada ];then
            marco=$mar
            pentrada=${memoriaFIFO[$mar]}
            marc=$ind
        fi

    done

    # Introducir la página en el marco
    memoriaPagina[$marco]=$pagina
    # Un contador en el que guardamos el tiempo de entrada de la pagina
    memoriaFIFO[$marco]=$t
    marcoFallo+=($marc)

    # Incrementar fallos del proceso
    (( numFallos[$enEjecucion]++ ))

    return 1

}

# DES: Encuentra cual va a ser el siguiente marco en utilizar en caso de que se produzca fallo en la siguiente página
ej_calcular_marco_siguiente() {
    # Marco en el que se va a introducir la página.
    local marco=""
    # Menor entrada
    local pentrada=-1
    # Si la página no está en memoria hay que buscar la página con menor tiempo de entrada.
    for ind in ${!marcosActuales[*]};do
        mar=${marcosActuales[$ind]}
        # Si el marco está vacío se usa siempre
        if [[ -z "${memoriaPagina[$mar]}" ]];then
            marco=$mar
            pentrada=0
            break
        
        # si el marco no está vacío, (menor tiempo de entrada)
        elif [[ -z "$marco" ]] || [ ${memoriaFIFO[$mar]} -lt $pentrada ];then
            marco=$mar
            pentrada=${memoriaFIFO[$mar]}
        fi
    done
    siguienteMarco=${marco}
}

# DES: Guardar el estado de la memoria en este momento para luego mostrar el resumen con los fallos
#      No está directamente relacionado con la ejecución. Es solo para la pantalla.
ej_ejecutar_guardar_fallos() {
    local marco=""
    local mom=$(( ${pc[$enEjecucion]} - 1 ))

    if [[ -z ${algoritmo_srtp[$enEjecucion]} ]];then 
        for mar in ${!marcosActuales[*]};do
            marco=${marcosActuales[$mar]}
            resumenFallos["$mom,$mar"]="${memoriaPagina[$marco]}"
        done
        for mar in ${!marcosActuales[*]};do
            marco=${marcosActuales[$mar]}
            if [ $siguienteMarco -eq $marco ];then
                resumenFIFO["$mom,$mar"]="1"
            else
                resumenFIFO["$mom,$mar"]="*"
            fi
        done
    else
        mom=0
        marcoFallo=(${marcoFallo[@]:1})
        # Lo repite para todos los momentos que ya habain sido introducidos antes deL SRPT para que se muestren bien por la pantalla
        for (( mom=0; mom<=$(( ${pc[$enEjecucion]} - 1 )); mom++ ));do

            for mar in ${!marcosActuales[*]};do
                if [[ $mar -eq $mom ]];then
                    marco=${marcosActuales[$mar]}
                    # Posicion en la que se ha introducido 
                    for ((i=0;i<=$((${pc[$enEjecucion]}-1));++i)); do
                        resumenFallos["$((mom+i)),$mar"]="${memoriaPagina[$marco]}"
                        resumenFIFO["$mom,$((mar+1))"]="1"
                        if [[ "${resumenFIFO[$mom,$((mar+1))]}" == "1" ]]; then
                            resumenFIFO["$((mom+i)),$mar"]="*"
                            resumenFIFO["$mom,$((mar+2+i))"]="*"
                        fi
                    done
                    if [[ -n $resumenFallos["$mom,$mar"] ]];then
                        marcoFallo+=($mar)
                    fi
                fi
            done
        done
        unset algoritmo_srtp[$enEjecucion]
    fi

}

# DES: Llegada de procesos, ejecución, introducción a memoria...
ej_ejecutar() {
    # Calcular tiempo de espera y de ejecución para los procesos
    ej_ejecutar_tesp_tret

    # Atender la llegada de procesos
    ej_ejecutar_llegada

    # Introducir procesos que han llegado a memoria si se puede
    ej_ejecutar_memoria_proceso

    # Si hay proceso en ejecucion
    if [[ -n "$enEjecucion" ]];then
        # Comprueba si se cumplen las condiciones de SRPT
        ej_ejecutar_comprobar_algoritmo_SRTP \
            &&  ej_ejecutar_sacar_ejecucion \
                &&  ej_ejecutar_empezar_ejecucion \
                    && (( ++tREj[$enEjecucion] )) 

        # Decrementar tiempo restante de ejecución
        (( --tREj[$enEjecucion] ))
        # ej_ordenar_cola_ejecucion

        # Guardar el estado de la memoria en este momento para luego mostrar el resumen con los fallos
        ej_ejecutar_guardar_fallos

        # Si el proceso se ha terminado de ejecutar
        if [ ${tREj[$enEjecucion]} -eq 0 ];then
            ej_ejecutar_fin_ejecutar
            ej_ejecutar_memoria_proceso
        fi

    fi
       
    # Reubicación
    ej_ejecutar_comprobar_reubicacion \
        && ej_ejecutar_reubicar

    # Si no hay procesos en ejecución y hay procesos esperando a ser ejecutados
    if [[ -z "$enEjecucion" ]] && [[ ${#colaEjecucion[*]} -gt 0 ]]; then
        ej_ejecutar_empezar_ejecucion
    fi

    # Si hay un proceso en ejecución, introducir su siguiente página a memoria
    if [[ -n "$enEjecucion" ]];then
        ej_ejecutar_memoria_pagina
        ej_calcular_marco_siguiente

        # Incrementar el contador del proceso
        (( pc[$enEjecucion]++ ))
    fi
}


# ------------------------------------
# --------- PANTALLA ----------------
# ------------------------------------

# DES: Mostrar una cabecera con información sobre el algoritmo y sobre la memoria
ej_pantalla_cabecera() {
    echo -e -n "${ft[0]} SRPT-"
	echo -e -n "Paginación-"
    echo -e -n "FIFO-NC-R${rstf}\n"

}

# DES: Mostrar el tiempo actual
ej_pantalla_tiempo() {
    printf " ${cl[$re]}${ft[0]}%s${rstf}: %-6s" "T" "${t}"
    printf " ${cl[$re]}${ft[0]}%7s${rstf}: %-6s" "Nº Dirs" "${tamanoMemoria}"
    printf " ${cl[$re]}${ft[0]}%8s${rstf}: %-6s" "Tam Pág" "${tamanoPagina}"
    printf " ${cl[$re]}${ft[0]}%7s${rstf}: %-6s" "Nº Marc" "${numeroMarcos}"
    printf " ${cl[$re]}${ft[0]}%7s${rstf}: %-6s\n" "mNUR" "${mNUR}"
}

# DES: Mostrar información sobre la llegada de procesos
ej_pantalla_llegada() {

    case ${#llegada[*]} in
        # Si no ha llegado ningún proceso no hacer nada
        0 )
        ;;
        # Si ha llegada un proceso
        1 )
            local temp=${llegada[0]}
            echo -e " Ha llegado el proceso ${nombreProcesoColor[$temp]}."
        ;;
        # Si ha llegado más de un proceso
        * )
            echo -e -n " Han llegado los procesos "
            for p in ${!llegada[*]};do
                # Número del proceso
                local temp=${llegada[$p]}

                # Si es el antepenúltimo proceso
                if [ $p -eq $(( ${#llegada[*]} - 2 )) ];then

                    echo -e -n "${nombreProcesoColor[$temp]}"

                # Si es el último proceso
                elif [[ $p -eq $(( ${#llegada[*]} - 1 )) ]];then

                    echo -e " y ${nombreProcesoColor[$temp]}."

                # Si es cualquier otro proceso
                else

                    echo -e -n "${nombreProcesoColor[$temp]}, "

                fi
            done
        ;;
    esac

}

# DES: Mostrar tabla con los procesos y sus datos
ej_pantalla_tabla() {

    # Color del proceso que se está imprimiendo
    local color
    # Estado del proceso
    local est

    local anchoRestante
    local anchoCadena

    local anchoCadenaTotal=21
    local anchoCadenaInter=()
    local anchoCadenaRestPro=()

    local marcosContinuos

    for proc in ${listaLlegada[*]};do
        for (( i=0; ; i++ ));do

            anchoCadena=$(( ${#procesoDireccion[$proc,$i]} + ${#procesoPagina[$proc,$i]} + 2 ))
            # Si ya no quedan páginas
            [[ -z "${procesoDireccion[$proc,$i]}" ]] \
                && break

            anchoCadenaInter[$proc]=$(( ${anchoCadenaInter[$proc]} + $anchoCadena ))
        done

        if [[ ${anchoCadenaInter[proc]} -gt $anchoCadenaTotal ]];then
            anchoCadenaTotal=${anchoCadenaInter[proc]}
        fi

    done

    local ancho=$(( $anchoColRef + $anchoColTll + $anchoColTej + $anchoColNm + $anchoColTEsp + $anchoColTRet + $anchoColTREj + $anchoColMini + $anchoColMfin + $anchoEstados + $(($anchoCadenaTotal + 2 )) + 20 ))

    local anchoRestDire=$((anchoCadenaTotal - 15 ))
	
    # Mostrar cabecera
    printf "${ft[0]}" # Negrita
    for ((i=0; i<=${ancho}; i++));do
        if [[ $i -eq 0 ]];then
            printf "┌"
        elif [[ $i -eq $ancho ]];then 
            printf "┐"
        else
            printf "─"
        fi
    done
    printf "${rstf}\n"

    printf "│"
    # Nº proceso
    printf "%-${anchoColRef}s" " Ref"
    printf "${cl[0]} │${cl[$color]}"
    # 1ª parte
    printf "%${anchoColTll}s" " Tll"  
    printf "${cl[0]} │${cl[$color]}"      
    printf "%${anchoColTej}s" " Tej"
    printf "${cl[0]} │${cl[$color]}" 
    printf "%${anchoColNm}s" " nMar"
    printf "${cl[0]} │${cl[$color]}" 
    # 2ª Parte
    printf "%${anchoColTEsp}s" " Tesp"
    printf "${cl[0]} │${cl[$color]}" 
    printf "%${anchoColTRet}s" " Tret"
    printf "${cl[0]} │${cl[$color]}" 
    printf "%${anchoColTREj}s" " Trej"
    printf "${cl[0]} │${cl[$color]}" 
	printf "%${anchoColMini}s" " Mini"
    printf "${cl[0]} │${cl[$color]}" 
	printf "%${anchoColMfin}s" " Mfin"
    printf "${cl[0]} │${cl[$color]}" 
    # Estado
    printf "%-${anchoEstados}s" " Estado"
    printf "│"
    # Direcciones
    printf " Dirección - Página"
    printf "%${anchoRestDire}s" "│" 
    printf "${rstf}\n"

    for ((i=0; i<=${ancho}; i++));do
        if [[ $i -eq 0 ]];then
            printf "├"
        elif [[ $i -eq $ancho ]];then 
            printf "┤"
        else
            printf "─"
        fi
    done

    # Mostrar los procesos en orden de llegada
    for proc in ${listaLlegada[*]};do
        
        # Poner la fila con el color del proceso
        color=${colorProceso[$proc]}
        # Hayar el estado
        est=${estado[$proc]}
        est=${cadenaEstado[$est]}
        selector=${estado[$proc]}
        
        printf "${ft[0]}" # Negrita

        printf "${rstf}\n"
        printf "│"
        printf "${cl[$color]}${ft[0]}"
        # Ref
        printf "%-${anchoColRef}s" " ${nombreProceso[$proc]}"
        printf "${cl[0]} │${cl[$color]}"
        # 1ª parte
        printf "%${anchoColTll}s" "${tiempoLlegada[$proc]}"
        printf "${cl[0]} │${cl[$color]}"
        printf "%${anchoColTej}s" "${tiempoEjecucion[$proc]}"
        printf "${cl[0]} │${cl[$color]}"
        printf "%${anchoColNm}s" "${minimoEstructural[$proc]}"
        printf "${cl[0]} │${cl[$color]}"
        # 2ª Parte
        [[ -n "${tEsp[$proc]}" ]] \
            && printf "%${anchoColTEsp}s" "${tEsp[$proc]}" \
            || printf "%${anchoColTEsp}s" "-"
        printf "${cl[0]} │${cl[$color]}"
        [[ -n "${tRet[$proc]}" ]] \
            && printf "%${anchoColTRet}s" "${tRet[$proc]}" \
            || printf "%${anchoColTRet}s" "-"
        printf "${cl[0]} │${cl[$color]}"
        [[ -n "${tREj[$proc]}" ]] \
            && printf "%${anchoColTREj}s" "${tREj[$proc]} " \
            || printf "%${anchoColTREj}s" "-"
        printf "${cl[0]} │${cl[$color]}"
        # Muestra los marcos iniciales y finales
		case $selector in
            3) #En Ejecucion
                #Identifica si el proceso es continuo o no.
                numeroEspaciosNoContinuos[$enEjecucion]=0
                marcosContinuos=$((${marcosActuales[-1]}-${marcosActuales[0]}+1))
                #En caso de que sea continuo
                if [[ $marcosContinuos -eq ${minimoEstructural[$enEjecucion]} ]];then
                    printf "%${anchoColMini}s" "${marcosActuales[0]}"
                    printf "${cl[0]} │${cl[$color]}"
                    printf "%${anchoColMfin}s" "${marcosActuales[-1]}"
                    printf "${cl[0]} │${cl[$color]}"
                    datos_almacena_marcos ${proc} ${marcosActuales[0]} ${marcosActuales[-1]} 
                    numeroEspaciosNoContinuos[$enEjecucion]=$((numeroEspaciosNoContinuos[$enEjecucion]+1)) 
                    
                else
                    local bloque_inicio="${marcosActuales[0]}"
                    local bloque_fin="${marcosActuales[0]}"

                    for ((i=1; i<${#marcosActuales[@]}; i++)); do
                        local num=${marcosActuales[i]}
                        local pre_num=${marcosActuales[i-1]}
                        
                        if [[ $num -ne $(($pre_num + 1)) ]]; then
                        # Si no es continuo
                            if [[ $bloque_inicio -eq "${marcosActuales[0]}" ]];then
                                printf "%${anchoColMini}s" "$bloque_inicio"
                                printf "${cl[0]} │${cl[$color]}"
                                printf "%${anchoColMfin}s" "$bloque_fin"
                                printf "${cl[0]} │${cl[$color]}"
                                datos_almacena_marcos ${proc} ${bloque_inicio} ${bloque_fin}
                               
                                printf "%-s%*s" " ${est}" $(( ${anchoEstados} - ${#est} - 1)) ""
                                printf "${cl[0]}│${cl[$color]}"


                                for (( j=0; ; j++ ));do
                                    if [ $anchoRestante -lt $anchoCadena ];then
                                        printf "\n"
                                        anchoRestante=$anchoTotal
                                    fi
                                    printf " "
                                    if [ $j -lt ${pc[$proc]} ];then
                                        printf "${ft[2]}"
                                    fi
                                    # Si ya no quedan páginas
                                    if [[ -z ${procesoDireccion[$proc,$j]} ]]; then
                                        break
                                    fi
                                    # Imprime todas las direcciones
                                    printf "${ft[1]}${procesoDireccion[$proc,$j]}-${ft[0]}${procesoPagina[$proc,$j]}"
                                    if [ $j -lt ${pc[$proc]} ];then
                                        printf "${ft[3]}"
                                    fi
                                    anchoRestante=$(( $anchoRestante - $anchoCadena ))
                                done 

                                anchoCadenaRestPro[$proc]=$(($anchoCadenaTotal - ${anchoCadenaInter[proc]} ))
                                printf "%${anchoCadenaRestPro[$proc]}s" ""
                                printf "${cl[0]}│${cl[$color]}" 
                            
                                printf "\n" 
                            else
                                # Ref
                                printf "${cl[0]}│ ${cl[$color]}"
                                printf "%-${anchoColRef}s" ""
                                printf "${cl[0]} │${cl[$color]}"
                                # 1ª parte
                                printf "%${anchoColTll}s" ""
                                printf "${cl[0]} │${cl[$color]}"
                                printf "%${anchoColTej}s" ""
                                printf "${cl[0]} │${cl[$color]}"
                                printf "%${anchoColNm}s" ""
                                printf "${cl[0]} │${cl[$color]}"
                                # 2ª Parte
                                printf "%${anchoColTEsp}s" "" 
                                printf "${cl[0]} │${cl[$color]}"
                                printf "%${anchoColTRet}s" ""
                                printf "${cl[0]} │${cl[$color]}"
                                printf "%${anchoColTREj}s" " " 
                                printf "${cl[0]} │${cl[$color]}"
                                printf "%${anchoColMini}s" "$bloque_inicio"
                                printf "${cl[0]} │${cl[$color]}"
                                printf "%${anchoColMfin}s" "$bloque_fin"
                                printf "${cl[0]} │${cl[$color]}"
                                datos_almacena_marcos ${proc} ${bloque_inicio} ${bloque_fin}
                                printf "\n"
                            fi

                            bloque_inicio=$num
                            bloque_fin=$num
                            numeroEspaciosNoContinuos[$enEjecucion]=$((numeroEspaciosNoContinuos[$enEjecucion]+1)) 
                        else
                            # El número es continuo, actualiza el fin del bloque actual
                            bloque_fin=$num
                        fi
                       
                    done

                    # Muestra el último bloque
                    # Ref
                    printf "${cl[0]}│ ${cl[$color]}"
                    printf "%-${anchoColRef}s" ""
                    printf "${cl[0]} │${cl[$color]}"
                    # 1ª parte
                    printf "%${anchoColTll}s" ""
                    printf "${cl[0]} │${cl[$color]}"
                    printf "%${anchoColTej}s" ""
                    printf "${cl[0]} │${cl[$color]}"
                    printf "%${anchoColNm}s" ""
                    printf "${cl[0]} │${cl[$color]}"
                    # 2ª Parte
                    printf "%${anchoColTEsp}s" "" 
                    printf "${cl[0]} │${cl[$color]}"
                    printf "%${anchoColTRet}s" ""                        
                    printf "${cl[0]} │${cl[$color]}"
                    printf "%${anchoColTREj}s" " " 
                    printf "${cl[0]} │${cl[$color]}"
                    printf "%${anchoColMini}s" "$bloque_inicio"
                    printf "${cl[0]} │${cl[$color]}"
                    printf "%${anchoColMfin}s" "${marcosActuales[-1]}"
                    printf "${cl[0]} │${cl[$color]}"
                    datos_almacena_marcos ${proc} ${bloque_inicio} ${bloque_fin}

                    printf "%${anchoEstados}s" ""
                    printf "${cl[0]}│${cl[$color]}"
                    # Direcciones  
                    for (( i=0; ; i++ ));do
                        # Si ya no quedan páginas
                        [[ -z "${procesoDireccion[$proc,$i]}" ]] \
                            && break
                        anchoRestante=$(( $anchoRestante - $anchoCadena ))
                    done 

                    anchoCadenaRestPro[$proc]=$(($anchoCadenaTotal - ${anchoCadenaInter[proc]} ))

                    printf "%${anchoCadenaTotal}s" ""
                    printf "${cl[0]} │${cl[$color]}"
                    numeroEspaciosNoContinuos[$enEjecucion]=$((numeroEspaciosNoContinuos[$enEjecucion]+1)) 

                    continue
                fi
                ;;
            4) #Finalizado
                #Identifica si el proceso es continuo o no.
                if [[ "${numeroEspaciosNoContinuos[$proc]}" -eq 1 ]];then
                    datos_obtiene_marcos 0 $proc
                    printf "%${anchoColMini}s" "$Mini"
                    printf "${cl[0]} │${cl[$color]}"
                    datos_obtiene_marcos 1 $proc
                    printf "%${anchoColMfin}s" "$Mfin"
                    printf "${cl[0]} │${cl[$color]}"
                else
                    datos_obtiene_marcos 0 $proc
                    printf "%${anchoColMini}s" "$Mini"
                    printf "${cl[0]} │${cl[$color]}"
                    datos_obtiene_marcos 1 $proc
                    printf "%${anchoColMfin}s" "$Mfin"
                    printf "${cl[0]} │${cl[$color]}"
                    printf "%-s%*s" " ${est}" $(( ${anchoEstados} - ${#est} - 1)) ""
                    printf "${cl[0]}│${cl[$color]}"

                    for (( j=0; ; j++ ));do
                        if [ $anchoRestante -lt $anchoCadena ];then                               
                            printf "\n"
                            anchoRestante=$anchoTotal
                        fi
                        printf " "
                        if [ $j -lt ${pc[$proc]} ];then
                            printf "${ft[2]}"
                        fi
                        # Si ya no quedan páginas
                        if [[ -z ${procesoDireccion[$proc,$j]} ]]; then
                            break
                        fi
                        # Imprime todas las direcciones
                        printf "${ft[1]}${procesoDireccion[$proc,$j]}-${ft[0]}${procesoPagina[$proc,$j]}"
                        if [ $j -lt ${pc[$proc]} ];then
                            printf "${ft[3]}"
                        fi
                        anchoRestante=$(( $anchoRestante - $anchoCadena ))
                    done 

                    anchoCadenaRestPro[$proc]=$(($anchoCadenaTotal - ${anchoCadenaInter[proc]} ))
                    
                    printf "%${anchoCadenaRestPro[$proc]}s" ""
                    printf "${cl[0]}│${cl[$color]}" 
                    printf "\n" 
                    for ((l = 2; l <= (numeroEspaciosNoContinuos[$proc] * 2 - 2); l += 2)); do

                        printf "${cl[0]}│ ${cl[$color]}"
                        printf "%-${anchoColRef}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        # 1ª parte
                        printf "%${anchoColTll}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        printf "%${anchoColTej}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        printf "%${anchoColNm}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        # 2ª Parte
                        printf "%${anchoColTEsp}s" "" 
                        printf "${cl[0]} │${cl[$color]}"
                        printf "%${anchoColTRet}s" ""                        
                        printf "${cl[0]} │${cl[$color]}"
                        printf "%${anchoColTREj}s" " " 
                        printf "${cl[0]} │${cl[$color]}"
                        datos_obtiene_marcos $l $proc
                        printf "%${anchoColMini}s" "$Mini"
                        printf "${cl[0]} │${cl[$color]}"
                        datos_obtiene_marcos $((l + 1)) $proc
                        printf "%${anchoColMfin}s" "$Mfin"
                        printf "${cl[0]} │${cl[$color]}"

                        printf "%${anchoEstados}s" ""
                        printf "${cl[0]}│${cl[$color]}"
                        # Direcciones  
                        for (( i=0; ; i++ ));do
                            # Si ya no quedan páginas
                            [[ -z "${procesoDireccion[$proc,$i]}" ]] \
                                && break
                            anchoRestante=$(( $anchoRestante - $anchoCadena ))
                        done 

                        anchoCadenaRestPro[$proc]=$(($anchoCadenaTotal - ${anchoCadenaInter[proc]} ))

                        printf "%${anchoCadenaTotal}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        if [[ $l -ne $((numeroEspaciosNoContinuos[$proc] * 2 - 2)) ]]; then
                            printf "\n"
                        fi
                    done
                continue
                fi
                ;;
            5) #En espera
                #Identifica si el proceso es continuo o no.
                if [[ "${numeroEspaciosNoContinuos[$proc]}" -eq 1 ]];then
                    datos_obtiene_marcos 0 $proc
                    printf "%${anchoColMini}s" "$Mini"
                    printf "${cl[0]} │${cl[$color]}"
                    datos_obtiene_marcos 1 $proc
                    printf "%${anchoColMfin}s" "$Mfin"
                    printf "${cl[0]} │${cl[$color]}"
                else
                    datos_obtiene_marcos 0 $proc
                    printf "%${anchoColMini}s" "$Mini"
                    printf "${cl[0]} │${cl[$color]}"
                    datos_obtiene_marcos 1 $proc
                    printf "%${anchoColMfin}s" "$Mfin"
                    printf "${cl[0]} │${cl[$color]}"
                    printf "%-s%*s" " ${est}" $(( ${anchoEstados} - ${#est} - 1)) ""
                    printf "${cl[0]}│${cl[$color]}"

                    for (( j=0; ; j++ ));do
                        if [ $anchoRestante -lt $anchoCadena ];then                               
                            printf "\n"
                            anchoRestante=$anchoTotal
                        fi
                        printf " "
                        if [ $j -lt ${pc[$proc]} ];then
                            printf "${ft[2]}"
                        fi
                        # Si ya no quedan páginas
                        if [[ -z ${procesoDireccion[$proc,$j]} ]]; then
                            break
                        fi
                        # Imprime todas las direcciones
                        printf "${ft[1]}${procesoDireccion[$proc,$j]}-${ft[0]}${procesoPagina[$proc,$j]}"
                        if [ $j -lt ${pc[$proc]} ];then
                            printf "${ft[3]}"
                        fi
                        anchoRestante=$(( $anchoRestante - $anchoCadena ))
                    done 

                    anchoCadenaRestPro[$proc]=$(($anchoCadenaTotal - ${anchoCadenaInter[proc]} ))
                    
                    printf "%${anchoCadenaRestPro[$proc]}s" ""
                    printf "${cl[0]}│${cl[$color]}"      
                    printf "\n" 

                    for ((l = 2; l <= (numeroEspaciosNoContinuos[$proc] * 2 - 2); l += 2)); do
                        printf "${cl[0]}│ ${cl[$color]}"
                        printf "%-${anchoColRef}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        # 1ª parte
                        printf "%${anchoColTll}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        printf "%${anchoColTej}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        printf "%${anchoColNm}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        # 2ª Parte
                        printf "%${anchoColTEsp}s" "" 
                        printf "${cl[0]} │${cl[$color]}"
                        printf "%${anchoColTRet}s" ""                        
                        printf "${cl[0]} │${cl[$color]}"
                        printf "%${anchoColTREj}s" " " 
                        printf "${cl[0]} │${cl[$color]}"
                        datos_obtiene_marcos $l $proc
                        printf "%${anchoColMini}s" "$Mini"
                        printf "${cl[0]} │${cl[$color]}"
                        datos_obtiene_marcos $((l + 1)) $proc
                        printf "%${anchoColMfin}s" "$Mfin"
                        printf "${cl[0]} │${cl[$color]}"

                        printf "%${anchoEstados}s" ""
                        printf "${cl[0]}│${cl[$color]}"
                        # Direcciones  
                        for (( i=0; ; i++ ));do
                            # Si ya no quedan páginas
                            [[ -z "${procesoDireccion[$proc,$i]}" ]] \
                                && break
                            anchoRestante=$(( $anchoRestante - $anchoCadena ))
                        done 

                        anchoCadenaRestPro[$proc]=$(($anchoCadenaTotal - ${anchoCadenaInter[proc]} ))

                        printf "%${anchoCadenaTotal}s" ""
                        printf "${cl[0]} │${cl[$color]}"
                        if [[ $l -ne $((numeroEspaciosNoContinuos[$proc] * 2 - 2)) ]]; then
                            printf "\n"
                        fi
                    done
                continue
                fi
                ;;
            *)
                printf "%${anchoColMini}s" "-"
                printf "${cl[0]} │${cl[$color]}"
                printf "%${anchoColMfin}s" "-"
                printf "${cl[0]} │${cl[$color]}"
                ;;
        esac
        
        # Estado
        # Para que puedan haber tildes hay que poner el ancho diferente.
        printf "%-s%*s" " ${est}" $(( ${anchoEstados} - ${#est} - 1)) ""
        printf "${cl[0]}│${cl[$color]}"

        anchoRestante=$(( $anchoTotal - $ancho ))

        # Direcciones
        for (( i=0; ; i++ ));do

            if [ $anchoRestante -lt $anchoCadena ];then
                printf "\n"
                anchoRestante=$anchoTotal
            fi
            printf " "
            if [ $i -lt ${pc[$proc]} ];then
                printf "${ft[2]}"
            fi
            
            # Si ya no quedan páginas
            [[ -z "${procesoDireccion[$proc,$i]}" ]] \
                && break

            # Imprime todas las direcciones
            printf "${ft[1]}${procesoDireccion[$proc,$i]}-${ft[0]}${procesoPagina[$proc,$i]}"
            
            
            if [ $i -lt ${pc[$proc]} ];then
                printf "${ft[3]}"
            fi

            anchoRestante=$(( $anchoRestante - $anchoCadena ))

        done 
        
        anchoCadenaRestPro[$proc]=$(($anchoCadenaTotal - ${anchoCadenaInter[proc]} + 3))
        printf "${rstf}"
        printf "%${anchoCadenaRestPro[$proc]}s" "│" 

    done
    printf "${rstf}\n"

    if [[ $proc -ne ${listaLlegada[-1]} ]];then
        printf "│"
    else
        for ((i=0; i<=${ancho}; i++));do
            if [[ $i -eq 0 ]];then
                printf "└"
            elif [[ $i -eq $ancho ]];then 
                printf "┘"
            else
                printf "─"
            fi
        done        
    fi
    printf "${rstf}\n"

}

# DES: Mostrar el cambio de memoria que ha habido en la reubicación
ej_pantalla_reubicacion() {
    # Si no se ha producido reubicación salir sin mostrar nada
    if [ $reubicacion -ne 1 ];then
        return
    fi

    echo " Se ha producido reubicación:"

    # LINEA DE MEMORIA ANTES
    local temp
    local temp2

    local anchoBloque=$(($anchoGen + 1 ))
    local anchoEtiqueta=6
    local anchoRestante=$(( $anchoTotal - $anchoEtiqueta + 2 ))
    
    local numBloquesPorLinea

    local primerMarco=0
    local ultimoMarco=""
    local ultimoProceso=""

    for (( l=0; ; l++ ));do

        # Calcular cuantos marcos se van a imprimir en esta linea
        numBloquesPorLinea=$(( $anchoRestante / $anchoBloque ))
        ultimoMarco=$(( $primerMarco + $numBloquesPorLinea - 5 ))
        if [ $ultimoMarco -ge $numeroMarcos ];then
            ultimoMarco=$(( $numeroMarcos - 1 ))
        fi

        #PROCESOS
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        fi

        ultimoProceso=-2
        for (( m=$primerMarco; m<=$ultimoMarco; m++ ));do
            # Si el marco está vacío o es el mismo proceso
            if [ -z "${memoriaProcesoPrevia[$m]}" ] || [ ${ultimoProceso} -eq ${memoriaProcesoPrevia[$m]} ];then
                printf "%${anchoBloque}s"
                if [ -z "${memoriaProcesoPrevia[$m]}" ];then
                    ultimoProceso=-1
                fi
            # Si se cambia de proceso
            elif [ ${ultimoProceso} -ne ${memoriaProcesoPrevia[$m]} ];then
                temp=${memoriaProcesoPrevia[$m]}
                printf "%s%*s" "${nombreProcesoColor[$temp]}" "$(( ${anchoBloque} - ${#nombreProceso[$temp]} ))" ""
                ultimoProceso=${temp}
            fi
        done
        printf "${rstf}|\n"
        (( ++$l ))

        #PÁGINAS
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" " ANT: "
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        fi
        for (( m=$primerMarco; m<=$ultimoMarco; m++ ));do
            # Poner el color
            if [ -n "${memoriaProcesoPrevia[$m]}" ];then
                temp=${memoriaProcesoPrevia[$m]}
                temp2=${colorProceso[$temp]}
                echo -e -n "${cf[$temp2]}"
                [[ " ${coloresClaros[@]} " =~ " ${temp2} " ]] \
                    && echo -n -e "${cl[1]}" \
                    || echo -n -e "${cl[2]}"
            else
                printf "${cf[17]}"
            fi

            temp=${memoriaProcesoPrevia[$m]}
            temp2=$(( ${pc[$temp]} - 1 ))
            
            if [ -n "${memoriaProcesoPrevia[$m]}" ] && [ -z "${memoriaPaginaPrevia[$m]}" ];then
                printf "%${anchoBloque}s" "-"
            else
                printf "%${anchoBloque}s" "${memoriaPaginaPrevia[$m]}"
            fi
        done
        printf "${rstf}|\n"

        #NÚMERO DE MARCO
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        fi
        ultimoProceso=-2
        for (( m=$primerMarco; m<=$ultimoMarco; m++ ));do
            # Si el marco está vacío o es el mismo proceso
            if [ -z "${memoriaProcesoPrevia[$m]}" ] || [ ${ultimoProceso} -eq ${memoriaProcesoPrevia[$m]} ];then
                if [ $ultimoProceso -eq -2 ];then
                    printf "%${anchoBloque}s" "$m"
                else
                    printf "%${anchoBloque}s"
                fi
                if [ -z "${memoriaProcesoPrevia[$m]}" ];then
                    ultimoProceso=-1
                fi
            # Si se cambia de proceso
            else
                printf "%${anchoBloque}s" "$m"
                ultimoProceso=${memoriaProcesoPrevia[$m]}
            fi
        done

        printf "${rstf}|\n"
        # Si se ha llegado al último marco
        if [ $ultimoMarco -eq $(( $numeroMarcos - 1 )) ];then
            break;
        fi
        primerMarco=$(( $ultimoMarco + 1 ))
        anchoRestante=$(( $anchoTotal - 2 ))
    done

    local anchoRestante=$(( $anchoTotal - $anchoEtiqueta - 2 ))

    local primerMarco=0
    local ultimoMarco=""
    local ultimoProceso=""

    for (( l=0; ; l++ ));do

        # Calcular cuantos marcos se van a imprimir en esta linea
        numBloquesPorLinea=$(( $anchoRestante / $anchoBloque ))
        ultimoMarco=$(( $primerMarco + $numBloquesPorLinea - 1 ))
        if [ $ultimoMarco -ge $numeroMarcos ];then
            ultimoMarco=$(( $numeroMarcos - 1 ))
        fi

        #PROCESOS
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        fi

        ultimoProceso=-2
        for (( m=$primerMarco; m<=$ultimoMarco; m++ ));do
            # Si el marco está vacío o es el mismo proceso
            if [ -z "${memoriaProcesoFinal[$m]}" ] || [ ${ultimoProceso} -eq ${memoriaProcesoFinal[$m]} ];then
                printf "%${anchoBloque}s"
                if [ -z "${memoriaProcesoFinal[$m]}" ];then
                    ultimoProceso=-1
                fi
            # Si se cambia de proceso
            elif [ ${ultimoProceso} -ne ${memoriaProcesoFinal[$m]} ];then
                temp=${memoriaProcesoFinal[$m]}
                printf "%s%*s" "${nombreProcesoColor[$temp]}" "$(( ${anchoBloque} - ${#nombreProceso[$temp]} ))" ""
                ultimoProceso=${temp}
            fi
        done
        printf "${rstf}|\n"
        (( ++$l ))

        #PÁGINAS
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" " DES: "
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        fi

        for (( m=$primerMarco; m<=$ultimoMarco; m++ ));do
            # Poner el color
            if [ -n "${memoriaProcesoFinal[$m]}" ];then
                temp=${memoriaProcesoFinal[$m]}
                temp2=${colorProceso[$temp]}
                echo -e -n "${cf[$temp2]}"
                [[ " ${coloresClaros[@]} " =~ " ${temp2} " ]] \
                    && echo -n -e "${cl[1]}" \
                    || echo -n -e "${cl[2]}"
            else
                printf "${cf[17]}"
            fi

            temp=${memoriaProcesoFinal[$m]}
            temp2=$(( ${pc[$temp]} - 1 ))
            
            if [ -n "${memoriaProcesoFinal[$m]}" ] && [ -z "${memoriaPaginaFinal[$m]}" ];then
                printf "%${anchoBloque}s" "-"
            else
                printf "%${anchoBloque}s" "${memoriaPaginaFinal[$m]}"
            fi
        done
        printf "${rstf}|\n"

        #NÚMERO DE MARCO
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        fi
        
        ultimoProceso=-2
        for (( m=$primerMarco; m<=$ultimoMarco; m++ ));do
            # Si el marco está vacío o es el mismo proceso
            if [ -z "${memoriaProcesoFinal[$m]}" ] || [ ${ultimoProceso} -eq ${memoriaProcesoFinal[$m]} ];then
                if [ $ultimoProceso -eq -2 ];then
                    printf "%${anchoBloque}s" "$m"
                else
                    printf "%${anchoBloque}s"
                fi
                if [ -z "${memoriaProcesoFinal[$m]}" ];then
                    ultimoProceso=-1
                fi
            # Si se cambia de proceso
            else
                printf "%${anchoBloque}s" "$m"
                ultimoProceso=${memoriaProcesoFinal[$m]}
            fi
        done

        printf "${rstf}|\n"
        # Si se ha llegado al último marco
        if [ $ultimoMarco -eq $(( $numeroMarcos - 1 )) ];then
            break;
        fi
        primerMarco=$(( $ultimoMarco + 1 ))
        anchoRestante=$(( $anchoTotal - 2 ))
    done
}

# DES: Mostrar media de Tesp y de Tret
ej_pantalla_media_tiempos() {

    local mediaTesp
    local mediaTret
    local sum=0
    local cont=0

    # CÁLCULOS
    
    for tiem in ${tEsp[*]};do
        sum=$(( sum + $tiem ))
        (( cont++ ))
    done
    [ $cont -ne 0 ] \
        && mediaTesp="$(bc -l <<<"scale=2;$sum / $cont")"
    sum=0
    cont=0

    for tiem in ${tRet[*]};do
        sum=$(( sum + $tiem ))
        (( cont++ ))
    done
    [ $cont -ne 0 ] \
        && mediaTret="$(bc -l <<<"scale=2;$sum / $cont")"
    
    # IMPRESIÓN
    if [ -n "${mediaTesp}" ];then
        if [[ "${mediaTesp}" == "0" ]]; then
            printf " ${cl[$re]}%s${rstf}: %-9s" "TespM" "0.00"
        else
            printf " ${cl[$re]}%s${rstf}: %-9s" "TespM" "${mediaTesp}"
        fi
    else
        printf " ${cl[$re]}%s${rstf}: %-9s" "TespM" "0.00"
    fi

    if [ -n "${mediaTret}" ];then
        if [[ "${mediaTret}" == "0" ]]; then
            printf " ${cl[$re]}%s${rstf}: %s\n" "TretM" "0.00"
        else
            printf " ${cl[$re]}%s${rstf}: %s\n" "TretM" "${mediaTret}"
        fi
    else
        printf " ${cl[$re]}%s${rstf}: %s\n" "TretM" "0.00"
    fi
}

# DES: Mostrar un resumen con los fallos de página que han habido durante la ejecución
ej_pantalla_fin_fallos() {

    # El el ancho del número de marco máximo, para mostrarlos en el formato "03"
    local anchoNumMar=$(( ${minimoEstructural[$fin]} - 1 ))
    anchoNumMar=${#anchoNumMar}
    # El +4 es por la M de M03, el espacio a la izquierda y 2 por el ": " de la derecha
    local anchoEtiquetas=$(( ${#anchoNumMar} + 4 ))

    # Ancho de cada momento
    local anchoMomento=$anchoGen
    local anchoBloque=$(( $anchoMomento + 2 ))
    local anchoRestante=$(( $anchoTotal - $anchoEtiquetas ))

    # Número de momentos que se van a mostrar en esta linea
    local numBloquesPorLinea

    # Para saber por que marco se va en cada linea.
    # Son el primer momento y el último momento de cada linea.
    local ultimoMomento=""

    # Por cada linea.
    for (( l=0; ; l++ ));do

        local numBloquesPorLinea=$(( $anchoRestante / $anchoBloque ))
        ultimoMomento=$(( $numBloquesPorLinea - 1 ))
        if [ $ultimoMomento -ge ${tiempoEjecucion[$fin]} ];then
            ultimoMomento=$(( ${tiempoEjecucion[$fin]} - 1 ))
        fi
        
        # Etiqueta para el tiempo
        echo -e -n "${cl[$re]}${ft[0]}"
        printf "%${anchoEtiquetas}s" "T: "
        echo -e -n "${rstf}"
        # Imprimir el tiempo para cada momento
        for (( mom=0; mom<=$ultimoMomento; mom++ ));do
            printf "(%${anchoGen}s)" "${paginaTiempo[$fin,$mom]}"
        done
        printf "\n"

        # Imprimir la evolución de cada marco
        for (( mar=0; mar<${minimoEstructural[$fin]}; mar++ ));do
            # Etiqueta del marco
            echo -e -n "${cl[$re]}${ft[0]}"
            printf "%${anchoEtiquetas}s" " M$( printf "%0${anchoNumMar}d" "${mar}" ): "
            echo -e -n "${rstf}"
            # Imprimir la página de cada momento del marco
            printf "${ft[0]}"

            for (( mom=0; mom<=$ultimoMomento; mom++ ));do
                # Pintar la posicion donde se ha introducido el marco.
                if [ ${marcoFallo[$mom]} -eq $mar ];then
                    printf "${cf[3]}╔%${anchoGen}s╗${cf[0]}" "${resumenFallos[$mom,$mar]}"
                elif [[ "${resumenFIFO[$mom,$mar]}" == "1" ]]; then
                    printf "${cf[0]}╔%${anchoMomento}s╗${cf[0]}" ""
                else
                    printf "┌%${anchoGen}s┐" "${resumenFallos[$mom,$mar]}"
                fi

            done
            printf "${rstf}\n"
            printf "%${anchoEtiquetas}s" ""

            for (( mom=0; mom<=$ultimoMomento; mom++ ));do

                if [[ ${marcoFallo[$mom]} -eq $mar ]];then
                    printf "${cf[3]}╚%${anchoMomento}s╝${cf[0]}" "${resumenFIFO[$mom,$mar]}"
                elif [[ "${resumenFIFO[$mom,$mar]}" == "1" ]]; then
                    printf "${cf[0]}${ft[0]}${ft[2]}╚%${anchoMomento}s╝${ft[1]}${ft[3]}${cf[0]}" "${resumenFIFO[$mom,$mar]}"
                else
                    printf "└%${anchoMomento}s┘" "${resumenFIFO[$mom,$mar]}"
                fi
            done
            printf "\n"
        done

        if [ $ultimoMomento -eq $(( ${tiempoEjecucion[$fin]} - 1 )) ];then
            break;
        fi
        printf "\n"
        anchoRestante=$(( $anchoTotal - $anchoEtiquetas ))

    done
    numfallosAntes=${numfallos[$enEjecucion]}
}

# DES: Mostrar el proceso que ha finalizado su ejecución
ej_pantalla_fin() {

    if [[ -n "${fin}" ]];then

        echo -e " El proceso ${nombreProcesoColor[$fin]} ha finalizado su ejecución con ${cl[$re]}${numFallos[$fin]}${rstf} fallos de página."

        ej_pantalla_fin_fallos

    fi

}

# DES: Mostrar info sobre la entrada de procesos en memoria
ej_pantalla_entrada() {

    # Por cada proceso que ha entrado a memoria
    for p in ${entrada[*]};do

        echo -e " El proceso ${nombreProcesoColor[$p]} ha entrado a memoria a partir de la posición ${cl[$re]}${procesoMarcos[$p,0]}${rstf}."

    done

}

# DES: Mostrar cola de ejecución
ej_pantalla_cola_ejecucion() {
    if [ ${#colaEjecucion} -eq 0 ];then
        return
    fi

    echo -n -e " Cola Ejecucion (Orden ejecución por SRPT):"
    for proc in ${colaEjecucion[*]};do
        echo -n -e " ${nombreProcesoColor[$proc]}"
    done
    echo
}

# DES: Mostrar cola de memoria
ej_pantalla_cola_memoria(){
    if [ ${#colaMemoria} -eq 0 ];then
        return
    fi

    echo -n -e " Cola Memoria(Orden entrada en memoria por FIFO):"
    for proc in ${colaMemoria[*]};do
        echo -n -e " ${nombreProcesoColor[$proc]}"
    done
    echo
}

# DES: Mostrar el proceso que ha iniciado su ejecución
ej_pantalla_inicio() {
    if [ -n "$inicio" ];then
        echo -e " El proceso ${nombreProcesoColor[$inicio]} ha iniciado su ejecución."
    fi
}

# DES: ESTO LUEGO LO QUITAS
ej_pantalla_informacion() {
    echo -e " "
    echo -e " "
}

# DES: Mostrar el proceso que ha parado su ejecución
ej_pantalla_salida_ejecucion() {
    if [ -n "$salida_ejecucion" ];then
        echo -e " El proceso ${nombreProcesoColor[$salida_ejecucion]} ha parado su ejecucion."
    fi
}

# DES: Mostrar el proceso que ha salido de memoria
ej_pantalla_salida_memoria() {
    if [ -n "$salida_memoria" ];then
        echo -e " El proceso ${nombreProcesoColor[$salida_memoria]} ha salido de la memoria."
    fi
}

# DES: Muestra la linea de memoria grande
ej_pantalla_linea_memoria_grande() {
    
    # Ancho del interior del bloque 
    local anchoBloqueIn=$anchoGen
    if [ $anchoBloqueIn -lt 4 ];then
        anchoBloqueIn=4
    fi

    # Ancho del bloque completo con los paréntesis
    local anchoBloqueOut=$(( $anchoBloqueIn + 2 ))
    local anchoEtiquetas=11
    local anchoRestante=$(( $anchoTotal - $anchoEtiquetas - 3))
    local numMaxBloquesPorLinea=$(( $anchoRestante / $anchoBloqueOut ))
    local numLineas=$(( $numeroMarcos / $numMaxBloquesPorLinea ))

    # Para saber por que marco se va en cada linea.
    local primerMarco=0
    local ultimoMarco=""
    local ultimoProceso=-2

    for (( l=0; l<=$numLineas; l++ ));do

        if [ $l -eq $numLineas ];then
            numBloquesPorLinea=$(( $numeroMarcos % $numMaxBloquesPorLinea ))
            if [ $numBloquesPorLinea -eq 0 ];then
                break
            fi

        else
            numBloquesPorLinea=$numMaxBloquesPorLinea
        fi

        ultimoMarco=$(( $primerMarco + $numBloquesPorLinea ))

        printf "%${anchoEtiquetas}s ${cl[3]}██%*s██${rstf}\n" "" $(( $numBloquesPorLinea * $anchoBloqueOut - 2 )) ""

        # PROCESOS
        # Etiqueta
        printf "${ft[0]}${cl[re]}%${anchoEtiquetas}s ${cl[3]}█${rstf}" "Proceso:"
        mar=${primerMarco}

        for ((; mar<${ultimoMarco}; mar++ ));do

            # Poner el color
            if [ -n "${memoriaProceso[$mar]}" ];then
                temp=${memoriaProceso[$mar]}
                temp2=${colorProceso[$temp]}
                echo -e -n "${cl[$temp2]}"
            fi

            local marcoSiguiente=$(( $mar + 1 ))
            # Si el marco está vacío
            if [ -z "${memoriaProceso[$mar]}" ];then

                # Si antes tambien estaba vacío
                if [ $ultimoProceso -eq -1 ];then
                    printf " %${anchoBloqueIn}s"  ""
                else
                    echo -e -n "${cf[0]}${cl[0]}"
                    printf "[%-${anchoBloqueIn}s" "NADA"
                fi
                
                if [ -n "${memoriaProceso[$marcoSiguiente]}" ] || [[ $mar -eq $(( $numeroMarcos - 1 )) ]] ;then
                    printf "]"
                else
                    printf " "
                fi
                ultimoProceso=-1
            
            # Si se cambia de proceso
            elif [ ${ultimoProceso} -ne ${memoriaProceso[$mar]} ];then

                # Poner el color de fondo
            
                temp=${memoriaProceso[$mar]}

                printf "[${ft[0]}%-${anchoBloqueIn}s${ft[1]}" "${nombreProceso[$temp]}"

                if [ -z "${memoriaProceso[$marcoSiguiente]}" ] || [ ${memoriaProceso[$mar]} -ne ${memoriaProceso[$marcoSiguiente]} ];then
                    printf "]"
                else
                    printf " "
                fi

                ultimoProceso=${memoriaProceso[$mar]}

            # Si sigue el mismo proceso
            else
                printf " %${anchoBloqueIn}s"

                if [ -z "${memoriaProceso[$marcoSiguiente]}" ] || [ ${memoriaProceso[$mar]} -ne ${memoriaProceso[$marcoSiguiente]} ];then
                    printf "]"
                else
                    printf " "
                fi
            fi

            echo -e -n "${rstf}"

        done

        printf "${cl[3]}█${rstf}\n"

        # MARCOS
        # Etiqueta
        printf "${ft[0]}${cl[re]} %${anchoEtiquetas}s ${cl[3]}█${rstf}" "Nº Marco:"
        mar=${primerMarco}

        for (( ; mar<${ultimoMarco}; mar++ ));do

            # Poner el color
            if [ -n "${memoriaProceso[$mar]}" ];then
                temp=${memoriaProceso[$mar]}
                temp2=${colorProceso[$temp]}
                echo -e -n "${cl[$temp2]}"
            fi

            if [ -n "${siguienteMarco}" ] && [ $siguienteMarco -eq $mar ];then
                printf "${ft[0]}("
            else
                printf "["
            fi

            printf "%${anchoBloqueIn}s" "$mar"

            if [ -n "${siguienteMarco}" ] && [ $siguienteMarco -eq $mar ];then
                printf ")"
            else
                printf "]"
            fi

            echo -e -n "${rstf}"

        done

        printf "${cl[3]}█${rstf}\n"

        
        # PÁGINA
        # Etiqueta
        printf "${ft[0]}${cl[re]} %${anchoEtiquetas}s ${cl[3]}█${rstf}" "Página:"
        mar=${primerMarco}

        for (( ; mar<${ultimoMarco}; mar++ ));do

            # Poner el color
            if [ -n "${memoriaProceso[$mar]}" ];then
                temp=${memoriaProceso[$mar]}
                temp2=${colorProceso[$temp]}
                echo -e -n "${cl[$temp2]}"
            fi

            if [ -n "${siguienteMarco}" ] && [ $siguienteMarco -eq $mar ];then
                printf "${ft[0]}("
            else
                printf "["
            fi

            printf "%${anchoBloqueIn}s" "${memoriaPagina[$mar]}"
            if [ -n "${siguienteMarco}" ] && [ $siguienteMarco -eq $mar ];then
                printf ")"
            else
                printf "]"
            fi

            echo -e -n "${rstf}"

        done

        printf "${cl[3]}█${rstf}\n"

        # GESTION FIFO
        # Etiqueta
        printf "${ft[0]}${cl[re]}%${anchoEtiquetas}s ${cl[3]}█${rstf}" "Apuntador:"
        mar=${primerMarco}
		sigMar=mar++

        for (( ; mar<${ultimoMarco}; mar++ ));do

            # Poner el color
            if [ -n "${memoriaProceso[$mar]}" ];then
                temp=${memoriaProceso[$mar]}
                temp2=${colorProceso[$temp]}
                echo -e -n "${cl[$temp2]}"
            fi

			# Pone uno donde está el apuntador, el siguiente marco en ocupar
            if [ -n "${siguienteMarco}" ] && [ $siguienteMarco -eq $mar ];then
                printf "${ft[0]}("
            else
                printf "["
            fi
			
			if [ -n "${memoriaProceso[$mar]}" ] && [ $siguienteMarco -eq $mar ];then
                printf "%${anchoBloqueIn}s" "1"
			else
				printf "%${anchoBloqueIn}s" "-"
			fi

            if [ -n "${siguienteMarco}" ] && [ $siguienteMarco -eq $mar ];then
				printf ")"
            else
                printf "]"
            fi

            echo -e -n "${rstf}"

        done

        printf "${cl[3]}█${rstf}\n"
        printf "%${anchoEtiquetas}s ${cl[3]}██%*s██${rstf}\n" "" $(( $numBloquesPorLinea * $anchoBloqueOut - 2 )) ""


        primerMarco=$ultimoMarco

    done
}

# DES: Muestra la linea de memoria pequeña
ej_pantalla_linea_memoria_pequena() {

    local temp
    local temp2

    local anchoBloque=$(( $anchoGen + 1 ))
    local anchoEtiqueta=5
    local anchoEtiquetaFinal=6
    local anchoRestante=$(( $anchoTotal - $anchoEtiqueta - 0)) # Anteriormente estaba con un 1
    local contador=0
    local senal

    local procesoActual=-2
    local primerMarco=0
    local ultimoProceso=""

    for (( l=0; ; l++ ));do
        # En caso de que no se pueda la informacion final al final de la linea y no haya mas marcos
        if [ $primerMarco -eq $numeroMarcos ] && [[ $senal -eq 1 ]];then
            printf "%${anchoEtiqueta}s${rstf} |\n"
            printf "%${anchoEtiqueta}s${rstf} | M:"${numeroMarcos}"\n"
            printf "%${anchoEtiqueta}s${rstf} |\n"
        fi

        # Comprueba si ya ha impreso todos los marcos de pagina
        if [ $primerMarco -eq $numeroMarcos ];then
            break;
        fi

        #PROCESOS
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf " "
        fi

        ultimoProceso=-2
        for (( m=$primerMarco; ; m++ ));do
            # Si el marco está vacío o es el mismo proceso
            if [ -z "${memoriaProceso[$m]}" ] || [ ${ultimoProceso} -eq ${memoriaProceso[$m]} ];then
                printf "%${anchoBloque}s"
                anchoRestante=$(( $anchoRestante - $anchoBloque ))
                ((++contador))

                if [ -z "${memoriaProceso[$m]}" ];then
                    ultimoProceso=-1
                fi
            # Si se cambia de proceso
            elif [ ${ultimoProceso} -ne ${memoriaProceso[$m]} ];then
                temp=${memoriaProceso[$m]}
                printf "%s%*s" "${nombreProcesoColor[$temp]}" "$(( ${anchoBloque} - ${#nombreProceso[$temp]} ))" ""
                ultimoProceso=${temp}
                anchoRestante=$(( $anchoRestante - $anchoBloque ))
                ((++contador))
            fi

            if [[ $anchoRestante -le $anchoBloque ]] || [[ $contador -eq $numeroMarcos ]] ;then
                break
            fi
        done

        if [[ $anchoRestante -lt $anchoEtiquetaFinal ]];then
            printf "${rstf}\n"
            senal=1
        else                
            printf "${rstf}|\n"
            senal=0
        fi

        #PÁGINAS
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" " BM: "
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf " "
        fi

        for (( m=$primerMarco; m<$contador; m++ ));do
            # Poner el color
            if [ -n "${memoriaProceso[$m]}" ];then
                temp=${memoriaProceso[$m]}
                temp2=${colorProceso[$temp]}
                echo -e -n "${cf[$temp2]}"
                [[ " ${coloresClaros[@]} " =~ " ${temp2} " ]] \
                    && echo -n -e "${cl[1]}" \
                    || echo -n -e "${cl[2]}"
            else
                printf "${cf[17]}" 
            fi

            temp=${memoriaProceso[$m]}
            temp2=$(( ${pc[$temp]} - 1 ))
            if [ -n "${memoriaPagina[$m]}" ] && [ ${procesoPagina[$temp,$temp2]} -eq ${memoriaPagina[$m]} ];then
                printf "${ft[0]}"               
            fi

            if [ -n "${memoriaProceso[$m]}" ] && [ -z "${memoriaPagina[$m]}" ];then
                printf "%${anchoBloque}s" "-"
            else
                printf "%${anchoBloque}s" "${memoriaPagina[$m]}"
            fi

            if [ -n "${memoriaPagina[$m]}" ] && [ ${procesoPagina[$temp,$temp2]} -eq ${memoriaPagina[$m]} ];then
                printf "${ft[1]}"
            fi
         
        done

        if [[ $anchoRestante -lt $anchoEtiquetaFinal ]];then
            printf "${rstf}\n"
        else
            printf "${rstf}| M:"${numeroMarcos}"\n"
        fi

        #NÚMERO DE MARCO
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf " "
        fi

        ultimoProceso=-2
		Mini=()
        for (( m=$primerMarco; m<$contador; m++ ));do
            if [ -n "${memoriaProceso[$m]}" ];then
                procesoActual="${memoriaProceso[$m]}"
            else
                procesoActual=-1
            fi
            if [ $ultimoProceso -eq $procesoActual ];then
                printf "%${anchoBloque}s" ""
            else
                printf "%${anchoBloque}s" "$m"
                ultimoProceso=$procesoActual
                Mini=(${Mini[@]} $m)
            fi
        done

	    if [[ $anchoRestante -lt $anchoEtiquetaFinal ]];then
            printf "${rstf}\n"
        else
            printf "${rstf}|\n"
        fi

        primerMarco=$(( $contador + 0 ))
        anchoRestante=$(( $anchoTotal - $anchoEtiqueta ))
    done
    printf "\n"
}

# DES: Mostrar la linea temporal
ej_pantalla_linea_tiempo() {
    local temp
    local temp2

    local anchoBloque=$(( $anchoGen + 1 ))
    local anchoEtiqueta=5
    local anchoEtiquetaFinal=6
    local anchoRestante=$(( $anchoTotal - $anchoEtiqueta )) # Anteriormente estaba con un 1
    local contador=0
    local senal
    
    local primerTiempo=0
    local ultimoProceso=""
    for (( l=0; ; l++ ));do
        # En caso de que no se pueda la informacion final al final de la linea y no haya mas marcos
        if [ $(($primerTiempo-1)) -eq $t ] && [[ $senal -eq 1 ]];then
            printf "%${anchoEtiqueta}s${rstf} |\n"
            printf "%${anchoEtiqueta}s${rstf} | T:"${t}"\n"
            printf "%${anchoEtiqueta}s${rstf} |\n"
        fi

        # Comprueba si ya ha impreso todos los marcos de pagina
        if [ $(($primerTiempo-1)) -eq $t ];then
            break;
        fi

        #PROCESOS
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        else 
            printf "%${anchoEtiqueta}s" ""
            printf " "
        fi

        ultimoProceso=-2
        for (( m=$primerTiempo; ; m++ ));do
            # Si el marco está vacío o es el mismo proceso
            if [ -z "${tiempoProceso[$m]}" ] || [ ${ultimoProceso} -eq ${tiempoProceso[$m]} ];then
                printf "%${anchoBloque}s"
                anchoRestante=$(( $anchoRestante - $anchoBloque ))
                ((++contador))

                if [ -z "${tiempoProceso[$m]}" ];then
                    ultimoProceso=-1
                fi
            # Si se cambia de proceso
            elif [ ${ultimoProceso} -ne ${tiempoProceso[$m]} ];then
                temp=${tiempoProceso[$m]}
                printf "%s%*s" "${nombreProcesoColor[$temp]}" "$(( ${anchoBloque} - ${#nombreProceso[$temp]} ))" ""
                ultimoProceso=${temp}
                anchoRestante=$(( $anchoRestante - $anchoBloque ))
                ((++contador))
            fi
            
            if [[ $anchoRestante -le $anchoBloque ]] || [[ $(($contador-1)) -eq $t ]] ;then
                break;
            fi
        done

        if [[ $anchoRestante -lt $anchoEtiquetaFinal ]];then
            printf "${rstf}\n"
            senal=1
        else                
            printf "${rstf}|\n"
            senal=0
        fi

        # (( ++$l ))

        #PÁGINAS
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" " BT: "
            printf "|"
        else
            printf "%${anchoEtiqueta}s" ""
            printf " "
        fi

        for (( m=$primerTiempo; m<$contador; m++ ));do
            # Poner el color
            if [ $m -eq $t ];then
                printf "${rstf}"
            elif [ -n "${tiempoProceso[$m]}" ];then
                temp=${tiempoProceso[$m]}
                temp2=${colorProceso[$temp]}
                echo -e -n "${cf[$temp2]}"
                [[ " ${coloresClaros[@]} " =~ " ${temp2} " ]] \
                    && echo -n -e "${cl[1]}" \
                    || echo -n -e "${cl[2]}"
            else
                printf "${cf[17]}"
            fi
            printf "%${anchoBloque}s" "${tiempoPagina[$m]}"
        done

        if [[ $anchoRestante -lt $anchoEtiquetaFinal ]];then
            printf "${rstf}\n"
        else
            printf "${rstf}| T:"$t"\n"
        fi

        #TIEMPO
        # Imprimir la etiqueta si estamos en la primera linea
        if [ $l -eq 0 ];then 
            printf "%${anchoEtiqueta}s" ""
            printf "|"
        else
            printf "%${anchoEtiqueta}s" ""
            printf " "
        fi

        ultimoProceso=-2
        for (( m=$primerTiempo; m<$contador; m++ ));do

            if [[ "$ultimoProceso" -eq "-2" || -z "${tiempoProceso[$m]}" && $ultimoProceso -ne -1 || -n "${tiempoProceso[$m]}" && "${ultimoProceso}" -ne "${tiempoProceso[$m]}" ]];then
                    printf "%${anchoBloque}s" "$m"

                    [ -z "${tiempoProceso[$m]}" ] \
                        && ultimoProceso=-1 \
                        || ultimoProceso=${tiempoProceso[$m]}
            else
                printf "%${anchoBloque}s"
            fi
        done

        if [[ $anchoRestante -lt $anchoEtiquetaFinal ]];then
            printf "${rstf}\n"
        else
            printf "${rstf}|\n"
        fi

        primerTiempo=$contador
        anchoRestante=$(( $anchoTotal - $anchoEtiqueta ))
    done
}

# DES: Muestra la pantalla con la información de los eventos que han ocurrido
ej_pantalla() {

    # Mostrar una cabecera con información sobre el algoritmo y sobre la memoria
    ej_pantalla_cabecera

    # Mostrar el tiempo actual
    ej_pantalla_tiempo

    # Mostrar info sobre la llegada de procesos
    ej_pantalla_llegada
	
	# Mostrar info sobre la entrada de procesos en memoria
    ej_pantalla_entrada

    # Mostrar el proceso que ha iniciado su ejecución
    ej_pantalla_inicio

    # Mostrar cola de memoria
    ej_pantalla_cola_memoria

    # Mostrar cola de ejecución
    ej_pantalla_cola_ejecucion

    # Mostrar el proceso que ha salido de ejecución
    ej_pantalla_salida_ejecucion
    
    # Mostrar el proceso que ha salido de memoria
    ej_pantalla_salida_memoria

    # Mostrar tabla con los procesos
    ej_pantalla_tabla
    
    # Mostrar media de Tesp y de Tret
    ej_pantalla_media_tiempos
	
	# Mostrar el proceso que ha finalizado su ejecución junto con un resumen de sus fallos
    ej_pantalla_fin

    # Mostrar el cambio de memoria que ha habido en la reubicación
    ej_pantalla_reubicacion

    # Mostrar la linea de memoria grande
    ej_pantalla_linea_memoria_grande

    # Mostrar la linea de memoria más pequeña
    ej_pantalla_linea_memoria_pequena

    # Mostrar la linea temporal
    ej_pantalla_linea_tiempo

    # #ESTO LUEGO LO QUITAS
    # ej_pantalla_informacion

}

# DES: resetea las variables de evento para que no se vuelvan a mostrar
ej_limpiar_eventos() {
    # No seguir mostrando la pantalla
    mostrarPantalla=0
    reubicacion=0

    llegada=()
    entrada=()
    inicio=""
    salida_ejecucion=""
    salida_memoria=""

    # Si ha finalizado un proceso
    if [[ -n "${fin}" ]];then
        resumenFallos=()
        resumenFIFO=()
        numfallosAntes=0
        
        # Por si entra un proceso a la vez que sale
        local corte=${tiempoEjecucion[$fin]}
        marcoFallo=(${marcoFallo[@]:$corte})
        fin=""
    fi
}

# DES: Muestra un resumen de lo que ha pasado
ej_resumen() {
    # CABECERA
    echo -e                "${cf[$ac]}                                                 ${rstf}"
    echo -e                 "${cf[17]}                                                 ${rstf}"

    echo -e "${cf[17]}${cl[1]}${ft[0]}  SRPT - Pag - FIFO - NC - R                     ${rstf}"

    printf          "${cf[17]}${cl[1]}  %-47s${rstf}\n" "Resumen Final" # Mantiene el ancho de la cabecera
    echo -e                 "${cf[17]}                                                 ${rstf}"
    echo -e                "${cf[$ac]}                                                 ${rstf}"
    echo

    # TABLA PROCESOS
    # Color del proceso que se está imprimiendo
    local color


    if [ $anchoGen -lt 5 ]; then
        local anchoColIni=5 # INICIO EJECUCIÓN
        local anchoColFin=5 # FIN EJECUCIÓN
    else
        local anchoColIni=$anchoGen # INICIO EJECUCIÓN
        local anchoColFin=$anchoGen # FIN EJECUCIÓN
    fi
    if [ $anchoGen -lt 6 ]; then
        local anchoColFal=7 # FALLOS
    else
        local anchoColFal=$anchoGen # FALLOS
    fi

    # Mostrar cabecera
    printf "${ft[0]}" # Negrita
    # Nº proceso
    printf "%-${anchoColRef}s" " Ref"
    # 1ª parte
    printf "%${anchoColTll}s" "Tll "
    printf "%${anchoColTej}s" "Tej "
    # 2ª Parte
    printf "%${anchoColTEsp}s" "Tesp "
    printf "%${anchoColTRet}s" "Tret "
    # Inicio y Fin
    printf "%${anchoColIni}s" "Ini "
    printf "%${anchoColFin}s" "Fin "
    # Fallos
    printf "%${anchoColFal}s" "Fallos "
    printf "${rstf}\n"

    # Mostrar los procesos en orden de llegada
    for proc in ${listaLlegada[*]};do
        
        # Poner la fila con el color del proceso
        color=${colorProceso[$proc]}
        printf "${cl[$color]}${ft[0]}"

        # Ref
        printf "%-${anchoColRef}s" " ${nombreProceso[$proc]}"
        # 1ª parte
        printf "%${anchoColTll}s" "${tiempoLlegada[$proc]} "
        printf "%${anchoColTej}s" "${tiempoEjecucion[$proc]} "
        # 2ª Parte
        printf "%${anchoColTEsp}s" "${tEsp[$proc]} "
        printf "%${anchoColTRet}s" "${tRet[$proc]} "
        # Inicio y Fin
        printf "%${anchoColIni}s" "${procesoInicio[$proc]} "
        printf "%${anchoColFin}s" "${procesoFin[$proc]} "
        # Fallos
        printf "%${anchoColFal}s" "${numFallos[$proc]} "
        printf "${rstf}\n"
    done

    # DATOS VARIOS

    local mediaTesp
    local mediaTret

    local totalFallos=0
    local totalPags=0

    local sum=0
    local cont=0
    for tiem in ${tEsp[*]};do
        sum=$(( sum + $tiem ))
        (( cont++ ))
    done
    [ $cont -ne 0 ] \
        && mediaTesp="$(bc -l <<<"scale=2;$sum / $cont")"
    sum=0
    cont=0

    for tiem in ${tRet[*]};do
        sum=$(( sum + $tiem ))
        (( cont++ ))
    done
    [ $cont -ne 0 ] \
        && mediaTret="$(bc -l <<<"scale=2;$sum / $cont")"


    for p in ${procesos[*]};do
        ((totalFallos+=${numFallos[$p]}))
        ((totalPags+=${tiempoEjecucion[$p]}))
    done

    echo
    echo " Tiempo de espera medio: $mediaTesp"
    echo " Tiempo de retorno medio: $mediaTret"
    echo

}

# DES: Aquí empieza lo difícil. Esto es lo que más vas a tener que cambiar.
ej() {
    # Variables locales

    # Elegir cómo se va a mostrar la ejecución
    local metodoEjecucion
    preguntar "Método de ejecución" \
              "¿Cómo quieres ejecutar el algoritmo?" \
              metodoEjecucion \
              "Mostrar los eventos interesantes" \
			  "Ejecución automática" \
			  "Ejecución completa" \
              "Mostrar solo el resumen final"

    # ------------VARIABLES SOLO PARA LA EJECUCIÓN-------------
    # Memoria
    local memoriaProceso=()         # Contiene el proceso que hay en cada marco. El índice respectivo está vacío si no hay nada.
    local memoriaPagina=()          # Contiene la página que hay en cada marco. El índice respectivo está vacío si no hay nada.
    local memoriaLibre=$numeroMarcos # Número de marcos libres. Se empieza con la memoria vacía.
    local memoriaOcupada=0          # Número de marcos ocupados. Empieza en 0.
    local memoriaFIFO=()             # Contiene el tiempo de entrada a memoria de la pagina. El índice está vacío si no hay nada.
    local marcosActuales=()         # Marcos asignados al proceso en ejecución.
    local guardar_marcosActuales=() # Marcos asignados al proceso en ejecución.

    # Procesos
    local pc=()                     # Contador de los procesos. Contiene la siguiente instrucción a ejecutar para cada proceso.
    for p in ${procesos[*]};do pc[$p]=0 ;done # Poner contador a 0 para todos los procesos

    declare -A procesoMarcos        # Contiene los marcos asignados a cada proceso actualmente

    local estado=()                 # Estado de cada proceso
    # [0=fuera del sistema 1=en espera para entrar a memoria 2=en espera para ser ejecutado 3=en ejecución 4=Finalizado]
    local cadenaEstado=()           # Cadenas correspondientes a cada estado. Es lo que se muestra en la tabla.
    cadenaEstado[0]="Fuera de sist."
    cadenaEstado[1]="En espera"
    cadenaEstado[2]="En memoria"
    cadenaEstado[3]="En ejecución"
    cadenaEstado[4]="Finalizado"
    cadenaEstado[5]="En Pausa"
    for p in ${procesos[*]};do estado[$p]=0 ;done # Poner todos los procesos en estado 0 (fuera del sistema)

    local siguienteMarco=""         # Puntero al siguiente marco en el que se va a introducir una página si no está ya en memoria.

    # Tiempos de espera, de ejecución y restante de ejecución
    local tEsp=()       # Tiempo de espera de cada proceso
    local tRet=()       # Tiempo de retorno (Desde llegada hasta fin de ejecución)
    local tREj=()       # Tiempo restante de ejecución
	local Mini=()       # Marco inicial en memoria
	local Mfin=()       # Marco final en memoria

    # Colas
    local colaLlegada=("${listaLlegada[@]}") # Procesos que están por llegar. En orden de llegada
    local colaMemoria=()            # Procesos que han llegado pero no caben en la memoria y están esperando
    local colaEjecucion=()          # Procesos en memoria esperando a ser ejecutados.
    local enEjecucion               # Proceso en ejecución (Vacío si no se ejecuta nada)

    # Reubicación
    local memoriaProcesoPrevia=()   # Estado de la memoria previo a la reubicación
    local memoriaPaginaPrevia=()    # Estado de la memoria previo a la reubicación
    local memoriaFIFOPrevia=()      # Estado de la memoria previo a la reubicación

    local memoriaProcesoFinal=()    # Estado de la memoria justo después de reubicar
    local memoriaPaginaFinal=()     # Estado de la memoria justo después de reubicar
    
    # ------------VARIABLES PARA EL MOSTRADO DE LA INFORMACIÓN-------------
    local mostrarPantalla=1         # [1=Se va a mostrar la pantalla 0=No se muestra porque no ha ocurrido nada interesante]

    local reubicacion=0             # [0=no ha habido reubicación 1=ha habido reubicación]

    # Anchos para la tabla de procesos
    local anchoColTEsp=5
    local anchoColTRet=5
    local anchoColTREj=$(($anchoColTej + 2 ))
    local anchoEstados=16
	local anchoColMini=5
	local anchoColMfin=5
    local anchoColDire=$anchoGen
	

    # Datos de los eventos que han ocurrido
    local llegada=()                # Procesos que han llegado en este tiempo
    local entrada=()                # Procesos que han entrado a memoria en este tiempo
    local inicio=""                 # Proceso que ha empezado a ejecutarse
    local salida_ejecucion=""       # Proceso que ha salido de ejecutarse
    local algoritmo_srtp=()         #ESTE LUEGO LO QUITAS
    local salida_memoria=""         # Proceso que ha salido de memoria
    local fin=""                    # Proceso que ha finalizado su ejecución

    declare -A resumenFallos        # Contiene información de los fallos de página que han habido durante la ejecución del proceso
                                    # se muestra cuando un proceso finaliza su ejecución. resumenFallos[$momento,$marco]
    declare -A resumenFIFO           # Contiene el estado del contador para cada marco en cada momento
    declare -A paginaTiempo         # Contiene el tiempo en el que se introduce cada página del proceso [$proc,$pc]
    local marcoFallo=()             # Marco que se usa para cada página
    local numFallos=()              # Número de fallos de cada proceso
    local numFallosAntes=0
    for p in ${procesos[*]};do numFallos[$p]=0 ;done

    # Variables para la linea temporal
    local tiempoProceso=()          # Contien el proceso que está en ejecución en cada tiempo
    local tiempoPagina=()           # Contiene la página que se ha ejecutado en cada tiempo

    local numProcesosFinalizados=0
    local numeroEspaciosNoContinuos=()


    # VARIABLES PARA LA PANTALLA DE RESUMEN
    local procesoInicio=()          # Contiene el tiempo de inicio de cada proceso
    local procesoFin=()             # COntiene el tiempo de fin de cada proceso
	
	# Ejecución
	# Dependiendo de la respuesta dada se ejecuta la función correspondiente.
    case $metodoEjecucion in
        1 )
            # Ejecucion eventos interesantes (entrer)
			# Cada ciclo se incrementa el tiempo t
            for (( t=0; ; t++ ));do

        # Si el tiempo es más grande que el ancho general
        if [ ${#t} -gt $anchoGen ];then
            anchoGen=${#t}
        fi

        # Llegada de procesos, ejecución, introducción a memoria...
        ej_ejecutar

        # Mostrado de la pantalla con los eventos que ocurren
        if [ $mostrarPantalla -eq 1 ] && [ $metodoEjecucion -eq 1 ];then
            
            clear
            # Ancho total respecto al cual se van a imprimir las cosas
            local anchoTotal=$( tput cols )
            # mostrar la pantalla
            ej_pantalla

            # Añadir a los informes
            informar_color "$( ej_pantalla )"
            informar_color "----------------------------------------------------------------"

            # Establecer el ancho para el informe plano
            local anchoTotal=$anchoInformeBW
            informar_plano "$( ej_pantalla | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"
            informar_plano "----------------------------------------------------------------"
            
            # limpiar las variables de evento para que no se vuelvan a mostrar
            ej_limpiar_eventos

            # Guardar los informes con la pantalla
            guardar_informes

            pausa_tecla
        fi
        
        # Si no hay ningún proceso en cola ni ejecutandose salir del loop.
        if [ ${#colaEjecucion[*]} -eq 0 ] && [ ${#colaLlegada[*]} -eq 0 ] && [ ${#colaMemoria[*]} -eq 0 ] && [ -z "$enEjecucion" ] ;then
            break
        fi
			done
			# Ejecucion del resumen final
            clear
			# Mostrar el resumen de la ejecución
			ej_resumen
			# Hacer los informes
			informar_color "$( ej_resumen )"
			informar_plano "$( ej_resumen | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"
			guardar_informes
			pausa_tecla
        ;;
        2 )
			# Ejecucion automática, pregunta por el tiempo enrte pantallas
			preguntar_segundos "Tiempo de espera" \
                "¿Cual es el tiempo de espera entre pantallas? (seg)" \
                tiempoEspera
			# Cada ciclo se incrementa el tiempo t	
            # Ejecucion eventos interesantes (entrer)
            for (( t=0; ; t++ ));do

        # Si el tiempo es más grande que el ancho general
        if [ ${#t} -gt $anchoGen ];then
            anchoGen=${#t}
        fi

        # Llegada de procesos, ejecución, introducción a memoria...
        ej_ejecutar

        # Mostrado  los eventos que ocurren un determinado tiempo
        if [ $mostrarPantalla -eq 1 ] && [ $metodoEjecucion -eq 2 ];then
				
            clear
            # Ancho total respecto al cual se van a imprimir las cosas
            local anchoTotal=$( tput cols )
            # mostrar la pantalla
            ej_pantalla

            # Añadir a los informes
            informar_color "$( ej_pantalla )"
            informar_color "----------------------------------------------------------------"

            # Establecer el ancho para el informe plano
            local anchoTotal=$anchoInformeBW
            informar_plano "$( ej_pantalla | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"
            informar_plano "----------------------------------------------------------------"
            
            # limpiar las variables de evento para que no se vuelvan a mostrar
            ej_limpiar_eventos

            # Guardar los informes con la pantalla
            guardar_informes

            sleep "$tiempoEspera"s
        fi
        
        # Si no hay ningún proceso en cola ni ejecutandose salir del loop.
        if [ ${#colaEjecucion[*]} -eq 0 ] && [ ${#colaLlegada[*]} -eq 0 ] && [ ${#colaMemoria[*]} -eq 0 ] && [ -z "$enEjecucion" ] ;then
            break
        fi
			done
			# Ejecucion del resumen final
            clear
			# Mostrar el resumen de la ejecución
			ej_resumen
			# Hacer los informes
			informar_color "$( ej_resumen )"
			informar_plano "$( ej_resumen | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"
			guardar_informes
			pausa_tecla
        ;;
        3 )
            # Ejecucion completa, no pregunta
			# Cada ciclo se incrementa el tiempo t
            for (( t=0; ; t++ ));do

        # Si el tiempo es más grande que el ancho general
        if [ ${#t} -gt $anchoGen ];then
            anchoGen=${#t}
        fi

        # Llegada de procesos, ejecución, introducción a memoria...
        ej_ejecutar

        # Mostrado de la pantalla con los eventos que ocurren
        if [ $mostrarPantalla -eq 1 ] && [ $metodoEjecucion -eq 3 ];then
            
            clear
            # Ancho total respecto al cual se van a imprimir las cosas
            local anchoTotal=$( tput cols )
            # mostrar la pantalla
            ej_pantalla

            # Añadir a los informes
            informar_color "$( ej_pantalla )"
            informar_color "----------------------------------------------------------------"

            # Establecer el ancho para el informe plano
            local anchoTotal=$anchoInformeBW
            informar_plano "$( ej_pantalla | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"
            informar_plano "----------------------------------------------------------------"
            
            # limpiar las variables de evento para que no se vuelvan a mostrar
            ej_limpiar_eventos

            # Guardar los informes con la pantalla
            guardar_informes
			
        fi
        
        # Si no hay ningún proceso en cola ni ejecutandose salir del loop.
        if [ ${#colaEjecucion[*]} -eq 0 ] && [ ${#colaLlegada[*]} -eq 0 ] && [ ${#colaMemoria[*]} -eq 0 ] && [ -z "$enEjecucion" ] ;then
            break
        fi
			done
			# Ejecucion del resumen final
            clear
			# Mostrar el resumen de la ejecución
			ej_resumen
			# Hacer los informes
			informar_color "$( ej_resumen )"
			informar_plano "$( ej_resumen | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"
			guardar_informes
			pausa_tecla
        ;;
		4 )
			# Ejecucion final
			# Cada ciclo se incrementa el tiempo t
            for (( t=0; ; t++ ));do

        # Si el tiempo es más grande que el ancho general
        if [ ${#t} -gt $anchoGen ];then
            anchoGen=${#t}
        fi

        # Llegada de procesos, ejecución, introducción a memoria...
        ej_ejecutar

        # Mostrado de la pantalla con los eventos que ocurren
        if [ $mostrarPantalla -eq 1 ] && [ $metodoEjecucion -eq 4 ];then
            
            clear
            # Ancho total respecto al cual se van a imprimir las cosas
            local anchoTotal=$( tput cols )

            # Añadir a los informes
            informar_color "$( ej_pantalla )"
            informar_color "----------------------------------------------------------------"

            # Establecer el ancho para el informe plano
            local anchoTotal=$anchoInformeBW
            informar_plano "$( ej_pantalla | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"
            informar_plano "----------------------------------------------------------------"
            
            # limpiar las variables de evento para que no se vuelvan a mostrar
            ej_limpiar_eventos

            # Guardar los informes con la pantalla
            guardar_informes
			
        fi
        
        # Si no hay ningún proceso en cola ni ejecutandose salir del loop.
        if [ ${#colaEjecucion[*]} -eq 0 ] && [ ${#colaLlegada[*]} -eq 0 ] && [ ${#colaMemoria[*]} -eq 0 ] && [ -z "$enEjecucion" ] ;then
            break
        fi
			done
		# Ejecucion del resumen final
            clear
		# Mostrar el resumen de la ejecución
		ej_resumen
		# Hacer los informes
		informar_color "$( ej_resumen )"
		informar_plano "$( ej_resumen | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"
		guardar_informes
		pausa_tecla
        ;;
    esac

}

# Función principal
main() {
    init
    intro
    opciones
    datos
    ej
}
main