require(RSQLite)

writeFreqDT <- function(freq.dt){
  db <- dbConnect(SQLite(), dbname="ngram.db")
  dbWriteTable(conn = db, 'grams', freq.dt, append=T)
  dbDisconnect(db)
}

sendQuery <- function(query){
  db <- dbConnect(SQLite(), dbname="ngram.db")
  result <- dbGetQuery(db, query)
  dbDisconnect(db)
  result
}

readGrams <- function(){
  db <- dbConnect(SQLite(), dbname="ngram.db")
  freq.dt <- data.table(dbReadTable(conn = db, 'grams', freq.dt, append=T))
  dbDisconnect(db)
  freq.dt
}