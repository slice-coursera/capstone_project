require(tm)
require(RWeka)

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
  corpus <- VCorpus(DirSource(corpus.dir), readerControl = list(language = "en_US"))
  corpus
}

cleanCorpus <- function(corpus){
  if (!file.exists("bad_words.csv")) {
    download.file("http://www.bannedwordlist.com/lists/swearWords.csv", "bad_words.csv", "auto")
  }
  bad.words <- read.csv("bad_words.csv")
  corpus <- tm_map(corpus, removeWords, bad.words)
  #Remove any tokens containing a non-english symbol
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*[^ -~]\\S*", replacement="")
  #Remove hashtag, twitter handles
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="#\\S*", replacement="")
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="@\\S*", replacement="")
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="/|@|\\|", replacement="")
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*.com\\S*", replacement="")
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*.net\\S*", replacement="")
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*.org\\S*", replacement="")
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="rt|via", replacement="")
  sample.corpus <- tm_map(sample.corpus, stripWhitespace)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus
}

generateNGram <- function(corpus, ngram=2){
  
  # Create Term Document Matrix with tokenization
  options(mc.cores=1)
  gramTokenizer <- function(x) NGramTokenizer(x,Weka_control(min=ngram,max=ngram))
  dtm <- DocumentTermMatrix(corpus, control = list(tokenize = gramTokenizer))
  dtm
}

