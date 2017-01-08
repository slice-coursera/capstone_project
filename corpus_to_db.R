source('database_helper.R')
require(RWeka)
require(stringi)
require(data.table)
require(slam)
require(LaF)


replace.token='removeemee'
cleanCorpus <- function(corpus){
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
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\b*(rt)", replacement=replace.token)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="[^[:alnum:][:space:]']", replacement=" ")
  corpus <- tm_map(corpus, stripWhitespace)
  corpus
}

generateFrequencies <- function(dtm){
  freq.terms <- sort(col_sums(dtm, na.rm=T), decreasing = T)
  freq.terms.dt <- data.table(term=names(freq.terms), frequency=as.numeric(freq.terms))
  freq.terms.dt
}

extractHistory <- function(freq.dt){
  freq.dt[,c("history", "keyword"):=list(unlist(strsplit(term, "[ ]+?[[:alnum:]]+$")),
                                         unlist(strsplit(term, "^([[:alnum:]']+[ ])+"))[2]), by=term]
}

generateNGram <- function(corpus, ngram=2){
  # Create Term Document Matrix with tokenization
  #options(mc.cores=1)
  if(ngram == 1){
    dtm <- DocumentTermMatrix(corpus, control = list(stopwords=FALSE, removePunctuation=TRUE))
    return(dtm)
  }
  gramTokenizer <- function(x) NGramTokenizer(x,Weka_control(min=ngram,max=ngram,delimiters=' \r\n\t'))
  dtm <- DocumentTermMatrix(corpus, control = list(tokenize = gramTokenizer))
  return(dtm)
}

removeBadWordsFromFreqDT <- function(freq.dt){
  if (!file.exists("bad_words.csv")) {
    download.file("http://www.bannedwordlist.com/lists/swearWords.csv", "bad_words.csv", "auto")
  }
  
  bad.words <- readLines('bad_words.csv')
  bad.words <- as.character(unlist(strsplit(bad.words, ',')))
  freq.dt <- freq.dt[!keyword %in% bad.words]
  freq.dt
}

generateFreqDT <- function(corpus, ngram=2, onlyKeepTop=TRUE){
  clean.corpus <- cleanCorpus(corpus)
  print("corpus clean...")
  if (ngram <= 0 | ngram > 6){
    return(NULL)
  }
  dtm <- generateNGram(clean.corpus, ngram)
  print("dtm created...")
  freq.dt <- generateFrequencies(dtm)
  freq.dt <- freq.dt[!term %like% replace.token]
  print("freq.dt created...")
  extractHistory(freq.dt)
  print("history extracted...")
  # freq.dt <- freq.dt[!keyword %in% stopwords()]
  freq.dt <- removeBadWordsFromFreqDT(freq.dt)
  print("bad words removed...")
  if (ngram > 1){
    ## limit the number of each history you get
    if (onlyKeepTop) {
      freq.dt <- freq.dt[, head(.SD,5), by=history]  
    }
    freq.dt[, "total":=list(sum(frequency)), by=history][, "probability":=list(frequency/total)]
  } else {
    freq.dt[, "total":=list(sum(frequency))][, "probability":=list(frequency/total)][, keyword:=history][, history:="<NA>"]
  }
  
  freq.dt[, n:=ngram]
  freq.dt[, term:=NULL]
  freq.dt[, total:=NULL]
  setcolorder(freq.dt, c("history", "keyword", "frequency", "probability", "n"))
  freq.dt
}

processToDB <- function(corpus, ngram=2){
  freq.dt <- generateFreqDT(corpus, ngram)
  writeFreqDT(freq.dt)
}



