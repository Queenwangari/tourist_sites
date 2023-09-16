#setting the working directory
setwd("C:/Users/PC/Desktop/Wildlife/R")

#getting the working directory
getwd()
dir()

#calling the libraries
library(sf)
library(sp)
library(GISTools)
library(rgdal)
library(leaflet)
library(leaflet.providers)
library(RColorBrewer)
library(viridis)
library(viridisLite)
library(htmltools)
library(htmlwidgets)

#importing the data
Counties<-st_read("kenya_counties.GeoJSON")
Protected_Areas<-st_read( "Protected_Areas.geojson")
Attraction_sites<-st_read("Tourist_attractions.shp")
fuel<-st_read("fuel.shp")
Hotels<-st_read("Hotels.shp" )


#setting color palettes for symbolization
#color function for protected areas
pal1=colorFactor(topo.colors(4), Protected_Areas$DESIGNATE)

#color function for the Attraction sites
pal2=colorFactor(viridis(3), Attraction_sites$Type)

#color function for IBA
pal3=colorFactor(rocket(6), fuel$name)

#color function for hotels
pal4=colorFactor(turbo(4), Hotels$TYPE)

#creating some icons
icons <- awesomeIcons(
  icon = 'ios-close',
  iconColor = 'black',
  library = 'ion')

#Introducing leaflets
library(leaflet)
basemap<-leaflet()%>%
  addTiles(group="OSM(Default)")%>%
  addProviderTiles(providers$Esri.WorldImagery,group = "Esri.WorldImagery")%>%
  addProviderTiles(providers$CartoDB.Positron,group = "CartoDB.Positron") %>%
  addEasyButton(easyButton(
    icon="fa-globe", title="Zoom to Level 1",
    onClick=JS("function(btn, map){ map.setZoom(1); }"))) %>%
  addEasyButton(easyButton(
    icon="fa-crosshairs", title="Locate Me",
    onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) 
basemap %>%
  addCircleMarkers(data = Attraction_sites,
                   color=pal2(Attraction_sites$Type),
                   radius = 0.1,
                   group = "Attraction Sites",
                   clusterOptions = markerClusterOptions(),
                   popup =paste("<h3>Attraction Site<h3>",
                                "<b>Name:</b>",Attraction_sites$name,"<br>",
                                "<b>Type:</b>",Attraction_sites$Type))%>%
  addPolygons(data=Counties,
              color = "grey",
              opacity = 0.7,
              weight = 0.1,
              highlightOptions = highlightOptions(
                weight = 2,
                color = "red",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              label =paste(Counties$NAME_1),
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"),
              group = "Kenya Counties")%>%
  addPolygons(data = Protected_Areas,
              color = pal1(Protected_Areas$DESIGNATE),
              weight = 1,
              opacity = 0.5,
              popup =paste0("<h3>Protected Area</h3>",
                            "<b>Area_Name:</b>", Protected_Areas$AREANAME,"<br>",
                            "<b>Type:</b>",Protected_Areas$DESIGNATE,"<br>",
                            "<b>Establishment_Year:</b>",Protected_Areas$YEAR,"<br>"), 
              group = "Protected Areas")%>%
  addCircleMarkers(data = Hotels,
                   color=pal4(Hotels$TYPE),
                   radius = 0.1,
                   group = "Hotels",
                   clusterOptions = markerClusterOptions(),
                   popup =paste("<h3>Hotel<h3>",
                                "<b>Name:</b>",Hotels$NAME,"<br>",
                                "<b>Type:</b>",Hotels$TYPE))%>%
  addCircleMarkers(data = fuel,
                   radius = 0.1,
                   group = "Petrol Stations",
                   clusterOptions = markerClusterOptions(),
                   popup =paste("<h3>Fueling Station<h3>",
                                "<b>Name:</b>",fuel$name,"<br>",
                                "<b>Street:</b>",fuel$addrstreet))%>%
  addLegend(pal = pal1,
            values = Protected_Areas$DESIGNATE,
            title = "Protected Areas",
            opacity = 2,
            position = "bottomright")%>%
  addLegend(pal = pal2,
            values = Attraction_sites$Type,
            title = "Attraction Sites",
            opacity = 2,
            position = "bottomleft")%>%
  addLegend(pal = pal4,
            values =Hotels$TYPE,
            title = "Hotels",
            opacity = 2,
            position = "topleft")%>%
  
  addMeasure(position = "topright",
             primaryLengthUnit = "meters",
             primaryAreaUnit = "sqmeters",
             activeColor = "red",
             completedColor = "green")%>%

  # Layers control
  addLayersControl(
    baseGroups = c("OSM (default)", "Esri.WorldImagery", "CartoDB.Positron"),
    overlayGroups = c("Protected Areas",
                      "Kenya Counties",
                      "Attraction Sites",
                      "Petrol Stations",
                      "Hotels" ),
    options = layersControlOptions(collapsed = TRUE))





