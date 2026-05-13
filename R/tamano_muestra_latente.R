# -----------------------------------------------------------------------------
# tamano_muestra_latente.R
# -----------------------------------------------------------------------------
# Funcion para calcular, a priori, el numero aproximado de parametros libres
# y el tamano muestral recomendado para AFC/SEM bajo el criterio:
#
#   N_recomendado = max(N_minimo, q * r)
#
# donde q es el numero de parametros libres y r es la razon casos/parametro.
#
# La funcion NO requiere datos y NO ejecuta lavaan. Esta pensada para la fase
# de planificacion de encuestas o tesis, antes de recolectar la muestra final.
# -----------------------------------------------------------------------------

#' Calculo a priori del tamano muestral para AFC/SEM
#'
#' @param items_por_constructo Vector numerico con el numero de items por constructo.
#'   Puede estar nombrado, por ejemplo c(F1 = 4, F2 = 4, F3 = 4).
#' @param n_constructos Numero de constructos. Se usa si no se proporciona
#'   items_por_constructo, o si items_por_constructo tiene longitud 1.
#' @param total_items Numero total de items. Se usa si no se proporciona
#'   items_por_constructo.
#' @param tipo Tipo de modelo: "AFC" o "SEM".
#' @param paths Caminos estructurales SEM. Puede ser NULL, un vector de texto
#'   como c("F2 ~ F1", "F3 ~ F1 + F2"), un data.frame con columnas lhs y rhs,
#'   o una matriz con filas = variables dependientes y columnas = predictoras.
#' @param covarianzas_latentes "auto", "todas", "ninguna" o un numero entero.
#'   En AFC, "auto" cuenta todas las covarianzas latentes. En SEM, "auto"
#'   cuenta solo las covarianzas entre constructos exogenos.
#' @param cargas_cruzadas Numero de cargas cruzadas adicionales planificadas.
#' @param covarianzas_residuales Numero de covarianzas residuales adicionales
#'   entre indicadores.
#' @param incluir_interceptos Si TRUE, suma un intercepto por item continuo.
#' @param ordinal Si TRUE, cuenta umbrales para items ordinales.
#' @param categorias Numero de categorias ordinales. Puede ser un unico valor
#'   para todos los items o un vector de longitud igual al total de items.
#' @param umbrales_por_item Numero de umbrales por item. Alternativa a categorias.
#' @param conteo_ordinal "conservador" o "parsimonioso". El conservador suma
#'   umbrales al conteo continuo. El parsimonioso no cuenta varianzas residuales
#'   de indicadores como parametros libres adicionales, aproximando algunas
#'   parametrizaciones ordinales.
#' @param parametros_extra Parametros libres adicionales definidos por el usuario.
#' @param restricciones_igualdad Numero de restricciones de igualdad independientes
#'   que reducen el numero de parametros libres.
#' @param razones Vector con razones casos/parametro, por ejemplo c(10, 15, 20).
#' @param N_minimo Piso minimo absoluto para la recomendacion muestral.
#'
#' @return Objeto de clase tamano_muestra_latente con resumen, desglose de
#'   parametros y recomendacion muestral.
#'
#' @examples
#' res <- tamano_muestra_latente(
#'   items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
#'   tipo = "AFC"
#' )
#' res
#'
#' res_sem <- tamano_muestra_latente(
#'   items_por_constructo = c(F1 = 4, F2 = 4, F3 = 4),
#'   tipo = "SEM",
#'   paths = c("F2 ~ F1", "F3 ~ F1 + F2")
#' )
#' res_sem
# -----------------------------------------------------------------------------

