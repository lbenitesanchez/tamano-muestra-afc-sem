# Todos los ejemplos principales
# ------------------------------
# Ejecute este archivo desde la raiz del repositorio.

source("R/tamano_muestra_latente.R")

cat("\n============================\n")
cat("Ejemplo 1: AFC basica\n")
cat("============================\n")
res_afc <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  razones = c(10, 15, 20),
  N_minimo = 200
)
print(res_afc)

cat("\n============================\n")
cat("Ejemplo 2: AFC con total de items\n")
cat("============================\n")
res_afc_total <- tamano_muestra_latente(
  n_constructos = 3,
  total_items = 12,
  tipo = "AFC",
  razones = c(10, 15, 20),
  N_minimo = 200
)
print(res_afc_total)

cat("\n============================\n")
cat("Ejemplo 3: SEM con tres paths\n")
cat("============================\n")
res_sem <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "SEM",
  paths = c("F2 ~ F1", "F3 ~ F1 + F2"),
  razones = c(10, 15, 20),
  N_minimo = 200
)
print(res_sem)

cat("\n============================\n")
cat("Ejemplo 4: SEM con dos exogenos\n")
cat("============================\n")
res_sem2 <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "SEM",
  paths = c("F3 ~ F1 + F2"),
  razones = c(10, 15, 20),
  N_minimo = 200
)
print(res_sem2)

cat("\n============================\n")
cat("Ejemplo 5: AFC ordinal Likert 5 categorias\n")
cat("============================\n")
res_afc_ordinal <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  ordinal = TRUE,
  categorias = 5,
  conteo_ordinal = "conservador",
  razones = c(10, 15, 20),
  N_minimo = 300
)
print(res_afc_ordinal)

cat("\n============================\n")
cat("Ejemplo 6: AFC con covarianzas residuales\n")
cat("============================\n")
res_afc_errores <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  covarianzas_residuales = 2,
  razones = c(10, 15, 20),
  N_minimo = 200
)
print(res_afc_errores)
