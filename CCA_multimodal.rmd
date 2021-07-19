---
title: "CCA in Huntingtons disease"
author: "Pablo Iriso Soret"
date: "`r format(Sys.time(), '%d %B, %Y')`"
output:
  pdf_document: default
  html_document:
    df_print: paged
subtitle: IDIBELL - UOC practices
institute: Universitat Oberta de Catalunya
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```


```{r, echo=F,message=F,warning=F,comment=F}
library(xlsx)
library(CCA)
library(CCP)  # for sig test (Wilks)
library(plyr) # for permutation (Xia et al., 2018)
library(dplyr) # reordering variables
library(ggplot2)
library(ggpmisc)# statpolyeq
library(fdcov) # perm.plot
library(binovisualfields) # U vs. V plot legend
library(itsadug) 
library(corrplot)
library(mvnormtest)
library(nlme) # hierarchical linear modeling
library(dplyr) # outliers
library(tidyr) # outliers
library(purrr) # outliers
library(Hmisc)
library(PerformanceAnalytics)
library(naniar) #replace with NA
library(tidyverse)
library(rmarkdown)
library(knitr)
library(listviewer)
# library(kableExtra)
library(captioner)
library(CCP)  # for sig test (Wilks)
library(pander)
library(kableExtra)

ind.tabla<-1
ind.figura<-0
table_nums <- captioner(prefix = "Tabla.")
```


Huntington disease is a progressive brain disorder that causes uncontrolled movements, emotional problems, and cognitive problems, including apathy. We want to acknowledge the relationship between clinical apathy, and physioligical traits.

In order to do this we calculated the tracts using probabilistic tractography with FSL software. Then we performed a canonical correlation analysis for this two sets of variables (clinical and physiological). The basic CCA scenario consists of two latent variables, which are both proxied by linear combinations of multiple observable indicators.

We got significant evidence of the correlation between clinical apathy and tracts in different areas of the brain. 
 


```{r, echo=FALSE, message=FALSE, warning=FALSE}
# We define our working directory and load the df.excel
setwd('C:/Datasets/Tracts')
df.excel <- read.xlsx("CCA_matrix.xlsx", sheetIndex=1)
```

```{r, echo=FALSE, message=FALSE, warning=FALSE}
# We now load FA values obtained in the study, both exclusion and no exclusion.
setwd('C:/Datasets/Tracts/WM')
IEAL <- read.csv(file='Initial_Exclusion_accumbens_left.csv', sep = "")[,2]
IEAR <- read.csv(file='Initial_Exclusion_accumbens_right.csv', sep = "")[,2]
IECL <- read.csv(file='Initial_Exclusion_caudate_left.csv', sep = "")[,2]
IECR <- read.csv(file='Initial_Exclusion_caudate_right.csv', sep = "")[,2]
IEPL <- read.csv(file='Initial_Exclusion_putamen_left.csv', sep = "")[,2]
IEPR <- read.csv(file='Initial_Exclusion_putamen_right.csv', sep = "")[,2]
InEAL <- read.csv(file='Initial_No_Exclusion_accumbens_left.csv', sep = "")[,2]
InEAR <- read.csv(file='Initial_No_Exclusion_accumbens_right.csv', sep = "")[,2]
InECL <- read.csv(file='Initial_No_Exclusion_caudate_left.csv', sep = "")[,2]
InECR <- read.csv(file='Initial_No_Exclusion_caudate_right.csv', sep = "")[,2]
InEPL <- read.csv(file='Initial_No_Exclusion_putamen_left.csv', sep = "")[,2]
InEPR <- read.csv(file='Initial_No_Exclusion_putamen_right.csv', sep = "")[,2]
```

```{r, echo=FALSE, message=FALSE, warning=FALSE}
# We create a new dataframe with FA values, and select only those belonging to patients
wm <- as.data.frame(cbind(IEAL,IEAR,IECL,IECR,IEPL,IEPR,InEAL,InEAR,InECL,InECR,InEPL,InEPR))
wm <- wm[33:73,]

