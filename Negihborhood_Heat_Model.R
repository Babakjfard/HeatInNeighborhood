# R Project Template

# 1. Prepare Problem
# a) Load libraries
library(caret)

# b) Load dataset
# The definition and creation of datasets are provided in the Rmd file GettingData.Rmd
source("makeData.R")
# c) Split-out validation dataset
set.seed(7)
validationIndex <- createDataPartition(Heat_in_Neighborhood$amb_temp, p=0.8, list = FALSE)
# select 20% for validation
validation <- Heat_in_Neighborhood[-validationIndex,]
# use the remaining 80% for training
dataset <- Heat_in_Neighborhood[validationIndex,]

save(validation, dataset, file = "validation_test.rda")

# ---------------------------------------------------
# 2. Summarize Data  ----># I will do it in a Notebook (EDA.Rmd)
# a) Descriptive statistics

# b) Data visualizations


# 3. Prepare Data
# a) Data Cleaning

# b) Feature Selection
# c) Data Transforms

# 4. Evaluate Algorithms
# a) Test options and evaluation metric
# I am going to use 10-fold cross validation as starting point
load("validation_test.rda")
trainControl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
metric <- "RMSE"

# b) Spot Check Algorithms
# This is a regression problem, I am goint to use algorithms as follow

# I) Linear Algorithms
# Linear Regression (LR)
set.seed(7)
fit.lm <- train(amb_temp~., data=dataset, method="lm", metric=metric, 
                preProc=c("center", "scale"), trControl=trainControl)
# Generalized Linear Model (GLM)
set.seed(7)
fit.glm <- train(amb_temp~., data=dataset, method="glm", metric=metric, 
                 preProc=c("center", "scale"), trControl=trainControl)


# II) Non-Linear Algorithms
# SVM
set.seed(7)
fit.svm <- train(amb_temp~., data=dataset, method="svmRadial", metric=metric,
                 preProc=c("center", "scale"), trControl=trainControl)

# Classification and Regression Trees (CART)
set.seed(7)
grid <- expand.grid(.cp=c(0, 0.05, 0.1))
fit.cart <- train(amb_temp~., data=dataset, method="rpart", metric=metric, tuneGrid=grid,
                  preProc=c("center", "scale"), trControl=trainControl)

# -------------------------
# c) Compare Algorithms
results <- resamples(list(LM=fit.lm, GLM=fit.glm,SVM=fit.svm, CART=fit.cart))
save(fit.cart, fit.glm, fit.lm, fit.svm, results, file = "trained_models_I.rda")
 # Now Switch to 'Eval_Algorithms" notebook to see the evaluation 
# and get an idea for improving the results

# 5. Improve Accuracy
# Later, Look into your model, the correlations and remove highly correlated features
# and re-evaluate the models

# a) Algorithm Tuning
# For later time, look into different ways that you can tune your models for better results

# b) Ensembles
# For now, I am just trying Random Forest. Later, I might add XGBoost, too.
# try ensembles
trainControl2 <- trainControl(method="repeatedcv", number=10, repeats=3)
metric <- "RMSE"
# Random Forest
set.seed(7)
fit.rf <- train(amb_temp~., data=dataset, method="rf", 
                metric=metric, preProc=c("BoxCox"), trControl=trainControl)
results_with_ensembles <- resamples(list(RF=fit.rf, LM=fit.lm, GLM=fit.glm,SVM=fit.svm, CART=fit.cart))
save(fit.rf, results_with_ensembles, file = "models_I_withensembles.rda")
# Now Switch to 'Eval_Algorithms" notebook AGAIN and see the evaluation


# 6. Finalize Model
# a) Predictions on validation dataset
# b) Create standalone model on entire training dataset
# c) Save model for later use
