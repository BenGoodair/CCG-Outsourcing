#####START####
####load libraries####
library(dplyr)
library(tidyverse)
library(stringr)
library(rebus)
library(plm)
library(texreg)
library(regclass)
library(stargazer)
library(sjPlot)
library(lme4)
library(clubSandwich)
library(lmerTest)
library(sf)
library(sp)
library(spdep)
library(rgdal)
library(rgeos)
library(tmap)
library(tmaptools)
library(spgwr)
library(grid)
library(gridExtra)
library(reshape2)

options(scipen=999)

rm(list=setdiff(ls(), c("")))


setwd("C:/Users/bengo/OneDrive - Nexus365/Documents/PhDing2020")

####CCG Dataset####

avoidable_mortality <- read_csv("Data/avoidablemortalitybyccg2018.csv") 
treatable_mortality <- read_csv("Data/treatable_mortality.csv") 
treatable_deaths <- read_csv("Data/tr_mort_deaths.csv") 
preventable_mortality <- read_csv("Data/preventablemort.csv") 
preventable_mortality18 <- read_csv("Data/preventablemort18.csv") 

ccg_codes <- read_csv("Data/CCG_codes.csv")


avoidable_mortality <- melt(avoidable_mortality,id = c("CCG_Name", "ccg19cd"), variable.name = "year")
names(avoidable_mortality)[names(avoidable_mortality)=="value"] <- "Avoidable_Mortality_Rate"

treatable_mortality <- melt(treatable_mortality,id =  "ccg19cd", variable.name = "year")
names(treatable_mortality)[names(treatable_mortality)=="value"] <- "Treatable_Mortality_Rate"

preventable_mortality <- melt(preventable_mortality,id =  "ccg19cd", variable.name = "year")
names(preventable_mortality)[names(preventable_mortality)=="value"] <- "Preventatable_Mortality_Rate"

preventable_mortality18 <- melt(preventable_mortality18,id =  "ccg19cd", variable.name = "year")
names(preventable_mortality18)[names(preventable_mortality18)=="value"] <- "Preventatable_Mortality_Rate"


avoid2019<-read_csv("Data/avoidablemortalitybyccg2019.csv")
treat2019 <- read_csv("Data/treatablemortalitybyccg2019.csv")

avoid2019$year <- factor(2019)
treat2019$year <- factor(2019)

avoidable_mortality <- avoidable_mortality[-c(1)]

avoidable_mortality <- rbind(avoidable_mortality, avoid2019)
preventable_mortality <- rbind(preventable_mortality18, preventable_mortality)
preventable_mortality <- unique(preventable_mortality)
preventable_mortality <- preventable_mortality[complete.cases(preventable_mortality$ccg19cd),]

treatable_mortality <- rbind(treatable_mortality, treat2019)

MyAnnualDataCCG <- merge(avoidable_mortality, treatable_mortality, by=c("ccg19cd", "year"), all=TRUE)
MyAnnualDataCCG <- merge(MyAnnualDataCCG, preventable_mortality, by=c("ccg19cd", "year"), all=TRUE)

MyAnnualDataCCG <- MyAnnualDataCCG[complete.cases(MyAnnualDataCCG$ccg19cd),]
MyAnnualDataCCG <- MyAnnualDataCCG[-c(3)]


##Add CCG region Variables##

regions <-read_csv("Data/LSOAtoCCGtoLAD19.csv")
regions2 <- read_csv("Data/LADtoNUTS19.csv")


##create lookup to English regions## 
regions <- regions[c(4,9,10)]
regions <- unique(regions)
regions2 <- regions2[c(2, 4,5)]
regions <- merge(regions, regions2, by="LAD19CD", all.x=T)
regions <- regions[c(2,4,5)]
regions <- unique(regions)

#Four CCGs have tiny overlaps in two different NUTS1 regions, Camb+Peter, tameside+glossop, Swindon & Morecombe Bay
#reassign them to their majority regions

regions <-regions[order(regions$ccg19cd),]
regions$id <-  1:nrow(regions)
regions <-regions[which(regions$id!=22),]
regions <-regions[which(regions$id!=193),]
regions <-regions[which(regions$id!=148),]
regions <-regions[which(regions$id!=147),]



MyAnnualDataCCG <- merge(MyAnnualDataCCG, regions, by="ccg19cd", all.x=T)



##Panel Controls##

#download data
localauthority <-read_csv("Data/LSOAtoCCGtoLAD19.csv")