# Merge both dataframes
df.excel <- df.excel[-c(32,40,43,45,46), ] 
df.excel <- as.data.frame(cbind(df.excel,wm))

# Replace missing values with median
for(i in which(sapply(df.excel, is.numeric))){  # 1:ncol(df)
  df.excel[is.na(df.excel[,i]), i] <- median(df.excel[,i], na.rm = TRUE)
}

# Relocate some variables
data <- df.excel %>% relocate(CAG, Sex, Education_yrs, age, cap, dis_burden, .after = last_col())

# Calculate TIV values
data$Left_Caudate_tiv <- data$Left_Caudate / data$TIV
data$Left_Putamen_tiv <- data$Left_Putamen / data$TIV
data$Left_Accumbens_area_tiv <- data$Left_Accumbens_area / data$TIV
data$Right_Caudate_tiv <- data$Right_Caudate / data$TIV
data$Right_Putamen_tiv <- data$Right_Putamen / data$TIV
data$Right_Accumbens_area_tiv <- data$Right_Accumbens_area / data$TIV

# Scale values
scaled.df <- scale(data[,5:133])

# Create replace outliers function
replace_outlier_with_mean <- function(x) {
  replace(x, x %in% boxplot.stats(x)$out, mean(x))  
}
```


```{r, echo=FALSE, message=FALSE, warning=FALSE}
# Now we are going to create the two sets of variables we are going to use in the CCA
# First we have clin, with clinical variables
# Secondly we have mri with resonance image values, for FA, rs and TIV. 
clin <- as.data.frame(scaled.df[,c(87,88,89)], drop=FALSE)
mri <- as.data.frame(scaled.df[,c(48:53,124:129,106:111,112:117)], drop=FALSE) # Here we have resting + tiv + FA both exclusion and no exclusion
# We also add cap variable, which would later control for previous the CCA
cap <- as.data.frame(scaled.df[,c(122)], drop=FALSE)

#Merge dataframes and change name
total <- cbind(clin, mri, cap)
colnames(total)[28] <- "cap"

#Remove outliers using function previously created
total <- as.data.frame(total) %>% mutate(across(.fns = replace_outlier_with_mean))

#control for cap
# We do this by performing an linear model between cap and each of the mri variables
# We will later perform the CCA between clin and the residues of this models. The residues
# represent variability not explained by cap
total_cap4 <- lm(cap~as.numeric(unlist(total[4])), data=total)
total_cap5 <- lm(cap~as.numeric(unlist(total[5])), data=total)
total_cap6 <- lm(cap~as.numeric(unlist(total[6])), data=total)
total_cap7 <- lm(cap~as.numeric(unlist(total[7])), data=total)
total_cap8 <- lm(cap~as.numeric(unlist(total[8])), data=total)
total_cap9 <- lm(cap~as.numeric(unlist(total[9])), data=total)
total_cap10 <- lm(cap~as.numeric(unlist(total[10])), data=total)
total_cap11 <- lm(cap~as.numeric(unlist(total[11])), data=total)
total_cap12 <- lm(cap~as.numeric(unlist(total[12])), data=total)
total_cap13 <- lm(cap~as.numeric(unlist(total[13])), data=total)
total_cap14 <- lm(cap~as.numeric(unlist(total[14])), data=total)
total_cap15 <- lm(cap~as.numeric(unlist(total[15])), data=total)
total_cap16 <- lm(cap~as.numeric(unlist(total[16])), data=total)
total_cap17 <- lm(cap~as.numeric(unlist(total[17])), data=total)
total_cap18 <- lm(cap~as.numeric(unlist(total[18])), data=total)
total_cap19 <- lm(cap~as.numeric(unlist(total[19])), data=total)
total_cap20 <- lm(cap~as.numeric(unlist(total[20])), data=total)
total_cap21 <- lm(cap~as.numeric(unlist(total[21])), data=total)
total_cap22 <- lm(cap~as.numeric(unlist(total[22])), data=total)
total_cap23 <- lm(cap~as.numeric(unlist(total[23])), data=total)
total_cap24 <- lm(cap~as.numeric(unlist(total[24])), data=total)
total_cap25 <- lm(cap~as.numeric(unlist(total[25])), data=total)
total_cap26 <- lm(cap~as.numeric(unlist(total[26])), data=total)
total_cap27 <- lm(cap~as.numeric(unlist(total[27])), data=total)

