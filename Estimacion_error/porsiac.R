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
#Solo tenemos las fotos 119,124,127
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
abril_2025_RLOF <- abril_2025_RLOF %>%
  mutate(Clase = ifelse(
    Clase %in% c("zarcillo adulto", "zarcillo juvenil"),
    "zarcillo",
    Clase
  ))

#w <- abril_2025_RLOF %>% group_by(FOTO,Clase) %>% summarise(n=n())
writexl::write_xlsx(abril_2025_RLOF,"datos_aves_marinas/2025/abril/RLOF/conteos_reales.xlsx")

### Calculo del Error:
estimaciones_rlof_abrl_2025 <- read_excel("datos_aves_marinas/2025/abril/RLOF/estimaciones.xlsx")
estimaciones_rlof_abrl_2025$FOTO <- as.numeric(estimaciones_rlof_abrl_2025$FOTO)
unido_rlof_abrl_2025 <- left_join(estimaciones_rlof_abrl_2025,abril_2025_RLOF,by=c("FOTO","Clase"))
unido_rlof_abrl_2025$Real[is.na(unido_rlof_abrl_2025$Real)] <- 0
unido_rlof_abrl_2025 <- unido_rlof_abrl_2025 %>%
  #quitamos las filas en donde no hay conteos ni estimaciones
  unido_rlof_abrl_2025 <- unido_rlof_abrl_2025 %>%
  mutate(
    across(
      matches("^(n|s|m|l|x)_"),
      ~ Real - .,
      .names = "Error_{.col}"
    )
  ) #calculo de errores

errores_rlof_abrl_2025 <- unido_rlof_abrl_2025 %>% select(FOTO,Real ,Clase, starts_with("Error_"))
clases_rlof_abrl_2025 <- unique(errores_rlof_abrl_2025$Clase)

filtrados_rlof_abrl_2025 <- list()
for (i in 1:length(clases_rlof_abrl_2025)){
  filtrados_rlof_abrl_2025[[i]] <- errores_rlof_abrl_2025 %>% filter(Clase==clases_rlof_abrl_2025[i]) %>% 
    filter(if_any(-c(FOTO, Clase), ~ . != 0))
}
names(filtrados_rlof_abrl_2025) <- clases_rlof_abrl_2025

h <- filtrados_rlof_abrl_2025[["pinguino adulto"]]
h <- h %>% select(FOTO,Real,Error_m_0.24)


MAE <- filtrados_rlof_abrl_2025[["pinguino adulto"]] %>%
  summarise(
    across(
      starts_with("Error_"),
      ~ mean(abs(.x), na.rm = TRUE)
    )
  ) %>%
  rename_with(~ sub("^Error_", "MAE_", .x))

min(MAE)
names(MAE)[which.min(MAE)]



##Rompeolas-------------------------------------------------------
### (Exte Inte afue)----------------------------------------------------
datos <- read_excel("datos_aves_marinas/2025/abril/Rompeolas/rompeolas_abr_2025.xlsx",sheet = "datos_limpios")
#Solo tenemos las fotos 119,124,127
exte_inte_afue_abril_2025 <- datos %>% filter(FOTO==119|FOTO==124|FOTO==127)
totales <- exte_inte_afue_abril_2025 %>% group_by(FOTO,ESPECIE) %>% summarise(Adultos=sum(ADULTOS,na.rm = T),
                                                                              Juveniles=sum(JUVENILES,na.rm=T))


