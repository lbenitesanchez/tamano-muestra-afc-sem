# Ejemplo 2: AFC indicando solo numero de constructos y total de items
# ---------------------------------------------------------------------
# En una AFC simple, bajo los supuestos de la funcion, basta con conocer
# el numero de constructos y el numero total de items.

if (!exists("tamano_muestra_latente")) {
  if (file.exists("R/tamano_muestra_latente.R")) {
    source("R/tamano_muestra_latente.R")
  } else {
    source("../R/tamano_muestra_latente.R")
  }
}

res_afc_total <- tamano_muestra_latente(
  n_constructos = 3,
  total_items = 12,
  tipo = "AFC",
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_afc_total
