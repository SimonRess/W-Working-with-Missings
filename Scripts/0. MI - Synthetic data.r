---
title: "R Notebook"
output: html_notebook
---

This is an [R Markdown](http://rmarkdown.rstudio.com) Notebook. When you execute code within the notebook, the results appear beneath the code. 

Try executing this chunk by clicking the *Run* button within the chunk or by placing your cursor inside it and pressing *Ctrl+Shift+Enter*. 

```{r}


# for(i in 1:4000){
#   set.seed(415)
#     
#   Mann = ifelse(runif(5000,0,1) < 0.50, 1, 0)
#   Alter = as.numeric(cut(runif(5000,20,70), c(20,30,40,50,60,70)))
#   
#   FK = ifelse((Mann*0.2 + Alter*0.1 + runif(5000,0,0.6)) > 0.95, 1, 0)
#   mean(FK, na.rm = T)
#   lm(FK~Mann+Alter)
#   m = lm(FK~Mann+Alter)$coefficients["Mann"]
#   a = lm(FK~Mann+Alter)$coefficients["Alter"]
#   if(m>0.2 & m<0.201 & a>0.1 & a<0.101) print(i)
# }
# 
# 
# if(!require(foreach)) install.packages("foreach")
# require(foreach)
# if(!require(doParallel)) install.packages("doParallel")
# require(doParallel)
# if(!require(parallel)) install.packages("parallel")
# require(parallel)
# 
# cnt_clust = detectCores() -1
# c1 = makeCluster(cnt_clust) 
# registerDoParallel(c1)
# 
# system.time(
#   zz <- foreach(i = 1:200) %:% 
#     foreach(z = 1:40) %:%
#     foreach(y = 1:20) %dopar% {
#       for(i in 1:3000) {
#         set.seed(i)
#         B5.1 = as.numeric(cut(FK*1.5 + B2.1*0.2 + Alter*(-0.30) + rnorm(5000,2.5,0.30), c(-2,1,2,3,4,8)))
#         # B5.1 = FK*1.5 + B2.1*0.2 + Alter*(-0.30)
#         f= lm(B5.1~FK+B2.1+Alter)$coefficients["FK"]
#         a= lm(B5.1~Alter+FK+B2.1)$coefficients["Alter"]
#         b= lm(B5.1~B2.1+FK+Alter)$coefficients["B2.1"]
#         if(f>1.5 & f<1.505 & a> (-0.305) & a< (-0.3) & b>0.2 & b<0.205) print(paste0("i:",i," /z:",z," / y:",y))
#       }
#       if(f>1.49 & f<1.505 & a> (-0.305) & a<(-0.3) & b>0.19 & b<0.21) {
#         print(paste0("i:",i," /z:",z," / y:",y)) 
#         return(paste0("i:",i," /z:",z," / y:",y))
#       }else return("")
#     }
# )
# stopCluster(c1)
# unlist(zz)[unlist(zz)!=""]



set.seed(415)
Mann = ifelse(runif(5000,0,1) < 0.50, 1, 0)
Alter = as.numeric(cut(runif(5000,20,70), c(20,30,40,50,60,70)))

FK = ifelse((Mann*0.2 + Alter*0.1 + runif(5000,0,0.6)) > 0.95, 1, 0)
lm(FK~Mann+Alter)

B2.1 = as.numeric(cut(FK*2 + rnorm(5000,2,0.35), c(0,1,2,3,4,6)))
lm(B2.1~FK)

set.seed(1015)
B5.1 = as.numeric(cut(FK*1.5 + B2.1*0.2 + Alter*(-0.30) + rnorm(5000,2.5,0.30), c(-2,1,2,3,4,8)))
lm(B5.1~FK+B2.1+Alter)$coefficients["FK"]
lm(B5.1~Alter+FK+B2.1)$coefficients["Alter"]
lm(B5.1~B2.1+FK+Alter)$coefficients["B2.1"]

df = data.frame(Mann, Alter, FK, B2.1, B5.1)

#Testing whether true effects can be estimated
  # Mann -(+0.2)> FK
    lm(FK~Mann, data = df)
  
  # Alter -(+0.1)> FK
    lm(FK~Alter, data = df)
  
  # FK -(+2)> B2.1
    lm(B2.1~FK, data = df)
  
  # FK -(+1.5)> B5.1
    lm(B5.1~FK, data = df)
    lm(B5.1~FK+B2.1+Alter, data = df)
    
  # B2.1 -(+1.5)> B5.1
    lm(B5.1~B2.1, data = df)
    lm(B5.1~B2.1+FK+Alter, data = df)    
  
  # Alter -(-0.3)> B5.1
    lm(B5.1~Alter, data = df)
    lm(B5.1~Alter+FK+B2.1, data = df)
    
    

if(!require(missMethods)) install.packages("missMethods")
library(missMethods)

#MCAR
#Generate MCAR values on vars: FK, B2.1
    sum(is.na(df$FK))
    sum(is.na(df$B2.1))
  df_mcar <- delete_MCAR(df, 0.3, "FK")
  df_mcar <- delete_MCAR(df_mcar, 0.35, "B2.1")


#MAR
#Generate MAR values on vars: FK, B2.1
  df_mar <- delete_MAR_1_to_x(df, 0.3, "FK", cols_ctrl = "Alter", x = 10)
  df_mar <- delete_MAR_1_to_x(df_mar, 0.35, "B2.1", cols_ctrl = "Mann", x = 10)

#MNAR
#Generate MNAR values on vars: FK, B2.1
  df_mnar <- delete_MNAR_1_to_x(df, 0.3, "FK", x = 3)
  df_mnar <- delete_MNAR_1_to_x(df_mnar, 0.5, "B2.1", x = 3)


if(!require(mice)) install.packages("mice")
library(mice)
  
#Check missing data pattern
  
  #Check: Jointly occurring missing
    md.pattern(df)  
    md.pattern(df_mcar)
    md.pattern(df_mar)
    md.pattern(df_mnar)
  
  #Check: Bivariate relationship of the missing of X to the values of Y
    if(!require(VIM)) install.packages("VIM")
    library(VIM)
    
    #red-box distribution of "Alter" with "FK"-Missings
    #blue-box distribution of "Alter" with "FK"-NON-Missings
    marginplot(df_mcar[c("FK","Alter")])
    marginplot(df_mar[c("FK","Alter")])
    marginplot(df_mnar[c("FK","Alter")])
  
 
# Handling Missing Data

  # 1. Case wise deletion (default in most commands e.g. lm, corr, ...)
    
    df_mcar_cwd = df_mcar[complete.cases(df_mcar), ]
    df_mar_cwd = df_mar[complete.cases(df_mar), ]
    df_mnar_cwd = df_mnar[complete.cases(df_mnar), ]
    
  # 2. Mean Imputation
     
    df_mcar_meanimp = missMethods::impute_mean(df_mcar, type = "columnwise")
    df_mar_meanimp = missMethods::impute_mean(df_mar, type = "columnwise")
    df_mnar_meanimp = missMethods::impute_mean(df_mnar, type = "columnwise")
    
  # 3. Multiple Imputation
    
    #Perform Multiple Impuations
      df_mcar_mi =mice(df_mcar, maxit = 5)
      df_mar_mi =mice(df_mar, maxit = 5)
      df_mnar_mi =mice(df_mnar, maxit = 5)
    
    #Handling MI-data as "normal" data frame -> biased standard errors (SE)
      df_mcar_mi_one_dataset <- mice::complete(df_mcar_mi, action="long", include = TRUE)
      summary(lm(B5.1~Alter+FK+B2.1, df_mcar_mi_one_dataset))
    
    #I.Handling MI-data in regard to its special structure
      model1 <- with(df_mcar_mi, lm(B5.1~Alter+FK+B2.1))
      summary(model1)
      pool(model1)
    
    #II.Handling MI-data in regard to its special structure
      if(!require(mitml)) install.packages("mitml")
      library(mitml)
      implist <- mitml::mids2mitml.list(df_mcar_mi)
      model1 <- with(implist, lm(B5.1~Alter+FK+B2.1))
      mitml::testEstimates(model1)
    

# Comparison of the results according to the missing values handling technique     
      
  #MCAR - Missings COMPLETELY at Random
    mcar_comparison = list()
    for(i in c("Mann-(+0.2)>FK", "Alter-(+0.1)>FK", "FK-(+2)>B2.1", "FK-(+1.5)>B5.1", 
               "B2.1-(+1.5)>B5.1","Alter-(-0.3)>B5.1")){
      mcar_comparison[[i]] = data.frame(Technique = c("Case wise deletion", "Mean Imputation", "Multiple Imputation", "MI(wrong method)"),
                                      Estimate = c("","","",""), Std.Error = c("","","",""), "Beta.Diff.from.True.in.Perc"= c("","","",""),
                                      "Std.E.Diff.from.True.in.Perc"= c("","","",""))
    }
      # Mann -(+0.2)> FK
        mcar_comparison[["Mann-(+0.2)>FK"]][1,2:3] = round(summary(lm(FK~Mann, data = df_mcar_cwd))$coefficients["Mann",1:2],5)
        mcar_comparison[["Mann-(+0.2)>FK"]][2,2:3] = round(summary(lm(FK~Mann, data = df_mcar_meanimp))$coefficients["Mann",1:2],5)
        mcar_comparison[["Mann-(+0.2)>FK"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mcar_mi), lm(FK~Mann)))$estimates["Mann",1:2],5)
        mcar_comparison[["Mann-(+0.2)>FK"]][4,2:3] = round(summary(lm(FK~Mann, data = mice::complete(df_mcar_mi, action="long", include = TRUE)))$coefficients["Mann",1:2],5)
        
        mcar_comparison[["Mann-(+0.2)>FK"]][,4] = (0.2 - as.numeric(mcar_comparison[["Mann-(+0.2)>FK"]][,2])) / 0.2*100
        mcar_comparison[["Mann-(+0.2)>FK"]][,5] = (as.numeric(mcar_comparison[["Mann-(+0.2)>FK"]][3,3]) - as.numeric(mcar_comparison[["Mann-(+0.2)>FK"]][,3])) / as.numeric(mcar_comparison[["Mann-(+0.2)>FK"]][3,3])*100
        mcar_comparison[["Mann-(+0.2)>FK"]]
        
        
      # Alter -(+0.1)> FK
        mcar_comparison[["Alter-(+0.1)>FK"]][1,2:3] = round(summary(lm(FK~Alter, data = df_mcar_cwd))$coefficients["Alter",1:2],5)
        mcar_comparison[["Alter-(+0.1)>FK"]][2,2:3] = round(summary(lm(FK~Alter, data = df_mcar_meanimp))$coefficients["Alter",1:2],5)
        mcar_comparison[["Alter-(+0.1)>FK"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mcar_mi), lm(FK~Alter)))$estimates["Alter",1:2],5)
        mcar_comparison[["Alter-(+0.1)>FK"]][4,2:3] = round(summary(lm(FK~Alter, data = mice::complete(df_mcar_mi, action="long", include = TRUE)))$coefficients["Alter",1:2],5)
        
        mcar_comparison[["Alter-(+0.1)>FK"]][,4] = (0.1 - as.numeric(mcar_comparison[["Alter-(+0.1)>FK"]][,2])) / 0.1*100
        mcar_comparison[["Alter-(+0.1)>FK"]][,5] = (as.numeric(mcar_comparison[["Alter-(+0.1)>FK"]][3,3]) - as.numeric(mcar_comparison[["Alter-(+0.1)>FK"]][,3])) / as.numeric(mcar_comparison[["Alter-(+0.1)>FK"]][3,3])*100
        mcar_comparison[["Alter-(+0.1)>FK"]]
      
        
      # FK -(+2)> B2.1
        mcar_comparison[["FK-(+2)>B2.1"]][1,2:3] = round(summary(lm(B2.1~FK, data = df_mcar_cwd))$coefficients["FK",1:2],5)
        mcar_comparison[["FK-(+2)>B2.1"]][2,2:3] = round(summary(lm(B2.1~FK, data = df_mcar_meanimp))$coefficients["FK",1:2],5)
        mcar_comparison[["FK-(+2)>B2.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mcar_mi), lm(B2.1~FK)))$estimates["FK",1:2],5)
        mcar_comparison[["FK-(+2)>B2.1"]][4,2:3] = round(summary(lm(B2.1~FK, data = mice::complete(df_mcar_mi, action="long", include = TRUE)))$coefficients["FK",1:2],5)
        
        mcar_comparison[["FK-(+2)>B2.1"]][,4] = (2 - as.numeric(mcar_comparison[["FK-(+2)>B2.1"]][,2])) / 2*100
        mcar_comparison[["FK-(+2)>B2.1"]][,5] = (as.numeric(mcar_comparison[["FK-(+2)>B2.1"]][3,3]) - as.numeric(mcar_comparison[["FK-(+2)>B2.1"]][,3])) / as.numeric(mcar_comparison[["FK-(+2)>B2.1"]][3,3])*100
        mcar_comparison[["FK-(+2)>B2.1"]]
      
        
      # FK -(+1.5)> B5.1
        mcar_comparison[["FK-(+1.5)>B5.1"]][1,2:3] = round(summary(lm(B5.1~FK+B2.1+Alter, data = df_mcar_cwd))$coefficients["FK",1:2],5)
        mcar_comparison[["FK-(+1.5)>B5.1"]][2,2:3] = round(summary(lm(B5.1~FK+B2.1+Alter, data = df_mcar_meanimp))$coefficients["FK",1:2],5)
        mcar_comparison[["FK-(+1.5)>B5.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mcar_mi), lm(B5.1~FK+B2.1+Alter)))$estimates["FK",1:2],5)
        mcar_comparison[["FK-(+1.5)>B5.1"]][4,2:3] = round(summary(lm(B5.1~FK+B2.1+Alter, data = mice::complete(df_mcar_mi, action="long", include = TRUE)))$coefficients["FK",1:2],5)
        
        mcar_comparison[["FK-(+1.5)>B5.1"]][,4] = (1.5 - as.numeric(mcar_comparison[["FK-(+1.5)>B5.1"]][,2])) / 1.5*100
        mcar_comparison[["FK-(+1.5)>B5.1"]][,5] = (as.numeric(mcar_comparison[["FK-(+1.5)>B5.1"]][3,3]) - as.numeric(mcar_comparison[["FK-(+1.5)>B5.1"]][,3])) / as.numeric(mcar_comparison[["FK-(+1.5)>B5.1"]][3,3])*100
        mcar_comparison[["FK-(+1.5)>B5.1"]]
      
        
      # B2.1 -(+0.2)> B5.1
        mcar_comparison[["B2.1-(+1.5)>B5.1"]][1,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mcar_cwd))$coefficients["B2.1",1:2],5)
        mcar_comparison[["B2.1-(+1.5)>B5.1"]][2,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mcar_meanimp))$coefficients["B2.1",1:2],5)
        mcar_comparison[["B2.1-(+1.5)>B5.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mcar_mi), lm(B5.1~B2.1+FK+Alter)))$estimates["B2.1",1:2],5)
        mcar_comparison[["B2.1-(+1.5)>B5.1"]][4,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = mice::complete(df_mcar_mi, action="long", include = TRUE)))$coefficients["B2.1",1:2],5)
        
        mcar_comparison[["B2.1-(+1.5)>B5.1"]][,4] = (0.2 - as.numeric(mcar_comparison[["B2.1-(+1.5)>B5.1"]][,2])) / 0.2*100
        mcar_comparison[["B2.1-(+1.5)>B5.1"]][,5] = (as.numeric(mcar_comparison[["B2.1-(+1.5)>B5.1"]][3,3]) - as.numeric(mcar_comparison[["B2.1-(+1.5)>B5.1"]][,3])) / as.numeric(mcar_comparison[["B2.1-(+1.5)>B5.1"]][3,3])*100
        mcar_comparison[["B2.1-(+1.5)>B5.1"]]
      
        
      # Alter -(-0.3)> B5.1
        mcar_comparison[["Alter-(-0.3)>B5.1"]][1,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mcar_cwd))$coefficients["Alter",1:2],5)
        mcar_comparison[["Alter-(-0.3)>B5.1"]][2,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mcar_meanimp))$coefficients["Alter",1:2],5)
        mcar_comparison[["Alter-(-0.3)>B5.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mcar_mi), lm(B5.1~B2.1+FK+Alter)))$estimates["Alter",1:2],5)
        mcar_comparison[["Alter-(-0.3)>B5.1"]][4,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = mice::complete(df_mcar_mi, action="long", include = TRUE)))$coefficients["Alter",1:2],5)
        
        mcar_comparison[["Alter-(-0.3)>B5.1"]][,4] = (-0.3 - as.numeric(mcar_comparison[["Alter-(-0.3)>B5.1"]][,2])) / -0.3*100
        mcar_comparison[["Alter-(-0.3)>B5.1"]][,5] = (as.numeric(mcar_comparison[["Alter-(-0.3)>B5.1"]][3,3]) - as.numeric(mcar_comparison[["Alter-(-0.3)>B5.1"]][,3])) / as.numeric(mcar_comparison[["Alter-(-0.3)>B5.1"]][3,3])*100
        mcar_comparison[["Alter-(-0.3)>B5.1"]]
    
  
  #MAR - Missings at Random
    mar_comparison = list()
    for(i in c("Mann-(+0.2)>FK", "Alter-(+0.1)>FK", "FK-(+2)>B2.1", "FK-(+1.5)>B5.1", 
               "B2.1-(+1.5)>B5.1","Alter-(-0.3)>B5.1")){
      mar_comparison[[i]] = data.frame(Technique = c("Case wise deletion", "Mean Imputation", "Multiple Imputation", "MI(wrong method)"),
                                        Estimate = c("","","",""), Std.Error = c("","","",""), "Beta.Diff.from.True.in.Perc"= c("","","",""),
                                       "Std.E.Diff.from.True.in.Perc"= c("","","",""))
    }
      # Mann -(+0.2)> FK
        mar_comparison[["Mann-(+0.2)>FK"]][1,2:3] = round(summary(lm(FK~Mann, data = df_mar_cwd))$coefficients["Mann",1:2],5)
        mar_comparison[["Mann-(+0.2)>FK"]][2,2:3] = round(summary(lm(FK~Mann, data = df_mar_meanimp))$coefficients["Mann",1:2],5)
        mar_comparison[["Mann-(+0.2)>FK"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mar_mi), lm(FK~Mann)))$estimates["Mann",1:2],5)
        mar_comparison[["Mann-(+0.2)>FK"]][4,2:3] = round(summary(lm(FK~Mann, data = mice::complete(df_mar_mi, action="long", include = TRUE)))$coefficients["Mann",1:2],5)
        
        mar_comparison[["Mann-(+0.2)>FK"]][,4] = (0.2 - as.numeric(mar_comparison[["Mann-(+0.2)>FK"]][,2])) / 0.2*100
        mar_comparison[["Mann-(+0.2)>FK"]][,5] = (as.numeric(mar_comparison[["Mann-(+0.2)>FK"]][3,3]) - as.numeric(mar_comparison[["Mann-(+0.2)>FK"]][,3])) / as.numeric(mar_comparison[["Mann-(+0.2)>FK"]][3,3])*100
        mar_comparison[["Mann-(+0.2)>FK"]]
        
        
      # Alter -(+0.1)> FK
        mar_comparison[["Alter-(+0.1)>FK"]][1,2:3] = round(summary(lm(FK~Alter, data = df_mar_cwd))$coefficients["Alter",1:2],5)
        mar_comparison[["Alter-(+0.1)>FK"]][2,2:3] = round(summary(lm(FK~Alter, data = df_mar_meanimp))$coefficients["Alter",1:2],5)
        mar_comparison[["Alter-(+0.1)>FK"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mar_mi), lm(FK~Alter)))$estimates["Alter",1:2],5)
        mar_comparison[["Alter-(+0.1)>FK"]][4,2:3] = round(summary(lm(FK~Alter, data = mice::complete(df_mar_mi, action="long", include = TRUE)))$coefficients["Alter",1:2],5)
        
        mar_comparison[["Alter-(+0.1)>FK"]][,4] = (0.1 - as.numeric(mar_comparison[["Alter-(+0.1)>FK"]][,2])) / 0.1*100
        mar_comparison[["Alter-(+0.1)>FK"]][,5] = (as.numeric(mar_comparison[["Alter-(+0.1)>FK"]][3,3]) - as.numeric(mar_comparison[["Alter-(+0.1)>FK"]][,3])) / as.numeric(mar_comparison[["Alter-(+0.1)>FK"]][3,3])*100
        mar_comparison[["Alter-(+0.1)>FK"]]
        
        
      # FK -(+2)> B2.1
        mar_comparison[["FK-(+2)>B2.1"]][1,2:3] = round(summary(lm(B2.1~FK, data = df_mar_cwd))$coefficients["FK",1:2],5)
        mar_comparison[["FK-(+2)>B2.1"]][2,2:3] = round(summary(lm(B2.1~FK, data = df_mar_meanimp))$coefficients["FK",1:2],5)
        mar_comparison[["FK-(+2)>B2.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mar_mi), lm(B2.1~FK)))$estimates["FK",1:2],5)
        mar_comparison[["FK-(+2)>B2.1"]][4,2:3] = round(summary(lm(B2.1~FK, data = mice::complete(df_mar_mi, action="long", include = TRUE)))$coefficients["FK",1:2],5)
        
        mar_comparison[["FK-(+2)>B2.1"]][,4] = (2 - as.numeric(mar_comparison[["FK-(+2)>B2.1"]][,2])) / 2*100
        mar_comparison[["FK-(+2)>B2.1"]][,5] = (as.numeric(mar_comparison[["FK-(+2)>B2.1"]][3,3]) - as.numeric(mar_comparison[["FK-(+2)>B2.1"]][,3])) / as.numeric(mar_comparison[["FK-(+2)>B2.1"]][3,3])*100
        mar_comparison[["FK-(+2)>B2.1"]]
        
        
      # FK -(+1.5)> B5.1
        mar_comparison[["FK-(+1.5)>B5.1"]][1,2:3] = round(summary(lm(B5.1~FK+B2.1+Alter, data = df_mar_cwd))$coefficients["FK",1:2],5)
        mar_comparison[["FK-(+1.5)>B5.1"]][2,2:3] = round(summary(lm(B5.1~FK+B2.1+Alter, data = df_mar_meanimp))$coefficients["FK",1:2],5)
        mar_comparison[["FK-(+1.5)>B5.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mar_mi), lm(B5.1~FK+B2.1+Alter)))$estimates["FK",1:2],5)
        mar_comparison[["FK-(+1.5)>B5.1"]][4,2:3] = round(summary(lm(B5.1~FK+B2.1+Alter, data = mice::complete(df_mar_mi, action="long", include = TRUE)))$coefficients["FK",1:2],5)
        
        mar_comparison[["FK-(+1.5)>B5.1"]][,4] = (1.5 - as.numeric(mar_comparison[["FK-(+1.5)>B5.1"]][,2])) / 1.5*100
        mar_comparison[["FK-(+1.5)>B5.1"]][,5] = (as.numeric(mar_comparison[["FK-(+1.5)>B5.1"]][3,3]) - as.numeric(mar_comparison[["FK-(+1.5)>B5.1"]][,3])) / as.numeric(mar_comparison[["FK-(+1.5)>B5.1"]][3,3])*100
        mar_comparison[["FK-(+1.5)>B5.1"]]
        
        
      # B2.1 -(+0.2)> B5.1
        mar_comparison[["B2.1-(+1.5)>B5.1"]][1,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mar_cwd))$coefficients["B2.1",1:2],5)
        mar_comparison[["B2.1-(+1.5)>B5.1"]][2,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mar_meanimp))$coefficients["B2.1",1:2],5)
        mar_comparison[["B2.1-(+1.5)>B5.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mar_mi), lm(B5.1~B2.1+FK+Alter)))$estimates["B2.1",1:2],5)
        mar_comparison[["B2.1-(+1.5)>B5.1"]][4,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = mice::complete(df_mar_mi, action="long", include = TRUE)))$coefficients["B2.1",1:2],5)
        
        mar_comparison[["B2.1-(+1.5)>B5.1"]][,4] = (0.2 - as.numeric(mar_comparison[["B2.1-(+1.5)>B5.1"]][,2])) / 0.2*100
        mar_comparison[["B2.1-(+1.5)>B5.1"]][,5] = (as.numeric(mar_comparison[["B2.1-(+1.5)>B5.1"]][3,3]) - as.numeric(mar_comparison[["B2.1-(+1.5)>B5.1"]][,3])) / as.numeric(mar_comparison[["B2.1-(+1.5)>B5.1"]][3,3])*100
        mar_comparison[["B2.1-(+1.5)>B5.1"]]
        
        
      # Alter -(-0.3)> B5.1
        mar_comparison[["Alter-(-0.3)>B5.1"]][1,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mar_cwd))$coefficients["Alter",1:2],5)
        mar_comparison[["Alter-(-0.3)>B5.1"]][2,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mar_meanimp))$coefficients["Alter",1:2],5)
        mar_comparison[["Alter-(-0.3)>B5.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mar_mi), lm(B5.1~B2.1+FK+Alter)))$estimates["Alter",1:2],5)
        mar_comparison[["Alter-(-0.3)>B5.1"]][4,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = mice::complete(df_mar_mi, action="long", include = TRUE)))$coefficients["Alter",1:2],5)
        
        mar_comparison[["Alter-(-0.3)>B5.1"]][,4] = (-0.3 - as.numeric(mar_comparison[["Alter-(-0.3)>B5.1"]][,2])) / -0.3*100
        mar_comparison[["Alter-(-0.3)>B5.1"]][,5] = (as.numeric(mar_comparison[["Alter-(-0.3)>B5.1"]][3,3]) - as.numeric(mar_comparison[["Alter-(-0.3)>B5.1"]][,3])) / as.numeric(mar_comparison[["Alter-(-0.3)>B5.1"]][3,3])*100
        mar_comparison[["Alter-(-0.3)>B5.1"]]
        
        
  #MNAR - Missings NOT at Random
    mnar_comparison = list()
    for(i in c("Mann-(+0.2)>FK", "Alter-(+0.1)>FK", "FK-(+2)>B2.1", "FK-(+1.5)>B5.1", 
               "B2.1-(+1.5)>B5.1","Alter-(-0.3)>B5.1")){
      mnar_comparison[[i]] = data.frame(Technique = c("Case wise deletion", "Mean Imputation", "Multiple Imputation", "MI(wrong method)"),
                                       Estimate = c("","","",""), Std.Error = c("","","",""), "Beta.Diff.from.True.in.Perc"= c("","","",""),
                                       "Std.E.Diff.from.True.in.Perc"= c("","","",""))
    }
      # Mann -(+0.2)> FK
        mnar_comparison[["Mann-(+0.2)>FK"]][1,2:3] = round(summary(lm(FK~Mann, data = df_mnar_cwd))$coefficients["Mann",1:2],5)
        mnar_comparison[["Mann-(+0.2)>FK"]][2,2:3] = round(summary(lm(FK~Mann, data = df_mnar_meanimp))$coefficients["Mann",1:2],5)
        mnar_comparison[["Mann-(+0.2)>FK"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mnar_mi), lm(FK~Mann)))$estimates["Mann",1:2],5)
        mnar_comparison[["Mann-(+0.2)>FK"]][4,2:3] = round(summary(lm(FK~Mann, data = mice::complete(df_mnar_mi, action="long", include = TRUE)))$coefficients["Mann",1:2],5)
        
        mnar_comparison[["Mann-(+0.2)>FK"]][,4] = (0.2 - as.numeric(mnar_comparison[["Mann-(+0.2)>FK"]][,2])) / 0.2*100
        mnar_comparison[["Mann-(+0.2)>FK"]][,5] = (as.numeric(mnar_comparison[["Mann-(+0.2)>FK"]][3,3]) - as.numeric(mnar_comparison[["Mann-(+0.2)>FK"]][,3])) / as.numeric(mnar_comparison[["Mann-(+0.2)>FK"]][3,3])*100
        mnar_comparison[["Mann-(+0.2)>FK"]]
        
        
      # Alter -(+0.1)> FK
        mnar_comparison[["Alter-(+0.1)>FK"]][1,2:3] = round(summary(lm(FK~Alter, data = df_mnar_cwd))$coefficients["Alter",1:2],5)
        mnar_comparison[["Alter-(+0.1)>FK"]][2,2:3] = round(summary(lm(FK~Alter, data = df_mnar_meanimp))$coefficients["Alter",1:2],5)
        mnar_comparison[["Alter-(+0.1)>FK"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mnar_mi), lm(FK~Alter)))$estimates["Alter",1:2],5)
        mnar_comparison[["Alter-(+0.1)>FK"]][4,2:3] = round(summary(lm(FK~Alter, data = mice::complete(df_mnar_mi, action="long", include = TRUE)))$coefficients["Alter",1:2],5)
        
        mnar_comparison[["Alter-(+0.1)>FK"]][,4] = (0.1 - as.numeric(mnar_comparison[["Alter-(+0.1)>FK"]][,2])) / 0.1*100
        mnar_comparison[["Alter-(+0.1)>FK"]][,5] = (as.numeric(mnar_comparison[["Alter-(+0.1)>FK"]][3,3]) - as.numeric(mnar_comparison[["Alter-(+0.1)>FK"]][,3])) / as.numeric(mnar_comparison[["Alter-(+0.1)>FK"]][3,3])*100
        mnar_comparison[["Alter-(+0.1)>FK"]]
        
        
      # FK -(+2)> B2.1
        mnar_comparison[["FK-(+2)>B2.1"]][1,2:3] = round(summary(lm(B2.1~FK, data = df_mnar_cwd))$coefficients["FK",1:2],5)
        mnar_comparison[["FK-(+2)>B2.1"]][2,2:3] = round(summary(lm(B2.1~FK, data = df_mnar_meanimp))$coefficients["FK",1:2],5)
        mnar_comparison[["FK-(+2)>B2.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mnar_mi), lm(B2.1~FK)))$estimates["FK",1:2],5)
        mnar_comparison[["FK-(+2)>B2.1"]][4,2:3] = round(summary(lm(B2.1~FK, data = mice::complete(df_mnar_mi, action="long", include = TRUE)))$coefficients["FK",1:2],5)
        
        mnar_comparison[["FK-(+2)>B2.1"]][,4] = (2 - as.numeric(mnar_comparison[["FK-(+2)>B2.1"]][,2])) / 2*100
        mnar_comparison[["FK-(+2)>B2.1"]][,5] = (as.numeric(mnar_comparison[["FK-(+2)>B2.1"]][3,3]) - as.numeric(mnar_comparison[["FK-(+2)>B2.1"]][,3])) / as.numeric(mnar_comparison[["FK-(+2)>B2.1"]][3,3])*100
        mnar_comparison[["FK-(+2)>B2.1"]]
        
        
      # FK -(+1.5)> B5.1
        mnar_comparison[["FK-(+1.5)>B5.1"]][1,2:3] = round(summary(lm(B5.1~FK+B2.1+Alter, data = df_mnar_cwd))$coefficients["FK",1:2],5)
        mnar_comparison[["FK-(+1.5)>B5.1"]][2,2:3] = round(summary(lm(B5.1~FK+B2.1+Alter, data = df_mnar_meanimp))$coefficients["FK",1:2],5)
        mnar_comparison[["FK-(+1.5)>B5.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mnar_mi), lm(B5.1~FK+B2.1+Alter)))$estimates["FK",1:2],5)
        mnar_comparison[["FK-(+1.5)>B5.1"]][4,2:3] = round(summary(lm(B5.1~FK+B2.1+Alter, data = mice::complete(df_mnar_mi, action="long", include = TRUE)))$coefficients["FK",1:2],5)
        
        mnar_comparison[["FK-(+1.5)>B5.1"]][,4] = (1.5 - as.numeric(mnar_comparison[["FK-(+1.5)>B5.1"]][,2])) / 1.5*100
        mnar_comparison[["FK-(+1.5)>B5.1"]][,5] = (as.numeric(mnar_comparison[["FK-(+1.5)>B5.1"]][3,3]) - as.numeric(mnar_comparison[["FK-(+1.5)>B5.1"]][,3])) / as.numeric(mnar_comparison[["FK-(+1.5)>B5.1"]][3,3])*100
        mnar_comparison[["FK-(+1.5)>B5.1"]]
        
        
      # B2.1 -(+0.2)> B5.1
        mnar_comparison[["B2.1-(+1.5)>B5.1"]][1,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mnar_cwd))$coefficients["B2.1",1:2],5)
        mnar_comparison[["B2.1-(+1.5)>B5.1"]][2,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mnar_meanimp))$coefficients["B2.1",1:2],5)
        mnar_comparison[["B2.1-(+1.5)>B5.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mnar_mi), lm(B5.1~B2.1+FK+Alter)))$estimates["B2.1",1:2],5)
        mnar_comparison[["B2.1-(+1.5)>B5.1"]][4,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = mice::complete(df_mnar_mi, action="long", include = TRUE)))$coefficients["B2.1",1:2],5)
        
        mnar_comparison[["B2.1-(+1.5)>B5.1"]][,4] = (0.2 - as.numeric(mnar_comparison[["B2.1-(+1.5)>B5.1"]][,2])) / 0.2*100
        mnar_comparison[["B2.1-(+1.5)>B5.1"]][,5] = (as.numeric(mnar_comparison[["B2.1-(+1.5)>B5.1"]][3,3]) - as.numeric(mnar_comparison[["B2.1-(+1.5)>B5.1"]][,3])) / as.numeric(mnar_comparison[["B2.1-(+1.5)>B5.1"]][3,3])*100
        mnar_comparison[["B2.1-(+1.5)>B5.1"]]
        
        
      # Alter -(-0.3)> B5.1
        mnar_comparison[["Alter-(-0.3)>B5.1"]][1,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mnar_cwd))$coefficients["Alter",1:2],5)
        mnar_comparison[["Alter-(-0.3)>B5.1"]][2,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = df_mnar_meanimp))$coefficients["Alter",1:2],5)
        mnar_comparison[["Alter-(-0.3)>B5.1"]][3,2:3] = round(mitml::testEstimates(with(mitml::mids2mitml.list(df_mnar_mi), lm(B5.1~B2.1+FK+Alter)))$estimates["Alter",1:2],5)
        mnar_comparison[["Alter-(-0.3)>B5.1"]][4,2:3] = round(summary(lm(B5.1~B2.1+FK+Alter, data = mice::complete(df_mnar_mi, action="long", include = TRUE)))$coefficients["Alter",1:2],5)
        
        mnar_comparison[["Alter-(-0.3)>B5.1"]][,4] = (-0.3 - as.numeric(mnar_comparison[["Alter-(-0.3)>B5.1"]][,2])) / -0.3*100
        mnar_comparison[["Alter-(-0.3)>B5.1"]][,5] = (as.numeric(mnar_comparison[["Alter-(-0.3)>B5.1"]][3,3]) - as.numeric(mnar_comparison[["Alter-(-0.3)>B5.1"]][,3])) / as.numeric(mnar_comparison[["Alter-(-0.3)>B5.1"]][3,3])*100
        mnar_comparison[["Alter-(-0.3)>B5.1"]]
        
        
        
```

Add a new chunk by clicking the *Insert Chunk* button on the toolbar or by pressing *Ctrl+Alt+I*.

When you save the notebook, an HTML file containing the code and output will be saved alongside it (click the *Preview* button or press *Ctrl+Shift+K* to preview the HTML file).

The preview shows you a rendered HTML copy of the contents of the editor. Consequently, unlike *Knit*, *Preview* does not run any R code chunks. Instead, the output of the chunk when it was last run in the editor is displayed.
