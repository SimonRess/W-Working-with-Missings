#------------------------------------#
# Working with Multiple Imputed data #
#------------------------------------#

#------------------------#
# 0. Pre-Requirements ####
#------------------------#

  #Install required packages
    if(!require("dplyr")) install.packages("dplyr")
    library(dplyr)
  
  #Set Path
    path = "C:/Users/simon/Desktop/BIT-HR&C Datensätze/"
  
  #Load files
    mi.fk = readRDS(paste0(path, "multi-imput-FK-B12b.rds"))
    mi.ma = readRDS(paste0(path, "multi-imput-MA-B12b.rds"))
  
  #Check multiple imputed datasets
    table(mi.fk$`_mi_m`)
    
  #-------------------------#  
  # 0.1 Create functions ####
  #-------------------------#
    
    #stderror: Calculate the standard error
      stderror <- function(x) sd(x)/sqrt(length(x))
   
    #mi_se.dirty: Calculate the standard error in multiple imputed datasets (neglect between-component)
      #Pre-requirement: N of imputed datasets
        n_mi = length(unique(mi.fk$`_mi_m`))-1
      mi_se.dirty <- function(x) sd(x)/sqrt(length(x)/n_mi) # IMPORTANT: Divide by the number of imputed datasets -> increases standard error -> increases confidence interval
    
      #Testing the function
         mi_se.dirty(mi.fk[mi.fk$`_mi_m`!=0,]$B4181)
      
    #mi_se: Calculate the standard error in multiple imputed datasets
      mi_se = function(data, var, mi_id) {
        WIV = data %>%
          group_by(eval(parse(text =paste0("`",mi_id,"`")))) %>%
          summarise(variance = var(eval(parse(text=var)))) %>%
          summarise(var = mean(variance)) %>%
          .[[1]]
        
        BIV = data %>%
          group_by(eval(parse(text =paste0("`",mi_id,"`")))) %>%
          summarise(mean = mean(eval(parse(text=var)))) %>%
          mutate(diff.square = (mean - colMeans(.[2]))^2) %>%
          summarise(B = mean(diff.square)) %>%
          .[[1]]
        
        TIV = WIV+(1+1/length(unique(data[,mi_id])))*BIV
        
        SD = sqrt(TIV)
        SE = SD/sqrt(nrow(data)/length(unique(data[,mi_id])))
        #return(list(WIV,BIV,TIV,SE))
        return(SE)
      }
      
      #Testing the function
        mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")
  
  # build function to check missing patterns
    check.missings = function(data, var) {
      data = data %>%
        group_by(`_mi_m`) %>%
        summarise(n = length(eval(parse(text = var))),
                  n_non_miss = sum(!is.na(eval(parse(text = var)))),
                  n_miss = sum(is.na(eval(parse(text = var)))))
      
      print("----------------------------------------")
      print(paste0("Variable: ", var))
      print(data)
    }
  
    #Testing the function
      check.missings(mi.fk, "B4181")


#------------------------------------------------------#
# 1. Check missing pattern of vars by mi-dataset-ID ####
      #------------------------------------------------------#
  
  #Select vars
    vars = names(mi.fk)[startsWith(names(mi.fk), "B4")] 
    vars = vars[endsWith(vars, "1")] 
  
  # Check missing pattern of vars
    for(v in vars) {
      check.missings(mi.fk, v)
    }

        
#----------------------------------#
# 2. Calculate point-estimates  ####
#----------------------------------#
    
  #Mean: mean() & Confidence interval of B4181
    
    #Step by Step: Calculate Mean of B4181
      #1. Step: Calculate Mean by imputed dataset (_mi_m)
      mi.fk %>%
        filter(`_mi_m`!=0) %>%
        group_by(`_mi_m`) %>%
        summarise(mean = mean(B4181))
      
      #2. Step: Calculate Mean of Means -> point estimate
      mi.fk %>%
        filter(`_mi_m`!=0) %>%
        group_by(`_mi_m`) %>%
        summarise(mean = mean(B4181)) %>%
        summarise(mean = mean(mean))
      
      #Comparison:
        #Mean over all cases <- biased !!!
          mi.fk %>%
            filter(`_mi_m`!=0) %>%
            summarise(mean = mean(B4181))
          
        #Mean without imputation <- biased !!!
          mi.fk %>%
            filter(`_mi_m`==0) %>%
            summarise(mean = mean(B4181, na.rm = TRUE))

