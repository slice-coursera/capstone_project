require(tm)
require(quanteda)

createNGrams <- function(dir.source='./final/en_US/sample'){
  corpus <- corpus(VCorpus(DirSource(dir.source, encoding = "UTF-8"), readerControl = list(reader=readPlain, language="en_US")))
  
}