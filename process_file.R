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
  c('#\\S*', '@', '@\\S*', '\\S*[^ -~]\\S*', '/|@|\\|', '\\S*.com\\S*', '\\S\\.([A-z]\\.*)+', bad.words)
}

loadCorpus <- function(corpus.dir='./final/en_US/sample/'){
  txt.files <- paste(corpus.dir, '*.txt', sep = "")
  corpus <- corpus(textfile(txt.files, encoding='UTF-8'))
  corpus
}

getSentences <- function(corpus.doc){
  tokenize(corpus.doc, what='sentence', simplify=T)
}

getNGram <- function(corpus.doc, ngrams=1){
  dfm(corpus.doc, verbose=F, 
      removeNumbers = T, 
      removePunct = T, 
      removeHyphens=T, 
      ignoredFeatures = getFeaturesToIgnore(), 
      removeSeparators = T, 
      valuetype = 'regex', ngrams=ngrams)
}
## ngram=1
#with verbose per sentence
#user  system elapsed 
#178.19    2.55  185.10

# no verbose
#user  system elapsed 
#115.05    1.39  119.22 

#removing and ignoring
#user  system elapsed 
#213.89    7.36  226.86 



#ngram=2

