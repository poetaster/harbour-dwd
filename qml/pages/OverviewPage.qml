/*
  Copyright (C) 2021 Mark Washeim
  Contact: blueprint@poetaster.de


*/


import QtQuick 2.2
import Sailfish.Silica 1.0
import "../delegates"
import "../js/locations.js" as Locs
import "../js/locales.js" as TZ

Page {
    id: page
    property string name;
    property string lat;
    property string lon;
    property string dailyDate; // used to go to the next dayk
    property string headerDate; // used to go to the next dayk
    property var weather;
    property var now;
    property var debug;

    //onWeatherChanged: updateWeatherModel();
    //onQueryChanged: updateJSONModel();

    function reload(){
        debug = false;

        if (name === "") { name="Berlin" ;}
        if (lat === "") { lat="52.52"; }
        if (lon ==="") { lon="13.41"  ;}

        if (now == undefined) {
            now = new Date();
        }
        var tz = TZ.jstz.determine(); // Determines the time zone of the browser client
        var tzname = tz.name(); // Returns the name of the time zone eg "Europe/Berlin"

        var dYear = now.getFullYear() ;
        headerDate = now.toLocaleString().split(dYear)[0];

        // clear the listmodel
        //listModel.clear();
        weather = new Array;
        //listModel.clear();
        for (var j = 0; j < 5; j++) {
            var dDate = Locs.addDays(now,j).toISOString().replace(/T.*/,'') ;
            var uri = "https://api.brightsky.dev/weather?tz="+tzname+"&lat=" + lat + "&lon=" + lon + "&date=" + dDate;
            if (debug) console.debug(uri)
            // initialize listModel slot
            // sadly, this doesn't work
            //listModel.set(j,{})
            Locs.httpRequestIndex(uri,j, function(index,doc) {
                var response = JSON.parse(doc.responseText);
                var dailyDate = new Date(response.weather[0].timestamp);
                var dailyRain =  Locs.dailyTotal(response.weather ,"precipitation");
                var dailyCloud =  Locs.dailyAvg(response.weather ,"cloud_cover");
                var dailyIcon =  Locs.mapIcon(response.weather[15].icon,dailyRain,response.weather[15].condition) ;
                //var dailyIcon =  response.weather[15].icon) ;
                var dailyLow =  Locs.dailyMin(response.weather,"temperature");
                var dailyHigh =  Locs.dailyMax(response.weather,"temperature");
                var dailyWind=  Locs.dailyAvg(response.weather ,"wind_speed");
                var daily = {dailyDate: dailyDate, icon: dailyIcon , temperatureHigh:  dailyHigh, temperatureLow: dailyLow,
                    totalRain: dailyRain, cloud_cover:dailyCloud, wind_speed:dailyWind};

                weather[index]=daily;
                // the listmodel set method does not work. well sometimes.
                //listModel.set(index,daily)
                //listModel.insert(index,daily);
                // restart the timer. gives us enough time to
                // get all the results
                if(index < 4) getTimer.restart();
                //console.debug(JSON.stringify(weather[index]));
            });
        }
    }

    function updateWeatherModel(){
        listModel.clear();
        var modelComplete = true;
        for (var i = 0; i < 5; i++) {
            if (weather[i] === ""){
                if (debug) console.debug(JSON.stringify('weather: ' + i));
                modelComplete = false;
            }
        }
        for (var j = 0; j < 5; j++) {
            if (modelComplete === true){
                if (debug) console.debug(JSON.stringify('index: ' + j));
                listModel.append(weather[j]);
            }
        }
    }

    allowedOrientations: Orientation.Portrait
    anchors.fill: parent

    Timer{
        id:getTimer
        interval: 400
        repeat: false
        running:true
        triggeredOnStart:true
        onTriggered: updateWeatherModel()
    }

    //Component.onCompleted: page.reload();

    /*onStatusChanged: {
        switch (status) {
            case PageStatus.Activating:
                indicator.visible = true;
                errorMsg.visible = false;
                page.reloadDetails();
                break;
            case PageStatus.Deactivating:
                errorMsg.visible = false;
                break;
        }
    } */


    SilicaFlickable {

        anchors.fill: parent
        quickScroll: true

        PullDownMenu {
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
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    page.reload();
                }
            }
        }
        PageHeader {
                id: vDate
                title: name + " : " + now.toLocaleString().split(now.getFullYear())[0].slice(0,-1)
        }

        SilicaListView {
            anchors.fill: parent
            //anchors.top: vDate.bottom
            topMargin: 200
            //x: Theme.horizontalPageMargin
            width: parent.width
            height: 2000
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
                    //console.debug(JSON.stringify(weather[index]))
                    pageStack.push(Qt.resolvedUrl("DailyDetails.qml"), { "name": name, "lat": lat, "lon": lon, "dailyDate": dailyDate   });
                }
            }
            spacing: 2
            VerticalScrollDecorator {flickable: listView}
        }


        PushUpMenu {
            MenuItem {
                text: qsTr("Next")
                onClicked: {
                    now = Locs.addDays(now, 5);
                    //now = dailyDate;
                    console.debug(now);
                    dailyDate = now.toLocaleString();
                    page.reload();

                }
            }
        }

    }
}
