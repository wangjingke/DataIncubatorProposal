# DataIncubator Challenge Q3
library(ggmap)
library(XLConnect)
library(ggplot2)
library(gridExtra)
library(nlme)
library(mgcv)
library(geoR)
library(fields)
library(spdep)
library(maptools)
library(spgwr)

work_dir="/home/jing/Temp/Q3/"
setwd(work_dir)

# reading restaurants data downloaded from public website
restaurants=readWorksheetFromFile("Active_restaurant_heat_map.xlsx", sheet=1)
restaurants$zip=sapply(strsplit(restaurants$ZIP.CODE, "-"), "[[", 1)
restaurants=restaurants[restaurants$LOCATION!="" & !is.na(restaurants$LOCATION.START.DATE),]
restaurants$establish=as.numeric(sapply(strsplit(as.character(restaurants$LOCATION.START.DATE), "-"), "[[", 1))
restaurants$latitude=as.numeric(sapply(strsplit(restaurants$LOCATION, ",|\\(|\\)"), "[[", 2))
restaurants$longitude=as.numeric(sapply(strsplit(restaurants$LOCATION, ",|\\(|\\)"), "[[", 3))

# LA map from API
la=get_map(location="Los Angeles", zoom=10, color="bw", maptype="toner")

# distribution of all active restaurants in LA
active_now=ggmap(la)
active_now=active_now+geom_point(data=restaurants, aes(x=longitude, y=latitude), size=1, col="red")+ggtitle("All Active Restaurants in Los Angeles")+theme(plot.title=element_text(size=24))

# newly opened restaurants in LA since 2010
active_2015=ggmap(la)
active_2015=active_2015+geom_point(data=restaurants[restaurants$establish==2015,], aes(x=longitude, y=latitude), size=1, col="red")+ggtitle("Newly Established Restaurants in Los Angeles in 2015")+theme(plot.title=element_text(size=24))

png("Established_restaurants_LA.png", width=1800, height=900)
grid.arrange(active_now, active_2015, ncol=2)
dev.off()

# counting number of restaurants by zip code
zip_act=aggregate(restaurants$BUSINESS.NAME, by=list(c(restaurants$zip)), length)
colnames(zip_act)=c("zipcode", "ActRest")
zip_new_2015=aggregate(BUSINESS.NAME~zip, data=subset(restaurants, establish==2015), length)
colnames(zip_new_2015)=c("zipcode", "NewRest2015")
ActRest=merge(zip_act, zip_new_2015, by="zipcode", all=TRUE, sort=FALSE)
ActRest[is.na(ActRest)]=0

# reading demographic data scrapped from LA city website
lazipdem=readShapeSpatial("./LAZipDem/LAZipDem.shp", ID="OBJECTID")
lazipdem=merge(lazipdem, ActRest, by.x="ZIP", by.y="zipcode", all.x=TRUE, sort=FALSE)
lazipdem$rest_pt=100*lazipdem$NewRest2015/lazipdem$ActRest
lazipdem$rest_pt=ifelse(is.na(lazipdem$rest_pt), 0, lazipdem$rest_pt)
lazipdem$NewRest2015=ifelse(is.na(lazipdem$NewRest2015), 0, lazipdem$NewRest2015)

# creating regressive correlation across adjacent regions
rook=poly2nb(lazipdem, queen=FALSE)
rook.w=nb2listw(rook)
# Moran's I test
moranRest.rook=moran.test(lazipdem$rest_pt, rook.w)
moranRest.rook
png("Morans Scatterplot.png", width=1600, height=600)
par(mfrow=c(1,2))
mscat.rest_pt=moran.plot(lazipdem$rest_pt, rook.w, zero.policy=TRUE, pch=16, col="black", quiet=FALSE, labels=as.character(lazipdem$OBJECTID), main="Moran Scatterplot for Percentage Increase of New Restaurants", xlab="Percentage Increase of Active Restaurants in 2015", ylab="Spatial Lag", cex.lab=1.2, cex.main=1.5)
mscat.NewRest2015=moran.plot(lazipdem$NewRest2015, rook.w, zero.policy=TRUE, pch=16, col="black", quiet=FALSE, labels=as.character(lazipdem$OBJECTID), main="Moran Scatterplot for LA New Restaurants in 2015", xlab="New Restarurants in 2015", ylab="Spatial Lag", cex.lab=1.3, cex.main=1.5)
dev.off()

# population change
demographics=read.csv("demographics.csv", header=TRUE)
lazipdem=merge(lazipdem, demographics[c("ZIP", "income2000", "income2010")], by="ZIP", all.x=TRUE, sort=FALSE)
lazipdem$popchange=100*(lazipdem$POP2010b-lazipdem$POP2000b)/lazipdem$POP2000b

lazipdem$popchange=ifelse(lazipdem$popchange=="NaN",0, lazipdem$popchange)
lazipdem$income2010=ifelse(is.na(lazipdem$income2010),0, lazipdem$income2010)
lazipdem$white_pt=100*lazipdem$WHITE/lazipdem$POP2010b
lazipdem$white_pt=ifelse(is.na(lazipdem$white_pt),0, lazipdem$white_pt)
lazipdem$hispanic_pt=100*lazipdem$HISPANIC/lazipdem$POP2010b
lazipdem$hispanic_pt=ifelse(is.na(lazipdem$hispanic_pt),0, lazipdem$hispanic_pt)
lazipdem$asian_pt=100*lazipdem$ASIAN/lazipdem$POP2010b
lazipdem$asian_pt=ifelse(is.na(lazipdem$asian_pt),0, lazipdem$asian_pt)

# auto regressive model
queen=poly2nb(lazipdem, queen=TRUE)
col.palette=colorRampPalette(c("white", "orange", "red"), space="rgb")
col.ramp=col.palette(length(seq(0,1,0.2)))

sar=spautolm(NewRest2015~POP2010b+popchange+income2010+white_pt+hispanic_pt+asian_pt, data=lazipdem, nb2listw(queen), method="eigen")
summary(sar)
moran.test(sar$fit$residuals, listw=nb2listw(queen), zero.policy = T)
lazipdem$sar.res=sar$fit$residuals
sar.breaks=quantile(sar$fit$residuals, seq(0,1,0.2))
plot(lazipdem, border="lightgray", col=col.ramp[findInterval(lazipdem$sar.res, sar.breaks, all.inside=TRUE)], main="SAR Residuals")

##
## calling INFO from Yelp API
# library(httr)
# library(httpuv)
# library(jsonlite)

# consumerKey = "####"
# consumerSecret = "####"
# token = "####"
# token_secret = "####"

# authoriztion
# myapp = oauth_app("YELP", key=consumerKey, secret=consumerSecret)
# sig=sign_oauth1.0(myapp, token=token, token_secret=token_secret)

# limit = 10

# yelpurl=paste("http://api.yelp.com/v2/search/?limit=",limit,"&location=Los+Angeles&term=restaurants&cll=", restaurants$latitude[6],",", restaurants$longitude[6], sep="")

# locationdata=GET(yelpurl, sig)
# locationdataContent = content(locationdata)
# locationdataList=jsonlite::fromJSON(toJSON(locationdataContent))
# head(data.frame(locationdataList))


