source('load_data.R')
source('database_helper.R')

generateFreqDT <- function(corpus, ngram=2){
  dtm <- generateNGram(corpus, ngram)
  freq.dt <- generateFrequencies(dtm)
  freq.dt <- freq.dt[!term %like% replace.token]
  extractHistory(freq.dt)
  freq.dt[!keyword %in% stopwords()]
  freq.dt <- freq.dt[, head(.SD,3), by=history]
  freq.dt[, "total":=list(total=sum(frequency)), by=history][, "prob":=list(frequency/total)]
  freq.dt[, n:=ngram]
}

processToDB <- function(corpus, ngram=2){
  freq.dt <- generateFreqDT(corpus, ngram)
  writeFreqDT(freq.dt)
}
