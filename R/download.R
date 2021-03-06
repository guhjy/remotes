
#' @importFrom utils compareVersion

download <- function(path, url, auth_token = NULL, basic_auth = NULL,
                     quiet = TRUE) {

  real_url <- url

  if (!is.null(basic_auth)) {
    str <- paste0("://", basic_auth$user, ":", basic_auth$password, "@")
    real_url <- sub("://", str, url)
  }

  if (!is.null(auth_token)) {
    sep <- if (grepl("?", url, fixed = TRUE)) "&" else "?"
    real_url <- paste0(url, sep, "access_token=", auth_token)
  }

  if (compareVersion(get_r_version(), "3.2.0") == -1) {
    curl_download(real_url, path, quiet)

  } else {

    base_download(real_url, path, quiet)
  }

  path
 }

base_download <- function(url, path, quiet) {

  suppressWarnings(
    status <- utils::download.file(
      url,
      path,
      method = download_method(),
      quiet = quiet,
      mode = "wb"
    )
  )

  if (status != 0)  stop("Cannot download file from ", url, call. = FALSE)

  path
}

download_method <- function() {
  
  # R versions newer than 3.3.0 have correct default methods
  if (compareVersion(get_r_version(), "3.3") == -1) {
    
    if (os_type() == "windows") {
      "wininet"
      
    } else if (isTRUE(unname(capabilities("libcurl")))) {
      "libcurl"
      
    } else {
      "auto"
    }
    
  } else {
    "auto"
  }
}

curl_download <- function(url, path, quiet) {

  if (!pkg_installed("curl")) {
    stop("The 'curl' package is required if R is older than 3.2.0")
  }

  curl::curl_download(url, path, quiet = quiet, mode = "wb")
}
