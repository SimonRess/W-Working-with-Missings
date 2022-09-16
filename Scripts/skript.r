---
title: "R Notebook"
output: html_notebook
---

This is an [R Markdown](http://rmarkdown.rstudio.com) Notebook. When you execute code within the notebook, the results appear beneath the code. 

Try executing this chunk by clicking the *Run* button within the chunk or by placing your cursor inside it and pressing *Ctrl+Shift+Enter*. 

```{r}
if(!require(mice)) install.packages("mice")
library(mice)




for(i in 1:4000){
set.seed(415)
  
Mann = ifelse(runif(5000,0,1) < 0.50, 1, 0)
Alter = as.numeric(cut(runif(5000,20,70), c(20,30,40,50,60,70)))

FK = ifelse((Mann*0.2 + Alter*0.1 + runif(5000,0,0.6)) > 0.95, 1, 0)
mean(FK, na.rm = T)
lm(FK~Mann+Alter)
m = lm(FK~Mann+Alter)$coefficients["Mann"]
a = lm(FK~Mann+Alter)$coefficients["Alter"]
if(m>0.2 & m<0.201 & a>0.1 & a<0.101) print(i)
}


set.seed(415)
  
Mann = ifelse(runif(5000,0,1) < 0.50, 1, 0)
Alter = as.numeric(cut(runif(5000,20,70), c(20,30,40,50,60,70)))

FK = ifelse((Mann*0.2 + Alter*0.1 + runif(5000,0,0.6)) > 0.95, 1, 0)
lm(FK~Mann+Alter)

B2.1 = as.numeric(cut(FK*2 + rnorm(5000,2,0.35), c(0,1,2,3,4,6)))
lm(B2.1~FK)

for(i in 1:3000){
set.seed(i)
B5.1 = as.numeric(cut(FK*1.5 + B2.1*0.2 + Alter*(-0.30) + rnorm(5000,3.55,0.70), c(-2,1,2,3,4,8)))
f= lm(B5.1~FK+Alter)$coefficients["FK"]
a= lm(B5.1~FK+Alter)$coefficients["Alter"]
b= lm(B5.1~B2.1+FK)$coefficients["B2.1"]
if(f>1.5 & m<1.51 & a> (-0.3) & a< (-0.31) & b>0.2 & b<0.21) print(i)
}






ds_mcar <- delete_MCAR(ds_comp, 0.3, "X")
make_simple_MDplot(ds_comp, ds_mcar)

```

Add a new chunk by clicking the *Insert Chunk* button on the toolbar or by pressing *Ctrl+Alt+I*.

When you save the notebook, an HTML file containing the code and output will be saved alongside it (click the *Preview* button or press *Ctrl+Shift+K* to preview the HTML file).

The preview shows you a rendered HTML copy of the contents of the editor. Consequently, unlike *Knit*, *Preview* does not run any R code chunks. Instead, the output of the chunk when it was last run in the editor is displayed.
