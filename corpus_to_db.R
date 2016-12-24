source('load_data.R')
source('database_helper.R')

generateFreqDT <- function(corpus, ngram=2){
  clean.corpus <- cleanCorpus(corpus)
  if (ngram <= 0 | ngram > 6){
    return(NULL)
  }
  dtm <- generateNGram(clean.corpus, ngram)
  freq.dt <- generateFrequencies(dtm)
  freq.dt <- freq.dt[!term %like% replace.token]
  extractHistory(freq.dt)
  # freq.dt <- freq.dt[!keyword %in% stopwords()]
  
  if (ngram > 1){
  ## limit the number of each history you get
  freq.dt <- freq.dt[, head(.SD,5), by=history]
  }
  
  freq.dt[, "total":=list(sum(frequency)), by=history][, "prob":=list(frequency/total)]
  freq.dt[, n:=ngram]
  freq.dt[, term:=NULL]
  freq.dt
}

processToDB <- function(corpus, ngram=2){
  freq.dt <- generateFreqDT(corpus, ngram)
  writeFreqDT(freq.dt)
}



