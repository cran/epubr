context("epub")

file <- system.file("dracula.epub", package = "epubr")

test_that("epub unzipped as expected", {
  epub_unzip(file)
  expect_true(all(c("META-INF", "mimetype", "OEBPS") %in%
                    list.files(tempdir())))
  expect_equal(length(list.files(file.path(tempdir(), "OEBPS"))), 22)
})

test_that("epub and epub_meta read as expected", {
  err1 <- "File not found."
  err2 <- "All files must end in `.epub`."
  funs <- c(epub, epub_meta, epub_unzip)
  for(f in funs) expect_error(f("X"), err1)
  for(f in funs) expect_error(f(system.file("text.xml", package = "epubr")),
                              err2)

  x <- epub_meta(file)
  expect_identical(names(x), c("rights", "identifier", "creator", "title",
                               "language", "subject", "date", "source"))
  expect_equal(dim(x), c(1, 8))

  x <- epub(file)
  expect_equal(dim(x), c(1, 9))
  expect_equal(dim(x$data[[1]]), c(15, 4))

  x <- epub(file, fields = c("title", "creator"), drop_sections = "^cov")
  expect_equal(dim(x), c(1, 3))
  expect_equal(dim(x$data[[1]]), c(14, 4))

  x <- epub(file, fields = c("title", "creator", "file"),
            drop_sections = "^cov", add_pattern = "xyz")
  expect_equal(dim(x), c(1, 4))
  expect_true("file" %in% names(x))
  expect_equal(dim(x$data[[1]]), c(14, 4))

  f <- function() list(pattern = "Dracula", chapter_check = "Dracula",
                       chapter_doublecheck = "Dracula")
  x <- epub(file, fields = c("title", "creator", "file"),
            drop_sections = "^cov", add_pattern = f,
            chapter_pattern = "item\\d\\d")
  expect_equal(dim(x), c(1, 5))
  expect_true("file" %in% names(x))
  expect_equal(dim(x$data[[1]]), c(14, 5))

  x <- epub(file, fields = c("title", "creator", "file"))
  expect_equal(dim(x), c(1, 4))
  expect_equal(dim(x$data[[1]]), c(15, 4))


  x <- epub(file, fields = c("title", "creator", "file"),
            drop_sections = "^cov", chapter_pattern = "item\\d\\d")
  expect_equal(dim(x), c(1, 5))
  expect_true("nchap" %in% names(x))
  expect_equal(x$nchap, 10)
  expect_identical(x$data[[1]]$section, c(paste0("item", 6:9),
                                          paste0("ch0", 1:9), "ch10"))
  expect_identical(x$data[[1]]$is_chapter,
                   rep(c(FALSE, TRUE), times = c(4, 10)))
  expect_equal(dim(x$data[[1]]), c(14, 5))

  x <- epub(file, fields = c("title", "creator", "file"))
  expect_equal(dim(x), c(1, 4))
  expect_equal(dim(x$data[[1]]), c(15, 4))

  x <- epub(file, fields = c("file", "creator", "title"), title = "creator")
  y <- c("file", "title", "data")
  expect_identical(names(x), y)
  expect_equal(x$title, "Bram Stoker")
  x <- epub(file, fields = "file", title = "X")
  expect_identical(names(x), y)
  expect_equal(x$title, x$file)
  expect_equal(x$title, "dracula.epub")
})

test_that("epub_head returns as expected", {
  x <- epub_head(file)
  y <- epub_head(epub(file))
  expect_identical(x, y)
  expect_equal(names(x), c("section", "text"))
  expect_equal(dim(x), c(15, 2))
})

test_that("epub_cat returns as expected", {
  x <- epub(file)
  x1 <- capture.output(epub_cat(file))
  x2 <- capture.output(y <- epub_cat(x))
  expect_identical(x1, x2)
  expect_is(y, "NULL")

  y <- length(capture.output(epub_cat(x, max_paragraphs = NULL, skip = 1)))
  expect_equal(y, 4623)

  expect_message(epub_cat(x, skip = 1e5),
                 "`skip` is too large. All text skipped.")
})

test_that("count_words returns as expected", {
  x <- " This   sentence will be counted to have:\n\n10 (ten) words."
  y <- ".$/ *#a1 23b :5;-6 a-b\n\nc"
  expect_identical(count_words(x), 10L)
  expect_identical(count_words(c(x, "a", y, "")), c(10L, 1L, 5L, 0L))
  expect_identical(count_words(character(0)), 0L)
  expect_error(count_words(5), "`x` must be character.")
})
