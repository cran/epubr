## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>", message = FALSE, warning = FALSE, error = FALSE, tidy = TRUE
)

## ----ex1-----------------------------------------------------------------
library(epubr)
file <- system.file("dracula.epub", package = "epubr")
(x <- epub(file))

x$data[[1]]

## ----ex2-----------------------------------------------------------------
epub_meta(file)

## ----ex3-----------------------------------------------------------------
epub(file, fields = c("title", "creator", "file"))

## ----ex4-----------------------------------------------------------------
epub(file, drop_sections = "cov")$data[[1]]

## ----ex5-----------------------------------------------------------------
x <- epub(file, drop_sections = "cov", chapter_pattern = "^item\\d\\d")
x

x$data[[1]]

## ----ex6-----------------------------------------------------------------
bookdir <- file.path(tempdir(), "dracula")
epub_unzip(file, exdir = bookdir)
list.files(bookdir, recursive = TRUE)

