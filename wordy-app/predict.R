# Predict, using N-Grams and Stupid Backoff
require(magrittr)
require(stringr)
require(tm)
require(RSQLite)
require(data.table)

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
  as.data.table(result)
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
  predicted <- data.table(history=character(), keyword=character(), frequency=integer(), probability=numeric(), n=integer())
  alpha <- 1.0
  for (i in min(length(sentence), max_ngram):0) {
    if (i < max_ngram & i > 0){
      alpha <- 0.4 ^ (max_ngram - i)
    }
    gram <- paste(tail(sentence, i), collapse=" ")
    if (i == 0){
      gram = "<NA>"
    }
    #print(gram)
    sql <- paste("SELECT * FROM grams WHERE ", 
                 " history==\"", paste(gram), "\"",
                 " AND n==", i + 1, " LIMIT 5", sep="")
    # print(sql)
    predictedN <- sendQuery(sql)
    predictedN[,probability:=probability*alpha]
    if (nrow(predictedN) > 0){
      predicted <- rbind(predicted, predictedN)
      
    }
    if (nrow(predicted) >= 5){
      return(predicted[,.(score=max(probability)), by=keyword])
    }
  }
  return(predicted[,.(score=max(probability)), by=keyword])
}