#Now we have the variance not explained by cap for each of the mri variables
#Create df with those variables
total_cap <- as.data.frame(cbind(total_cap4$residuals,total_cap5$residuals,total_cap6$residuals,total_cap7$residuals,total_cap8$residuals,total_cap9$residuals,total_cap10$residuals,total_cap11$residuals,total_cap12$residuals,total_cap13$residuals,total_cap14$residuals,total_cap15$residuals,total_cap16$residuals,total_cap17$residuals,total_cap18$residuals,total_cap19$residuals,total_cap20$residuals,total_cap21$residuals,total_cap22$residuals,total_cap23$residuals,total_cap24$residuals,total_cap25$residuals,total_cap26$residuals,total_cap27$residuals))

#rename columns of residuals
colnames(total_cap) <- colnames(total[4:27])
# Now we have all our variables with outliers removed and controlled for cap
```


## CCA for mri (FA, rs, TIV) ~ Clinical


### Exclusion

```{r, echo=FALSE, message=FALSE, warning=FALSE}
# We create the CCA  as total.cc
total_cc <- cc(as.data.frame(total_cap[,c(1:18)]), as.data.frame(total[,c(1, 2, 3)], drop=FALSE))
# Now we get the variability explain 

total_cc$cor %>%
  kable(col.names = "Coeficientes de correlación")
# We now get how much variability is explained by each of the 
expl_var <- (total_cc$cor)^2
expl_var %>%
  kable(col.names = "Variabilidad explicada")
#Correlation coefficients
pander(total_cc [3:4])

total_cc1 <- comput(total_cap[,c(1:18)],total[,c(1, 2, 3)], total_cc)
```


# Statistical Test

```{r, echo=FALSE, message=FALSE, warning=FALSE}
#Statistical test
rho <- total_cc$cor # tests of canonical dimensions
## Define number of observations, number of variables in first set, and number of variables in the second set.
n <- dim(total_cap[,c(1:18)])[1] # mri
p <- length(total_cap[,c(1:18)]) # mri
q <- length(total[,c(1, 2, 3)])  # clin

## Calculate p-values using the F-approximations of different test statistics:
results <- p.asym(rho, n, p, q, tstat = "Wilks") 
lambda <-  results$stat[1]
R <-  1 - lambda
R %>%
  kable(col.names = "R value")

# Save output as txt
X_xscores <- total_cc1$corr.X.xscores[,]
Y_yscores <- total_cc1$corr.Y.yscores[,]
#capture.output(X_xscores, file = "cc1_multimodal_X.txt")
#capture.output(Y_yscores, file = "cc1_multimodal_Y.txt")


# # standardized canonical coefficients (diagonal matrix of SDs) 
# s1 <- diag(sqrt(diag(cov(clin))))
# s_cc1 <- s1 %*% cc1$xcoef  ### Now S_CC1 = NAs -- I think it had to do with the NAs previously, particularly psychosis var
# s2 <- diag(sqrt(diag(cov(mri))))
# s_cc2 <- s2 %*% cc1$ycoef
```




```{r, echo=FALSE, message=FALSE, warning=FALSE}
#(https://cmdlinetips.com/2020/12/canonical-correlation-analysis-in-r/)
# We can use our data sets X & Y and the corresponding coefficients to get the canonical covariate pairs. In the code below, we perform matrix multiplication with each data sets and its first (and second separately) coefficient column to get the first canonical covariate pairs.

