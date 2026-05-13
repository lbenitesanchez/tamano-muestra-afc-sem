# Tamaño muestral a priori para AFC y SEM

Repositorio didáctico con una función en R para calcular, **antes de recolectar datos**, el número aproximado de parámetros libres y el tamaño muestral recomendado para modelos de **análisis factorial confirmatorio (AFC)** y **modelos de ecuaciones estructurales (SEM)**.

La función está pensada para estudiantes que deben justificar el tamaño de muestra en la fase de diseño de una encuesta, cuando todavía no tienen datos y, por tanto, no pueden ejecutar `cfa()` o `sem()` en `lavaan`.

## Criterio usado

La función calcula:

\[
N_{recomendado} = \max(N_{minimo}, q \times r)
\]

donde:

- `q` = número aproximado de parámetros libres del modelo planificado;
- `r` = razón de casos por parámetro libre, por ejemplo 10, 15 o 20;
- `N_minimo` = piso mínimo absoluto, por defecto 200.

Este criterio es una regla práctica de planificación. No reemplaza un análisis de potencia ni una simulación Monte Carlo, especialmente en modelos complejos, ordinales, multigrupo o con efectos pequeños.

## Cómo usar la función desde GitHub

Una vez que este repositorio esté publicado en GitHub, los estudiantes pueden cargar la función directamente con `source()`.

Reemplace `TU_USUARIO` y `TU_REPOSITORIO` por los datos reales del repositorio:

```r
source("https://raw.githubusercontent.com/TU_USUARIO/TU_REPOSITORIO/main/R/tamano_muestra_latente.R")
```

Ejemplo:

```r
source("https://raw.githubusercontent.com/miusuario/tamano-muestra-afc-sem/main/R/tamano_muestra_latente.R")
```

Si el repositorio usa la rama `master` en lugar de `main`, cambie `main` por `master`.

## Uso local

Si descarga o clona el repositorio, desde la raíz del proyecto ejecute:

```r
source("R/tamano_muestra_latente.R")
```

## Ejemplo 1: AFC con tres constructos y doce ítems

```r
res_afc <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_afc
```

En este modelo:

- 3 constructos;
- 12 ítems;
- una carga factorial fijada por constructo;
- factores correlacionados;
- sin cargas cruzadas;
- sin covarianzas residuales.

Resultado esperado:

| Parámetros libres | Casos/parámetro | N por regla | N mínimo | N recomendado |
|---:|---:|---:|---:|---:|
| 27 | 10 | 270 | 200 | 270 |
| 27 | 15 | 405 | 200 | 405 |
| 27 | 20 | 540 | 200 | 540 |

## Ejemplo 2: AFC indicando solo el total de ítems

```r
res_afc_total <- tamano_muestra_latente(
  n_constructos = 3,
  total_items = 12,
  tipo = "AFC",
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_afc_total
```

Bajo los supuestos básicos de la función, este caso también produce `q = 27`.

## Ejemplo 3: SEM con caminos estructurales

Modelo:

\[
F_2 \leftarrow F_1
\]

\[
F_3 \leftarrow F_1 + F_2
\]

Código:

```r
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
```

## Ejemplo 4: SEM con dos constructos exógenos

Modelo:

\[
F_3 \leftarrow F_1 + F_2
\]

En este caso, `F1` y `F2` son exógenos. Con `covarianzas_latentes = "auto"`, la función cuenta una covarianza latente entre ellos.

```r
res_sem2 <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "SEM",
  paths = c("F3 ~ F1 + F2"),
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_sem2
```

## Ejemplo 5: AFC ordinal con ítems Likert de cinco categorías

Cada ítem ordinal de 5 categorías tiene 4 umbrales. Con 12 ítems, se agregan 48 umbrales al conteo.

Conteo conservador:

```r
res_afc_ordinal <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  ordinal = TRUE,
  categorias = 5,
  conteo_ordinal = "conservador",
  razones = c(10, 15, 20),
  N_minimo = 300
)

res_afc_ordinal
```

También puede usarse un conteo parsimonioso:

```r
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
```

## Ejemplo 6: AFC con covarianzas residuales planificadas

```r
res_afc_errores <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  covarianzas_residuales = 2,
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_afc_errores
```

## Archivos incluidos

```text
R/tamano_muestra_latente.R
  Función principal y métodos auxiliares.

ejemplos/00_todos_los_ejemplos.R
  Ejecuta todos los ejemplos principales desde la raíz del repositorio.

ejemplos/01_afc_basica.R
  AFC con tres constructos y doce ítems.

ejemplos/02_afc_total_items.R
  AFC indicando solo constructos y total de ítems.

ejemplos/03_sem_paths.R
  SEM con tres caminos estructurales.

ejemplos/04_sem_exogenos.R
  SEM con dos constructos exógenos.

ejemplos/05_afc_ordinal_likert.R
  AFC ordinal con ítems Likert de cinco categorías.

ejemplos/06_afc_covarianzas_residuales.R
  AFC con covarianzas residuales planificadas.
```

