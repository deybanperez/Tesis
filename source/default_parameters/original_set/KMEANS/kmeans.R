#Setting work directory
rm(list = ls())

#Loading functions
source("source/functions/functions.R")

#Loading dataset
dataset = read.csv("dataset/NSLKDD_Training_New.csv",
                            sep = ",", header = TRUE)

#Removing unnecesary labels
dataset$Label_Normal_TypeAttack = NULL
dataset$Label_Num_Classifiers = NULL

#Extracting inforomation
Labels = dataset[, (ncol(dataset)-1):ncol(dataset)]

#Transforming predictors into numeric
dataset = as.data.frame(apply(dataset[, c(-41, -42)], 2, as.numeric))
dataset = cbind(dataset, Label = Labels[,1])

#Scaling set
dataset = ScaleSet(dataset)

dataset.five = cbind(dataset[, -ncol(dataset)], Label = Labels[,1])
dataset.two = cbind(dataset[, -ncol(dataset)], Label = Labels[,2])

#removing parcial variables
remove(list = c("Labels"))

#Analyzing Jambu's elbow results
jambu.results = readRDS("source/default_parameters/original_set/KMEANS/jambu_results.rds")
plot(jambu.results$IIC.Hartigan, col = "blue", type = "b", pch = 19,
     xlab = "Número de Grupos", ylab = "Inercia Intra-Grupos")
points(jambu.results$IIC.Lloyd, col = "red", type = "b", pch = 19)
points(jambu.results$IIC.Forgy, col = "green", type = "b", pch = 19)
points(jambu.results$IIC.MacQueen, col = "magenta", type = "b", pch= 19)
legend("topright", legend = c("Hartigan", "Lloyd", "Forgy", "MacQueen"),
       col = c("blue","red", "green", "magenta"), pch = 19)

#Selecting the best distance's algorithm
measures.results = readRDS("source/default_parameters/original_set/KMEANS/measures_results.rds")
measures.results$measure.two
measures.results$measure.two[1]
measures.results$measure.five
measures.results$measure.five[1]

#Testing the models
#Five class model
results.five = vector(mode = "numeric", length = 10)
best.accuracy.five = 0
for (i in 1:length(results.five))
{
  set.seed(i)
  model.kmeans.five = kmeans(dataset.five[,-ncol(dataset.five)],
                             5, iter.max = 100)
  
  prediction.five = OrderKmeans(model.kmeans.five)
  accuracy.five = mean(prediction.five == dataset.five$Label)
  
  results.five[i] = accuracy.five
  
  if(best.accuracy.five < accuracy.five)
  {
    best.prediction.five = prediction.five
    best.accuracy.five = accuracy.five
  }
}
#Printing results
results.five
#Calculating mean of results
mean(results.five) * 100
#Creating confusion matrix
confusion.matrix.five = table(Real = dataset.five$Label,
                              Prediction = best.prediction.five)
#Printing confusion matrix
confusion.matrix.five
#Printig accuracy rate and error rate
best.accuracy.five*100
ErrorRate(best.accuracy.five)*100
#Showing accuracy per label
AccuracyPerLabel(confusion.matrix.five, dataset.five)
#Confusion matrix Attack vs Normal
attack.normal.confusion.matrix.five = AttackNormalConfusionMatrix(dataset.five,
                                                                  best.prediction.five)
attack.normal.confusion.matrix.five
#printing accuracy per label
AccuracyPerLabel(attack.normal.confusion.matrix.five, dataset.two)

#Binary measures
Sensitivity(attack.normal.confusion.matrix.five) * 100
Especificity(attack.normal.confusion.matrix.five) * 100
Precision(attack.normal.confusion.matrix.five) * 100
#################################################################################
#Two class model
results.two = vector(mode = "numeric", length = 10)
best.accuracy.two = 0

for (i in 1:length(results.two))
{
  set.seed(i)
  model.kmeans.two = kmeans(dataset.two[,-ncol(dataset.two)],
                            2, iter.max = 100)
  
  prediction.two = OrderKmeans(model.kmeans.two)
  accuracy.two = mean(prediction.two == dataset.two$Label)
  
  results.two[i] = accuracy.two
  
  if(best.accuracy.two < accuracy.two)
  {
    best.prediction.two = prediction.two
    best.accuracy.two = accuracy.two
  }
}
#Printing results
results.two
#Calculating mean of results
mean(results.two) * 100
#Creating confusion matrix
confusion.matrix.two = table(Real = dataset.two$Label,
                             Prediction = best.prediction.two)
#Printing confusion matrix
confusion.matrix.two
#Printig accuracy rate and error rate
best.accuracy.two*100
ErrorRate(best.accuracy.two)*100
#Showing accuracy per label
AccuracyPerLabel(confusion.matrix.two, dataset.two)
#Binary measures
Sensitivity(confusion.matrix.two) * 100
Especificity(confusion.matrix.two) * 100
Precision(confusion.matrix.two) * 100