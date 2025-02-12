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
#and Then put it in the oudlbe 