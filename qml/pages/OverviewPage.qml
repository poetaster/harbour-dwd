/*
 * This file is part of harbour-dwd.
 * Copyright (C) 2023 <blueprint@poetaster.de> Mark Washeim
 *
 * harbour-dwd is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-dwd is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-meteoswiss.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../delegates"
import "../js/locations.js" as Locs
import "../js/locales.js" as TZ

Page {
    id: page
    property string name
    property string lat
    property string lon
    property string dailyDate // used to go to the next day
    property string headerDate // used to go to the next day
    property var weather
    property var now
    property bool debug: false
    property var locale: Qt.locale()

    //onWeatherChanged: updateWeatherModel();
    //onQueryChanged: updateJSONModel();
    function updateModel(index,response){

        for (var i = 0; i < response.weather.length && i < 30; i++) {
            switch( index ) {
               case 0 : {
                   model0.append(response.weather[i]);
                   break
               }
               case 1 : {
                   model1.append(response.weather[i]);
                   break
               }
               case 2 : {
                   model2.append(response.weather[i]);
                   break
               }
               case 3 : {
                   model3.append(response.weather[i]);
                   break
               }
               case 4 :  {
                   model4.append(response.weather[i]);
                   break
               }
               case 5 :  {
                   model5.append(response.weather[i]);
                   break
               }
               case 6 :  {
                   model6.append(response.weather[i]);
                   break
               }
               case 7 :  {
                   model7.append(response.weather[i]);
                   break
               }
               case 8 :  {
                   model8.append(response.weather[i]);
                   break
               }
               case 9 :  {
                   model9.append(response.weather[i]);
                   break
               }
               default : if (debug) console.log("none")

            }
        };

    }

    function reload(){
        model0.clear()
        model1.clear()
        model2.clear()
        model3.clear()
        model4.clear()
        model5.clear()
        model6.clear()
        model7.clear()
        model8.clear()
        model9.clear()

        debug = false;

        if (name === "") name="Berlin"
        if (lat === "" ) lat="52.52"
        if (lon ===""  ) lon="13.41"

        if (now === undefined) {
            now = new Date();
        }
        var tz = TZ.jstz.determine(); // Determines the time zone of the browser client
        var tzname = tz.name(); // Returns the name of the time zone eg "Europe/Berlin"

        var dYear = now.getFullYear() ;

        //headerDate = now.toLocaleString().split(dYear)[0];
        var headerDay = Locs.addDays(now, 9).toLocaleString(locale, "MM/dd");
        headerDate = now.toLocaleString(locale, "MM/dd - ") + headerDay;

        weather = new Array;
        for (var j = 0; j < 10; j++) {

            var dDate = Locs.addDays(now,j).toISOString().replace(/T.*/,'') ;
            //var uri = "https://api.brightsky.dev/weather?tz="+tzname+"&lat=" + lat + "&lon=" + lon + "&date=" + dDate + "&max_dist=5000";
            var uri = "https://api.brightsky.dev/weather?tz="+tzname+"&lat=" + lat + "&lon=" + lon + "&date=" + dDate ;

            if (debug) console.debug(uri)
            Locs.httpRequestIndex(uri,j, function(index,doc) {
                var response = JSON.parse(doc.responseText);
                var dailyDate = new Date(response.weather[0].timestamp);
                var dailyRain =  Locs.dailyTotal(response.weather ,"precipitation");
                var pRain =  Locs.dailyMax(response.weather,"precipitation_probability");
                var dailyCloud =  Locs.dailyAvg(response.weather ,"cloud_cover");
                var dailyIcon =  Locs.mapIcon(response.weather[15].icon,dailyRain,response.weather[15].condition) ;
                //var dailyIcon =  response.weather[15].icon) ;
                var dailyLow =  Locs.dailyMin(response.weather,"temperature");
                var dailyHigh =  Locs.dailyMax(response.weather,"temperature");
                var dailyWind=  Locs.dailyAvg(response.weather ,"wind_speed");
                var daily = {dailyDate: dailyDate, icon: dailyIcon , temperatureHigh:  dailyHigh, temperatureLow: dailyLow,
                    totalRain: dailyRain, likelyRain: pRain, cloud_cover:dailyCloud, wind_speed:dailyWind};

                weather[index]=daily
                updateModel(index,response)

                // restart the timer. gives us enough time to
                // get all the results since ORDER is not garanteed

                if( index > 8) getTimer.restart();
                if (debug) console.debug(JSON.stringify(weather[index]));
            });
        }
    }

    function updateWeatherModel(){


        listModel.clear();

        var modelComplete = true;
        for (var i = 0; i < 10; i++) {

            if (weather[i] === ""){
                if (debug) console.debug(JSON.stringify('weather: ' + i));
                modelComplete = false;
            }
        }
        for (var j = 0; j < 10; j++) {
            if (modelComplete === true){
                listModel.append(weather[j]);
            }
        }
        if (debug) console.debug("length0 : " + model0.count);
        if (debug) console.debug("length1 : " + model1.count);
        if (debug) console.debug("length2 : " + model2.count);
        if (debug) console.debug("length3 : " + model3.count);
        if (debug) console.debug("length4 : " + model4.count);

        /*for (var i = 0; i < model4.count; i++) {
                console.log("element " + i + ":" + model4.get(i).timestamp)
        }*/
    }

    allowedOrientations: Orientation.Portrait
    anchors.fill: parent

    Timer{
        id:getTimer
        interval: 400
        repeat: false
        running:false
        triggeredOnStart:true
        onTriggered: updateWeatherModel()
    }

    //Component.onCompleted: page.reload();

   /* onStatusChanged: {
        switch (status) {
            case PageStatus.Activating:
                //indicator.visible = true;
                //errorMsg.visible = false;
                page.reload();
                break;
            case PageStatus.Deactivating::w

                //errorMsg.visible = false;
                break;
        }
    }*/


    SilicaFlickable {

        anchors.fill: parent
        quickScroll: true

        PullDownMenu {
            /*
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("About.qml"),{});
                }
            }
            MenuItem {
                text: qsTr("GPS Locations")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ManageLocations.qml"),{});
                }
            }
            MenuItem {
                text: qsTr("Add Locations")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"),{});
                }
            }
            */
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    page.reload();
                }
            }
            MenuItem {
                text: qsTr("Rain Radar")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("RadarView.qml"), { "name": name, "lat": lat, "lon": lon, "dailyDate": dailyDate   });
                }
            }
        }
        PageHeader {
                id: vDate
                //title: name + " : " + now.toLocaleString().split(now.getFullYear())[0].slice(0,-1)
                title: name + " : " + headerDate
        }

        SilicaListView {
            anchors.fill: parent
            //anchors.top: vDate.bottom
            topMargin: 200
            //x: Theme.horizontalPageMargin
            width: parent.width
            height: contentItem.childrenRect.heigh
            id: listView
            model:   ListModel {
                id: listModel
                function update() {
                    page.reload()
                }
                Component.onCompleted:update()
            }
            delegate: ForecastItem {
                id:delegate
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("DailyDetails.qml"), { "name": name, "lat": lat, "lon": lon, "dailyDate": dailyDate, "oindex": index   });
                }
            }
            spacing: 2
            VerticalScrollDecorator {flickable: listView}
        }

        /*
        PushUpMenu {
            MenuItem {
                text: qsTr("Next")
                onClicked: {
                    now = Locs.addDays(now, 5);
                    //now = dailyDate;
                    //console.debug(now);
                    dailyDate = now.toLocaleString();
                    page.reload();

                }
            }
        }
        */

    }
}