localauthority <- localauthority[c(4,9, 10)]

localauthority <- unique(localauthority)

managerpanel <- read_csv("Data/manager_per.csv")
profpanel <- read_csv("Data/prof_per.csv")
ethnicitypanel <- read_csv("Data/ethnicitypanel.csv")
educationpanel <- read_csv("Data/educationpanel.csv")
unemploymentpanel <- read_csv("Data/unemployment.csv")
claimantpanel <- read_csv("Data/claimantcounts.csv")
poppanel <- read_csv("Data/population_panel.csv")
pop2020 <- read_csv("Data/2020pop.csv")
laspend2012 <- read_csv("Data/LAspend2012.csv")
laspend2013 <- read_csv("Data/LAspend2014.csv")
laspend2015 <- read_csv("Data/LAspend2015.csv")
laspend2016 <- read_csv("Data/LAspend2016.csv")
laspend2017 <- read_csv("Data/LAspend2017.csv")
laspend2018 <- read_csv("Data/LAspend2018.csv")
laspend2019 <- read_csv("Data/LAspend2019.csv")
laspend2020 <- read_csv("Data/LAspend2020.csv")
laspend2014 <- read_csv("Data/LAspend2014.csv")
gdhisw <- read_csv("Data/gdhipersw19.csv")
gdhilon <- read_csv("Data/gdhiperlon19.csv")
gdhise <- read_csv("Data/gdhiperse19.csv")
gdhinw <- read_csv("Data/gdhipernw19.csv")
gdhiwm <- read_csv("Data/gdhiperwm19.csv")
gdhiem <- read_csv("Data/gdhiperem19.csv")
gdhiyh <- read_csv("Data/gdhiperyh19.csv")
gdhine <- read_csv("Data/gdhiperne19.csv")
gdhiee <- read_csv("Data/gdhiperee19.csv")

#gdhiee <- gdhiee[-c(12)]

gdhi <- rbind(gdhiyh, gdhisw,gdhise,gdhine,gdhinw,gdhiem,gdhiwm,gdhilon, gdhiee )

gdhi <- gdhi[-c(1,3)]
names(gdhi)[names(gdhi)=="LAD code"] <- "LAD19CD"

pop2020$year <- 2020
laspend2012$year <- 2012
laspend2013$year <- 2013
laspend2015$year <- 2015
laspend2016$year <- 2016
laspend2017$year <- 2017
laspend2018$year <- 2018
laspend2019$year <- 2019
laspend2020$year <- 2020
laspend2014$year <- 2014

laspend2012 <- laspend2012[c(2,4,5)]
laspend2013 <- laspend2013[c(2,4,5)]
laspend2014 <- laspend2014[c(2,4,5)]
laspend2015 <- laspend2015[c(3,6,7)]
laspend2016 <- laspend2016[c(3,5,6)]
laspend2017 <- laspend2017[c(3,5,6)]
laspend2018 <- laspend2018[c(3,5,6)]
laspend2019 <- laspend2019[c(3,5,6)]
laspend2020 <- laspend2020[c(3,5,6)]

laspend <- rbind(laspend2012, laspend2013, laspend2014, laspend2015, laspend2016, laspend2017, laspend2018, laspend2019, laspend2020)

poppanel <- melt(poppanel,id =  c("LAD19CD", "LAD19NM"), variable.name = "year")
names(poppanel)[names(poppanel)=="value"] <- "Est_Population"

profpanel <- melt(profpanel,id =  c("LAD19CD", "LAD19NM"), variable.name = "year")
names(profpanel)[names(profpanel)=="value"] <- "Professional_occupation"

managerpanel <- melt(managerpanel,id =  c("LAD19CD", "LAD19NM"), variable.name = "year")
names(managerpanel)[names(managerpanel)=="value"] <- "Managerial_occupation"

gdhi <- melt(gdhi,id =  c("LAD19CD"), variable.name = "year")
names(gdhi)[names(gdhi)=="value"] <- "GDHI_per_person"
gdhi <- gdhi[complete.cases(gdhi$LAD19CD),] 

gdhisw <- read_csv("Data/gdhipersw.csv")
gdhilon <- read_csv("Data/gdhiperlon.csv")
gdhise <- read_csv("Data/gdhiperse.csv")
gdhinw <- read_csv("Data/gdhipernw.csv")
gdhiwm <- read_csv("Data/gdhiperwm.csv")
gdhiem <- read_csv("Data/gdhiperem.csv")
gdhiyh <- read_csv("Data/gdhiperyh.csv")
gdhine <- read_csv("Data/gdhimillsne.csv")
gdhiee <- read_csv("Data/gdhiperee.csv")

