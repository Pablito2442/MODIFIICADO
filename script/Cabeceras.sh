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