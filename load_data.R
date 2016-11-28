require(quanteda)

downloadData <- function(){
  blog_file_path <- './final/en_US/en_US.blogs.txt'
  if (!file.exists(blog_file_path)){
    download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip", "swiftkey_dataset.zip", "auto")
    unzip('swiftkey_dataset.zip')
  }
}

sampleDocument <- function(file.path, line.count, out.path, percent=0.01){
  sample.doc = sample_lines(file.path, n=line.count*percent, nlines=line.count)
  out.conn <- file(out.path, "w")
  writeLines(sample.doc, con = out.conn, sep="")
  close(out.conn)
}

getBadWords <- function(){
  if (!file.exists("bad_words.csv")){
    download.file("http://www.bannedwordlist.com/lists/swearWords.csv", "bad_words.csv", "auto")
  }
  bad.words <- read.csv("bad_words.csv", colClasses = c("character"), header = F)
  as.character(bad.words[1,])
}

loadCorpus <- function(corpus.dir='./final/en_US/sample/'){
  txt.files <- paste(corpus.dir, '*.txt', sep = "")
  corpus <- corpus(textfile(txt.files))
  corpus
}

cleanCorpus <- function(corpus){
  #Remove any tokens containing a non-english symbol
  texts(corpus) <- gsub("\\S*[^ -~]\\S*", "", texts(corpus))
  #Remove twitter hashtags
  texts(corpus) <- gsub("#\\S*", "", texts(corpus))
  #Remove twitter handles
  texts(corpus) <- gsub("@\\S*", "", texts(corpus))
}