gdhiee <- gdhiee[-c(12)]

gdhi2 <- rbind(gdhiyh, gdhisw,gdhise,gdhine,gdhinw,gdhiem,gdhiwm,gdhilon, gdhiee )

gdhi2 <- gdhi2[-c(1,3)]
names(gdhi2)[names(gdhi2)=="LAD code"] <- "LAD19CD"

gdhi2 <- melt(gdhi2,id =  c("LAD19CD"), variable.name = "year")
names(gdhi2)[names(gdhi2)=="value"] <- "GDHI_per_person"
gdhi2 <- gdhi2[complete.cases(gdhi2$LAD19CD),] 

er <- merge(gdhi2, gdhi, by=c("LAD19CD", "year"), all=T)
changes21 <- er[is.na(er$GDHI_per_person.y),]
changes21 <- changes21[c("LAD19CD", "year", "GDHI_per_person.x")]
names(changes21)[names(changes21)=="GDHI_per_person.x"] <- "GDHI_per_person"
gdhi <- rbind(gdhi, changes21)

ethnicitypanel <- melt(ethnicitypanel,id =  "LAD19NM", variable.name = "year")
names(ethnicitypanel)[names(ethnicitypanel)=="value"] <- "BAME_percent"

educationpanel <- melt(educationpanel,id =  "LAD19NM", variable.name = "year")
names(educationpanel)[names(educationpanel)=="value"] <- "Qual_lvl4_percent"

unemploymentpanel <- melt(unemploymentpanel,id =  "LAD19NM", variable.name = "year")
names(unemploymentpanel)[names(unemploymentpanel)=="value"] <- "Unemployment_percent"

claimantpanel <- melt(claimantpanel,id =  "LAD19NM", variable.name = "year")
names(claimantpanel)[names(claimantpanel)=="value"] <- "Claimant_percent"


#convert data to ccgs

panelcontrols <- merge(localauthority, unemploymentpanel, by="LAD19NM", all.x=T)

