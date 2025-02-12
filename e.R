#note: this r file is for study how to use the double di-biasd machine learning 

#clean the enviroment
rm(list = ls())

#lode the pacakge
library(DoubleML)
library(mlr3)
library(mlr3learners)
library(data.table)
library(ggplot2)

# suppress messages during fitting
lgr::get_logger("mlr3")$set_threshold("warn") 

# load data as a data.table
data = fetch_401k(return_type = "data.table", instrument = TRUE)
dim(data)
str(data)

# Set up basic model: Specify variables for data-backend
features_base = c("age", "inc", "educ", "fsize",
                  "marr", "twoearn", "db", "pira", "hown")



# Initialize DoubleMLData (data-backend of DoubleML)
data_dml_base = DoubleMLData$new(data,
                                 y_col = "net_tfa", #Here we put the variable that need to be explained
                                 d_cols = "e401", #here is D_i here 
                                 x_cols = features_base) #All other variables

#so, the idea is like: 
#we first determine which variables are the variable that is not important
#and Then put it in the double di-biased machine learning function! 

######


# Set up a model according to regression formula with polynomials
formula_flex = formula(" ~ -1 + poly(age, 2, raw=TRUE) +
                        poly(inc, 2, raw=TRUE) + poly(educ, 2, raw=TRUE) +
                        poly(fsize, 2, raw=TRUE) + marr + twoearn +
                        db + pira + hown")


#lm_model = lm(y ~ x1 + x2, data = mydata)
#lm_model = lm(formula(y ~ x1 + x2), data = mydata)
#so, The formular() can build a model so from there we can do in different function without repate it? 



features_flex = data.frame(model.matrix(formula_flex, data))
#The model.matrix() is working as the way to processing the data according to the formular() and then
#save at features_flex

model_data = data.table("net_tfa" = data[, net_tfa],
                        "e401" = data[, e401],
                        features_flex)

#process the dataset in teh way of the double dibiased machine learning 




# Initialize DoubleMLData (data-backend of DoubleML)
data_dml_flex = DoubleMLData$new(model_data,
                                 y_col = "net_tfa",
                                 d_cols = "e401")


######################################################################

## Initialize learners
set.seed(123)
lasso = lrn("regr.cv_glmnet", nfolds = 5, s = "lambda.min")
lasso_class = lrn("classif.cv_glmnet", nfolds = 5, s = "lambda.min")


# Initialize DoubleMLPLR model
dml_plr_lasso = DoubleMLPLR$new(data_dml_base, 
                                ml_l = lasso,
                                ml_m = lasso_class,
                                n_folds = 3)
dml_plr_lasso$fit()
dml_plr_lasso$summary()