## Supuestos del cálculo

La función asume, salvo que se indique lo contrario:

1. Modelo de medición reflectivo.
2. Identificación por carga marcadora: una carga factorial fijada en 1 por constructo.
3. Cada ítem carga en un solo constructo.
4. No hay cargas cruzadas, salvo que se indiquen con `cargas_cruzadas`.
5. No hay covarianzas residuales entre indicadores, salvo que se indiquen con `covarianzas_residuales`.
6. En AFC, todos los constructos latentes correlacionan por defecto.
7. En SEM, correlacionan por defecto solo los constructos exógenos.
8. Para ítems ordinales, se agregan umbrales. El conteo `conservador` suma umbrales al conteo continuo base; el conteo `parsimonioso` no suma varianzas residuales de indicadores.

## Argumentos principales

| Argumento | Descripción |
|---|---|
| `items_por_constructo` | Vector con el número de ítems por constructo. Ejemplo: `c(F1 = 4, F2 = 4, F3 = 4)`. |
| `n_constructos` | Número de constructos, útil si solo se conoce el total de ítems. |
| `total_items` | Número total de ítems. |
| `tipo` | `"AFC"` o `"SEM"`. |
| `paths` | Caminos estructurales para SEM. Ejemplo: `c("F2 ~ F1", "F3 ~ F1 + F2")`. |
| `ordinal` | Si `TRUE`, cuenta umbrales para ítems ordinales. |
| `categorias` | Número de categorías ordinales. Ejemplo: `5` para Likert de cinco categorías. |
| `conteo_ordinal` | `"conservador"` o `"parsimonioso"`. |
| `razones` | Razones casos/parámetro. Por defecto `c(10, 15, 20)`. |
| `N_minimo` | Piso mínimo absoluto. Por defecto `200`. |

## Referencias metodológicas sugeridas

Bentler, P. M., & Chou, C. P. (1987). Practical issues in structural modeling. *Sociological Methods & Research, 16*(1), 78–117. https://doi.org/10.1177/0049124187016001004

Boomsma, A. (1985). Nonconvergence, improper solutions, and starting values in LISREL maximum likelihood estimation. *Psychometrika, 50*, 229–242. https://doi.org/10.1007/BF02294248

Hoogland, J. J., & Boomsma, A. (1998). Robustness studies in covariance structure modeling: An overview and a meta-analysis. *Sociological Methods & Research, 26*(3), 329–367. https://doi.org/10.1177/0049124198026003003

Jackson, D. L. (2003). Revisiting sample size and number of parameter estimates: Some support for the N:q hypothesis. *Structural Equation Modeling: A Multidisciplinary Journal, 10*(1), 128–141. https://doi.org/10.1207/S15328007SEM1001_6

Kline, R. B. (2023). *Principles and practice of structural equation modeling* (5th ed.). The Guilford Press.

Li, C. H. (2016). Confirmatory factor analysis with ordinal data: Comparing robust maximum likelihood and diagonally weighted least squares. *Behavior Research Methods, 48*, 936–949. https://doi.org/10.3758/s13428-015-0619-7

MacCallum, R. C., Browne, M. W., & Sugawara, H. M. (1996). Power analysis and determination of sample size for covariance structure modeling. *Psychological Methods, 1*(2), 130–149. https://doi.org/10.1037/1082-989X.1.2.130

Muthén, L. K., & Muthén, B. O. (2002). How to use a Monte Carlo study to decide on sample size and determine power. *Structural Equation Modeling: A Multidisciplinary Journal, 9*(4), 599–620. https://doi.org/10.1207/S15328007SEM0904_8

Rhemtulla, M., Brosseau-Liard, P. É., & Savalei, V. (2012). When can categorical variables be treated as continuous? A comparison of robust continuous and categorical SEM estimation methods under suboptimal conditions. *Psychological Methods, 17*(3), 354–373. https://doi.org/10.1037/a0029315

Westland, J. C. (2010). Lower bounds on sample size in structural equation modeling. *Electronic Commerce Research and Applications, 9*(6), 476–487. https://doi.org/10.1016/j.elerap.2010.07.003

Wolf, E. J., Harrington, K. M., Clark, S. L., & Miller, M. W. (2013). Sample size requirements for structural equation models: An evaluation of power, bias, and solution propriety. *Educational and Psychological Measurement, 73*(6), 913–934. https://doi.org/10.1177/0013164413495237

## Licencia

Material preparado para uso académico. Puede adaptarse para docencia e investigación citando las fuentes metodológicas correspondientes.
