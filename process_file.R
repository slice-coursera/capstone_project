require(quanteda)

getBadWords <- function(){
  if (!file.exists("bad_words.csv")){
    download.file("http://www.bannedwordlist.com/lists/swearWords.csv", "bad_words.csv", "auto")
  }
  bad.words <- read.csv("bad_words.csv", colClasses = c("character"), header = F)
  as.character(bad.words[1,])
}

getFeaturesToIgnore <- function(){
  bad.words <- getBadWords()
  c('#\\S*', '@', '@\\S*', '\\S*[^ -~]\\S*', '[A-z]?', bad.words)
}

loadCorpus <- function(corpus.dir='./final/en_US/sample/'){
  txt.files <- paste(corpus.dir, '*.txt', sep = "")
  corpus <- corpus(textfile(txt.files, encoding='UTF-8'))
  corpus
}

getSentences <- function(corpus.doc){
  tokenize(corpus.doc, what='sentence', simplify=T)
  #lapply(X = b.sent, FUN=tokenize, what='word', removePunct=T, removeNumbers=T, removeHyphens=T, removeSymbols=T, removeURL=T)
}

getNGram <- function(corpus.doc, ngrams=1){
  dfm(corpus.doc, verbose=F, removeNumbers=TRUE, removePunct=T, ngrams=ngrams)
}

#with verbose per sentence
#user  system elapsed 
#178.19    2.55  185.10

#no verbose
#user  system elapsed 
#115.05    1.39  119.22 