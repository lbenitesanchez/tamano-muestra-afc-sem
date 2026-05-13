# Instrucciones para subir el material a GitHub

## 1. Crear el repositorio

Cree un repositorio público en GitHub, por ejemplo:

```text
tamano-muestra-afc-sem
```

## 2. Subir los archivos

Suba todo el contenido de esta carpeta al repositorio:

```text
README.md
INSTRUCCIONES_GITHUB.md
.gitignore
R/tamano_muestra_latente.R
ejemplos/00_todos_los_ejemplos.R
ejemplos/01_afc_basica.R
ejemplos/02_afc_total_items.R
ejemplos/03_sem_paths.R
ejemplos/04_sem_exogenos.R
ejemplos/05_afc_ordinal_likert.R
ejemplos/06_afc_covarianzas_residuales.R
```

## 3. Verificar la rama principal

Verifique si la rama principal del repositorio se llama `main` o `master`.

La mayoría de repositorios nuevos usan `main`.

## 4. Comando que usarán los estudiantes

Si el repositorio está en la rama `main`, el comando será:

```r
source("https://raw.githubusercontent.com/TU_USUARIO/TU_REPOSITORIO/main/R/tamano_muestra_latente.R")
```

Ejemplo hipotético:

```r
source("https://raw.githubusercontent.com/miusuario/tamano-muestra-afc-sem/main/R/tamano_muestra_latente.R")
```

Si la rama se llama `master`, use:

```r
source("https://raw.githubusercontent.com/TU_USUARIO/TU_REPOSITORIO/master/R/tamano_muestra_latente.R")
```

## 5. Prueba mínima para los estudiantes

Después de ejecutar `source()`, deben probar:

```r
res <- tamano_muestra_latente(
  items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
  tipo = "AFC"
)

res
```

Si la función carga correctamente, R imprimirá el resumen general, el desglose de parámetros libres y la recomendación muestral.

## 6. Recomendación docente

En el sílabo o guía de trabajo, indique explícitamente:

```r
source("https://raw.githubusercontent.com/TU_USUARIO/TU_REPOSITORIO/main/R/tamano_muestra_latente.R")
```

No use el enlace que contiene `/blob/`, porque ese enlace apunta a la página HTML de GitHub y no al archivo R crudo.
