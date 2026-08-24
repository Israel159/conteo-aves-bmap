library(tidyr)
library(dplyr)
library(jsonlite)
library(readxl)
library(stringr)
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


##Rompeolas-------------------------------------------------------
### (Exte Inte aden)----------------------------------------------------
datos <- read_excel("datos_aves_marinas/2025/abril/Rompeolas/rompeolas_abr_2025.xlsx",sheet = "datos_limpios")
exte_aden_abril_2025 <- datos %>% filter(LADO=="EXTE ADEN"|LADO=="INTE ADEN")
totales_exte_aden_abril_2025 <- exte_aden_abril_2025 %>% group_by(FOTO,ESPECIE)%>% summarise(Adultos=sum(ADULTOS,na.rm = T),
                                                                                             Juveniles=sum(JUVENILES,na.rm=T))
totales_3 <- totales_exte_aden_abril_2025 %>%
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

abril_2025_Rompeolas <- totales_3 
abril_2025_Rompeolas <- abril_2025_Rompeolas %>%
  mutate(Clase = ifelse(
    Clase %in% c("zarcillo adulto", "zarcillo juvenil"),
    "zarcillo",
    Clase
  ))
writexl::write_xlsx(abril_2025_Rompeolas,"datos_aves_marinas/2025/abril/Rompeolas/conteos_reales.xlsx")

#Abril 2026-------------------------------------------------

##RLOF-------------------------------------------------------

### (Exte Inte afue)----------------------------------------------------
datos <- read_excel("datos_aves_marinas/2026/abril/RLOF/RLOF.xlsx",sheet = "datos_limpios")

exte_inte_afue_abril_2026 <- datos %>% filter(LADO=="EXTE AFUE"|LADO=="INTE AFUE")
totales <- exte_inte_afue_abril_2026 %>% group_by(FOTO,ESPECIE) %>% summarise(Adultos=sum(ADULTOS,na.rm = T),
                                                                              Juveniles=sum(JUVENILES,na.rm=T))

# Transformamos a formato largo para el modelo
totales_4 <- totales %>%
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

abril_2025_RLOF <- abril_2025_RLOF %>% arrange(FOTO)
abril_2025_RLOF <- abril_2025_RLOF %>%
  mutate(Clase = ifelse(
    Clase %in% c("zarcillo adulto", "zarcillo juvenil"),
    "zarcillo",
    Clase
  ))


### Exte aden-----------------
exte_aden_abril_2026 <- datos %>% filter(LADO=="EXTE ADEN")
totales_exte_aden_abril_2026 <- exte_aden_abril_2026 %>% group_by(FOTO,ESPECIE)%>% summarise(Adultos=sum(ADULTOS,na.rm = T),
                                                                                             Juveniles=sum(JUVENILES,na.rm=T))
totales_5 <- totales_exte_aden_abril_2026 %>%
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


abril_2026_RLOF <- rbind(totales_4,totales_5)
abril_2026_RLOF <- abril_2026_RLOF %>% arrange(FOTO)
abril_2026_RLOF <- abril_2026_RLOF %>%
  mutate(Clase = ifelse(
    Clase %in% c("zarcillo adulto", "zarcillo juvenil"),
    "zarcillo",
    Clase
  ))
writexl::write_xlsx(abril_2026_RLOF,"datos_aves_marinas/2026/abril/RLOF/conteos_reales.xlsx")


##Rompeolas-------------------------------------------------------
### (Exte Inte aden)----------------------------------------------------
datos <- read_excel("datos_aves_marinas/2026/abril/Rompeolas/Rompeolas.xlsx",sheet = "datos_limpios")
exte_aden_abril_2026 <- datos %>% filter(LADO=="EXTE ADEN"|LADO=="INTE ADEN")
totales_exte_aden_abril_2026 <- exte_aden_abril_2026 %>% group_by(FOTO,ESPECIE)%>% summarise(Adultos=sum(ADULTOS,na.rm = T),
                                                                                             Juveniles=sum(JUVENILES,na.rm=T))
totales_6 <- totales_exte_aden_abril_2026 %>%
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

abril_2026_Rompeolas <- totales_6
abril_2026_Rompeolas <- abril_2026_Rompeolas %>%
  mutate(Clase = ifelse(
    Clase %in% c("zarcillo adulto", "zarcillo juvenil"),
    "zarcillo",
    Clase
  ))
writexl::write_xlsx(abril_2026_Rompeolas,"datos_aves_marinas/2026/abril/Rompeolas/conteos_reales.xlsx")










