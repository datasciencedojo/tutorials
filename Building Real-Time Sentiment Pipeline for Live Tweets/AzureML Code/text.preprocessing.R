# Copyright © Microsoft.  All rights reserved.
# Licensed for use under the agreement under which you purchased Azure services.

###########################################################################
# preprocessText
###########################################################################
preprocessText <- function(textVector, 
                         replaceSpecialChars,
                         removeDuplicateChars,
                         replaceNumbers,
                         convertToLowerCase,
                         removeDefaultStopWords,
                         removeGivenStopWords,
                         stemWords,
                         stopword_list = NULL)
{
  library("tm")
  if(replaceSpecialChars == TRUE) {
    print("replace special characters with space ....")
    textVector <- gsub("[^0-9a-z]", " ", textVector, ignore.case = TRUE)
  } 
  if(removeDuplicateChars == TRUE) {
    print("remove duplicate characters ....")
    textVector <- gsub('([[:alpha:]])\\1+', '\\1\\1', textVector)
  }
  if(replaceNumbers == TRUE) {
    print("replace numbers with space ....")
    textVector <- gsub("[^a-z]", " ", textVector, ignore.case = TRUE)
  }
  textVector <- gsub("\\s+", " ", textVector)
  textVector <- gsub("^\\s", "", textVector)
  textVector <- gsub("\\s$", "", textVector)
  
  print("create corpus ....")
  theCorpus <- Corpus(VectorSource(textVector))
  
  if(convertToLowerCase == TRUE) {
    print("convert to lower case ....")
    theCorpus <- tm_map(theCorpus, content_transformer(tolower))  
  }
  if(removeDefaultStopWords == TRUE){
    print("remove default stopwords ....")
    theCorpus <- tm_map(theCorpus, removeWords, stopwords("english"))
  }
  if(removeGivenStopWords == TRUE & !missing(stopword_list) & !is.null(stopword_list)) {
    print("remove given stopwords ....")
    theCorpus <- tm_map(theCorpus, removeWords, stopword_list)  
  }  
  if(stemWords == TRUE) {
    print("word stemming ....")
    theCorpus <- tm_map(theCorpus, stemDocument, "english")
  }
  print("stripWhitespace") 
  #multiple whitespace characters collapsed to a single blank
  theCorpus <- tm_map(theCorpus, stripWhitespace)
      
  textVector  <- unlist(lapply(theCorpus, 
                                function(x) return(x[1]$content)))
  
  textVector <- gsub("\\s+", " ", textVector)
  textVector <- gsub("^\\s", "", textVector)
  textVector <- gsub("\\s$", "", textVector)
  
  return(textVector)    
}

