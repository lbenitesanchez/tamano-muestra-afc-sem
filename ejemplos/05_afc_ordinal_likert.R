# Ejemplo 5: AFC ordinal con items Likert de cinco categorias
# -----------------------------------------------------------
# Cada item ordinal de 5 categorias tiene 4 umbrales.
# Con 12 items, se agregan 48 umbrales al conteo.

if (!exists("tamano_muestra_latente")) {
  if (file.exists("R/tamano_muestra_latente.R")) {
    source("R/tamano_muestra_latente.R")
  } else {
    source("../R/tamano_muestra_latente.R")
  }
}

# Conteo conservador: suma umbrales al conteo continuo base.
res_afc_ordinal_conservador <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  ordinal = TRUE,
  categorias = 5,
  conteo_ordinal = "conservador",
  razones = c(10, 15, 20),
  N_minimo = 300
)

res_afc_ordinal_conservador

# Conteo parsimonioso: no suma varianzas residuales de indicadores.
# Es una aproximacion a ciertas parametrizaciones ordinales.
res_afc_ordinal_parsimonioso <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  ordinal = TRUE,
  categorias = 5,
  conteo_ordinal = "parsimonioso",
  razones = c(10, 15, 20),
  N_minimo = 300
)

res_afc_ordinal_parsimonioso
