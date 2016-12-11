require(tm)
require(RWeka)
require(stringi)
require(data.table)
require(slam)
require(LaF)

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

getBadWords <- function(){
  if (!file.exists("bad_words.csv")){
    download.file("http://www.bannedwordlist.com/lists/swearWords.csv", "bad_words.csv", "auto")
  }
  bad.words <- read.csv("bad_words.csv", colClasses = c("character"), header = F)
  as.character(bad.words[1,])
}

loadCorpus <- function(corpus.dir='./final/en_US/sample/'){
  corpus <- VCorpus(DirSource(corpus.dir, encoding = "UTF-8"), readerControl = list(language = "en_US"))
  corpus
}


replace.token='__r__m__'
cleanCorpus <- function(corpus){
  if (!file.exists("bad_words.csv")) {
    download.file("http://www.bannedwordlist.com/lists/swearWords.csv", "bad_words.csv", "auto")
  }
  
  bad.words <- readLines('bad_words.csv')
  bad.words <- as.character(unlist(strsplit(bad.words, ',')))
  corpus <- tm_map(corpus, removePunctuation)
  #Remove any tokens containing a non-english symbol
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*[^ -~]\\S*", replacement=replace.token)
  corpus <- tm_map(corpus, content_transformer(tolower))
  #Remove hashtag, twitter handles
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="#\\S*", replacement=replace.token)
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*@\\S*", replacement=replace.token)
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="/|@|\\|", replacement=" ")
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*.com\\S*", replacement=replace.token)
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*.net\\S*", replacement=replace.token)
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*.org\\S*", replacement=replace.token)
  corpus <- tm_map(corpus, removeWords, unlist(bad.words))
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="rt|via", replacement=replace.token)
  corpus <- tm_map(corpus, removeNumbers)
  #corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus
}

generateNGram <- function(corpus, ngram=2){
  # Create Term Document Matrix with tokenization
  #options(mc.cores=1)
  gramTokenizer <- function(x) NGramTokenizer(x,Weka_control(min=ngram,max=ngram,delimiters=' \r\n\t'))
  dtm <- DocumentTermMatrix(corpus, control = list(tokenize = gramTokenizer))
  dtm
}

tdmToFreq <- function(tdm) {
  # Takes tm TermDocumentMatrix and processes into frequency data.table
  freq <- sort(row_sums(tdm, na.rm=TRUE), decreasing=TRUE)
  word <- names(freq)
  data.table(word=word, freq=freq)
}

generateFrequencies <- function(dtm){
  freq.terms <- sort(col_sums(dtm, na.rm=T), decreasing = T)
  freq.terms.dt <- data.table(term=names(freq.terms), frequency=as.numeric(freq.terms))
  freq.terms.dt
}

extractHistory <- function(freq.dt){
  freq.dt[,c("history", "keyword"):=list(unlist(strsplit(term, "[ ]+?[a-z]+$")),
                                          unlist(strsplit(term, "^([a-z]+[ ])+"))[2]),
          by=term]
}