#--------------------------------------------------------------------#
  #Median: median() & Confidence interval of B4181
    mi.fk %>%
      filter(`_mi_m`!=0) %>%
      group_by(`_mi_m`) %>%
      summarise(median = median(B4181)) %>%
      summarise(median = mean(median))
    
    #Comparison:
      #Median over all cases <- biased
        mi.fk %>%
          filter(`_mi_m`!=0) %>%
          summarise(median = median(B4181))
      
      #Median without imputation <- biased
        mi.fk %>%
          filter(`_mi_m`==0) %>%
          summarise(median = median(B4181, na.rm = TRUE))
    
#--------------------------------------------------------------------#    
  #3. Quantile : summary()[5] & Confidence interval of B4181
    mi.fk %>%
      filter(`_mi_m`!=0) %>%
      group_by(`_mi_m`) %>%
      summarise(Q3 = summary(B4181)[5]) %>%
      summarise(Q3 = mean(Q3))  
    
    #Comparison:
      #3. Quantile over all cases <- biased
        mi.fk %>%
          filter(`_mi_m`!=0) %>%
          summarise(Q3 = summary(B4181)[5])
      
      #3. Quantile without imputation <- biased
        mi.fk %>%
          filter(`_mi_m`==0) %>%
          summarise(Q3 = summary(B4181)[5])
        
        
#--------------------------------------------------------------------#    
  # Correlation: cor.test() & Confidence interval of B4181
    mi.fk %>%
      filter(`_mi_m`!=0) %>%
      group_by(`_mi_m`) %>%
      summarise(corr = cor.test(B4181,B4171)$estimate) %>%
      summarise(corr = mean(corr)) 
    
    #Comparison:
      #Correlation over all cases <- biased
        mi.fk %>%
          filter(`_mi_m`!=0) %>%
          summarise(corr = cor.test(B4181,B4171)$estimate)
      
      #Correlation without imputation <- biased
        mi.fk %>%
          filter(`_mi_m`==0) %>%
          summarise(corr = cor.test(B4181,B4171)$estimate)
    
#--------------------------------------------------------------------#   
  #Regression: summary(lm()) & Confidence interval of B4181           
    mi.fk %>%
      filter(`_mi_m`!=0) %>%
      group_by(`_mi_m`) %>%
      summarise(beta = summary(lm(B4181~B4171))$coefficients[2,1])  %>%
      summarise(beta = mean(beta)) 
      
    #Comparison:
      #Regression over all cases <- biased
      mi.fk %>%
        filter(`_mi_m`!=0) %>%
        summarise(beta = summary(lm(B4181~B4171))$coefficients[2,1])  
      
      #Regression without imputation <- biased
      mi.fk %>%
        filter(`_mi_m`==0) %>%
        summarise(beta = summary(lm(B4181~B4171))$coefficients[2,1])  
    
    
    
#--------------------------------------------------------#
# 3. Calculate point-estimates & confidence intervals ####
#--------------------------------------------------------#
      
  #-----------------------------------------------------#   
  # 3.1 The wrong way -> Biased confidence intervals ####
  #-----------------------------------------------------#
    
    #Mean: mean() & Confidence interval of B4181
      #Step by Step: Calculate Mean & Confidence interval of B4181
      
        #1. Step: Calculate Mean of Means -> point estimate
          mi.fk %>%
            filter(`_mi_m`!=0) %>%
            group_by(`_mi_m`) %>%
            summarise(mean = mean(B4181),
                      lower.limit = mean - stderror(B4181)*1.96,
                      upper.limit = mean + stderror(B4181)*1.96)
          
        #2. Step (dirty): Calculate Overall Mean ("Mean of Means") & Overall confidence interval (Mean of CIs) <- BIASED
          mi.fk %>%
            filter(`_mi_m`!=0) %>%
            group_by(`_mi_m`) %>%
            summarise(mean = mean(B4181),
                      lower.limit = mean - stderror(B4181)*1.96,
                      upper.limit = mean + stderror(B4181)*1.96) %>%
            summarise(mean = mean(mean),
                      lower.limit = mean(lower.limit),
                      upper.limit = mean(upper.limit))
            
          
        #Alternative (fast but BIASED): SE without between-component
          mi.fk %>%
            filter(`_mi_m`!=0) %>%
            summarise(mean = mean(B4181),
                      lower.limit = mean - mi_se.dirty(B4181)*1.96,
                      upper.limit = mean + mi_se.dirty(B4181)*1.96)
          
        #Alternative (fast but BIASED): SE completely neglect MI-structure  -> 1. no consideration of the increased number of cases / 2. no between-component
          mi.fk %>%
            filter(`_mi_m`!=0) %>%
            summarise(mean = mean(B4181),
                      lower.limit = mean - stderror(B4181)*1.96,
                      upper.limit = mean + stderror(B4181)*1.96)

    

  ##########################################################    
  # 2.2 The correct way -> UNbiased confidence intervals ###
  ##########################################################
    
    #Mean: mean()
      mi.fk %>%
        filter(`_mi_m`!=0) %>%
        summarise(mean = mean(B4181),
                  lower.limit = mean - mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96,
                  upper.limit = mean + mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96)

        mi.fk %>%
          filter(`_mi_m`!=0) %>%
          group_by(`_mi_m`) %>%
          summarise(mean = mean(B4181)) %>%
          summarise(mean = mean(mean)) %>%
          mutate(lower.limit = mean - mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96,
                 upper.limit = mean + mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96)     
          
      #Comparison:
          #SE as mean of partial SEs
          mi.fk %>%
            filter(`_mi_m`!=0) %>%
            group_by(`_mi_m`) %>%
            summarise(mean = mean(B4181),
                      lower.limit = mean - stderror(B4181)*1.96,
                      upper.limit = mean + stderror(B4181)*1.96) %>%
            summarise(mean = mean(mean),
                      lower.limit = mean(lower.limit),
                      upper.limit = mean(upper.limit))
          
          #SE without between-component
          mi.fk %>%
            filter(`_mi_m`!=0) %>%
            summarise(mean = mean(B4181),
                      lower.limit = mean - mi_se.dirty(B4181)*1.96,
                      upper.limit = mean + mi_se.dirty(B4181)*1.96)
          
          #SE completely neglect MI-structure -> 1. no consideration of the increased number of cases / 2. no between-component
          mi.fk %>%
            filter(`_mi_m`!=0) %>%
            summarise(mean = mean(B4181),
                      lower.limit = mean - stderror(B4181)*1.96,
                      upper.limit = mean + stderror(B4181)*1.96)
                      
          
