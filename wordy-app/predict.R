# Predict, using N-Grams and Stupid Backoff
require(magrittr)
require(stringr)
require(tm)
require(RSQLite)

cleanCorpus <- function(corpus){
  #Remove any tokens containing a non-english symbol
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="\\S*[^ -~]\\S*", replacement=" ")
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeNumbers)
  # remove punctuation
  corpus <- tm_map(corpus, content_transformer(gsub), pattern="[^[:alnum:][:space:]']", replacement=" ")
  corpus <- tm_map(corpus, stripWhitespace)
  corpus
}

sendQuery <- function(query){
  db <- dbConnect(SQLite(), dbname="ngram.db")
  result <- dbGetQuery(db, query)
  dbDisconnect(db)
  result
}

rawToClean <- function(raw){
  sentence <- VCorpus(VectorSource(raw))
  sentence <- cleanCorpus(sentence)
  sentence <- as.character(sentence[[1]])
  sentence <- str_trim(sentence, side="both")
  sentence <- unlist(strsplit(sentence, split = " "))
  sentence
}

predictNext <- function(raw, max_ngram=4) {
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

