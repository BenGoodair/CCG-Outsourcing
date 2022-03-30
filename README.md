# CCG-Outsourcing
A repository of reproducibility files for the upcoming paper, co-authored with [Aaron Reeves](https://aaronreeves.org/): 'Is the outsourcing of healthcare services to the private sector associated with higher mortality rates? An observational analysis of ‘creeping privatisation’ in England’s Clinical Commissioning Groups, 2013-2020.'

The entire paper is written in RMarkdown. In theory anyone should be able to download 'outsourcing_and_mortality.Rmd' and reproduce all the analyses, text and citations in the paper without any additional files. 

The Rmd file makes use of a custom R package "NHS_privatisation_and_mortality". This package contains functions to download, clean, and analyse the data as per the paper. Raw code for these functions are available in this repository for full transparency.

Please get in touch with me at benjamin.goodair@spi.ox.ac.uk if you would like to discuss anything from the paper or code published in this repository.

The main raw data source of this paper is available from:

[Rahal, Charles & Mohan, John, 2022. "The Role of the Third Sector in Public Health Service Provision: Evidence from 25,338 heterogeneous procurement datasets," SocArXiv t4x52, Center for Open Science.](https://ideas.repec.org/p/osf/socarx/t4x52.html)

For the purposes of easy reproducibility, the code for this paper directly pulls the data from the repository [Rahal, Knowles, Barnard and Mohan, 'Introducing NHSSpend'](https://zenodo.org/record/5054717)

Supplementary data used in analysis is published in this repository - again the code directly pulls the data so no data should need to be manually downloaded for the purpose of reproduction.

Data cleaning code for the supplementary data is provided, location of the raw data is presented in the full paper.

I am eternally grateful to the support and guidance of [Charles Rahal](https://crahal.github.io/) in the development of this paper.

