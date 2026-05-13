# Ejemplo 3: SEM con caminos estructurales
# ----------------------------------------
# Modelo:
# F2 <- F1
# F3 <- F1 + F2

if (!exists("tamano_muestra_latente")) {
  if (file.exists("R/tamano_muestra_latente.R")) {
    source("R/tamano_muestra_latente.R")
  } else {
    source("../R/tamano_muestra_latente.R")
  }
}

res_sem <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "SEM",
  paths = c(
    "F2 ~ F1",
    "F3 ~ F1 + F2"
  ),
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_sem
