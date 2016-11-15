require(tm)
loadData <- function(path='./final/en_US/'){
  blog_file_path <- paste(path,'en_US.blogs.txt', sep='')
  if (!file.exists(blog_file_path)){
    download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip", "swiftkey_dataset.zip", "auto")
    unzip('swiftkey_dataset.zip')
  }
  corpus <- VCorpus(DirSource(path, encoding = "UTF-8"), readerControl = list(reader=readPlain, language="en_US"))
  corpus
}

removeBadWords <- function(corpus){
  if (!file.exists("bad_words.csv")){
    download.file("http://www.bannedwordlist.com/lists/swearWords.csv", "bad_words.csv", "auto")
  }
  bad.words <- read.csv("bad_words.csv")
  corpus <- tm_map(corpus, removeWords, bad.words)
}

cleanData <- function(corpus){
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(removeNonEnglish))
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- removeBadWords(corpus)
  corpus <- tm_map(corpus, stemDocument)
  corpus
}

removeNonEnglish <- function(x){
  x <- iconv(x, 'latin1', 'ASCII', '!NonEng!')
  gsub(pattern = '\\S*!NonEng!\\S*', replacement = '',x = x)
}