#--------------------------------------------------------------------#   
          
    #Median: median()
      mi.fk %>%
        filter(`_mi_m`!=0) %>%
        group_by(`_mi_m`) %>%
        summarise(median = median(B4181)) %>%
        summarise(median = mean(median)) %>%
        mutate(lower.limit = median - mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96,
               upper.limit = median + mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96)
  
#--------------------------------------------------------------------#   
  
    #3. Quantile : summary()[5]
      mi.fk %>%
        filter(`_mi_m`!=0) %>%
        group_by(`_mi_m`) %>%
        summarise(Q3 = summary(B4181)[5]) %>%
        summarise(Q3 = mean(Q3)) %>%
        mutate(lower.limit = Q3 - mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96,
               upper.limit = Q3 + mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96)
                    
  
  
#--------------------------------------------------------------------#   
  
    # Correlation: cor.test()
      mi.fk %>%
        filter(`_mi_m`!=0) %>%
        group_by(`_mi_m`) %>%
        summarise(corr = cor.test(B4181,B4171)$estimate) %>%
        summarise(corr = mean(corr)) %>%
        mutate(lower.limit = corr - mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96,
               upper.limit = corr + mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96)
                  
  
#--------------------------------------------------------------------#   
  
    #Regression: summary(lm())          
      mi.fk %>%
        filter(`_mi_m`!=0) %>%
        group_by(`_mi_m`) %>%
        summarise(beta = summary(lm(B4181~B4171))$coefficients[2,1]) %>%
        summarise(beta = mean(beta)) %>%
        mutate(lower.limit = beta - mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96,
               upper.limit = beta + mi_se(mi.fk[mi.fk$`_mi_m`!=0,],"B4181", "_mi_m")*1.96)
      
      #Comparison:
        #SE as mean of partial SEs
        mi.fk %>%
          filter(`_mi_m`!=0) %>%
          summarise(beta = summary(lm(B4181~B4171))$coefficients[2,1],
                    lower.limit = beta - stderror(B4181)*1.96,
                    upper.limit = beta + stderror(B4181)*1.96) %>%
          summarise(mean = mean(beta),
                    lower.limit = mean(lower.limit),
                    upper.limit = mean(upper.limit))
        
        #SE without between-component
        mi.fk %>%
          filter(`_mi_m`!=0) %>%
          summarise(beta = summary(lm(B4181~B4171))$coefficients[2,1],
                    lower.limit = beta - mi_se.dirty(B4181)*1.96,
                    upper.limit = beta + mi_se.dirty(B4181)*1.96)
        
        #SE completely neglect MI-structure -> 1. no consideration of the increased number of cases / 2. no between-component
        mi.fk %>%
          filter(`_mi_m`!=0) %>%
          summarise(beta = summary(lm(B4181~B4171))$coefficients[2,1],
                    lower.limit = beta - stderror(B4181)*1.96,
                    upper.limit = beta + stderror(B4181)*1.96)
        
        mi.fk %>%
          filter(`_mi_m`!=0) %>%
          {summary(lm(B4181~B4171, data=.))}

#--------------------------------------------------------------------#   
  