CC1_X <- as.matrix(total_cap[,c(1:18)]) %*% total_cc$xcoef[, 1]
CC1_Y <- as.matrix(total[,c(1, 2, 3)]) %*% total_cc$ycoef[, 1]

CC2_X <- as.matrix(total_cap[,c(1:18)]) %*% total_cc$xcoef[, 2]
CC2_Y <- as.matrix(total[,c(1, 2, 3)]) %*% total_cc$ycoef[, 2]

cor(CC1_X,CC1_Y)
```


```{r, echo=FALSE, message=FALSE, warning=FALSE, fig.width=4,fig.height=4}
# Create graph variable
cca_df <- total_cap %>% 
  mutate(CC1_X=CC1_X,
         CC1_Y=CC1_Y,
         CC2_X=CC2_X,
         CC2_Y=CC2_Y)
#Plot the graph
cca_df %>% 
  ggplot(aes(x=CC1_X,y=CC1_Y))+
  geom_point(color="darkblue", size=2)+
  ggtitle("Correlation between the first pair of canonical covariates")
```



### No exclusion

```{r, echo=FALSE, message=FALSE, warning=FALSE}
total_cc2 <- cc(as.data.frame(total_cap[,c(1:12,19:23)]), as.data.frame(total[,c(1, 2, 3)], drop=FALSE))
total_cc2$cor %>%
  kable(col.names = "Coeficientes de correlación")


expl_var <- (total_cc2$cor)^2
expl_var %>%
  kable(col.names = "Variabilidad explicada")

pander(total_cc2[3:4])
```


# Statistical Test

```{r, echo=FALSE, message=FALSE, warning=FALSE}
#Statistical test
rho <- total_cc2$cor # tests of canonical dimensions
## Define number of observations, number of variables in first set, and number of variables in the second set.
n <- dim(total_cap[,c(1:12,19:23)])[1] # mri
p <- length(total_cap[,c(1:12,19:23)]) # mri
q <- length(total[,c(1, 2, 3)])  # clin

## Calculate p-values using the F-approximations of different test statistics:
results <- p.asym(rho, n, p, q, tstat = "Wilks") 
lambda <-  results$stat[1]
R <-  1 - lambda
R %>%
  kable(col.names = "R value")

# Save output as txt
X_xscores <- total_cc1$corr.X.xscores[,]
Y_yscores <- total_cc1$corr.Y.yscores[,]

```


```{r, echo=FALSE, message=FALSE, warning=FALSE}
#(https://cmdlinetips.com/2020/12/canonical-correlation-analysis-in-r/)
# We can use our data sets X & Y and the corresponding coefficients to get the canonical covariate pairs. In the code below, we perform matrix multiplication with each data sets and its first (and second separately) coefficient column to get the first canonical covariate pairs.

CC1_X <- as.matrix(total_cap[,c(1:12,19:23)]) %*% total_cc2$xcoef[, 1]
CC1_Y <- as.matrix(total[,c(1, 2, 3)]) %*% total_cc2$ycoef[, 1]

CC2_X <- as.matrix(total_cap[,c(1:12,19:23)]) %*% total_cc2$xcoef[, 2]
CC2_Y <- as.matrix(total[,c(1, 2, 3)]) %*% total_cc2$ycoef[, 2]

cor(CC1_X,CC1_Y)
```


```{r, echo=FALSE, message=FALSE, warning=FALSE, fig.width=4,fig.height=4}
cca_df <- total_cap %>% 
  mutate(CC1_X=CC1_X,
         CC1_Y=CC1_Y,
         CC2_X=CC2_X,
         CC2_Y=CC2_Y)

cca_df %>% 
  ggplot(aes(x=CC1_X,y=CC1_Y))+
  geom_point(color="darkblue", size=2)+
  ggtitle("Correlation between the first pair of canonical covariates")
