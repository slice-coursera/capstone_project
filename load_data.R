require(tm)

downloadData <- function(){
  blog_file_path <- './final/en_US/en_US.blogs.txt'
  if (!file.exists(blog_file_path)){
    download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip", "swiftkey_dataset.zip", "auto")
    unzip('swiftkey_dataset.zip')
  }
}

sampleDocument <- function(file.path, out.path, percent=0.02){
  flines = determine_nlines(file.path)
  sample.doc = sample_lines(file.path, n=flines*percent, nlines=flines)
  out.conn <- file(out.path, "w")
  writeLines(sample.doc, con = out.conn, sep="")
  close(out.conn)
}

loadCorpus <- function(corpus.dir='./final/en_US/sample/'){
  corpus <- VCorpus(DirSource(corpus.dir, encoding = "UTF-8"), readerControl = list(language = "en_US"))
  corpus
}
