[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/BenGoodair/CCG-Outsourcing-Binder/HEAD)
# CCG-Outsourcing
Welcome to a repository of reproducibility files for the upcoming paper in the Lancet Public Health, co-authored with [Aaron Reeves](https://aaronreeves.org/): 'Outsourcing healthcare services to the private sector and treatable mortality rates in England, 2013-2020: An observational study of NHS privatisation.' 

<p align="center">
  <img src="https://raw.githubusercontent.com/BenGoodair/CCG-Outsourcing/main/Interactive%20Plots/scrollwarmstill.jpg"  />
</p>

The entire paper is written in RMarkdown. In theory anyone should be able to download the .Rmd file in the manuscript folder and reproduce all the analyses, text and citations in the paper without any additional files simply by knitting the file.[^1][^2][^3] (To download the Rmd file, click 'raw' on the 'CCG_Outsourcing_Manuscript.Rmd' file, right click on the page, 'save as', change the name of the file making sure it still ends '.Rmd', and save it as 'all files' - not a text document)

The .Rmd file makes use of a custom R package "NHSOutsourcingTMortality". This package contains functions to download, clean, and analyse the data as per the paper (and the very long supplementary material). The package is downloaded from the 'master' branch of this repository. Raw code for all functions are available in the 'raw code' folder of this repository for full transparency.

The NHS expenditure data used in this paper is openly available from:

[Rahal, Charles & Mohan, John, 2022. "The Role of the Third Sector in Public Health Service Provision: Evidence from 25,338 heterogeneous procurement datasets," SocArXiv t4x52, Center for Open Science.](https://ideas.repec.org/p/osf/socarx/t4x52.html)

Thanks to Charlie Rahal's admirable committment to open science, we can very easily download the data files from the minted repository [Rahal, Knowles, Barnard and Mohan, 'Introducing NHSSpend'](https://zenodo.org/record/5054717).

So if you would like to dowload the data directly to R, the custom package of functions provides an easy way of doing this:

    ` 
    if (!require("pacman")) install.packages("pacman")
    pacman::p_load(devtools, utils, zen4R)
        
    devtools::install_github("BenGoodair/CCG-Outsourcing", ref = "master")
    library(NHSOutsourcingTMortality)
    myDataCCG <- NHSOutsourcingTMortality::Download_CCG_payments() 
    `
Then you too can make snappy visualisations of the data like this one:

<p align="center">
  <img src="https://github.com/BenGoodair/CCG-Outsourcing/blob/main/Interactive%20Plots/NHS_creeping_gif.gif" alt="animated" />
</p>


Supplementary data used in the paper's analysis is published in this repository or loaded via APIs - again the code directly pulls the data so nothing should need to be manually downloaded for the purpose of reproduction. Data cleaning code used to create the supplementary datasets is provided for the sake of transparency.

I am extremely grateful to the endless support and guidance of [Charles Rahal](https://crahal.github.io/) in the development of this paper.

Please get in touch with me at benjamin.goodair@spi.ox.ac.uk if you would like to discuss anything from the paper or code published in this repository.

If you experience any issues with packages, I am working on a Binder version which runs a dockerized version of all the code in a web browser - it is not yet finalised but will eventually be available [here](https://github.com/BenGoodair/CCG-Outsourcing-Binder).



[^1]: Warning: Running this code involves data to be directly downloaded to your pc. 
[^2]: Some of the analyses involved in the paper are computationally intensive. To make them accessible, simulations are much reduced in power in the repoducibility code. 
[^3]: Expect the Rmd file to take ~15 minutes to knit an html version of the paper.