###########################################################################
# drawWordCloud
###########################################################################
drawWordCloud <- function(textVector, labelVector, maxWords=50) 
{
  library("wordcloud")
  library("tm")
  theCorpus <- Corpus(VectorSource(textVector))
  
  label.set <- unique(labelVector)
  for(i in 1:length(label.set)){
    idx <- which(labelVector == label.set[i])  
    wordcloud(theCorpus[idx], max.words=maxWords)
  }
}
###########################################################################
# create.vocabulary 
# background corpus is not necessary to be labeled, it is different from the
# labeled dat used to train the text classifier
# vocabulary creation is unsupervised task
###########################################################################
create.vocabulary <- function(text.column, minWordLen, maxWordLen, minDF, maxDF)
{  
  if(length(text.column) ==0){
    output.voc <- data.frame(row.names = c("df", "idf"))
    return(output.voc)
  }
  #check input parameters 
  if(minWordLen < 1) {
    stop("create.vocabulary error: minWordLen can't be less than < 1")  
  }
  if(maxWordLen < 1 ) {
    stop("create.vocabulary error: maxWordLen can't be less than < 1")  
  }
  if(maxWordLen < minWordLen) {
    stop("create.vocabulary error: maxWordLen can't be less than minWordLen")  
  }
  if(minDF < 1) {
    stop("create.vocabulary error: minDF can't be less than < 1")  
  }
  if(maxDF < 1) {
    stop("create.vocabulary error: maxDF can't be less than < 1")  
  }
  if(maxDF < minDF) {
    stop("create.vocabulary error: maxDF can't be less than minDF")  
  }
  
  library("tm")
  theCorpus <- Corpus(VectorSource(text.column))
  DTM <- DocumentTermMatrix(theCorpus, 
                            control = list(dictionary = NULL,                                                 
                                           weighting = weightBin,
                                           bounds = list(global = c(minDF, maxDF)),
                                           WordLengths = c(minWordLen, maxWordLen))) 
  #nDocs(DTM) 
  #nTerms(DTM)
  terms  <- Terms(DTM)
  ## S3 method for class 'TermDocumentMatrix'
  df <-  tm_term_score(DTM, terms, FUN = slam::col_sums)
  idf <- log(nDocs(DTM)/df)
  
  output.voc <- data.frame(row.names = c("df", "idf"))
  output.voc <- rbind(output.voc, df)
  output.voc <- rbind(output.voc, idf)
  names(output.voc) <- terms
  
  output.voc <- cbind(data.frame(total.docs=length(text.column)), output.voc)
    
  return(output.voc)
}
###########################################################################
# merge.vocabulary
###########################################################################
merge.vocabulary <- function(input1.voc, input2.voc)
{  
  #check input parameters 
  if(!is.data.frame(input1.voc)){
    stop("merge.vocabulary error: input1.voc must be a data frame")  
  }
  if(!is.data.frame(input2.voc)){
    stop("merge.vocabulary error: input2.voc must be a data frame")  
  }
  
  if(nrow(input1.voc) ==0){
    if(nrow(input2.voc) ==0){
      output <- data.frame()
      return(output)
    }else{
      return(nput2.voc)
    }
  }else{
    if(nrow(input2.voc) ==0){
      return(nput1.voc)
    }
  }
  
  library("tm")  
  total.docs <- input1.voc[1,"total.docs"] + input2.voc[1,"total.docs"]
  input1.voc <- subset( input1.voc, select = -c(total.docs) )
  input2.voc <- subset( input2.voc, select = -c(total.docs) )
      
  input1.dictionary <- names(input1.voc)
  input2.dictionary <- names(input2.voc)
  
  output <- NULL
  common.dictionary <- intersect(input1.dictionary, input2.dictionary)
  if(length(common.dictionary) > 0) 
  {  
    df1 <-  data.frame(input1.voc[1, common.dictionary])
    names(df1) <- common.dictionary
    
    df2 <-  data.frame(input2.voc[1, common.dictionary])
    names(df2) <- common.dictionary
    
    output <- rbind(df1, df2)
    m <- as.matrix(output)
    
    add.dfs <- m[1,] + m[2,]
    add.dfs <- t(add.dfs )
    output <- data.frame(add.dfs) 
    names(output) <- common.dictionary
  }
  
  left.extra.dictionary <- setdiff(input1.dictionary, input2.dictionary)
  if(length(left.extra.dictionary) > 0) 
  {  
    df3 <- data.frame(input1.voc[1, left.extra.dictionary])
    names(df3) <- left.extra.dictionary
    
    if(!is.null(output)){ 
      output <- cbind(output, df3)
    } else{
      output <- df3
    }      
  }
  
  right.extra.dictionary <- setdiff(input2.dictionary, input1.dictionary)
  if(length(right.extra.dictionary) > 0)
  { 
    df4 <- data.frame(input2.voc[1, right.extra.dictionary])
    names(df4) <- right.extra.dictionary
    
    if(!is.null(output)){
      output <- cbind(output, df4)
    } else{
      output <- df4
    }
  }
  output.dictionary <- sort(union(input1.dictionary, input2.dictionary))
  output <- output [, output.dictionary]
  
  output <- cbind(data.frame(total.docs=total.docs), output)
  
  return(output)
}
###########################################################################
# calculate.IDF
###########################################################################
calculate.IDF <- function(input.voc, minDF, maxDF)
{  
  #check input parameters 
  if(!is.data.frame(input.voc)){
    stop("calculate.IDF error: input.voc must be a data frame")  
  }
  if(nrow(input.voc) ==0){
    stop("calculate.IDF error: input.voc can not be empty")  
  }
  total.docs <- input.voc[1,"total.docs"] 
  
  input.voc <- subset( input.voc, select = -c(total.docs) )
  terms <- names(input.voc) 
  dfs <- as.matrix(input.voc [1,])
  kept_ids <- which(dfs >= minDF & dfs <= maxDF)
  kept_dfs <- dfs[kept_ids] 

  idfs <- log(total.docs/kept_dfs)
  
  output.voc <- data.frame(word=terms[kept_ids], df=kept_dfs, idf=idfs)
  
  return(output.voc)
}
###########################################################################
# calculate.TFIDF
###########################################################################
calculate.TFIDF <- function(text.column, input.voc, minWordLen, maxWordLen)
{
  #check input parameters 
  if(minWordLen < 1) {
    stop("calculate.TFIDF error: minWordLen can't be less than < 1")  
  }
  if(maxWordLen < 1 ) {
    stop("calculate.TFIDF error: maxWordLen can't be less than < 1")  
  }
  if(maxWordLen < minWordLen) {
    stop("calculate.TFIDF error: maxWordLen can't be less than minWordLen")  
  }
  if(!is.data.frame(input.voc)){
    stop("calculate.TFIDF error: input.voc must be a data frame")  
  }
  library("tm")  
  if(nrow(input.voc) ==0){
    stop("calculate.TFIDF error: input.voc can not be empty")  
  }
  input.dictionary <- as.vector(input.voc$word)
  
  theCorpus <- Corpus(VectorSource(text.column))
  DTM <- DocumentTermMatrix(theCorpus, 
                            control = list(dictionary = NULL,
                                           weighting = weightTf,                                                 
                                           WordLengths = c(minWordLen, maxWordLen)))  
  
  current.dictionary  <- Terms(DTM)
  common.dictionary <- intersect(input.dictionary, current.dictionary)
  DTM <- DTM[, common.dictionary]
  
  #nDocs(DTM)   
  #nTerms(DTM)
  #convert/coarse DTM into data frame
  document.term.matrix <- data.frame(doc.id = DTM$i, term.id = DTM$j, 
                                     word = common.dictionary[DTM$j], tf = DTM$v)
  
  extra.dictionary <- setdiff(input.dictionary, current.dictionary)
  
  output <- merge(x =  document.term.matrix, y = input.voc, by = "word")
  output <- output[sort.int(output$doc.id, index.return = TRUE)$ix, ]
  output <- cbind(output, tf.idf =output$tf * output$idf)
  row.names(output) <- NULL
  
  #replace TF with TF-IDF  
  DTM$v <- output$tf.idf  
  
  #convert "sparse" DocumentTermMatrix into "dense" Matrix
  denseMatrix <- as.matrix(DTM)
  
  zeroMatrix <- matrix(data =  rep(0,nrow(DTM)*length(extra.dictionary)), 
                       nrow = nrow(DTM), 
                       ncol = length(extra.dictionary), byrow = FALSE,
                       dimnames = list(Docs(DTM),
                                       extra.dictionary))
  
  denseMatrix <- cbind(denseMatrix, zeroMatrix)
  #re-order the columns in the matrix
  denseMatrix <- subset(denseMatrix, ,input.dictionary)
  
  #convert Matrix into data frame (dataset)
  df <- as.data.frame(denseMatrix)    
  
  return(df)
}

###########################################################################
# extract.TF.UsingVocabulary
###########################################################################
extract.TF.UsingVocabulary <- function(text, vocab){  
  library("tm")
  theCorpus <- Corpus(VectorSource(text))
  
  sparseDTM <- DocumentTermMatrix(theCorpus, 
                                   control = list(dictionary = vocab,
                                                  weighting = weightTf
                                                  #weighting = weightTfIdf 
                                                  #weighting = weightBin
                                   ))  
  #return(sparseDTM)
  #convert "sparse" DocumentTermMatrix into "dense" Matrix
  denseDTM <- as.matrix(sparseDTM)
  
  #convert Matrix into data frame
  df <- as.data.frame(denseDTM)  
  
  return(df)
}