# Calculo del Metricas de regresión:------------------
## Abril 2025--------------------------------
### Rlof -------------------
estimaciones_rlof_abrl_2025 <- read_excel("datos_aves_marinas/2025/abril/RLOF/estimaciones_balanc.xlsx")
estimaciones_rlof_abrl_2025$FOTO <- as.numeric(estimaciones_rlof_abrl_2025$FOTO)
unido_rlof_abrl_2025 <- left_join(estimaciones_rlof_abrl_2025, abril_2025_RLOF, by = c("FOTO", "Clase"))
unido_rlof_abrl_2025 <- unido_rlof_abrl_2025 %>% filter(!is.na(Real))
cols_estimacion <- names(unido_rlof_abrl_2025)[str_detect(names(unido_rlof_abrl_2025), "^(n|s|m|l|x)_")]

# Calcular métricas por clase y tamaño de confianza
metricas_por_clase <- unido_rlof_abrl_2025 %>%
  select(FOTO, Clase, Real, all_of(cols_estimacion)) %>%
  pivot_longer(
    cols = all_of(cols_estimacion),
    names_to = "tamano_confianza",
    values_to = "estimacion"
  ) %>%
  # ESTRATEGIA: excluir fila solo cuando AMBOS son cero
  filter(!(Real == 0 & estimacion == 0)) %>%
  group_by(Clase, tamano_confianza) %>%
  summarise(
    # MAE en unidades de aves (3 decimales)
    MAE = round(mean(abs(Real - estimacion)), 3),
    
    # sMAPE como porcentaje (0-200%). 
    # Fórmula: 200 * mean( |Real - Estimado| / (Real + Estimado) )
    sMAPE = round(mean(2 * abs(Real - estimacion) / (Real + estimacion)) * 100, 2),
    
    # RMSE como referencia adicional
    RMSE = round(sqrt(mean((Real - estimacion)^2)), 3),
    
    # Número de observaciones válidas para este umbral
    n = n(),
    .groups = "drop"
  )

