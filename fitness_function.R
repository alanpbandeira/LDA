# This function implements the Silhouette Coefficient (fitness function to maximize).  
# The Silhouette coefficient takes values in [-1; 1]. Higher Silhouette Coefficient  
# denotes better clustering quality
fitness_LDA<-function(x=c()){
  numero_topic<-round(x[1]) #x[1] = number of topics k
  iteration<-round(x[2])    #x[2] = number of gibbs iteration
  pAlpha<-x[3]              #x[3] = Alpha
  pDelta<-x[4]              #x[4] = Beta
  
  print('1')
  
  # apply LDA to the term-by-document matrix
  ldm <- LDA(tdm, method="Gibbs", control = list(
    alpha=pAlpha,
    delta=pDelta,
    iter=iteration,
    seed=5,
    verbose=1,
    nstart=1), k = numero_topic)  # k = num of topics

  print('2')
  
  pldm <- posterior(ldm)
  names(pldm)

  # compute the topic-by-term matrix    
  names(tdm$dimnames)
  docs <- tdm$dimnames$Docs
  topics<-names(terms(ldm))
  matrix<-pldm$topics
  dimnames(matrix)<-list(docs,topics)

  print('3')

  # compute the distance between documents in the topics space
  distances <- as.matrix(dist(matrix, method = "euclidean", diag = T, upper = T))

  # computing number of clusters
  clustering<-matrix("",length(rownames(matrix)),1)
   

  for (i in 1:length(rownames(matrix))) {
    flag<-(matrix[i,]==max(matrix[i,]))# each documents belongs to the cluster with the higher probability
    flag<-which(flag==TRUE)
    topics <- sort(flag)
    clustering[i,1]<-paste(topics, collapse = '_')
  }

  rownames(clustering)<-rownames(matrix)

  print('4')

  # assign the clusters
  clusters<-unique(clustering)
  count <- 1
  for (clust in clusters){
    clustering[clustering[,1] == clust,1] <- count
    count <- count+1
  }
   cluster_objects<-list(); 
   cluster_objects$clustering <- as.numeric(clustering)
  
  # compute the cohesion for each documents
  cohesion <- matrix(nrow = length(rownames(distances)), ncol = 1)
  for (i in 1:length(rownames(distances))){
    cohesion[i,1] <- max(distances[clustering[,1] == clustering[i,1],i])
  }
  
  # compute the separation from other clusters 
  separation <- matrix(nrow = length(rownames(distances)), ncol = 1)
  for (i in 1:length(rownames(distances))){
    separation[i,1] <- min(distances[clustering[,1] != clustering[i,1],i])
  }
  print('5')
  # compute the silhouette coefficient
  sil <- matrix(nrow = length(rownames(distances)), ncol = 1)
  for (i in 1:length(rownames(distances))){
    if (sum(clustering[i,1] == clustering)>1)
      sil[i,1] <- (separation[i,1] - cohesion[i,1]) / max(separation[i,1], cohesion[i,1])
    else
      sil[i,1] <- 0 # if the cluster contanis only one document, the Silohuette Coeff. is zero
  }
  return(mean(sil))
}

LdaOptimized <- function(x){
  numero_topic<-round(x[1]) #x[1] = number of topics k
  iteration<-round(x[2])    #x[2] =  number of gibbs iteration
  pAlpha<-x[3]              #x[3] = Alpha
  pDelta<-x[4]              #x[4] = Beta
  
  ldm <- LDA(tdm, method="Gibbs", control = list(alpha=pAlpha, delta=pDelta, iter=iteration, seed=5, nstart=1), k = numero_topic)  # k = num of topics
  ap_topics1 <- tidy(ldm, matrix = "gamma")
  ap_topics2 <- tidy(ldm, matrix = "beta")

  write.csv(ap_topics1, file = "./Results/OptimizedLDAGamma.csv")
  write.csv(ap_topics2, file = "./Results/OptimizedLDABeta.csv")

  # pldm <- posterior(ldm)
  # document2topic <- pldm$topics

}