```



## CCA for MRI (RD, rs, TIV) ~ Clínicas


```{r, echo=FALSE, message=FALSE, warning=FALSE}
setwd('C:/Datasets/Tracts/WM')
IEAL <- read.csv(file='Initial_Exclusion_accumbens_left.csv', sep = "")[,3]
IEAR <- read.csv(file='Initial_Exclusion_accumbens_right.csv', sep = "")[,3]
IECL <- read.csv(file='Initial_Exclusion_caudate_left.csv', sep = "")[,3]
IECR <- read.csv(file='Initial_Exclusion_caudate_right.csv', sep = "")[,3]
IEPL <- read.csv(file='Initial_Exclusion_putamen_left.csv', sep = "")[,3]
IEPR <- read.csv(file='Initial_Exclusion_putamen_right.csv', sep = "")[,3]
InEAL <- read.csv(file='Initial_No_Exclusion_accumbens_left.csv', sep = "")[,3]
InEAR <- read.csv(file='Initial_No_Exclusion_accumbens_right.csv', sep = "")[,3]
InECL <- read.csv(file='Initial_No_Exclusion_caudate_left.csv', sep = "")[,3]
InECR <- read.csv(file='Initial_No_Exclusion_caudate_right.csv', sep = "")[,3]
InEPL <- read.csv(file='Initial_No_Exclusion_putamen_left.csv', sep = "")[,3]
InEPR <- read.csv(file='Initial_No_Exclusion_putamen_right.csv', sep = "")[,3]
```

```{r, echo=FALSE, message=FALSE, warning=FALSE}
wm <- as.data.frame(cbind(IEAL,IEAR,IECL,IECR,IEPL,IEPR,InEAL,InEAR,InECL,InECR,InEPL,InEPR))
wm <- wm[33:73,]

# Merge dataframes
df.excel <- as.data.frame(cbind(df.excel,wm))

# Replace missing values with median
for(i in which(sapply(df.excel, is.numeric))){  # 1:ncol(df)
  df.excel[is.na(df.excel[,i]), i] <- median(df.excel[,i], na.rm = TRUE)
}

data <- df.excel %>% relocate(CAG, Sex, Education_yrs, age, cap, dis_burden, .after = last_col())

# Obtenemos variables
data$Left_Caudate_tiv <- data$Left_Caudate / data$TIV
data$Left_Putamen_tiv <- data$Left_Putamen / data$TIV
data$Left_Accumbens_area_tiv <- data$Left_Accumbens_area / data$TIV
data$Right_Caudate_tiv <- data$Right_Caudate / data$TIV
data$Right_Putamen_tiv <- data$Right_Putamen / data$TIV
data$Right_Accumbens_area_tiv <- data$Right_Accumbens_area / data$TIV

#scale 
scaled.df <- scale(data[,5:133])
```


```{r, echo=FALSE, message=FALSE, warning=FALSE}
# Create dataframes
clin <- as.data.frame(scaled.df[,c(87,88,89)], drop=FALSE)
mri <- as.data.frame(scaled.df[,c(48:53,124:129,106:111,112:117)], drop=FALSE) 
# Here we have resting + tiv + FA both exclusion and no exclusion
cap <- as.data.frame(scaled.df[,c(122)], drop=FALSE)

total <- cbind(clin, mri, cap)
colnames(total)[28] <- "cap"

#Remove outliers
total <- as.data.frame(total) %>% mutate(across(.fns = replace_outlier_with_mean))

