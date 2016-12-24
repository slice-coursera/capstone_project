source('load_data.R')
source('database_helper.R')

addGoodTuringDiscount <- function(freq.dt, k=5){
  freq.dt$discount <- rep(1, nrow(freq.dt))
  for(i in k:1){
    currFreq = i
    nextFreq = currFreq + 1
    currFreqN = nrow(freq.dt[frequency == currFreq])
    nextFreqN = nrow(freq.dt[frequency == nextFreq])
    currDiscount = nextFreq/currFreq * nextFreqN/currFreqN # assumption 0 < d < 1
    freq.dt[frequency == currFreq, discount := currDiscount]
  }
  freq.dt[, "leftover":=list(calcLeftOverProb(keyword, frequency, discount)), by=history]
  freq.dt
}


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
  ## limit the number of each history you get
  # freq.dt <- freq.dt[, head(.SD,3), by=history]
  #freq.dt[, "total":=list(sum(frequency)), by=history][, "prob":=list(frequency/total)]
  freq.dt[, n:=ngram]
  freq.dt <- addGoodTuringDiscount(freq.dt)
  freq.dt[, term:=NULL]
  freq.dt
}

calcLeftOverProb <- function(lastTerm, frequency, discount){
  all_freq <- sum(frequency)
  return(1-sum((discount*frequency)/all_freq))
}

processToDB <- function(corpus, ngram=2){
  freq.dt <- generateFreqDT(corpus, ngram)
  writeFreqDT(freq.dt)
}



