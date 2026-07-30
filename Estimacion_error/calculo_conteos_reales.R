library(tidyr)
library(dplyr)
library(jsonlite)
library(readxl)

# Diccionario completo de especies
diccionario_especies <- c(
  "AMOY"  = "Ostrero americano",
  "BFBO"  = "Piquero de patas azules",
  "BLOY"  = "Ostrero negro",
  "BLVU"  = "Gallinazo de cabeza negra",
  "BROPE" = "pelicano",
  "CHAL"  = "Chorlitejo patinegro",
  "CHUCO" = "chuita",
  "FRGU"  = "Gaviota de Franklin",
  "GRGU"  = "Garuma",
  "GUCO"  = "guanay",
  "HUPE"  = "pinguino",
  "INTE"  = "zarcillo",
  "KEGU"  = "Gaviota dominicana",
  "NECO"  = "cushuri",
  "PEBO"  = "piquero",
  "PEGU"  = "gaviota peruana",
  "PEFA"  = "Halcón peregrino",
  "PEPE"  = "pelicano",
  "PLAMA" = "Playerito manchado",
  "RYNI"  = "Rayador",
  "SNDL"  = "Playerito blanco",
  "SWPL"  = "Chorlo nevado",
  "THAEL" = "Gaviotín elegante",
  "THAMA" = "Gaviotín real",
  "THASA" = "Gaviotín de Sandwich",
  "TUVU"  = "gallinazo cabeza roja",
  "VEFLY" = "Turtupilín",
  "YCNH"  = "Huaco de corona amarilla",
  "ZATRI" = "Zarapito trinador"
)


#Abril 2025-------------------------------------------------

##RLOF-------------------------------------------------------

### (Exte Inte afue)----------------------------------------------------
datos <- read_excel("datos_aves_marinas/2025/abril/RLOF/RLOF.xlsx",sheet = "datos_limpios")
#Solo fotos 119,124,127
exte_inte_afue_abril_2025 <- datos %>% filter(FOTO==119|FOTO==124|FOTO==127)
totales <- exte_inte_afue_abril_2025 %>% group_by(FOTO,ESPECIE) %>% summarise(Adultos=sum(ADULTOS,na.rm = T),
                                                                              Juveniles=sum(JUVENILES,na.rm=T))

# Transformamos a formato largo para el modelo
totales_1 <- totales %>%
  pivot_longer(
    cols = c(Adultos, Juveniles),
    names_to = "Edad",
    values_to = "Real"
  ) %>%
  mutate(
    # Nombre base de la especie
    nombre_base = diccionario_especies[ESPECIE],
    # Clase final: "Especie adulto" o "Especie juvenil"
    Clase = ifelse(Edad == "Adultos",
                   paste(nombre_base, "adulto"),
                   paste(nombre_base, "juvenil")),
  ) %>%
  # Mantener los ceros para evaluar también las ausencias (recomendado)
  select(FOTO,Clase, Real) %>% filter(Real>0)



### Exte aden-----------------
exte_aden_abril_2025 <- datos %>% filter(LADO=="EXTE ADEN")
totales_exte_aden_abril_2025 <- exte_aden_abril_2025 %>% group_by(FOTO,ESPECIE)%>% summarise(Adultos=sum(ADULTOS,na.rm = T),
                                                                          Juveniles=sum(JUVENILES,na.rm=T))
totales_2 <- totales_exte_aden_abril_2025 %>%
  pivot_longer(
    cols = c(Adultos, Juveniles),
    names_to = "Edad",
    values_to = "Real"
  ) %>%
  mutate(
    # Nombre base de la especie
    nombre_base = diccionario_especies[ESPECIE],
    # Clase final: "Especie adulto" o "Especie juvenil"
    Clase = ifelse(Edad == "Adultos",
                   paste(nombre_base, "adulto"),
                   paste(nombre_base, "juvenil")),
  ) %>%
  select(FOTO,Clase, Real) %>% filter(Real>0)


abril_2025_RLOF <- rbind(totales_1,totales_2)
abril_2025_RLOF <- abril_2025_RLOF %>% arrange(FOTO)

writexl::write_xlsx(abril_2025_RLOF,"datos_aves_marinas/2025/abril/RLOF/conteos_reales.xlsx")

#Rompeolas abril 2025 -------------------------
datos <- read.delim("clipboard")


