# Predict, using N-Grams and Stupid Backoff
require(magrittr)
require(stringr)
require(tm)

source('database_helper.R')


ngram_backoff <- function(raw) {
  # From Brants et al 2007.
  # Find if n-gram has been seen, if not, multiply by alpha and back off
  # to lower gram model. Alpha unnecessary here, independent backoffs.
  
  max = 3  # max n-gram - 1
  
  # process sentence, don't remove stopwords
  sentence <- tolower(raw) %>%
    removePunctuation %>%
    removeNumbers %>%
    stripWhitespace %>%
    str_trim %>%
    strsplit(split=" ") %>%
    unlist
  
  for (i in min(length(sentence), max):1) {
    gram <- paste(tail(sentence, i), collapse=" ")
    sql <- paste("SELECT keyword, frequency FROM grams WHERE ", 
                 " history=='", paste(gram), "'",
                 " AND n==", i + 1, " LIMIT 3", sep="")
    predicted <- sendQuery(sql)
    #predicted <- dbFetch(res, n=-1)
    names(predicted) <- c("Next Possible Word", "Score (Adjusted Freq)")
    print(predicted)
    
    if (nrow(predicted) > 0) return(predicted)
  }
  
  return("Sorry! You've stumped me, I don't know what would come next.")
}