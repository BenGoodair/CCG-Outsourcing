# CCG-Outsourcing
A repository of reproducibility files for the upcoming paper, co-authored with [Aaron Reeves](https://aaronreeves.org/): 'Is the outsourcing of healthcare services to the private sector associated with higher mortality rates? An observational analysis of ‘creeping privatisation’ in England’s Clinical Commissioning Groups, 2013-2020.'

The entire paper is written in RMarkdown. In theory anyone should be able to download 'outsourcing_and_mortality.Rmd' or 'Supplementary_Material.Rmd' and reproduce all the analyses, text and citations in the paper without any additional files.[^1][^2][^3]

The Rmd file makes use of a custom R package "NHS_privatisation_and_mortality_R_package". This package contains functions to download, clean, and analyse the data as per the paper. Raw code for these functions are available in this repository for full transparency.

Please get in touch with me at benjamin.goodair@spi.ox.ac.uk if you would like to discuss anything from the paper or code published in this repository.

The NHS expenditure data used in this paper is available from:

[Rahal, Charles & Mohan, John, 2022. "The Role of the Third Sector in Public Health Service Provision: Evidence from 25,338 heterogeneous procurement datasets," SocArXiv t4x52, Center for Open Science.](https://ideas.repec.org/p/osf/socarx/t4x52.html)

For the purposes of easy reproducibility, the code for our paper directly downloads and unpacks the data from the repository [Rahal, Knowles, Barnard and Mohan, 'Introducing NHSSpend'](https://zenodo.org/record/5054717).

Supplementary data used in the paper's analysis is published in this repository or loaded via APIs - again the code directly pulls the data so nothing should need to be manually downloaded for the purpose of reproduction.

Data cleaning code used to create the supplementary datasets is provided for the sake of transparency.

I am extremely grateful to the endless support and guidance of [Charles Rahal](https://crahal.github.io/) in the development of this paper.




[^1]: Warning: Running this code involves data to be directly downloaded to your pc. 
[^2]: Some of the analyses involved in the paper are computationally intensive. To make them accessible, simulations are much reduced in power in the repoducibility code. 
[^3]: Expect the Rmd file to take ~1 hour to knit a pdf version of the paper.