#control for cap
total_cap4 <- lm(cap~as.numeric(unlist(total[4])), data=total)
total_cap5 <- lm(cap~as.numeric(unlist(total[5])), data=total)
total_cap6 <- lm(cap~as.numeric(unlist(total[6])), data=total)
total_cap7 <- lm(cap~as.numeric(unlist(total[7])), data=total)
total_cap8 <- lm(cap~as.numeric(unlist(total[8])), data=total)
total_cap9 <- lm(cap~as.numeric(unlist(total[9])), data=total)
total_cap10 <- lm(cap~as.numeric(unlist(total[10])), data=total)
total_cap11 <- lm(cap~as.numeric(unlist(total[11])), data=total)
total_cap12 <- lm(cap~as.numeric(unlist(total[12])), data=total)
total_cap13 <- lm(cap~as.numeric(unlist(total[13])), data=total)
total_cap14 <- lm(cap~as.numeric(unlist(total[14])), data=total)
total_cap15 <- lm(cap~as.numeric(unlist(total[15])), data=total)
total_cap16 <- lm(cap~as.numeric(unlist(total[16])), data=total)
total_cap17 <- lm(cap~as.numeric(unlist(total[17])), data=total)
total_cap18 <- lm(cap~as.numeric(unlist(total[18])), data=total)
total_cap19 <- lm(cap~as.numeric(unlist(total[19])), data=total)
total_cap20 <- lm(cap~as.numeric(unlist(total[20])), data=total)
total_cap21 <- lm(cap~as.numeric(unlist(total[21])), data=total)
total_cap22 <- lm(cap~as.numeric(unlist(total[22])), data=total)
total_cap23 <- lm(cap~as.numeric(unlist(total[23])), data=total)
total_cap24 <- lm(cap~as.numeric(unlist(total[24])), data=total)
total_cap25 <- lm(cap~as.numeric(unlist(total[25])), data=total)
total_cap26 <- lm(cap~as.numeric(unlist(total[26])), data=total)
total_cap27 <- lm(cap~as.numeric(unlist(total[27])), data=total)

#Now we have the variance not explained by cap for each of the mri variables
#Create df with those variables
total_cap <- as.data.frame(cbind(total_cap4$residuals,total_cap5$residuals,total_cap6$residuals,total_cap7$residuals,total_cap8$residuals,total_cap9$residuals,total_cap10$residuals,total_cap11$residuals,total_cap12$residuals,total_cap13$residuals,total_cap14$residuals,total_cap15$residuals,total_cap16$residuals,total_cap17$residuals,total_cap18$residuals,total_cap19$residuals,total_cap20$residuals,total_cap21$residuals,total_cap22$residuals,total_cap23$residuals,total_cap24$residuals,total_cap25$residuals,total_cap26$residuals,total_cap27$residuals))

#rename columns of residuals
colnames(total_cap) <- colnames(total[4:27])
# Now we have all our variables with outliers removed and controlled for cap
```


### Exclusion

```{r, echo=FALSE, message=FALSE, warning=FALSE}
total_cc <- cc(as.data.frame(total_cap[,c(1:18)]), as.data.frame(total[,c(1, 2, 3)], drop=FALSE))
total_cc$cor %>%
  kable(col.names = "Coeficientes de correlación")

expl_var <- (total_cc$cor)^2
expl_var %>%
  kable(col.names = "Variabilidad explicada") 

pander(total_cc[3:4])
```

# Statistical Test

```{r, echo=FALSE, message=FALSE, warning=FALSE}
#Statistical test
rho <- total_cc$cor # tests of canonical dimensions
## Define number of observations, number of variables in first set, and number of variables in the second set.
n <- dim(total_cap[,c(1:18)])[1] # mri
p <- length(total_cap[,c(1:18)]) # mri
q <- length(total[,c(1, 2, 3)])  # clin

## Calculate p-values using the F-approximations of different test statistics:
results <- p.asym(rho, n, p, q, tstat = "Wilks") 
lambda <-  results$stat[1]
R <-  1 - lambda
R %>%
  kable(col.names = "R value")
```


```{r, echo=FALSE, message=FALSE, warning=FALSE}
#(https://cmdlinetips.com/2020/12/canonical-correlation-analysis-in-r/)
# We can use our data sets X & Y and the corresponding coefficients to get the canonical covariate pairs. In the code below, we perform matrix multiplication with each data sets and its first (and second separately) coefficient column to get the first canonical covariate pairs.

