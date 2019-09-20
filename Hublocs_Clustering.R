library(ggplot2)
library(reshape2)
library(parallel)
library(geosphere)
require(geosphere)
library(xlsx)
library(osrm)
SCD_RW <- read.csv("Masked_InputData.csv", stringsAsFactors = FALSE)

# Filtering data


# Computing weights
SCD_RW$weights<- SCD_RW$Sales/sum(SCD_RW$Sales)*1000

SCD_RW$Lat_weighted<-SCD_RW$Latitude*SCD_RW$weights
SCD_RW$Lon_weighted<-SCD_RW$Longitude*SCD_RW$weights

df_w     <- data.frame(lon=SCD_RW$Longitude, lat=SCD_RW$Latitude)
df_w['ID'] = seq(1,nrow(df_w ))

#data<-data.frame( identifier = df_w$ID, lon  = df_w$lon, lat =df_w$lat)
#data$identifier = as.character(data$identifier)
#data$lon=as.numeric(as.character(data$lon))
#data$lat=as.numeric(as.character(data$lat))
#DistTab = osrmTable(data[1:10,])

output<-list()
for(K in 1:10) 
{
  set.seed(123)

  Centers <- as.data.frame(kmeans(SCD_RW[SCD_RW$Sales>quantile(SCD_RW$Sales,0.9),3:2],K)$centers )
  SCD_RW$Cluster_ID=0
  SCD_RW$Distance=0
  
  for(itr in 1:30)
  {
    prevCent = Centers
    #Find cluster membership
    for(i in 1:nrow(SCD_RW))
    {
       d =  distHaversine(SCD_RW[i,3:2], Centers)
        SCD_RW$Cluster_ID[i] = which.min(d)
        SCD_RW$Distance[i] = min(d)/1000
        assign(paste0('SCD_RW_',K),SCD_RW[,c(1:4,8,9)])
    } 
    
    Z <- assign(paste0('SCD_RW_',K),SCD_RW[,c(1:4,8,9)])
    AvgDistance<- mean(SCD_RW$Distance)
    Z$avgdistance<-assign(paste0('Avgdist_',K),AvgDistance)
    #Find centroid 
    
    for(c in unique(SCD_RW$Cluster_ID))
    {
      dsub = subset(SCD_RW, Cluster_ID==c)
      Centers[c,] = c(sum(dsub$Lon_weighted)/sum(dsub$weights), sum(dsub$Lat_weighted)/sum(dsub$weights)) 
      
    }
    
      Centers[,3] = seq(1,nrow(Centers))
      colnames(Centers)[colnames(Centers)=='V3']<-'ID'
      Centers[,4] = K
      colnames(Centers)[colnames(Centers)=='V4']<-'Kvalue'
    
      colnames(Centers)[1:2] <-c( "Center_Longitude","Center_Latitude")
      totalGap = sum(distHaversine(prevCent,Centers))
        if (totalGap < 1)
          Y<-paste0('Centers_',K)
          assign(paste0('Centers_',K),Centers[,c(1:3)])
          #Centers['ID'] = seq(1,nrow(Centers))
        break
  
  }
      x<-assign(paste0('Sheet_K_',K),merge(Z,Centers, by.x="Cluster_ID", by.y= "ID"))
      output[[K]]<-do.call(cbind,x)
     
    #write.xlsx(x, file="FinalOutput.xlsx", sheetName=paste0('Sheetname_',K), append=TRUE, row.names=FALSE)
}
finaldata<-do.call(rbind,output)
write.csv(finaldata,file="FinalOutput1.csv",row.names = FALSE)

