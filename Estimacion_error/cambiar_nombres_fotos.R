library(stringr)
# Carpeta donde están las imágenes
carpeta <- "datos_aves_marinas\\2025\\abril\\RLOF\\fotos"

# Listar todos los archivos
archivos <- list.files(carpeta, full.names = TRUE)

# Nombre de los archivos sin la ruta
nombres <- basename(archivos)

# Extraer el número 
numero <- as.integer(str_extract(nombres, "\\d+"))

# Extraer la extensión
extension <- tools::file_ext(nombres)

# Nuevo nombre
nuevo_nombre <- paste0(numero, ".", extension)

# Renombrar
file.rename(
  from = archivos,
  to   = file.path(carpeta, nuevo_nombre)
)
