arquivos <- list.files("data-raw",
                       full.names = TRUE,
                       pattern = ".xlsx")


ler_sigbm <- function(caminho){
  data <- readxl::read_excel(caminho, col_names = FALSE, n_max = 1)[1,1] |>
    as.character() |>
    stringr::str_remove("Informação extraída do SIGBM: ") |>
    readr::parse_datetime(format = "%d/%m/%Y - %H:%M:%S")

  readxl::read_excel(caminho, skip = 4) |>
    janitor::clean_names() |>
    dplyr::mutate(data_sigbm = data)
}

lista_arquivos_lidos <- purrr::map(.x = arquivos,
             .f = ler_sigbm,
             .progress = TRUE)

historico_sigbm <- lista_arquivos_lidos |>
  dplyr::bind_rows() |>
  dplyr::distinct()


readr::write_csv2(historico_sigbm, "historico_sigbm.csv.gz")

piggyback::pb_upload("historico_sigbm.csv.gz",
                     repo = "beatrizmilz/sigbm",
                     tag = "dados")
