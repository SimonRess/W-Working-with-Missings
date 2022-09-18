---
title: |
       <center>
       ![](Slides_files/RUB.jpg){width=2.5in}
       </center>
subtitle:  "Multiple Imputation and subsequent calculations"
author: "Simon Ress | Ruhr-Universität Bochum"
institute: "Workshop at hr&c, Bochum, 2021"
date: "September 22, 2022"

fontsize: 10pt

output:
  beamer_presentation:
    keep_md: true
    keep_tex: no
    latex_engine: xelatex
    #theme: metropolis
    slide_level: 2 # which header level should be printed as slides
    incremental: no
header-includes:
  - \usetheme[numbering=fraction]{metropolis}
#Define footer:
  - \definecolor{beaublue}{RGB}{182, 203, 201} #{0.74, 0.83, 0.9}
  - \setbeamertemplate{frame footer}{\tiny{\textcolor{beaublue}{Workshop Multiple Imputation and subsequent calculations (at hr\&c),  2022 | SIMON RESS}}}
#hide footer on title page:
  - |
    \makeatletter
    \def\ps@titlepage{%
      \setbeamertemplate{footline}{}
    }
    \addtobeamertemplate{title page}{\thispagestyle{titlepage}}{}
    \makeatother
#show footer on section's start/title pages:
  #overwrite "plain,c,noframenumbering" in section pages definition -> enables footer:
  - |
    \makeatletter
    \renewcommand{\metropolis@enablesectionpage}{
      \AtBeginSection{
        \ifbeamer@inframe
          \sectionpage
        \else
          \frame[c]{\sectionpage}
        \fi
      }
    }
    \metropolis@enablesectionpage
    \makeatother
  #define footer of section pages:
  - |
    \makeatletter
    \def\ps@sectionpage{%
      \setbeamertemplate{frame footer}{\tiny{\textcolor{beaublue}{Conference 56. Jahrestagung der DGSMP, 2021 | SIMON RESS}}}
    }
    \addtobeamertemplate{section page}{\thispagestyle{sectionpage}}{}
    \makeatother
#add secrtion numbers to TOC:
  - |
    \setbeamertemplate{section in toc}{
    \leavevmode%
    \inserttocsectionnumber. 
    \inserttocsection\par%
    }
    \setbeamertemplate{subsection in toc}{
    \leavevmode\leftskip=2.5em\inserttocsubsection\par     }
#Adjust representation of chunks
  #Reduce space between code chunks and code output
  - |
    \setlength{\OuterFrameSep}{-4pt}
    \makeatletter
    \preto{\@verbatim}{\topsep=-10pt \partopsep=-10pt }
    \makeatother
  #Change background-color of source-code
  - \definecolor{shadecolor}{RGB}{240,240,240}
  #Set a frame around the results
  - | 
    \let\verbatim\undefined
    \let\verbatimend\undefined
    \DefineVerbatimEnvironment{verbatim}{Verbatim}{frame=single, rulecolor=\color{shadecolor}, framerule=0.3mm,framesep=1mm}
---




## Content
\tableofcontents[]

# Examplary Data Set

## Planing the interdependencies of variables

- Every variable is constructed by an *random term*
- Some variables are influenced by *values of other variables*
- **e.g. "Mann" = 1 increases the probability for FK=1 by 20%**


\includegraphics[width=1\linewidth,height=0.9\textheight]{Slides_files/figure-beamer/planing-dataset-creation-1} 



## Data Set Creation

\footnotesize

```r
#Create variables
set.seed(415)
Mann = ifelse(runif(5000,0,1) < 0.50, 1, 0)
Alter = as.numeric(cut(runif(5000,20,70), 
                       c(20,30,40,50,60,70)))
FK = ifelse((Mann*0.2 + Alter*0.1 + 
             runif(5000,0,0.6)) > 0.95, 1, 0)
B2.1 = as.numeric(cut(FK*2 + 
                      rnorm(5000,2,0.35), c(0,1,2,3,4,6)))
set.seed(1015)
B5.1 = as.numeric(cut(FK*1.5 + B2.1*0.2 + Alter*(-0.30) + 
                      rnorm(5000,2.5,0.30), c(-2,1,2,3,4,8)))

#Build data frame
df = data.frame(Mann, Alter, FK, B2.1, B5.1)
```
\normalsize


