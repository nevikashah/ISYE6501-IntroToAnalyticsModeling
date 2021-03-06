# QUESTION 2.1

# During the Covid-19 global pandemic, the growing population of people contracting
# the virus in addition to the everyday patient population negative for the virus results in a shortage in
# necessary ventilators. Thus we can create a classification model to understand which patients will and will not
# get ventilators given that there is a shortage  
# Some of the predictors are:
# 1. Sequential Organ Failure Assessment (SOFA) Score: predicts ICU mortality based on lab results and clinical data. (e.g. patients with SOFA score greater than 3 will not get ventilator)
# 2. Comorbidity Score: Score (1-4) given to severity of medical comorbidity (e.g. diabetes = 1, lung cancer = 4). (e.g. patients with scores greater than 2 will not receive ventilators) 
# 3. Age: younger patients take priority over older patients (e.g. older patients are less likely to get a ventilator vs. younger patients)






#install and import kernlab/kknn packages
install.packages("kernlab")
install.packages("kknn")
library (kernlab)
library (kknn)

#set working directory
setwd("/Users/nevi.r.shah@ey.com/documents/Homework_ISYE")

#read in cc data with headers
cc_data <- read.table("credit_card_data_2.txt", header=TRUE, stringsAsFactors=FALSE)





#QUESTION 2.2

#view data to make sure everything looks ok
head(cc_data)

#create ksvm model using the vanilladot kernel. I tried C =.00001, 100 and 100000000. 
#I found that C=100 gave the best prediction 
model <- ksvm(as.matrix(cc_data[,1:10]), as.factor(cc_data[,11]), C=100, scaled=TRUE, kernel="vanilladot", type="C-svc")

#view model 
model

#calculate a1...am
a <- colSums(model@xmatrix[[1]] * model@coef[[1]] )

#view coeficients
a

#coefficients a1...am are as followed:
  # -0.0010065348
  # -0.0011729048
  # -0.0016261967
  # 0.0030064203
  # 1.0049405641
  # -0.0028259432
  # 0.0002600295
  # -0.0005349551
  # -0.0012283758
  # 0.1063633995

#calculate a0
a0 <- -model@b

#view value
a0
#a0 value is 0.08158492

#thus equation is 
#0.08158492+-0.0010065348x1+-0.0011729048x2+-0.0016261967x3+0.0030064203x4+1.0049405641x5+-0.0028259432x6+0.0002600295x7+-0.0005349551x8+-0.0012283758x9+0.1063633995x10

#checking accuracy
#model prediction 
pred <- predict(model,cc_data[,1:10])

#view matrix
pred

#percentage of accuracy on model prediction is 86.39% (.8639144)
sum(pred == cc_data[,11]) / nrow(cc_data)







#QUESTION 2.3

#set seed for reprodicible results 
set.seed(1)

#finding k value for kknn
kfunction = function(neigbhborNum) {
  
  #initialize vector
  pred <- rep(0,(nrow(cc_data)))
  
  #for loop to iterate through cc_data and predict response from other rows
  for (index in 1:nrow(cc_data)){
    
    #scaled data: using -index so it does not use itself (the current iteration in the loop)
    model=kknn(R1~.,cc_data[-index,],cc_data[index,],k=neighborNum, scale = TRUE) 
    
    #if prediction is greater than or equal to .5 round to 1 otherwise round to 0 
    pred[index] <- as.integer(fitted(model)+0.5) 
  }
  
  #find average of correct predictions of all predictions 
  overallAccuracy = sum(pred == cc_data[,11]) / nrow(cc_data)
  
  #return accuracy as a decimal 
  return(overallAccuracy)
}

#try values of K from 1-50
#create empty vector
accvec=rep(0,50) 

#for loop to iterate through k number of neighbors from 1-50
for (neighborNum in 1:50) {
  
  #test k nearest neighbor with each value of k (number of neighbors)
  accvec[neighborNum] = kfunction(neighborNum)
}

#get highest accuracy value 
max(accvec)
#.85321

#get k value for that highest accuracy value 
which.max(accvec)
#k=12
#thus 12 is the number of neighbors we must look at to determine our prediction of a datapoint 








#QUESTION 3.1a

#setting seed value in order to produce same results if code is script is again
set.seed(1)

#separate data set into training and testing. 80% will be train and 20% will be test
sampledatasplit <- sample(1:nrow(cc_data),as.integer(0.8*nrow(cc_data)))

#set train data set
trainy = cc_data[sampledatasplit,]

#set test data set
testy = cc_data[-sampledatasplit,]

#check distribution of sampledatasplit
dim(trainy) #523 data points
dim(testy) #131 data points

#create model using training set 
model = train.kknn(R1 ~ ., data = train, kmax = 75, scale = TRUE)


#view model 
model 
 

#predict but this time using test data. Model was made by training data 
prediction <- round(predict(model, test))

#create confusion matrix to see distribution of predictions and outcomes 
predictionAccuracy <- table(prediction, test$R1)

#calculate accuracy of model tested on test data
sum(prediction==test$R1)/length(test$R1)

#Accuracy is 87.786%






#QUESTION 3.1b

#for reproducible results 
set.seed(1)

#separate data into train set (70%) and test set (30%). I will later break this 30% down 50/50 into test vs. validate
dataset <- sample(nrow(cc_data), .70 * nrow(cc_data)) 

#70% of data 
trainy <- cc_data[dataset, ]

#separate data into train (15%) and validate (15%) set
testandvalid <- cc_data[-dataset, ]
separatetestandvalid <- sample(nrow(testandvalid), .50 * nrow(testandvalid))

#validate set (15%)
validy <- testandvalid[-separatetestandvalid,]

#test set (15%)
testy <- testandvalid[separatetestandvalid, ]

#for simplicity reasons, I am only creating three different models each with a different value of C
#i have picked C's with very different magnitudes 
#in hindsight another way i could do this is loop through values of C to test even more and find one better than 100 
#but for now i am sticking to 3 
#below i create three different models manipulating our C value using the trainy set
model1 <- ksvm(as.matrix(trainy[,1:10]), as.factor(trainy[,11]), C=100, scaled=TRUE, kernel="vanilladot", type="C-svc")
model2 <- ksvm(as.matrix(trainy[,1:10]), as.factor(trainy[,11]), C=.00001, scaled=TRUE, kernel="vanilladot", type="C-svc")
model3 <- ksvm(as.matrix(trainy[,1:10]), as.factor(trainy[,11]), C=100000000, scaled=TRUE, kernel="vanilladot", type="C-svc")

#run predictions on validation set 
pred1 <- predict(model1,validy[,1:10])
pred2 <- predict(model2,validy[,1:10])
pred3 <- predict(model3,validy[,1:10])

#calculate percentage accuracy from validation set 
sum(pred1 == validy[,11]) / nrow(validy) #.848484
sum(pred2 == validy[,11]) / nrow(validy) #.565656
sum(pred3 == validy[,11]) / nrow(validy) #.626266

#model 1 has the highest accuracy rate therefore I will use model1 on my test set 
model1_prediction_testy <- predict(model1,testy[,1:10]) 
sum(model1_prediction_testy == testy[,11]) / nrow(testy)

#accuracy of model on test set is .877551.
#While normally the test set should be a lower accuracy than the validation set due to less randomness/luck, 
#it is possible that my sample test data contained enough random effects to overcome 
#and exceed the random effects in my validation data to produce a higher prediction accuracy. 

