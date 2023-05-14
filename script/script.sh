#!/usr/bin/env bash

# ███████████████████████████████
# █                             █
# █     FUNCIONES GENERALES     █
# █                             █
# ███████████████████████████████

source Generales.sh


# ███████████████████████████████
# █                             █
# █            INIT             █
# █                             █
# ███████████████████████████████

source Inicializacion.sh


# ███████████████████████████████
# █                             █
# █           INTRO             █
# █                             █
# ███████████████████████████████

#Para que se muestren no pueden estar dentro del archivo ns porque.
#source Cabeceras.sh

#Preguntar por si hay alguna forma diferente de hacerlo:

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
        informar_color "#  PriMayor-SN-NC-R: Iván Cortés                #"
        informar_color "#  R-R-Pag-Reloj-C-FI: Ismael Franco Hernando   #"
        informar_color "#  FCFS-SJF-Pag-NFU-NC-R: Cacuci Catalin Andrei #"
        informar_color "#  FCFS-SJF-Pag-NFU-NC-R: Jose Maria Santos     #"
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
        informar_color "${cf[17]}${cl[1]}  Algoritmo de procesos  :  SRPT                ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Tipo de algoritmo      :  PAGINACIÓN           ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Algoritmo de memoria   :  FIFO                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Memoria continua       :  NO                   ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Memoria reublicable    :  SÍ                   ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Autor: Maté Gómez, Pablo                 ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Autores anteriores:                            ${rstf}"
        informar_color "${cf[17]}${cl[1]}  RR-Pag-NRU-C-FI: Diego García Muñoz            ${rstf}"
        informar_color "${cf[17]}${cl[1]}  PriMayor-SN-NC-R: Iván Cortés                  ${rstf}"
        informar_color "${cf[17]}${cl[1]}  R-R-Pag-Reloj-C-FI: Ismael Franco Hernando     ${rstf}"
        informar_color "${cf[17]}${cl[1]}  FCFS-SJF-Pag-NFU-NC-R: Cacuci Catalin Andrei   ${rstf}"
        informar_color "${cf[17]}${cl[1]}  FCFS-SJF-Pag-NFU-NC-R: Jose Maria Santos   ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Asignatura: Sistemas Operativos                ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Profesor: Jose Manuel Saiz Diez                ${rstf}"
        informar_color         "${cf[17]}                                                 ${rstf}"
        informar_color "${cf[17]}${cl[1]}  Este script se creó usando la versión          ${rstf}"
        informar_color "${cf[17]}${cl[1]}  5.2.2 de Bash si no se ejecuta con esta             ${rstf}"
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
        echo -e        "${cf[$ac]}                                                 ${rstf}"
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

source Opciones.sh


# ███████████████████████████████
# █                             █
# █          DATOS              █
# █                             █
# ███████████████████████████████

source Datos.sh


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

        #ESTO PUEDE DAR A ERROR, EN CASOS EN LOS QUE SE HAYA ASIGNADO A UN PROCEOS UN SOLO MARCO DE PAGINA

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
    pausa=$enEjecucion

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
        # Lo repite para todos los momentos que ya habain sido introducidos antes deL SRPT para que se muestren bien por la pantalla
        for (( mom=0; mom<=$(( ${pc[$enEjecucion]} - 1 )); mom++ ));do

            for mar in ${!marcosActuales[*]};do
                # Nos imprime los valores que son los que introducidos en cada instante en ese momento.
                if [[ $mar -eq $mom ]];then
                    marco=${marcosActuales[$mar]}
                    Posicion en la que se ha introducido 
                    for ((i=0;i<=$((${pc[$enEjecucion]}-1));++i)); do
                        resumenFallos["$((mom+i)),$mar"]="${memoriaPagina[$marco]}"
                        resumenFIFO["$((mom+i)),$mar"]="${memoriaFIFO[$marco]}"
                    done
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

source Ejecucion_pantalla.sh


# Función principal
main() {
    init
    intro
    opciones
    datos
    ej
}
main