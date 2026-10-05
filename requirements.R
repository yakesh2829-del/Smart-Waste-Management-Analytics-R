packages <- c("shiny","ggplot2","dplyr","DT","scales","lubridate")
user_lib <- Sys.getenv("R_LIBS_USER")
if (!nzchar(user_lib)) {
  user_lib <- file.path(Sys.getenv("USERPROFILE"), "Documents", "R", "win-library",
                        paste0(R.version$major, ".", strsplit(R.version$minor, "\\.")[[1]][1]))
}
dir.create(user_lib, recursive=TRUE, showWarnings=FALSE)
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly=TRUE)]
if(length(missing)) install.packages(missing, lib=user_lib, repos="https://cloud.r-project.org")
cat("All required packages are ready.\n")
