
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

    local ancho=$(( $anchoColRef + $anchoColTll + $anchoColTej + $anchoColNm + $anchoColTEsp + $anchoColTRet + $anchoColMini + $anchoColMfin + $anchoColTREj + $anchoEstados ))
    local anchoRestante
    local anchoCadena
	
    # Mostrar cabecera
    printf "${ft[0]}" # Negrita
    # Nº proceso
    printf "%-${anchoColRef}s" " Ref"
    # 1ª parte
    printf "%${anchoColTll}s" "Tll"
    printf "%${anchoColTej}s" "Tej"
    printf "%${anchoColNm}s" "nMar"
    # 2ª Parte
    printf "%${anchoColTEsp}s" "Tesp"
    printf "%${anchoColTRet}s" "Tret"
    printf "%${anchoColTREj}s" "Trej"
	printf "%${anchoColMini}s" "Mini"
	printf "%${anchoColMfin}s" "Mfin"
    # Estado
    printf "%-${anchoEstados}s" " Estado"
    # Direcciones
    printf " Dirección - Página"
    printf "${rstf}\n"

    # Mostrar los procesos en orden de llegada
    for proc in ${listaLlegada[*]};do
        
        # Poner la fila con el color del proceso
        color=${colorProceso[$proc]}
        # Hayar el estado
        est=${estado[$proc]}
        est=${cadenaEstado[$est]}
        selector=${estado[$proc]}
        
        printf "${cl[$color]}${ft[0]}"
        # Ref
        printf "%-${anchoColRef}s" " ${nombreProceso[$proc]}"
        # 1ª parte
        printf "%${anchoColTll}s" "${tiempoLlegada[$proc]}"
        printf "%${anchoColTej}s" "${tiempoEjecucion[$proc]}"
        printf "%${anchoColNm}s" "${minimoEstructural[$proc]}"
        # 2ª Parte
        [[ -n "${tEsp[$proc]}" ]] \
            && printf "%${anchoColTEsp}s" "${tEsp[$proc]}" \
            || printf "%${anchoColTEsp}s" "-"
        [[ -n "${tRet[$proc]}" ]] \
            && printf "%${anchoColTRet}s" "${tRet[$proc]}" \
            || printf "%${anchoColTRet}s" "-"
        [[ -n "${tREj[$proc]}" ]] \
            && printf "%${anchoColTREj}s" "${tREj[$proc]} " \
            || printf "%${anchoColTREj}s" "-"
        # Muestra los marcos iniciales y finales
		case $selector in
            3)
				# Bucle que recorre todos los elementos del array marcosActuales()
				# for i in "${marcosActuales[@]}"; do
					# printf "${marcosActuales[i]}"
				# done
				
                printf "%${anchoColMini}s" "${marcosActuales[0]}"
                printf "%${anchoColMfin}s" "${marcosActuales[-1]}"
                datos_almacena_marcos ${marcosActuales[0]} ${marcosActuales[-1]} ${proc}
                ;;
            4)
				datos_obtiene_marcos 0 $proc
                printf "%${anchoColMini}s" "$Mini"
                datos_obtiene_marcos 1 $proc
				printf "%${anchoColMfin}s" "$Mfin"
                ;;
            5)
                datos_obtiene_marcos 0 $proc
                printf "%${anchoColMini}s" "$Mini"
                datos_obtiene_marcos 1 $proc
				printf "%${anchoColMfin}s" "$Mfin"
                ;;
            *)
                printf "%${anchoColMini}s" "-"
                printf "%${anchoColMfin}s" "-"
                ;;
        esac

        # Estado
        # Para que puedan haber tildes hay que poner el ancho diferente.
        printf "%-s%*s" " ${est}" $(( ${anchoEstados} - ${#est} - 1)) ""

        anchoRestante=$(( $anchoTotal - $ancho ))

        # Direcciones
        for (( i=0; ; i++ ));do
            anchoCadena=$(( ${#procesoDireccion[$proc,$i]} + ${#procesoPagina[$proc,$i]} + 2 ))

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

            printf "${ft[1]}${procesoDireccion[$proc,$i]}-${ft[0]}${procesoPagina[$proc,$i]}"
            
            if [ $i -lt ${pc[$proc]} ];then
                printf "${ft[3]}"
            fi

            anchoRestante=$(( $anchoRestante - $anchoCadena ))

        done

        printf "${rstf}\n"
    done

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

                if [ ${marcoFallo[$((mom % minimoEstructural[$fin]))]} -eq $mar ];then
                        printf "${cf[3]}╔%${anchoGen}s╗${cf[0]}" "${resumenFallos[$mom,$mar]}"
                else
                    printf "┌%${anchoGen}s┐" "${resumenFallos[$mom,$mar]}"
                fi

            
                # # Esto es una mejora que tengo que implementar despues pero no influye en nada para el codigo.
                # # Este es el apuntador donde se introduce el siguiente marco
                # # elif [[ ${marcoFallo[$mom]} -eq $((mar-1)) ]];then
                # #     printf "${cf[4]}┌%${anchoGen}s┐${cf[0]}" "${resumenFallos[$mom,$mar]}"




            done
            printf "${rstf}\n"
            printf "%${anchoEtiquetas}s" ""

            for (( mom=0; mom<=$ultimoMomento; mom++ ));do
                if [ ${marcoFallo[$((mom % minimoEstructural[$fin]))]} -eq $mar ];then
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

    # for (( mar=0; mar<4; mar++ ));do
    #     for (( mom=0; mom<=6; mom++ ));do
    #         if [ ${marcoFallo[$mom]} -eq $mar ];then
    #             echo -e "Ha entrado en la opcion"
    #         echo -e "La variable marcoFallo de mom tiene: ${marcoFallo[$mom]}"
    #         echo -e "La variable mar tiene: $mar"
    #         fi
    #     done
    # done

    echo -e "La variable marcoFallo tiene: ${marcoFallo[*]}"
    # echo -e "La variable numfallos tiene: ${numfallos[$enEjecucion]}"
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
    local anchoColTREj=$(( $anchoColTej + 1 ))
    local anchoEstados=16
	local anchoColMini=5
	local anchoColMfin=5
	

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