panelcontrols <- merge(panelcontrols, educationpanel, by=c("LAD19NM", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, ethnicitypanel, by=c("LAD19NM", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, poppanel, by=c("LAD19NM", "LAD19CD", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, laspend, by=c("LAD19NM",  "year"), all.x=T)
panelcontrols <- merge(panelcontrols, claimantpanel, by=c("LAD19NM",  "year"), all.x=T)
panelcontrols <- merge(panelcontrols, managerpanel, by=c("LAD19NM", "LAD19CD", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, profpanel, by=c("LAD19NM", "LAD19CD", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, gdhi, by=c("LAD19CD",  "year"), all.x=T)

panelcontrols$Total_Expenditure_1000 <- as.double(panelcontrols$Total_Expenditure_1000)
names(panelcontrols)[names(panelcontrols)=="Total_Expenditure_1000"] <- "Local_Authority_Expenditure"


#Create LA Spend per person
panelcontrols$Local_Authority_Spend_per_pop <- panelcontrols$Local_Authority_Expenditure/panelcontrols$Est_Population


panelcontrols2 <- panelcontrols[c(2,4,5,6,7,8,9,10,11,12,13,14)]
panelcontrols2$Professional_occupation <- as.double(panelcontrols2$Professional_occupation)
panelcontrols2$Managerial_occupation <- as.double(panelcontrols2$Managerial_occupation)

panelcontrols2 <- aggregate(panelcontrols2, by=list(panelcontrols2$ccg19cd,panelcontrols2$year), FUN=mean, na.rm=TRUE)

panelcontrols2 <- panelcontrols2[-c(3,4)]


names(panelcontrols2)[names(panelcontrols2)=="Group.1"] <- "ccg19cd"
names(panelcontrols2)[names(panelcontrols2)=="Group.2"] <- "year"


MyAnnualDataCCG <- merge(MyAnnualDataCCG, panelcontrols2, by=c("ccg19cd", "year"), all.x = T)


#add yearly CCG population estimates

ccgpop12 <- read_csv("Data/ccgpop12.csv")
ccgpop13 <- read_csv("Data/ccgpop13.csv")
ccgpop14 <- read_csv("Data/ccgpop14.csv")
ccgpop15 <- read_csv("Data/ccgpop15.csv")
ccgpop16 <- read_csv("Data/ccgpop16.csv")
ccgpop17 <- read_csv("Data/ccgpop17.csv")
ccgpop18 <- read_csv("Data/ccgpop18.csv")
ccgpop19 <- read_csv("Data/ccgpop19.csv")

ccgpop12$year <- 2012
ccgpop13$year <- 2013
ccgpop14$year <- 2014
ccgpop15$year <- 2015
ccgpop16$year <- 2016
ccgpop17$year <- 2017
ccgpop18$year <- 2018
ccgpop19$year <- 2019

ccgpop <- rbind(ccgpop12, ccgpop13, ccgpop14, ccgpop15, ccgpop16, ccgpop17, ccgpop18, ccgpop19)

MyAnnualDataCCG <- merge(MyAnnualDataCCG, ccgpop, by=c("ccg19cd", "year"), all.x = T)

##Add rural identifier##

ruralurban<-read.csv("Data/ruralurbanccgs.csv")

names(ruralurban)[names(ruralurban)=="ï..ccg19cd"] <- "ccg19cd"

MyAnnualDataCCG <- merge(MyAnnualDataCCG, ruralurban, by="ccg19cd", all.x=T)
MyAnnualDataCCG$Broad_RUC11 <- factor(MyAnnualDataCCG$Broad_RUC11,  levels = c("Predominantly Rural","Urban with Significant Rural","Predominantly Urban"))


imd <- read.csv("Data/ccg_imd_extent.csv")
healthimd <- read.csv("Data/ccg_imd_health.csv")

names(imd)[names(imd)=="ï..ccg19cd"] <- "ccg19cd"
names(healthimd)[names(healthimd)=="ï..ccg19cd"] <- "ccg19cd"

MyAnnualDataCCG <- merge(MyAnnualDataCCG, imd, by="ccg19cd", all.x=T)
MyAnnualDataCCG <- merge(MyAnnualDataCCG, healthimd, by="ccg19cd", all.x=T)

MyAnnualDataCCG$Total_Spend_10millions <- MyAnnualDataCCG$Total_Procurement_Spend/10000000
MyAnnualDataCCG$professional_and_managerial <- MyAnnualDataCCG$Managerial_occupation+MyAnnualDataCCG$Professional_occupation



doctors <- read.csv("Data/DoctorList.csv")
GPs <- read.csv("Data/GGPbyCCG.csv")

GPsperCCG <-  GPs %>% 
  group_by(CCG19CD) %>% 
  count_()

names(GPsperCCG)[names(GPsperCCG)=="CCG19CD"] <- "ccg19cd"
names(GPsperCCG)[names(GPsperCCG)=="n"] <- "number_of_practices"


doctors <- doctors[!complete.cases(doctors$end),]

doctorspergp <- doctors %>% 
  group_by(GP_code) %>% 
  count_()


names(doctorspergp)[names(doctorspergp)=="n"] <- "number_of_doctors"
GPs <- merge(GPs, doctorspergp, by="GP_code", all.x=T)
Docsperccg <- GPs[c(4,5)]
Docsperccg <- aggregate(. ~CCG19CD, data=Docsperccg, sum)
names(Docsperccg)[names(Docsperccg)=="CCG19CD"] <- "ccg19cd"
MyAnnualDataCCG <- merge(MyAnnualDataCCG, Docsperccg, by="ccg19cd", all.x=T)

Mortality_2013 <- read_csv("Data/treatable_mortality.csv") 

Mortality_2013 <- Mortality_2013[c("ccg19cd","2013")]

names(Mortality_2013)[names(Mortality_2013)=="2013"] <- "Treatable_Mortality_2013"

MyAnnualDataCCG <- merge(MyAnnualDataCCG, Mortality_2013, by="ccg19cd", all.x=T)

library(maptools)

ccgboundaries <- readShapeSpatial("ccg19shp")
names(ccgboundaries)[names(ccgboundaries)=="CCG19CD"] <- "ccg19cd"

ccgboundaries <- as.data.frame(ccgboundaries)

MyAnnualDataCCG <- merge(MyAnnualDataCCG,ccgboundaries , by="ccg19cd", all.x=T)




treatable_mortality_deaths19 <- read_csv("Data/raw_tr_mort_numbers_19.csv") 
treatable_mortality_deaths19$year <- "2019"

treatable_mortality_deaths20 <- read_csv("Data/treatable_deaths20.csv") 
treatable_mortality_deaths20$year <- "2020"


treatable_mortality_deaths <- read_csv("Data/tr_mort_deaths.csv") 
names(treatable_mortality_deaths)[names(treatable_mortality_deaths)=="Area Code"] <- "ccg19cd"
treatable_mortality_deaths <- treatable_mortality_deaths[c(2,4:17)]
treatable_mortality_deaths <- treatable_mortality_deaths[complete.cases(treatable_mortality_deaths),]

treatable_mortality_deaths <- melt(treatable_mortality_deaths,id = c("ccg19cd"), variable.name = "year")
names(treatable_mortality_deaths)[names(treatable_mortality_deaths)=="value"] <- "treatable_mortality_deaths"
treatable_mortality_deaths <- rbind(treatable_mortality_deaths, treatable_mortality_deaths19, treatable_mortality_deaths20)



MyAnnualDataCCG <- merge(MyAnnualDataCCG,treatable_mortality_deaths, by=c("ccg19cd", "year") ,all=T)

ccgage20 <- read.csv("Data/ccgage20.csv")
ccgage19 <- read.csv("Data/ccgage19.csv")
ccgage18 <- read.csv("Data/ccgage18.csv")
ccgage17 <- read.csv("Data/ccgage17.csv")
ccgage16 <- read.csv("Data/ccgage16.csv")
ccgage15 <- read.csv("Data/ccgage15.csv")
ccgage14 <- read.csv("Data/ccgage14.csv")
ccgage13 <- read.csv("Data/ccgage13.csv")

ccgage20$year <- 2020
ccgage19$year <- 2019
ccgage18$year <- 2018
ccgage17$year <- 2017
ccgage16$year <- 2016
ccgage15$year <- 2015
ccgage14$year <- 2014
ccgage13$year <- 2013

ccgage <- rbind(ccgage13, ccgage14, ccgage15, ccgage16, ccgage17, ccgage18, ccgage19,ccgage20)

ccgage$over80 <- as.double(ccgage$over80)
ccgage$over75 <- as.double(ccgage$over75)
ccgage$over70 <- as.double(ccgage$over70)

names(ccgage)[names(ccgage)=="ï..ccg19cd"] <- "ccg19cd"

ccgage <- ccgage[complete.cases(ccgage),]

MyAnnualDataCCG <- merge(MyAnnualDataCCG,ccgage, by=c("ccg19cd", "year") ,all=T)


MyAnnualDataCCG <- merge(MyAnnualDataCCG, ccg_codes, by="ccg19cd", all.x=TRUE)

MyAnnualDataCCG <- MyAnnualDataCCG[complete.cases(MyAnnualDataCCG$ccg19cd),]

#write.csv(MyAnnualDataCCG, "Data/Annual_Mortality_and_Control_Variables_ccg.csv")

####LA controls####
latreatmort <- read.csv("Data/latreatmort.csv")

latreatmort <- melt(latreatmort,id =  c("LAD19CD"), variable.name = "threeyears")
names(latreatmort)[names(latreatmort)=="value"] <- "Treatable_mortality_rate"

lapreventmort <- read.csv("Data/lapreventmort.csv")
names(lapreventmort)[names(lapreventmort) == "ï..LAD19CD"] <- "LAD19CD"

lapreventmort <- melt(lapreventmort,id =  c("LAD19CD"), variable.name = "threeyears")
names(lapreventmort)[names(lapreventmort)=="value"] <- "Preventable_mortality_rate"


localauthority <-read_csv("Data/LSOAtoCCGtoLAD19.csv")

localauthority <- localauthority[c(4,9, 10)]

localauthority <- unique(localauthority)

ladata <- merge(localauthority, latreatmort, by="LAD19CD", all.x=T)
ladata <- merge(ladata, lapreventmort, by=c("LAD19CD", "threeyears"), all.x=T)

lale <- read.csv("Data/life_expectancy_LAs.csv")
lale <- lale[which(lale$Ageband==1),]

lale <- lale %>% mutate(year = ifelse(lale$ï..years=="2009-2011", 2011,ifelse(lale$ï..years=="2010-2012", 2012, ifelse(lale$ï..years=="2012-2013", 2013 ,ifelse(lale$ï..years=="2012-2014", 2014,ifelse(lale$ï..years=="2013-2015", 2015,ifelse(lale$ï..years=="2014-2016", 2016,ifelse(lale$ï..years=="2015-2017", 2017,ifelse(lale$ï..years=="2016-2018", 2018,ifelse(lale$ï..years=="2017-2019", 2019,ifelse(lale$ï..years=="2018-2020", 2020,NA)))))))))) )

names(lale)[names(lale)=="Area.code"] <- "LAD19CD"

ladata <- ladata %>% mutate(year = ifelse(ladata$threeyears=="X2009.2011", 2011, ifelse(ladata$threeyears=="X2010.2012", 2012, ifelse(ladata$threeyears=="X2011.2013", 2013, ifelse(ladata$threeyears=="X2012.2014", 2014, ifelse(ladata$threeyears=="X2013.2015", 2015, ifelse(ladata$threeyears=="X2014.2016", 2016, ifelse(ladata$threeyears=="X2015.2017", 2017, ifelse(ladata$threeyears=="X2016.2018", 2018, ifelse(ladata$threeyears=="X2017.2019", 2019, ifelse(ladata$threeyears=="X2018.2020", 2020,NA)))))))))))
ladata$year <- as.Date(as.character(ladata$year), format = "%Y")
ladata$year <- format(ladata$year,"%Y")

larural <- read.csv("Data/laruralurban.csv")
ladata <- merge(ladata, larural, by="LAD19CD", all.x=T)


ladata$one <- 1
counts <- aggregate(one ~ threeyears + ccg19cd, data = ladata, FUN = sum)

counts$include <- 1


counts <- counts[which(counts$one>2),]

ladata2 <- merge(ladata, counts, by=c("ccg19cd", "threeyears"), all.x=T)
ladata2 <- ladata2[which(ladata2$include==1),]
count <- unique(ladata2$ccg19cd)

#controls#
managerpanel <- read_csv("Data/manager_per.csv")
profpanel <- read_csv("Data/prof_per.csv")
ethnicitypanel <- read_csv("Data/ethnicitypanel.csv")
educationpanel <- read_csv("Data/educationpanel.csv")
unemploymentpanel <- read_csv("Data/unemployment.csv")
claimantpanel <- read_csv("Data/claimantcounts.csv")
poppanel <- read_csv("Data/population_panel.csv")
pop2020 <- read_csv("Data/2020pop.csv")
laspend2012 <- read_csv("Data/LAspend2012.csv")
laspend2013 <- read_csv("Data/LAspend2014.csv")
laspend2015 <- read_csv("Data/LAspend2015.csv")
laspend2016 <- read_csv("Data/LAspend2016.csv")
laspend2017 <- read_csv("Data/LAspend2017.csv")
laspend2018 <- read_csv("Data/LAspend2018.csv")
laspend2019 <- read_csv("Data/LAspend2019.csv")
laspend2020 <- read_csv("Data/LAspend2020.csv")
laspend2014 <- read_csv("Data/LAspend2014.csv")
gdhisw <- read_csv("Data/gdhipersw19.csv")
gdhilon <- read_csv("Data/gdhiperlon19.csv")
gdhise <- read_csv("Data/gdhiperse19.csv")
gdhinw <- read_csv("Data/gdhipernw19.csv")
gdhiwm <- read_csv("Data/gdhiperwm19.csv")
gdhiem <- read_csv("Data/gdhiperem19.csv")
gdhiyh <- read_csv("Data/gdhiperyh19.csv")
gdhine <- read_csv("Data/gdhiperne19.csv")
gdhiee <- read_csv("Data/gdhiperee19.csv")

#gdhiee <- gdhiee[-c(12)]

gdhi <- rbind(gdhiyh, gdhisw,gdhise,gdhine,gdhinw,gdhiem,gdhiwm,gdhilon, gdhiee )

gdhi <- gdhi[-c(1,3)]
names(gdhi)[names(gdhi)=="LAD code"] <- "LAD19CD"

pop2020$year <- 2020
laspend2012$year <- 2012
laspend2013$year <- 2013
laspend2015$year <- 2015
laspend2016$year <- 2016
laspend2017$year <- 2017
laspend2018$year <- 2018
laspend2019$year <- 2019
laspend2020$year <- 2020
laspend2014$year <- 2014

laspend2012 <- laspend2012[c(2,4,5)]
laspend2013 <- laspend2013[c(2,4,5)]
laspend2014 <- laspend2014[c(2,4,5)]
laspend2015 <- laspend2015[c(3,6,7)]
laspend2016 <- laspend2016[c(3,5,6)]
laspend2017 <- laspend2017[c(3,5,6)]
laspend2018 <- laspend2018[c(3,5,6)]
laspend2019 <- laspend2019[c(3,5,6)]
laspend2020 <- laspend2020[c(3,5,6)]

laspend <- rbind(laspend2012, laspend2013, laspend2014, laspend2015, laspend2016, laspend2017, laspend2018, laspend2019, laspend2020)

poppanel <- melt(poppanel,id =  c("LAD19CD", "LAD19NM"), variable.name = "year")
names(poppanel)[names(poppanel)=="value"] <- "Est_Population"

profpanel <- melt(profpanel,id =  c("LAD19CD", "LAD19NM"), variable.name = "year")
names(profpanel)[names(profpanel)=="value"] <- "Professional_occupation"

managerpanel <- melt(managerpanel,id =  c("LAD19CD", "LAD19NM"), variable.name = "year")
names(managerpanel)[names(managerpanel)=="value"] <- "Managerial_occupation"


gdhi <- melt(gdhi,id =  c("LAD19CD"), variable.name = "year")
names(gdhi)[names(gdhi)=="value"] <- "GDHI_per_person"
gdhi <- gdhi[complete.cases(gdhi$LAD19CD),] 

gdhisw <- read_csv("Data/gdhipersw.csv")
gdhilon <- read_csv("Data/gdhiperlon.csv")
gdhise <- read_csv("Data/gdhiperse.csv")
gdhinw <- read_csv("Data/gdhipernw.csv")
gdhiwm <- read_csv("Data/gdhiperwm.csv")
gdhiem <- read_csv("Data/gdhiperem.csv")
gdhiyh <- read_csv("Data/gdhiperyh.csv")
gdhine <- read_csv("Data/gdhimillsne.csv")
gdhiee <- read_csv("Data/gdhiperee.csv")

gdhiee <- gdhiee[-c(12)]

gdhi2 <- rbind(gdhiyh, gdhisw,gdhise,gdhine,gdhinw,gdhiem,gdhiwm,gdhilon, gdhiee )

gdhi2 <- gdhi2[-c(1,3)]
names(gdhi2)[names(gdhi2)=="LAD code"] <- "LAD19CD"

gdhi2 <- melt(gdhi2,id =  c("LAD19CD"), variable.name = "year")
names(gdhi2)[names(gdhi2)=="value"] <- "GDHI_per_person"
gdhi2 <- gdhi2[complete.cases(gdhi2$LAD19CD),] 

er <- merge(gdhi2, gdhi, by=c("LAD19CD", "year"), all=T)
changes21 <- er[is.na(er$GDHI_per_person.y),]
changes21 <- changes21[c("LAD19CD", "year", "GDHI_per_person.x")]
names(changes21)[names(changes21)=="GDHI_per_person.x"] <- "GDHI_per_person"
gdhi <- rbind(gdhi, changes21)

ethnicitypanel <- melt(ethnicitypanel,id =  "LAD19NM", variable.name = "year")
names(ethnicitypanel)[names(ethnicitypanel)=="value"] <- "BAME_percent"

educationpanel <- melt(educationpanel,id =  "LAD19NM", variable.name = "year")
names(educationpanel)[names(educationpanel)=="value"] <- "Qual_lvl4_percent"

unemploymentpanel <- melt(unemploymentpanel,id =  "LAD19NM", variable.name = "year")
names(unemploymentpanel)[names(unemploymentpanel)=="value"] <- "Unemployment_percent"

claimantpanel <- melt(claimantpanel,id =  "LAD19NM", variable.name = "year")
names(claimantpanel)[names(claimantpanel)=="value"] <- "Claimant_percent"



panelcontrols <- merge(localauthority, unemploymentpanel, by="LAD19NM", all.x=T)

panelcontrols <- merge(panelcontrols, educationpanel, by=c("LAD19NM", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, ethnicitypanel, by=c("LAD19NM", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, poppanel, by=c("LAD19NM", "LAD19CD", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, managerpanel, by=c("LAD19NM", "LAD19CD", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, profpanel, by=c("LAD19NM", "LAD19CD", "year"), all.x=T)
panelcontrols <- merge(panelcontrols, laspend, by=c("LAD19NM",  "year"), all.x=T)
panelcontrols <- merge(panelcontrols, claimantpanel, by=c("LAD19NM",  "year"), all.x=T)
panelcontrols <- merge(panelcontrols, gdhi, by=c("LAD19CD",  "year"), all.x=T)

panelcontrols$Total_Expenditure_1000 <- as.double(panelcontrols$Total_Expenditure_1000)
names(panelcontrols)[names(panelcontrols)=="Total_Expenditure_1000"] <- "Local_Authority_Expenditure"



#Create LA Spend per person
panelcontrols$Local_Authority_Spend_per_pop <- panelcontrols$Local_Authority_Expenditure/panelcontrols$Est_Population



panelcontrols2 <- panelcontrols[-c(4)]
panelcontrols2 <- unique(panelcontrols2)

panelcontrols2$Professional_occupation <- as.double(panelcontrols2$Professional_occupation)
panelcontrols2$Managerial_occupation <- as.double(panelcontrols2$Managerial_occupation)


panelcontrols1214 <- panelcontrols2[which(panelcontrols2$year=="2013"|panelcontrols2$year=="2014"|panelcontrols2$year=="2012"),]
panelcontrols1214$threeyears <- "X2012.2014"  

panelcontrols1315 <- panelcontrols2[which(panelcontrols2$year=="2013"|panelcontrols2$year=="2014"|panelcontrols2$year=="2015"),]
panelcontrols1315$threeyears <- "X2013.2015"  

panelcontrols1416 <- panelcontrols2[which(panelcontrols2$year=="2016"|panelcontrols2$year=="2014"|panelcontrols2$year=="2015"),]
panelcontrols1416$threeyears <- "X2014.2016"  

panelcontrols1517 <- panelcontrols2[which(panelcontrols2$year=="2016"|panelcontrols2$year=="2017"|panelcontrols2$year=="2015"),]
panelcontrols1517$threeyears <- "X2015.2017"  

panelcontrols1618 <- panelcontrols2[which(panelcontrols2$year=="2016"|panelcontrols2$year=="2017"|panelcontrols2$year=="2018"),]
panelcontrols1618$threeyears <- "X2016.2018"  

panelcontrols1719 <- panelcontrols2[which(panelcontrols2$year=="2017"|panelcontrols2$year=="2018"|panelcontrols2$year=="2019"),]
panelcontrols1719$threeyears <- "X2017.2019"  

panelcontrols1820 <- panelcontrols2[which(panelcontrols2$year=="2018"|panelcontrols2$year=="2019"|panelcontrols2$year=="2020"),]
panelcontrols1820$threeyears <- "X2018.2020"  

panelcontrols1214 <- panelcontrols1214[-c(2,3)]
panelcontrols1315 <- panelcontrols1315[-c(2,3)]
panelcontrols1416 <- panelcontrols1416[-c(2,3)]
panelcontrols1517 <- panelcontrols1517[-c(2,3)]
panelcontrols1618 <- panelcontrols1618[-c(2,3)]
panelcontrols1719 <- panelcontrols1719[-c(2,3)]
panelcontrols1820 <- panelcontrols1820[-c(2,3)]

panelcontrols1214 <- aggregate(. ~LAD19CD+threeyears, data=panelcontrols1214, mean)
panelcontrols1315 <- aggregate(. ~LAD19CD+threeyears, data=panelcontrols1315, mean)
panelcontrols1416 <- aggregate(. ~LAD19CD+threeyears, data=panelcontrols1416, mean)
panelcontrols1517 <- aggregate(. ~LAD19CD+threeyears, data=panelcontrols1517, mean)
panelcontrols1618 <- aggregate(. ~LAD19CD+threeyears, data=panelcontrols1618, mean)
panelcontrols1719 <- aggregate(. ~LAD19CD+threeyears, data=panelcontrols1719, mean)
panelcontrols1820 <- aggregate(. ~LAD19CD+threeyears, data=panelcontrols1820, mean)

panelcontrolstotal <- rbind(panelcontrols1315,panelcontrols1416,panelcontrols1517,panelcontrols1618,panelcontrols1719,panelcontrols1820,panelcontrols1214 )

ladata2 <- merge(ladata2, panelcontrolstotal, by=c("LAD19CD", "threeyears"), all.x=T)

ladata2$Total_Spend_10millions <- ladata2$Total_Procurement_Spend/10000000
ladata2$professional_and_managerial <- ladata2$Managerial_occupation+ladata2$Professional_occupation


#write.csv(ladata2, "Data/Three_Year_Mortality_and_Control_Variables_LA.csv")



####end####
