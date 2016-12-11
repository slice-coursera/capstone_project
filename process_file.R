require(quanteda)
require(stringi)
require(dplyr)


getFeaturesToIgnore <- function(){
  bad.words <- getBadWords()
  c('#\\S*', '@', '@\\S*', '\\S*[^ -~]\\S*', '/|@|\\|', '\\S*.com\\S*', '\\S\\.([A-z]\\.*)+', bad.words)
}

loadCorpusQ <- function(corpus.dir='./final/en_US/sample/'){
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

getNGramObservations <-function(corpus.doc, ngrams=2){
  tokens <- tokenize(toLower(corpus.doc), what='fasterword',
                     removePunct=T,
                     removeNumbers=T,
                     removeHyphens=T,
                     removeURL=T, concatenator=" ", ngrams=ngrams)
  if(!is.null(tokens[[1]])){
    tokens <- removeFeatures(tokens, getFeaturesToIgnore(), valuetype='regex', simplify=T)
    ldply(lapply(unlist(tokens), observationExtract))
  }
}

observationExtract <- function(x){ 
  kw <- kwic(x, keywords=stri_extract_last_words(x))
  data.frame(history=kw$contextPre, term=kw$keyword)
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

