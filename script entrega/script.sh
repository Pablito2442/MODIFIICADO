


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
			
			# Asignar variables de marco inicial y marco final.

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
            resumenFIFO["$mom,$mar"]="${memoriaFIFO[$marco]}"
        done

    else
        mom=0
        marcoFallo=(${marcoFallo[@]:1})

        # Lo repite para todos los momentos que ya habain sido introducidos antes deL SRPT para que se muestren bien por la pantalla
        for (( mom=0; mom<=$(( ${pc[$enEjecucion]} - 1 )); mom++ ));do

            for mar in ${!marcosActuales[*]};do
                # Nos imprime los valores que son los que introducidos en cada instante en ese momento.
                if [[ $mar -eq $mom ]];then
                    marco=${marcosActuales[$mar]}
                    # Posicion en la que se ha introducido 
                    for ((i=0;i<=$((${pc[$enEjecucion]}-1));++i)); do
                        resumenFallos["$((mom+i)),$mar"]="${memoriaPagina[$marco]}"
                        resumenFIFO["$((mom+i)),$mar"]="${memoriaFIFO[$marco]}"
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

    local ancho=$(( $anchoColRef + $anchoColTll + $anchoColTej + $anchoColNm + $anchoColTEsp + $anchoColTRet + $anchoColMini + $anchoColMfin + $anchoColTREj + $anchoEstados + $(($anchoCadenaTotal + 2 )) + 20 ))

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
    printf " │"
    # 1ª parte
    printf "%${anchoColTll}s" " Tll"  
    printf " │"      
    printf "%${anchoColTej}s" " Tej"
    printf " │" 
    printf "%${anchoColNm}s" " nMar"
    printf " │" 
    # 2ª Parte
    printf "%${anchoColTEsp}s" " Tesp"
    printf " │" 
    printf "%${anchoColTRet}s" " Tret"
    printf " │" 
    printf "%${anchoColTREj}s" " Trej"
    printf " │" 
	printf "%${anchoColMini}s" " Mini"
    printf " │" 
	printf "%${anchoColMfin}s" " Mfin"
    printf " │" 
    # Estado
    printf "%-${anchoEstados}s" " Estado"
    printf "│"
    # Direcciones
    printf " Dirección - Página"
    printf "%${anchoRestDire}s" "│" 
    printf "${rstf}\n"
    for ((i=0; i<=${ancho}; i++));do
        if [[ $i -eq 0 ]];then
            printf "└"
        elif [[ $i -eq $ancho ]];then 
            printf "┘"
        else
            printf "─"
        fi
    done
    printf "${rstf}\n"

    for ((i=0; i<=${ancho}; i++));do
        if [[ $i -eq 0 ]];then
            printf "┌"
        elif [[ $i -eq $ancho ]];then 
            printf "┐"
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
        printf " │"
        # 1ª parte
        printf "%${anchoColTll}s" "${tiempoLlegada[$proc]}"
        printf " │"
        printf "%${anchoColTej}s" "${tiempoEjecucion[$proc]}"
        printf " │"
        printf "%${anchoColNm}s" "${minimoEstructural[$proc]}"
        printf " │"
        # 2ª Parte
        [[ -n "${tEsp[$proc]}" ]] \
            && printf "%${anchoColTEsp}s" "${tEsp[$proc]}" \
            || printf "%${anchoColTEsp}s" "-"
        printf " │"
        [[ -n "${tRet[$proc]}" ]] \
            && printf "%${anchoColTRet}s" "${tRet[$proc]}" \
            || printf "%${anchoColTRet}s" "-"
        printf " │"
        [[ -n "${tREj[$proc]}" ]] \
            && printf "%${anchoColTREj}s" "${tREj[$proc]} " \
            || printf "%${anchoColTREj}s" "-"
        printf " │"
        # Muestra los marcos iniciales y finales
		case $selector in
            3)

                printf "%${anchoColMini}s" "${marcosActuales[0]}"
                printf " │"
                printf "%${anchoColMfin}s" "${marcosActuales[-1]}"
                printf " │"
                datos_almacena_marcos ${marcosActuales[0]} ${marcosActuales[-1]} ${proc}
                ;;
            4)
				datos_obtiene_marcos 0 $proc
                printf "%${anchoColMini}s" "$Mini"
                printf " │"
                datos_obtiene_marcos 1 $proc
				printf "%${anchoColMfin}s" "$Mfin"
                printf " │"
                ;;
            5)
                datos_obtiene_marcos 0 $proc
                printf "%${anchoColMini}s" "$Mini"
                printf " │"
                datos_obtiene_marcos 1 $proc
				printf "%${anchoColMfin}s" "$Mfin"
                printf " │"
                ;;
            *)
                printf "%${anchoColMini}s" "-"
                printf " │"
                printf "%${anchoColMfin}s" "-"
                printf " │"
                ;;
        esac
        

        # Estado
        # Para que puedan haber tildes hay que poner el ancho diferente.
        printf "%-s%*s" " ${est}" $(( ${anchoEstados} - ${#est} - 1)) ""
        printf "│"

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

    local anchoBloque=$anchoGen
    local anchoEtiqueta=6
    local anchoRestante=$(( $anchoTotal - $anchoEtiqueta - 2 ))
    
    local numBloquesPorLinea

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
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" ""
        printf "|"
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

        #PÁGINAS
        # Imprimir la etiqueta si estamos en la primera linea
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" " ANT: "
        printf "|"
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
                printf "${cf[3]}"
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
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" ""
        printf "|"
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
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" ""
        printf "|"
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

        #PÁGINAS
        # Imprimir la etiqueta si estamos en la primera linea
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" " DES: "
        printf "|"
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
                printf "${cf[3]}"
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
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" ""
        printf "|"
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
                else
                    printf "┌%${anchoGen}s┐" "${resumenFallos[$mom,$mar]}"
                fi

            done
            printf "${rstf}\n"
            printf "%${anchoEtiquetas}s" ""

            for (( mom=0; mom<=$ultimoMomento; mom++ ));do
                if [ ${marcoFallo[$mom]} -eq $mar ];then
                    printf "${cf[3]}╚%${anchoMomento}s╝${cf[0]}" "${resumenFIFO[$mom,$mar]}"
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
				# printf "%${anchoBloqueIn}s"
            else
                printf "["
				# printf "%${anchoBloqueIn}s"
            fi
			
			
			if [ -n "${memoriaProceso[$mar]}" ] && [ $siguienteMarco -eq $mar ];then
                printf "%${anchoBloqueIn}s" "1"
			else
				printf "%${anchoBloqueIn}s" "-"
			fi
			
             # if [[ -n "${memoriaPagina[$mar]}" ]];then
                 # Tiempo de entrada de la página respectiva al marco
                 # local pentrada=${memoriaFIFO[$mar]}
                 # printf "%${anchoBloqueIn}s" "$pentrada"
             # else
                 # printf "%${anchoBloqueIn}s"
             # fi

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
    local anchoRestante=$(( $anchoTotal - $anchoEtiqueta - 2 ))
    
    local numBloquesPorLinea

    local procesoActual=-2
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
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" ""
        printf "|"
        ultimoProceso=-2
        for (( m=$primerMarco; m<=$ultimoMarco; m++ ));do
            # Si el marco está vacío o es el mismo proceso
            if [ -z "${memoriaProceso[$m]}" ] || [ ${ultimoProceso} -eq ${memoriaProceso[$m]} ];then
                printf "%${anchoBloque}s"
                if [ -z "${memoriaProceso[$m]}" ];then
                    ultimoProceso=-1
					
                fi
            # Si se cambia de proceso
            elif [ ${ultimoProceso} -ne ${memoriaProceso[$m]} ];then
                temp=${memoriaProceso[$m]}
                printf "%s%*s" "${nombreProcesoColor[$temp]}" "$(( ${anchoBloque} - ${#nombreProceso[$temp]} ))" ""
                ultimoProceso=${temp}
            fi
        done
        printf "${rstf}|\n"

        #PÁGINAS
        # Imprimir la etiqueta si estamos en la primera linea
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" " BM: "
        printf "|"
        for (( m=$primerMarco; m<=$ultimoMarco; m++ ));do
            # Poner el color
            if [ -n "${memoriaProceso[$m]}" ];then
                temp=${memoriaProceso[$m]}
                temp2=${colorProceso[$temp]}
                echo -e -n "${cf[$temp2]}"
                [[ " ${coloresClaros[@]} " =~ " ${temp2} " ]] \
                    && echo -n -e "${cl[1]}" \
                    || echo -n -e "${cl[2]}"
            else
                printf "${cf[2]}"
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
        printf "${rstf}| M:"${numeroMarcos}"\n"

        #NÚMERO DE MARCO
        # Imprimir la etiqueta si estamos en la primera linea
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" ""
        printf "|"
        ultimoProceso=-2
		Mini=()
        for (( m=$primerMarco; m<=$ultimoMarco; m++ ));do
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
		
        printf "${rstf}|\n"
        # Si se ha llegado al último marco
        if [ $ultimoMarco -eq $(( $numeroMarcos - 1 )) ];then
            break;
        fi
        primerMarco=$(( $ultimoMarco + 1 ))
        anchoRestante=$(( $anchoTotal - 2 ))
    done
}

# DES: Mostrar la linea temporal
ej_pantalla_linea_tiempo() {
    local temp
    local temp2

    local anchoBloque=$(( $anchoGen + 1 ))
    local anchoEtiqueta=5
    local anchoRestante=$(( $anchoTotal - $anchoEtiqueta - 2 ))
    
    local primerTiempo=0
    local ultimoTiempo=""
    local ultimoProceso=""
    for (( l=0; ; l++ ));do

        # Calcular cuntos marcos se van a imprimir en esta linea
        local numBloquesPorLinea=$(( $anchoRestante / $anchoBloque ))
        ultimoTiempo=$(( $primerTiempo + $numBloquesPorLinea - 1 ))
        if [ $ultimoTiempo -gt $t ];then
            ultimoTiempo=$(( $t ))
        fi

        #PROCESOS
        # Imprimir la etiqueta si estamos en la primera linea
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" ""
        printf "|"
        ultimoProceso=-2
        for (( m=$primerTiempo; m<=$ultimoTiempo; m++ ));do
            # Si el marco está vacío o es el mismo proceso
            if [ -z "${tiempoProceso[$m]}" ] || [ ${ultimoProceso} -eq ${tiempoProceso[$m]} ];then
                printf "%${anchoBloque}s"
                if [ -z "${tiempoProceso[$m]}" ];then
                    ultimoProceso=-1
                fi
            # Si se cambia de proceso
            elif [ ${ultimoProceso} -ne ${tiempoProceso[$m]} ];then
                temp=${tiempoProceso[$m]}
                printf "%s%*s" "${nombreProcesoColor[$temp]}" "$(( ${anchoBloque} - ${#nombreProceso[$temp]} ))" ""
                ultimoProceso=${temp}
            fi
        done
        printf "${rstf}|\n"

        #PÁGINAS
        # Imprimir la etiqueta si estamos en la primera linea
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" " BT: "
        printf "|"
        for (( m=$primerTiempo; m<=$ultimoTiempo; m++ ));do
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
                printf "${cf[2]}"
            fi
            printf "%${anchoBloque}s" "${tiempoPagina[$m]}"
        done
        printf "${rstf}| T:"$t"\n"

        #TIEMPO
        # Imprimir la etiqueta si estamos en la primera linea
        [ $l -eq 0 ] && printf "%${anchoEtiqueta}s" ""
        printf "|"
        ultimoProceso=-2
        for (( m=$primerTiempo; m<=$ultimoTiempo; m++ ));do

            if [[ "$ultimoProceso" -eq "-2" || -z "${tiempoProceso[$m]}" && $ultimoProceso -ne -1 || -n "${tiempoProceso[$m]}" && "${ultimoProceso}" -ne "${tiempoProceso[$m]}" ]];then
                printf "%${anchoBloque}s" "$m"

                [ -z "${tiempoProceso[$m]}" ] \
                    && ultimoProceso=-1 \
                    || ultimoProceso=${tiempoProceso[$m]}
            else
                printf "%${anchoBloque}s"
            fi
        done

        printf "${rstf}|\n"
        # Si se ha llegado al último marco
        if [ $ultimoTiempo -eq $t ];then
            break;
        fi
        primerTiempo=$(( $ultimoTiempo + 1 ))
        anchoRestante=$(( $anchoTotal - 2 ))
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

    #ESTO LUEGO LO QUITAS
    ej_pantalla_informacion

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
    local matriz_fallos=()          #ESTE LO QUITAS
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