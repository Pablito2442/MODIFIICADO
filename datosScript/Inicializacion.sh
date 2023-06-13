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