tamano_muestra_latente <- function(
    items_por_constructo = NULL,
    n_constructos = NULL,
    total_items = NULL,
    tipo = c("AFC", "SEM"),
    paths = NULL,
    covarianzas_latentes = c("auto", "todas", "ninguna"),
    cargas_cruzadas = 0,
    covarianzas_residuales = 0,
    incluir_interceptos = FALSE,
    ordinal = FALSE,
    categorias = NULL,
    umbrales_por_item = NULL,
    conteo_ordinal = c("conservador", "parsimonioso"),
    parametros_extra = 0,
    restricciones_igualdad = 0,
    razones = c(10, 15, 20),
    N_minimo = 200
) {
  tipo <- match.arg(tipo)
  conteo_ordinal <- match.arg(conteo_ordinal)

  validar_no_negativo <- function(x, nombre) {
    if (!is.numeric(x) || length(x) != 1 || is.na(x) || x < 0) {
      stop(nombre, " debe ser un numero no negativo.", call. = FALSE)
    }
  }

  validar_no_negativo(cargas_cruzadas, "cargas_cruzadas")
  validar_no_negativo(covarianzas_residuales, "covarianzas_residuales")
  validar_no_negativo(parametros_extra, "parametros_extra")
  validar_no_negativo(restricciones_igualdad, "restricciones_igualdad")

  if (!is.numeric(razones) || any(is.na(razones)) || any(razones <= 0)) {
    stop("razones debe ser un vector numerico con valores positivos.", call. = FALSE)
  }

  if (!is.numeric(N_minimo) || length(N_minimo) != 1 || is.na(N_minimo) || N_minimo < 0) {
    stop("N_minimo debe ser un numero no negativo.", call. = FALSE)
  }

  # ---------------------------------------------------------------------------
  # 1. Determinar numero de constructos e items
  # ---------------------------------------------------------------------------

  if (!is.null(items_por_constructo)) {

    if (!is.numeric(items_por_constructo)) {
      stop("items_por_constructo debe ser numerico.", call. = FALSE)
    }

    if (any(is.na(items_por_constructo)) || any(items_por_constructo <= 0)) {
      stop("Todos los constructos deben tener al menos un item.", call. = FALSE)
    }

    if (length(items_por_constructo) == 1) {
      if (is.null(n_constructos)) {
        stop("Si items_por_constructo tiene un solo valor, debe indicar n_constructos.", call. = FALSE)
      }
      if (!is.numeric(n_constructos) || length(n_constructos) != 1 || n_constructos <= 0) {
        stop("n_constructos debe ser un numero positivo.", call. = FALSE)
      }
      items_vec <- rep(items_por_constructo, n_constructos)
    } else {
      items_vec <- items_por_constructo

      if (!is.null(n_constructos) && length(items_vec) != n_constructos) {
        stop("n_constructos no coincide con la longitud de items_por_constructo.", call. = FALSE)
      }
    }

    k <- length(items_vec)
    p <- sum(items_vec)

    constructos <- names(items_vec)

    if (is.null(constructos) || any(constructos == "")) {
      constructos <- paste0("C", seq_len(k))
      names(items_vec) <- constructos
    }

  } else {

    if (is.null(n_constructos) || is.null(total_items)) {
      stop("Debe indicar items_por_constructo o, alternativamente, n_constructos y total_items.", call. = FALSE)
    }

    if (!is.numeric(n_constructos) || length(n_constructos) != 1 || is.na(n_constructos) || n_constructos <= 0) {
      stop("n_constructos debe ser un numero positivo.", call. = FALSE)
    }

    if (!is.numeric(total_items) || length(total_items) != 1 || is.na(total_items) || total_items <= 0) {
      stop("total_items debe ser un numero positivo.", call. = FALSE)
    }

    k <- n_constructos
    p <- total_items
    items_vec <- rep(NA_real_, k)
    constructos <- paste0("C", seq_len(k))
    names(items_vec) <- constructos
  }

  if (p < k) {
    stop("El numero total de items no puede ser menor que el numero de constructos.", call. = FALSE)
  }

  if (!any(is.na(items_vec)) && any(items_vec < 3)) {
    warning("Algunos constructos tienen menos de 3 items. El modelo puede estar debilmente identificado o ser poco estable.", call. = FALSE)
  }

  # ---------------------------------------------------------------------------
  # 2. Leer paths SEM
  # ---------------------------------------------------------------------------

  parsear_paths <- function(paths) {

    if (is.null(paths)) {
      return(data.frame(lhs = character(), rhs = character(), stringsAsFactors = FALSE))
    }

    if (is.character(paths)) {

      if (length(paths) == 0) {
        return(data.frame(lhs = character(), rhs = character(), stringsAsFactors = FALSE))
      }

      salida <- list()
      contador <- 1

      for (x in paths) {

        partes <- strsplit(x, "~", fixed = TRUE)[[1]]

        if (length(partes) != 2) {
          stop("Cada path debe tener la forma 'Y ~ X' o 'Y ~ X1 + X2'.", call. = FALSE)
        }

        lhs <- trimws(partes[1])
        rhs_todos <- trimws(strsplit(partes[2], "\\+")[[1]])
        rhs_todos <- rhs_todos[rhs_todos != ""]

        if (lhs == "" || length(rhs_todos) == 0) {
          stop("Cada path debe tener lhs y rhs validos.", call. = FALSE)
        }

        for (rhs in rhs_todos) {
          salida[[contador]] <- data.frame(
            lhs = lhs,
            rhs = rhs,
            stringsAsFactors = FALSE
          )
          contador <- contador + 1
        }
      }

      return(do.call(rbind, salida))
    }

    if (is.data.frame(paths)) {

      if (!all(c("lhs", "rhs") %in% names(paths))) {
        stop("Si paths es data.frame, debe contener las columnas lhs y rhs.", call. = FALSE)
      }

      return(data.frame(
        lhs = as.character(paths$lhs),
        rhs = as.character(paths$rhs),
        stringsAsFactors = FALSE
      ))
    }

    if (is.matrix(paths)) {

      if (is.null(rownames(paths)) || is.null(colnames(paths))) {
        stop("Si paths es matriz, debe tener nombres de filas y columnas.", call. = FALSE)
      }

      posiciones <- which(paths != 0, arr.ind = TRUE)

      if (nrow(posiciones) == 0) {
        return(data.frame(lhs = character(), rhs = character(), stringsAsFactors = FALSE))
      }

      return(data.frame(
        lhs = rownames(paths)[posiciones[, 1]],
        rhs = colnames(paths)[posiciones[, 2]],
        stringsAsFactors = FALSE
      ))
    }

    stop("paths debe ser NULL, un vector de texto, un data.frame o una matriz.", call. = FALSE)
  }

  paths_df <- parsear_paths(paths)

  if (tipo == "AFC" && nrow(paths_df) > 0) {
    warning("Se indico tipo = 'AFC'. Los paths estructurales seran ignorados.", call. = FALSE)
    paths_df <- data.frame(lhs = character(), rhs = character(), stringsAsFactors = FALSE)
  }

  if (nrow(paths_df) > 0) {
    variables_paths <- unique(c(paths_df$lhs, paths_df$rhs))
    no_encontradas <- setdiff(variables_paths, constructos)

    if (length(no_encontradas) > 0) {
      stop(
        paste0(
          "Los siguientes constructos aparecen en paths, pero no en items_por_constructo: ",
          paste(no_encontradas, collapse = ", "),
          ". Use nombres en items_por_constructo, por ejemplo c(F1 = 4, F2 = 4)."
        ),
        call. = FALSE
      )
    }

    paths_df <- unique(paths_df)
  }

  n_paths <- ifelse(tipo == "SEM", nrow(paths_df), 0)

  # ---------------------------------------------------------------------------
  # 3. Covarianzas latentes
  # ---------------------------------------------------------------------------

  if (is.numeric(covarianzas_latentes)) {

    if (length(covarianzas_latentes) != 1 || is.na(covarianzas_latentes) || covarianzas_latentes < 0) {
      stop("covarianzas_latentes, si es numerico, debe ser un numero no negativo.", call. = FALSE)
    }

    n_cov_latentes <- covarianzas_latentes

  } else {

    covarianzas_latentes <- match.arg(covarianzas_latentes)

    if (covarianzas_latentes == "auto") {

      if (tipo == "AFC" || n_paths == 0) {
        # En AFC estandar, todos los constructos latentes correlacionan.
        n_cov_latentes <- k * (k - 1) / 2
      } else {
        # En SEM estandar, correlacionan solo los constructos exogenos.
        constructos_endogenos <- unique(paths_df$lhs)
        constructos_exogenos <- setdiff(constructos, constructos_endogenos)
        n_exogenos <- length(constructos_exogenos)
        n_cov_latentes <- n_exogenos * (n_exogenos - 1) / 2
      }

    } else if (covarianzas_latentes == "todas") {

      n_cov_latentes <- k * (k - 1) / 2

    } else if (covarianzas_latentes == "ninguna") {

      n_cov_latentes <- 0
    }
  }

  # ---------------------------------------------------------------------------
  # 4. Umbrales / interceptos
  # ---------------------------------------------------------------------------

  if (ordinal) {

    if (incluir_interceptos) {
      warning("Para variables ordinales se cuentan umbrales. Los interceptos de indicadores no se sumaran.", call. = FALSE)
    }

    n_interceptos <- 0

    if (!is.null(umbrales_por_item)) {

      if (!is.numeric(umbrales_por_item) || any(is.na(umbrales_por_item)) || any(umbrales_por_item < 0)) {
        stop("umbrales_por_item debe ser numerico y no negativo.", call. = FALSE)
      }

      if (length(umbrales_por_item) == 1) {
        n_umbrales <- p * umbrales_por_item
      } else {
        if (length(umbrales_por_item) != p) {
          stop("umbrales_por_item debe tener longitud 1 o longitud igual al numero total de items.", call. = FALSE)
        }
        n_umbrales <- sum(umbrales_por_item)
      }

    } else if (!is.null(categorias)) {

      if (!is.numeric(categorias) || any(is.na(categorias)) || any(categorias < 2)) {
        stop("categorias debe ser numerico y cada item debe tener al menos 2 categorias.", call. = FALSE)
      }

      if (length(categorias) == 1) {
        n_umbrales <- p * (categorias - 1)
      } else {
        if (length(categorias) != p) {
          stop("categorias debe tener longitud 1 o longitud igual al numero total de items.", call. = FALSE)
        }
        n_umbrales <- sum(categorias - 1)
      }

    } else {
      stop("Si ordinal = TRUE, debe indicar categorias o umbrales_por_item.", call. = FALSE)
    }

  } else {

    n_umbrales <- 0
    n_interceptos <- ifelse(incluir_interceptos, p, 0)
  }

  # ---------------------------------------------------------------------------
  # 5. Conteo de parametros libres
  # ---------------------------------------------------------------------------
  # Supuesto central: identificacion por carga marcadora; una carga por
  # constructo se fija en 1.

  n_cargas_libres <- p - k
  n_varianzas_residuales_indicadores <- p
  n_varianzas_latentes_o_residuales <- k

  if (ordinal && conteo_ordinal == "parsimonioso") {
    n_varianzas_residuales_para_conteo <- 0
  } else {
    n_varianzas_residuales_para_conteo <- n_varianzas_residuales_indicadores
  }

  desglose <- data.frame(
    categoria = c(
      "Cargas factoriales libres",
      "Varianzas residuales de indicadores",
      "Varianzas o residuos de constructos latentes",
      "Covarianzas entre constructos latentes",
      "Paths estructurales",
      "Cargas cruzadas adicionales",
      "Covarianzas residuales adicionales",
      "Interceptos de indicadores",
      "Umbrales ordinales",
      "Parametros extra",
      "Restricciones de igualdad"
    ),
    cantidad = c(
      n_cargas_libres,
      n_varianzas_residuales_para_conteo,
      n_varianzas_latentes_o_residuales,
      n_cov_latentes,
      n_paths,
      cargas_cruzadas,
      covarianzas_residuales,
      n_interceptos,
      n_umbrales,
      parametros_extra,
      -restricciones_igualdad
    ),
    stringsAsFactors = FALSE
  )

  q <- sum(desglose$cantidad)

  if (q <= 0) {
    stop("El numero calculado de parametros libres no es positivo. Revise las entradas.", call. = FALSE)
  }

  # ---------------------------------------------------------------------------
  # 6. Recomendacion de tamano muestral
  # ---------------------------------------------------------------------------

  N_por_regla <- ceiling(q * razones)
  N_recomendado <- pmax(N_minimo, N_por_regla)

  recomendacion <- data.frame(
    parametros_libres = q,
    casos_por_parametro = razones,
    N_por_regla = N_por_regla,
    N_minimo = N_minimo,
    N_recomendado = N_recomendado,
    criterio_activo = ifelse(
      N_por_regla >= N_minimo,
      "casos_por_parametro",
      "N_minimo"
    ),
    stringsAsFactors = FALSE
  )

  resumen_general <- data.frame(
    tipo_modelo = tipo,
    constructos = k,
    total_items = p,
    ordinal = ordinal,
    conteo_ordinal = ifelse(ordinal, conteo_ordinal, NA_character_),
    parametros_libres = q,
    N_minimo = N_minimo,
    stringsAsFactors = FALSE
  )

  resultado <- list(
    resumen_general = resumen_general,
    items_por_constructo = data.frame(
      constructo = constructos,
      items = items_vec,
      stringsAsFactors = FALSE
    ),
    paths_estructurales = paths_df,
    desglose_parametros = desglose,
    recomendacion_muestral = recomendacion,
    supuestos = c(
      "Modelo reflectivo.",
      "Identificacion por carga marcadora: una carga factorial fijada en 1 por constructo.",
      "Cada item carga en un solo constructo, salvo que se indiquen cargas_cruzadas.",
      "No se incluyen covarianzas residuales entre indicadores, salvo que se indiquen.",
      "En AFC, por defecto, todos los constructos latentes correlacionan.",
      "En SEM, por defecto, correlacionan solo los constructos exogenos.",
      "El calculo es a priori: no requiere datos ni ajuste lavaan.",
      "Para items ordinales, el conteo conservador suma umbrales al conteo continuo.",
      "Para items ordinales, el conteo parsimonioso no suma varianzas residuales de indicadores."
    )
  )

  class(resultado) <- "tamano_muestra_latente"

  return(resultado)
}