# Encontrar el tamaño de confianza ÓPTIMO por clase (menor sMAPE)
optimo_por_clase <- metricas_por_clase %>%
  group_by(Clase) %>%
  slice_min(sMAPE, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(Clase, tamano_confianza, sMAPE, MAE, RMSE, n)
optimo_por_clase


# ver toda la curva de una clase específica
metricas_por_clase %>% filter(Clase == "zarcillo") %>% arrange(sMAPE)

# Guardamos los resultados
writexl::write_xlsx(optimo_por_clase, "datos_aves_marinas/2025/abril/RLOF/optimo_smape_por_clase.xlsx")
writexl::write_xlsx(metricas_por_clase, "datos_aves_marinas/2025/abril/RLOF/metricas_todos_umbrales.xlsx")

### Rompeolas -------------------
estimaciones_rompeolas_abrl_2025 <- read_excel("datos_aves_marinas/2025/abril/Rompeolas/estimaciones_balanc_sahi.xlsx")
estimaciones_rompeolas_abrl_2025$FOTO <- as.numeric(estimaciones_rompeolas_abrl_2025$FOTO)
unido_rompeolas_abrl_2025 <- left_join(estimaciones_rompeolas_abrl_2025, abril_2025_Rompeolas, by = c("FOTO", "Clase"))
unido_rompeolas_abrl_2025 <- unido_rompeolas_abrl_2025 %>% filter(!is.na(Real))
cols_estimacion <- names(unido_rompeolas_abrl_2025)[str_detect(names(unido_rompeolas_abrl_2025), "^(n|s|m|l|x)_")]

# Calcular métricas por clase y tamaño de confianza
metricas_por_clase <- unido_rompeolas_abrl_2025 %>%
  select(FOTO, Clase, Real, all_of(cols_estimacion)) %>%
  pivot_longer(
    cols = all_of(cols_estimacion),
    names_to = "tamano_confianza",
    values_to = "estimacion"
  ) %>%
  # ESTRATEGIA: excluir fila solo cuando AMBOS son cero
  filter(!(Real == 0 & estimacion == 0)) %>%
  group_by(Clase, tamano_confianza) %>%
  summarise(
    # MAE en unidades de aves (3 decimales)
    MAE = round(mean(abs(Real - estimacion)), 3),
    
    # sMAPE como porcentaje (0-200%). 
    # Fórmula: 200 * mean( |Real - Estimado| / (Real + Estimado) )
    sMAPE = round(mean(2 * abs(Real - estimacion) / (Real + estimacion)) * 100, 2),
    
    # RMSE como referencia adicional
    RMSE = round(sqrt(mean((Real - estimacion)^2)), 3),
    
    # Número de observaciones válidas para este umbral
    n = n(),
    .groups = "drop"
  )

# Encontrar el tamaño de confianza ÓPTIMO por clase (menor sMAPE)
optimo_por_clase <- metricas_por_clase %>%
  group_by(Clase) %>%
  slice_min(sMAPE, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(Clase, tamano_confianza, sMAPE, MAE, RMSE, n)
optimo_por_clase$Clase


# ver toda la curva de una clase específica
metricas_por_clase %>% filter(Clase == "zarcillo") %>% arrange(sMAPE)

# (Opcional) Guardar resultados
writexl::write_xlsx(optimo_por_clase, "datos_aves_marinas/2025/abril/Rompeolas/optimo_smape_por_clase.xlsx")
writexl::write_xlsx(metricas_por_clase, "datos_aves_marinas/2025/abril/Rompeolas/metricas_todos_umbrales.xlsx")

### Rompeolas + RLOF -------------------
estimaciones_rompeolas_rlof_abrl_2025 <- read_excel("datos_aves_marinas/2025/abril/rlof_rompeolas_balanceado_sahi.xlsx")
estimaciones_rompeolas_rlof_abrl_2025$FOTO <- as.numeric(estimaciones_rompeolas_rlof_abrl_2025$FOTO)
abril_2025_Rompeolas_rlof <- read_excel("datos_aves_marinas/2025/abril/conteos_reales_rlof+rompeolas.xlsx")
unido_rompeolas_abrl_2025 <- left_join(estimaciones_rompeolas_rlof_abrl_2025, abril_2025_Rompeolas_rlof, by = c("FOTO", "Clase"))
unido_rompeolas_abrl_2025 <- unido_rompeolas_abrl_2025 %>% filter(FOTO %in% unique(abril_2025_Rompeolas_rlof$FOTO))
cols_estimacion <- names(unido_rompeolas_abrl_2025)[str_detect(names(unido_rompeolas_abrl_2025), "^(n|s|m|l|x)_")]

# Calcular métricas por clase y tamaño de confianza
metricas_por_clase <- unido_rompeolas_abrl_2025 %>%
  select(FOTO, Clase, Real, all_of(cols_estimacion)) %>%
  pivot_longer(
    cols = all_of(cols_estimacion),
    names_to = "tamano_confianza",
    values_to = "estimacion"
  ) %>%
  # ESTRATEGIA: excluir fila solo cuando AMBOS son cero
  filter(!(Real == 0 & estimacion == 0)) %>%
  group_by(Clase, tamano_confianza) %>%
  summarise(
    # MAE en unidades de aves (3 decimales)
    MAE = round(mean(abs(Real - estimacion)), 3),
    
    # sMAPE como porcentaje (0-200%). 
    # Fórmula: 200 * mean( |Real - Estimado| / (Real + Estimado) )
    sMAPE = round(mean(2 * abs(Real - estimacion) / (Real + estimacion)) * 100, 2),
    
    # RMSE como referencia adicional
    RMSE = round(sqrt(mean((Real - estimacion)^2)), 3),
    
    # Número de observaciones válidas para este umbral
    n = n(),
    .groups = "drop"
  )

# Encontrar el tamaño de confianza ÓPTIMO por clase (menor sMAPE)
optimo_por_clase <- metricas_por_clase %>%
  group_by(Clase) %>%
  slice_min(sMAPE, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(Clase, tamano_confianza, sMAPE, MAE, RMSE, n)
optimo_por_clase

## Abril 2026------------------------
### Rlof -------------------
estimaciones_rlof_abrl_2026 <- read_excel("datos_aves_marinas/2026/abril/RLOF/estimaciones.xlsx")
estimaciones_rlof_abrl_2026$FOTO <- as.numeric(estimaciones_rlof_abrl_2026$FOTO)
unido_rlof_abrl_2026 <- left_join(estimaciones_rlof_abrl_2026, abril_2026_RLOF, by = c("FOTO", "Clase"))
unido_rlof_abrl_2026$Real[is.na(unido_rlof_abrl_2026$Real)] <- 0
cols_estimacion <- names(unido_rlof_abrl_2026)[str_detect(names(unido_rlof_abrl_2026), "^(n|s|m|l|x)_")]

# Calcular métricas por clase y tamaño de confianza
metricas_por_clase <- unido_rlof_abrl_2026 %>%
  select(FOTO, Clase, Real, all_of(cols_estimacion)) %>%
  pivot_longer(
    cols = all_of(cols_estimacion),
    names_to = "tamano_confianza",
    values_to = "estimacion"
  ) %>%
  # ESTRATEGIA: excluir fila solo cuando AMBOS son cero
  filter(!(Real == 0 & estimacion == 0)) %>%
  group_by(Clase, tamano_confianza) %>%
  summarise(
    # MAE en unidades de aves (3 decimales)
    MAE = round(mean(abs(Real - estimacion)), 3),
    
    # sMAPE como porcentaje (0-200%). 
    # Fórmula: 200 * mean( |Real - Estimado| / (Real + Estimado) )
    sMAPE = round(mean(2 * abs(Real - estimacion) / (Real + estimacion)) * 100, 2),
    
    # RMSE como referencia adicional
    RMSE = round(sqrt(mean((Real - estimacion)^2)), 3),
    
    # Número de observaciones válidas para este umbral
    n = n(),
    .groups = "drop"
  )

# Encontrar el tamaño de confianza ÓPTIMO por clase (menor sMAPE)
optimo_por_clase <- metricas_por_clase %>%
  group_by(Clase) %>%
  slice_min(sMAPE, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(Clase, tamano_confianza, sMAPE, MAE, RMSE, n)
optimo_por_clase


# ver toda la curva de una clase específica
metricas_por_clase %>% filter(Clase == "zarcillo") %>% arrange(sMAPE)

# Guardamos los resultados
writexl::write_xlsx(optimo_por_clase, "datos_aves_marinas/2026/abril/RLOF/optimo_smape_por_clase.xlsx")
writexl::write_xlsx(metricas_por_clase, "datos_aves_marinas/2026/abril/RLOF/metricas_todos_umbrales.xlsx")

### Rompeolas-----------
estimaciones_rompeolas_abrl_2026 <- read_excel("datos_aves_marinas/2026/abril/Rompeolas/estimaciones_sahi.xlsx")
estimaciones_rompeolas_abrl_2026$FOTO <- as.numeric(estimaciones_rompeolas_abrl_2026$FOTO)
unido_rompeolas_abrl_2026 <- left_join(estimaciones_rompeolas_abrl_2026, abril_2026_Rompeolas, by = c("FOTO", "Clase"))
unido_rompeolas_abrl_2026$Real[is.na(unido_rompeolas_abrl_2026$Real)] <- 0
cols_estimacion <- names(unido_rompeolas_abrl_2026)[str_detect(names(unido_rompeolas_abrl_2026), "^(n|s|m|l|x)_")]

# Calcular métricas por clase y tamaño de confianza
metricas_por_clase <- unido_rompeolas_abrl_2026 %>%
  select(FOTO, Clase, Real, all_of(cols_estimacion)) %>%
  pivot_longer(
    cols = all_of(cols_estimacion),
    names_to = "tamano_confianza",
    values_to = "estimacion"
  ) %>%
  # ESTRATEGIA: excluir fila solo cuando AMBOS son cero
  filter(!(Real == 0 & estimacion == 0)) %>%
  group_by(Clase, tamano_confianza) %>%
  summarise(
    # MAE en unidades de aves (3 decimales)
    MAE = round(mean(abs(Real - estimacion)), 3),
    
    # sMAPE como porcentaje (0-200%). 
    # Fórmula: 200 * mean( |Real - Estimado| / (Real + Estimado) )
    sMAPE = round(mean(2 * abs(Real - estimacion) / (Real + estimacion)) * 100, 2),
    
    # RMSE como referencia adicional
    RMSE = round(sqrt(mean((Real - estimacion)^2)), 3),
    
    # Número de observaciones válidas para este umbral
    n = n(),
    .groups = "drop"
  )

# Encontrar el tamaño de confianza ÓPTIMO por clase (menor sMAPE)
optimo_por_clase <- metricas_por_clase %>%
  group_by(Clase) %>%
  slice_min(sMAPE, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  select(Clase, tamano_confianza, sMAPE, MAE, RMSE, n)
optimo_por_clase


# ver toda la curva de una clase específica
metricas_por_clase %>% filter(Clase == "zarcillo") %>% arrange(sMAPE)

# (Opcional) Guardar resultados
writexl::write_xlsx(optimo_por_clase, "datos_aves_marinas/2026/abril/Rompeolas/optimo_smape_por_clase.xlsx")
writexl::write_xlsx(metricas_por_clase, "datos_aves_marinas/2026/abril/Rompeolas/metricas_todos_umbrales.xlsx")
