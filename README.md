# Cálculo a priori del tamaño de muestra para AFC y SEM

Este repositorio contiene una función en R para calcular, de manera preliminar, el tamaño de muestra recomendado para modelos de **análisis factorial confirmatorio (AFC)** y **modelos de ecuaciones estructurales (SEM)**.

La función está pensada para la etapa de diseño de una investigación, es decir, antes de aplicar la encuesta final y antes de contar con una base de datos. Por ello, no es necesario ejecutar previamente un AFC o SEM.

El cálculo se realiza a partir de la estructura teórica del modelo:

- número de constructos latentes;
- número de ítems por constructo;
- tipo de modelo: AFC o SEM;
- caminos estructurales propuestos, en caso de SEM;
- tratamiento de los ítems como continuos u ordinales;
- número de casos por parámetro libre.

---

## 1. Cargar la función desde GitHub

Abre R o RStudio en tu computadora y ejecuta el siguiente código:

```r
source("https://raw.githubusercontent.com/lbenitesanchez/tamano-muestra-afc-sem/main/tamano_muestra_latente_github/R/tamano_muestra_latente.R")
```

Este comando descarga y carga automáticamente la función `tamano_muestra_latente()` desde GitHub.

Para que funcione correctamente, debes tener conexión a internet.

> **Nota:** La ruta anterior corresponde a la estructura actual del repositorio, donde el archivo se encuentra dentro de la carpeta `tamano_muestra_latente_github/R/`. Si el repositorio se reorganiza y la carpeta `R/` queda directamente en la raíz, entonces la ruta sería:
>
> ```r
> source("https://raw.githubusercontent.com/lbenitesanchez/tamano-muestra-afc-sem/main/R/tamano_muestra_latente.R")
> ```

---

## 2. Verificar que la función fue cargada

Después de ejecutar `source()`, verifica que la función esté disponible:

```r
exists("tamano_muestra_latente")
```

Si el resultado es:

```r
TRUE
```

entonces la función fue cargada correctamente.

---

## 3. Ejemplo 1: AFC con tres constructos y doce ítems

Supón que tu modelo tiene tres constructos latentes y que cada constructo tiene cuatro ítems.

```r
res_afc <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_afc
```

En este ejemplo, el modelo tiene:

- 3 constructos latentes;
- 12 ítems en total;
- 4 ítems por constructo;
- modelo de medición tipo AFC.

La función calculará el número aproximado de parámetros libres y propondrá tamaños de muestra usando las reglas de 10, 15 y 20 casos por parámetro libre.

---

## 4. Ejemplo 2: AFC indicando solo el total de ítems

También puedes indicar únicamente el número total de constructos y el número total de ítems.

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

Este uso es útil cuando solo necesitas una aproximación general del tamaño de muestra.

---

## 5. Ejemplo 3: SEM con caminos estructurales

Supón que tienes tres constructos latentes y propones el siguiente modelo estructural:

```text
F2 <- F1
F3 <- F1 + F2
```

En R, la especificación se realiza así:

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

En este caso, la función considera tanto el modelo de medición como los caminos estructurales propuestos.

---

## 6. Ejemplo 4: SEM con dos constructos exógenos

Supón que el modelo estructural es:

```text
F3 <- F1 + F2
```

En este caso, `F1` y `F2` son constructos exógenos. La función considera automáticamente la covarianza entre constructos exógenos.

```r
res_sem2 <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "SEM",
  paths = c(
    "F3 ~ F1 + F2"
  ),
  razones = c(10, 15, 20),
  N_minimo = 200
)

res_sem2
```

---

## 7. Ejemplo 5: AFC con ítems tipo Likert de cinco categorías

Si los ítems están medidos con una escala Likert de 5 categorías y se desean tratar como ordinales, usa:

```r
res_afc_ordinal <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC",
  ordinal = TRUE,
  categorias = 5,
  razones = c(10, 15, 20),
  N_minimo = 300
)

res_afc_ordinal
```

Este caso suele producir una recomendación muestral mayor, porque al tratar los ítems como ordinales se incorporan umbrales al conteo de parámetros.

---

## 8. Ejemplo 6: AFC con covarianzas residuales planificadas

Si por razones teóricas se planea permitir algunas covarianzas residuales entre indicadores, estas pueden incorporarse al cálculo.

Por ejemplo, para dos covarianzas residuales:

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

---

## 9. Interpretación de la salida

La función devuelve varias tablas. La más importante es:

```r
recomendacion_muestral
```

Esta tabla contiene:

| Columna | Significado |
|---|---|
| `parametros_libres` | Número aproximado de parámetros libres del modelo. |
| `casos_por_parametro` | Regla usada: 10, 15 o 20 casos por parámetro libre. |
| `N_por_regla` | Tamaño de muestra calculado según la regla de casos por parámetro. |
| `N_minimo` | Tamaño mínimo definido como piso metodológico. |
| `N_recomendado` | Tamaño de muestra recomendado. |
| `criterio_activo` | Indica si predominó la regla de casos por parámetro o el tamaño mínimo absoluto. |

La fórmula general usada es:

```text
N_recomendado = max(N_minimo, q * r)
```

donde:

- `q` es el número de parámetros libres;
- `r` es la razón de casos por parámetro libre;
- `N_minimo` es el tamaño mínimo definido para evitar muestras demasiado pequeñas.

---

## 10. Actividad para el estudiante

Define el modelo teórico de tu investigación y responde:

1. ¿Cuántos constructos latentes tendrá tu modelo?
2. ¿Cuántos ítems medirá cada constructo?
3. ¿Tu modelo será AFC o SEM?
4. Si es SEM, ¿qué relaciones estructurales propones?
5. ¿Tus ítems serán tratados como continuos u ordinales?
6. Según la función, ¿cuál sería el tamaño de muestra recomendado bajo los criterios de 10, 15 y 20 casos por parámetro?

Luego, justifica cuál tamaño de muestra adoptarías para tu estudio.

---

## 11. Ejemplo de redacción para el informe

Puedes usar una redacción como la siguiente:

```text
El tamaño de muestra fue determinado de manera preliminar considerando el número aproximado de parámetros libres del modelo propuesto. Para ello, se utilizó la función tamano_muestra_latente(), la cual permite calcular el tamaño muestral recomendado antes de recolectar los datos, a partir del número de constructos, número de ítems por constructo y estructura teórica del modelo.

La recomendación se obtuvo mediante la expresión:

N_recomendado = max(N_minimo, q * r)

donde q representa el número aproximado de parámetros libres y r corresponde a la razón de casos por parámetro libre. Se evaluaron los criterios de 10, 15 y 20 casos por parámetro, junto con un tamaño mínimo absoluto de referencia.
```

---

## 12. Nota metodológica

El resultado entregado por la función debe interpretarse como una recomendación preliminar para la planificación del estudio. No reemplaza un análisis de potencia estadística ni una simulación Monte Carlo, especialmente en modelos complejos, modelos multigrupo, modelos con variables ordinales, cargas factoriales bajas o efectos estructurales pequeños.

---

## 13. Referencia rápida de uso

```r
source("https://raw.githubusercontent.com/lbenitesanchez/tamano-muestra-afc-sem/main/tamano_muestra_latente_github/R/tamano_muestra_latente.R")

res <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC"
)

res
```