## View Data Set

```r
head(df,10)
```

```
##    Mann Alter FK B2.1 B5.1
## 1     0     4  0    2    2
## 2     0     4  0    1    2
## 3     1     5  0    3    2
## 4     1     5  1    4    3
## 5     0     4  0    2    2
## 6     1     3  1    4    4
## 7     0     3  0    3    3
## 8     0     1  0    3    3
## 9     0     4  0    2    2
## 10    0     2  0    2    3
```


## I. Check whether true effects can be estimated
\scriptsize

Table: lm(FK~Mann) | Mann: +0.2

|            | Estimate| Std. Error| t value| Pr(>&#124;t&#124;)|
|:-----------|--------:|----------:|-------:|------------------:|
|(Intercept) |   0.0596|     0.0070|  8.5438|                  0|
|Mann        |   0.2001|     0.0099| 20.1491|                  0|



Table: lm(FK~Alter) | Alter: +0.1

|            | Estimate| Std. Error|  t value| Pr(>&#124;t&#124;)|
|:-----------|--------:|----------:|--------:|------------------:|
|(Intercept) |  -0.1406|     0.0110| -12.7686|                  0|
|Alter       |   0.1002|     0.0033|  30.0803|                  0|



Table: lm(B2.1~FK) | FK: +2

|            | Estimate| Std. Error|  t value| Pr(>&#124;t&#124;)|
|:-----------|--------:|----------:|--------:|------------------:|
|(Intercept) |   2.4980|     0.0079| 318.0197|                  0|
|FK          |   2.0115|     0.0197| 101.8565|                  0|
\normalsize


## II. Check whether true effects can be estimated (!)
\scriptsize

Table: lm(B5.1~FK) | FK: +1.5

|            | Estimate| Std. Error|  t value| Pr(>&#124;t&#124;)|
|:-----------|--------:|----------:|--------:|------------------:|
|(Intercept) |   2.6745|     0.0088| 302.2230|                  0|
|FK          |   1.4519|     0.0222|  65.2572|                  0|



Table: lm(B5.1~B2.1) | B2.1: +0.2

|            | Estimate| Std. Error| t value| Pr(>&#124;t&#124;)|
|:-----------|--------:|----------:|-------:|------------------:|
|(Intercept) |   1.3494|     0.0283| 47.6337|                  0|
|B2.1        |   0.5521|     0.0096| 57.5786|                  0|



Table: lm(B5.1~Alter) | Alter: -0.3

|            | Estimate| Std. Error|  t value| Pr(>&#124;t&#124;)|
|:-----------|--------:|----------:|--------:|------------------:|
|(Intercept) |   3.2286|     0.0251| 128.6139|                  0|
|Alter       |  -0.1088|     0.0076| -14.3234|                  0|
\normalsize


## Excursus: Modern Causal Analysis

- Satisfaction of the Conditional Independence Assumption (CIA) necessary to estimate true causal effects
- Meet the CIA using an appropriate set of control variables
- Choose control variables by a Directed Acyclic Graph (DAG)


## Excursus MCA: DAG (B5.1 <- FK)
\scriptsize
![](Slides_files/figure-beamer/DAG1-1.pdf)<!-- --> 

Table: lm(B5.1~FK+B2.1+Alter) | FK: +1.5

|            | Estimate| Std. Error| t value| Pr(>&#124;t&#124;)|
|:-----------|--------:|----------:|-------:|------------------:|
|(Intercept) |   2.9909|     0.0311| 96.2506|                  0|
|FK          |   1.5033|     0.0283| 53.1769|                  0|
\normalsize


## Excursus MCA: DAG (B5.1 <- B2.1)
\scriptsize
![](Slides_files/figure-beamer/DAG2-1.pdf)<!-- --> 

Table: lm(B5.1~B2.1+FK+Alter) | B2.1: +0.2

|            | Estimate| Std. Error| t value| Pr(>&#124;t&#124;)|
|:-----------|--------:|----------:|-------:|------------------:|
|(Intercept) |   2.9909|     0.0311| 96.2506|                  0|
|B2.1        |   0.2031|     0.0112| 18.0842|                  0|
\normalsize


## Excursus MCA: DAG (B5.1 <- Alter)
\scriptsize
![](Slides_files/figure-beamer/DAG3-1.pdf)<!-- --> 

Table: lm(B5.1~Alter+FK+B2.1) | Alter: -0.3

|            | Estimate| Std. Error|  t value| Pr(>&#124;t&#124;)|
|:-----------|--------:|----------:|--------:|------------------:|
|(Intercept) |   2.9909|     0.0311|  96.2506|                  0|
|Alter       |  -0.3007|     0.0044| -68.9450|                  0|
\normalsize


# Missing Patterns

## Missing Patterns: Missing completely at random (MCAR)

- Values are randomly missing in the dataset
  - Missing data values do not relate to any other data
  - There is no pattern to the actual values of the missing data themselves
- For instance, when smoking status is not recorded in a random subset of patients
- This is easy to handle, but unfortunately, data are almost never missing completely at random

## MCAR: Inserting Missing values in data frame


## Missing Patterns: Missing at random (MAR)

- Confusing and would be better stated as *missing conditionally at random*
- Missing data do have a relationship with other variables in the dataset
  - Whether a value is missing or not depends on other variables
- The actual values that are missing are random
- For example, smoking status is not documented in female patients because the doctor was too shy to ask


## Missing Patterns: Missing not at random (MNAR)

- The pattern of missingness is related to other variables in the dataset 
- In addition, the values of the missing data are not random
  - Whether a value is missing or not depends on other variables
- For example, when smoking status is not recorded in patients admitted as an emergency, who are also more likely to have worse outcomes from surgery



## Main Repos

- [Official GitHub Repo of Metropolis](https://github.com/matze/mtheme)
  (formerly mtheme); older version in TeXLive 
- [My GitHub Repo for a local Ubuntu package of Metropolis](https://github.com/eddelbuettel/pkg-latex-metropolis) -- formerly mtheme
- [Manuel](https://mirror.physik.tu-berlin.de/pub/CTAN/macros/latex/contrib/beamer-contrib/themes/metropolis/doc/metropolistheme.pdf)

## Slide with Bullets

- Bullet 1
- Bullet 2
- Bullet 3

# Slide with R Output


```r
summary(cars)
```

```
##      speed           dist       
##  Min.   : 4.0   Min.   :  2.00  
##  1st Qu.:12.0   1st Qu.: 26.00  
##  Median :15.0   Median : 36.00  
##  Mean   :15.4   Mean   : 42.98  
##  3rd Qu.:19.0   3rd Qu.: 56.00  
##  Max.   :25.0   Max.   :120.00
```

## Slide with Plot

![](Slides_files/figure-beamer/pressure-1.pdf)<!-- --> 



## Two column layout

Here is some text above which goes over to whole slide

<!-- -------------------------- -->
<!-- Start of two column layout -->

:::::::::::::: {.columns}
::: {.column width="50%"}

![](Slides_files/figure-beamer/AirPassengers-1.pdf)<!-- --> 

:::
::: {.column width="50%"}

- Description of plot
- Second point

:::
::::::::::::::

<!-- End of two column layout -->
<!-- ------------------------ -->


and here some text below which goes over to whole slide


<!-- Create new page without title -->
_ _ _  

\LARGE Breakout page

# Figures caption

\begin{figure}

{\centering \includegraphics[width=0.8\linewidth]{Slides_files/RUB} 

}

\caption{Figure: Here is a really important caption.}\label{fig:unnamed-chunk-1}
\end{figure}

## Using LaTeX Parts: Blocks

As one example of falling back into \LaTeX, consider the example of
three different block environments are pre-defined and may be styled
with an optional background color.

<!-- this sets the background -->
\metroset{block=fill} 

\begin{block}{Default}
  Block content.
\end{block}

\begin{alertblock}{Alert}
  Block content.
\end{alertblock}

\begin{exampleblock}{Example}
  Block content.
\end{exampleblock}
