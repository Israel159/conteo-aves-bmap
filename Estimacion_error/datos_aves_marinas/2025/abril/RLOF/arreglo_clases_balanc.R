library(readxl)
library(dplyr)
datos <- read_excel("estimaciones_balanc.xlsx")
datos1 <- datos %>% filter(Clase %in% c("cushuri adulto", "gaviota peruana adulta", "chuita adulta", "cushuri juvenil", "chuita", "gallinazo cabeza roja"))
datos1 <- datos1 %>% mutate(Clase1=case_when(
  Clase=="cushuri adulto" ~ "pinguino adulto",
  Clase=="gaviota peruana adulta" ~ "piquero juvenil",
  Clase=="chuita adulta" ~ "pelicano juvenil",
  Clase=="cushuri juvenil" ~ "pinguino juvenil",
  Clase=="chuita" ~ "pelicano adulto",
  Clase=="gallinazo cabeza roja" ~ "piquero adulto"
))
datos1$Clase <- datos1$Clase1
datos1$Clase1 <- NULL
str(datos1)
datos1$FOTO <- as.numeric(datos1$FOTO)
writexl::write_xlsx(datos1,"estimaciones_balanc.xlsx")