CC1_X <- as.matrix(total_cap[,c(1:18)]) %*% total_cc$xcoef[, 1]
CC1_Y <- as.matrix(total[,c(1, 2, 3)]) %*% total_cc$ycoef[, 1]

CC2_X <- as.matrix(total_cap[,c(1:18)]) %*% total_cc$xcoef[, 2]
CC2_Y <- as.matrix(total[,c(1, 2, 3)]) %*% total_cc$ycoef[, 2]

cor(CC1_X,CC1_Y)
```


```{r, echo=FALSE, message=FALSE, warning=FALSE, fig.width=4,fig.height=4}
cca_df <- total_cap %>% 
  mutate(CC1_X=CC1_X,
         CC1_Y=CC1_Y,
         CC2_X=CC2_X,
         CC2_Y=CC2_Y)

cca_df %>% 
  ggplot(aes(x=CC1_X,y=CC1_Y))+
  geom_point(color="darkblue", size=2)+
  ggtitle("Correlation between the first pair of canonical covariates")
```

### No exclusion

```{r, echo=FALSE, message=FALSE, warning=FALSE}
total_cc2 <- cc(as.data.frame(total_cap[,c(1:12,19:23)]), as.data.frame(total[,c(1, 2, 3)], drop=FALSE))
total_cc2$cor %>%
  kable(col.names = "Coeficientes de correlación") # %>%
  # kbl(caption = "Valores obtenidos") %>%
  # kable_classic(full_width = F, html_font = "Cambria")

expl_var <- (total_cc2$cor)^2
expl_var %>%
  kable(col.names = "Variabilidad explicada") 

pander(total_cc2[3:4])
```

```{r, echo=FALSE, message=FALSE, warning=FALSE}
#Statistical test
rho <- total_cc2$cor # tests of canonical dimensions
## Define number of observations, number of variables in first set, and number of variables in the second set.
n <- dim(total_cap[,c(1:12,19:23)])[1] # mri
p <- length(total_cap[,c(1:12,19:23)]) # mri
q <- length(total[,c(1, 2, 3)])  # clin

## Calculate p-values using the F-approximations of different test statistics:
results <- p.asym(rho, n, p, q, tstat = "Wilks") 
lambda <-  results$stat[1]
R <-  1 - lambda
R %>%
  kable(col.names = "R value")

# Save output as txt
X_xscores <- total_cc1$corr.X.xscores[,]
Y_yscores <- total_cc1$corr.Y.yscores[,]

```


```{r, echo=FALSE, message=FALSE, warning=FALSE}
#(https://cmdlinetips.com/2020/12/canonical-correlation-analysis-in-r/)
# We can use our data sets X & Y and the corresponding coefficients to get the canonical covariate pairs. In the code below, we perform matrix multiplication with each data sets and its first (and second separately) coefficient column to get the first canonical covariate pairs.

CC1_X <- as.matrix(total_cap[,c(1:12,19:23)]) %*% total_cc2$xcoef[, 1]
CC1_Y <- as.matrix(total[,c(1, 2, 3)]) %*% total_cc2$ycoef[, 1]

CC2_X <- as.matrix(total_cap[,c(1:12,19:23)]) %*% total_cc2$xcoef[, 2]
CC2_Y <- as.matrix(total[,c(1, 2, 3)]) %*% total_cc2$ycoef[, 2]

cor(CC1_X,CC1_Y)
```


```{r, echo=FALSE, message=FALSE, warning=FALSE, fig.width=4,fig.height=4}
cca_df <- total_cap %>% 
  mutate(CC1_X=CC1_X,
         CC1_Y=CC1_Y,
         CC2_X=CC2_X,
         CC2_Y=CC2_Y)

cca_df %>% 
  ggplot(aes(x=CC1_X,y=CC1_Y))+
  geom_point(color="darkblue", size=2)+
  ggtitle("Correlation between the first pair of canonical covariates")
```

