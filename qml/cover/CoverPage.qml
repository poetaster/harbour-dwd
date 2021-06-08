/*

*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/locations.js" as Locs

CoverBackground {
    id: back
    property var debug;
    property var now;
    property string name;
    property string lat;
    property string lon;

    function reload(){
        debug = true;

        if (name === "") { name="Berlin" ;}
        if (lat === "") { lat="52.52"; }
        if (lon ==="") { lon="13.41"  ;}

        if (now == undefined) {
            now = new Date();
        }
        var dYear = now.getFullYear() ;
        var headerDate = now.toLocaleString().split(dYear)[0];
        var headerTime = now.toLocaleString().split(dYear)[1];
        if (debug ) console.debug(JSON.stringify(headerDate));
        if (debug ) console.debug(JSON.stringify(headerTime));

        var dDate = now.toISOString().replace(/T.*/,'') ;
        var uri = "https://api.brightsky.dev/weather?lat=" + lat + "&lon=" + lon + "&date=" + dDate;

        if (debug ) console.debug(JSON.stringify(uri)) ;

        Locs.httpRequest(uri, function(doc) {
            var response = JSON.parse(doc.responseText);

            var dailyDate = new Date(response.weather[0].timestamp);
            if (debug) console.debug(JSON.stringify(response.weather[0].timestamp));
            var dailyRain =  Locs.dailyTotal(response.weather ,"precipitation");
            var dailyCloud =  Locs.dailyAvg(response.weather ,"cloud_cover");
            var dailyIcon =  Locs.mapIcon(response.weather[15].icon,dailyRain,response.weather[15].condition) ;
            //var dailyIcon =  response.weather[15].icon) ;
            var dailyLow =  Locs.dailyMin(response.weather,"temperature");
            var dailyHigh =  Locs.dailyMax(response.weather,"temperature");
            var dailyWind=  Locs.dailyAvg(response.weather ,"wind_speed");
            var daily = {dailyDate: dailyDate, icon: dailyIcon , temperatureHigh:  dailyHigh, temperatureLow: dailyLow,
                totalRain: dailyRain, cloud_cover:dailyCloud, wind_speed:dailyWind};

            console.debug(JSON.stringify(daily));
        });
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

    onStatusChanged: {
        reload();
    }

    Label {
        anchors.top: back.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        id: label
        text: qsTr("Deutscher") + "\n" +
                qsTr("Wetter")+ "\n" +
                qsTr("Dienst");
    }
    Image {
        id:logoImage
        width: 128
        height: 128
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        //anchors.centerIn: parent
        source: "/usr/share/icons/hicolor/128x128/apps/harbour-dwd.png"

    }
    Image {
        id:dwdImage
        width: 258
        height: 69
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: "../png/dwd_logo_258x69.png"
        Component.onCompleted:reload()
    }



    /*CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: 'image://theme/icon-cover-refresh'
            //onTriggered: firstpage.label.text = '0'
        }
    }*/

}