#' Metodo de impresion para tamano_muestra_latente
#'
#' @param x Objeto devuelto por tamano_muestra_latente().
#' @param ... Argumentos adicionales no usados.
# -----------------------------------------------------------------------------
print.tamano_muestra_latente <- function(x, ...) {

  cat("\nRESUMEN GENERAL\n")
  print(x$resumen_general, row.names = FALSE)

  cat("\nITEMS POR CONSTRUCTO\n")
  print(x$items_por_constructo, row.names = FALSE)

  if (nrow(x$paths_estructurales) > 0) {
    cat("\nPATHS ESTRUCTURALES\n")
    print(x$paths_estructurales, row.names = FALSE)
  }

  cat("\nDESGLOSE DE PARAMETROS LIBRES\n")
  print(x$desglose_parametros, row.names = FALSE)

  cat("\nRECOMENDACION MUESTRAL\n")
  print(x$recomendacion_muestral, row.names = FALSE)

  invisible(x)
}


#' Extrae solo la tabla de recomendacion muestral
#'
#' @param x Objeto devuelto por tamano_muestra_latente().
#' @return data.frame con recomendaciones muestrales.
# -----------------------------------------------------------------------------
recomendacion_muestral <- function(x) {
  if (!inherits(x, "tamano_muestra_latente")) {
    stop("x debe ser un objeto devuelto por tamano_muestra_latente().", call. = FALSE)
  }
  x$recomendacion_muestral
}


#' Extrae solo el desglose de parametros libres
#'
#' @param x Objeto devuelto por tamano_muestra_latente().
#' @return data.frame con el desglose de parametros.
# -----------------------------------------------------------------------------
desglose_parametros <- function(x) {
  if (!inherits(x, "tamano_muestra_latente")) {
    stop("x debe ser un objeto devuelto por tamano_muestra_latente().", call. = FALSE)
  }
  x$desglose_parametros
}
