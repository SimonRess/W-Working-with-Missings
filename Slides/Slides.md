---
title: |
       <center>
       ![](Slides_files/RUB.jpg){width=2.5in}
       </center>
subtitle:  "Multiple Imputation and subsequent calculations"
author: "Simon Ress | Ruhr-Universität Bochum"
institute: "Workshop at hr c, Bochum, 2021"
date: "September 22, 2022"

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
  - \setbeamertemplate{frame footer}{\tiny{\textcolor{beaublue}{Workshop Multiple Imputation and subsequent calculations (at hr c),  2022 | SIMON RESS}}}
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

# Metropolis theme

## Main Repos

- [Official GitHub Repo of Metropolis](https://github.com/matze/mtheme)
  (formerly mtheme); older version in TeXLive 
- [My GitHub Repo for a local Ubuntu package of Metropolis](https://github.com/eddelbuettel/pkg-latex-metropolis) -- formerly mtheme
- [Manuel](https://mirror.physik.tu-berlin.de/pub/CTAN/macros/latex/contrib/beamer-contrib/themes/metropolis/doc/metropolistheme.pdf) 

## Customization

test

# Examplary usage

Test

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
