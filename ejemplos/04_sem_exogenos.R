# Ejemplo 4: SEM con dos constructos exogenos
# -------------------------------------------
# Modelo:
# F3 <- F1 + F2
# En este caso, F1 y F2 son exogenos y la funcion cuenta una covarianza
# latente entre ellos cuando covarianzas_latentes = "auto".

if (!exists("tamano_muestra_latente")) {
  if (file.exists("R/tamano_muestra_latente.R")) {
    source("R/tamano_muestra_latente.R")
  } else {
    source("../R/tamano_muestra_latente.R")
  }
}

res_sem2 <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "SEM",
  paths = c("F3 ~ F1 + F2"),
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_sem2
