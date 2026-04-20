#read data
wd <- "/project/rrg-oespinga/oespinga/OAI/ClinicalData/CompleteData_ASCII/"
min8=read.table(paste0(wd,"/Acceldatabymin08.txt"), sep="|", header=T) 
min6=read.table(paste0(wd,"/Acceldatabymin06.txt"), sep="|", header=T) 

y8=read.table(paste0(wd,"/kxr_qjsw_duryea08.txt"), sep="|", header= T)

names(min8)
names(y8)
summary(y8)
summary(min8)
head(min8)
head(y8)

y8_out <- y8[, c("ID", "side", "V08MCMJSW")]
head(y8_out)

min8_out <- min8[, c("ID", "V08PAStudyDay", "V08MinSequence", "V08MINCnt")]
head(min8_out)

data_raw<- merge(
  min8_out,
  y8_out,
  by = "ID",
  all = FALSE
)
head(data_raw)

nrow(min8_out)
nrow(y8_out)
nrow(data_raw)

table(table(data_raw$ID))

side_check <- y8_out %>%
  count(ID, name = "n_side") %>%
  count(n_side, name = "n_ID")

side_check

numbers(y8_out$ID)
