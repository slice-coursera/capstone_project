# Predict, using N-Grams and Stupid Backoff
require(magrittr)
require(stringr)
require(tm)

source('database_helper.R')
source('load_data.R')

rawToClean <- function(raw){
  sentence <- VCorpus(VectorSource(raw))
  sentence <- cleanCorpus(sentence)
  sentence <- as.character(sentence[[1]])
  sentence <- str_trim(sentence, side="both")
  sentence <- unlist(strsplit(sentence, split = " "))
  sentence
}

ngram_backoff <- function(raw, max_ngram=3) {
  # From Brants et al 2007.
  # Find if n-gram has been seen, if not, multiply by alpha and back off
  # to lower gram model. Alpha unnecessary here, independent backoffs.
  sentence <- rawToClean(raw)
  for (i in min(length(sentence), max_ngram):1) {
    gram <- paste(tail(sentence, i), collapse=" ")
    print(gram)
    sql <- paste("SELECT keyword, prob FROM grams WHERE ", 
                 " history==\"", paste(gram), "\"",
                 " AND n==", i + 1, " LIMIT 3", sep="")
    print(sql)
    predicted <- sendQuery(sql)
    #predicted <- dbFetch(res, n=-1)
    names(predicted) <- c("prediction", "probability")
    if (nrow(predicted) > 0) return(predicted)
  }
  return("No prediction")
}