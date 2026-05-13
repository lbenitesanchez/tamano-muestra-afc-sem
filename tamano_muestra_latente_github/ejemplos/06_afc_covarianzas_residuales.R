# Ejemplo 6: AFC con covarianzas residuales planificadas
# ------------------------------------------------------
# Se agregan dos covarianzas residuales entre indicadores por razones teoricas.

if (!exists("tamano_muestra_latente")) {
  if (file.exists("R/tamano_muestra_latente.R")) {
    source("R/tamano_muestra_latente.R")
  } else {
    source("../R/tamano_muestra_latente.R")
  }
}

res_afc_errores <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  covarianzas_residuales = 2,
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_afc_errores
