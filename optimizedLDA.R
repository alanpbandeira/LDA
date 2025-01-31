require(tidytext)
require(topicmodels)
require(dplyr)
require(tm)
require(GA)
library(XML)
library(jsonlite)
library(slam)
library(igraph)
library(stringr)
library(cluster)
library(snakecase)
library(stopwords)
library(NMOF)
library(xtable)
source("./fitness_function.R")

matModel <- readr::read_csv("./corpus/database.csv")
tdm <- tidytext::cast_dtm(matModel, document, word, number)
tdm2 <- weightSMART(tdm, "ntn")
tdm$v <- as.integer(round(tdm2$v))

pop_size = 10
n_iterations = 5
lower_bounds <- c(5, # n. topics
                  10, # n. iterations
                  0,  # alpha
                  0   # beta
)

# upper_bounds <- c(length(unique(matModel$document)), # n. topics
upper_bounds <- c(40,                        # n. topics
                  100,                       # n. iterations
                  1,                         # alpha
                  1                          # beta
)

GA <- function(){
res<-ga(type = "real-valued", fitness = fitness_LDA,
	lower=lower_bounds, upper=upper_bounds, pmutation = 1/4,
	maxiter=n_iterations, run=n_iterations, popSize=pop_size, mutation=gareal_raMutation,
	crossover = gareal_blxCrossover)

print('6')
best <- summary(res)
write.csv(best$solution, file = "./Results/OptimizedParameters.csv")
return(best$solution)
}

Optimize <- function (){
	x <- GA()
	LdaOptimized(x)
	print('7')
}


Optimize()
