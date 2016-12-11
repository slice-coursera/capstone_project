source('load_data.R')
source('database_helper.R')

processToDB <- function(corpus, ngram=2){
  dtm <- generateNGram(corpus, ngram)
  freq.dt <- generateFrequencies(dtm)
  freq.dt <- freq.dt[!term %like% replace.token]
  freq.dt <- freq.dt[frequency > 1]
  extractHistory(freq.dt)
  freq.dt <- freq.dt[, head(.SD,3), by=history]
  freq.dt[, n:=ngram]
  writeFreqDT(freq.dt)
}
