# Ejemplo 1: AFC con tres constructos y doce items
# -------------------------------------------------
# Ejecute primero source() a la funcion.
# En GitHub, cambie TU_USUARIO y TU_REPOSITORIO por los valores reales.
# source("https://raw.githubusercontent.com/TU_USUARIO/TU_REPOSITORIO/main/R/tamano_muestra_latente.R")

if (!exists("tamano_muestra_latente")) {
  if (file.exists("R/tamano_muestra_latente.R")) {
    source("R/tamano_muestra_latente.R")
  } else {
    source("../R/tamano_muestra_latente.R")
  }
}

res_afc <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_afc

# Extraer solo las tablas principales
recomendacion_muestral(res_afc)
desglose_parametros(res_afc)
