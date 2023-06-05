/*

*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Store
import "../js/locations.js" as Locs
import "../js/locales.js" as TZ

CoverBackground {
    FontLoader {
        id: localFont
        source: "../png/weathericons-regular-webfont.ttf"
    }
    id: back
    property bool debug: false
    property var now
    property string name
    property string lat
    property string lon
    property var hourly

    function reload(){
        var tz = TZ.jstz.determine(); // Determines the time zone of the browser client
        var tzname = tz.name(); // Returns the name of the time zone eg "Europe/Berlin"

        var cLocation = Store.getLocationData(Store.getCoverLocation());
        if (debug) console.debug(JSON.stringify(cLocation));
        name = cLocation.name;
        lat = cLocation.lat;
        lon = cLocation.lon;

        if (name === "") { name="Berlin" ;}
        if (lat === "") { lat="52.52"; }
        if (lon ==="") { lon="13.41"  ;}

        now = new Date();
        var dYear = now.getFullYear() ;
        var headerDate = now.toLocaleString().split(dYear)[0];
        var headerTime = now.toLocaleString().split(dYear)[1];
        if (debug ) console.debug(JSON.stringify(now.getHours()));
        if (debug ) console.debug(JSON.stringify(headerTime));

        var dDate = now.toISOString().replace(/T.*/,'') ;
        if (debug ) console.debug(JSON.stringify(dDate));

        var uri = "https://api.brightsky.dev/weather?tz="+tzname+"&lat=" + lat + "&lon=" + lon + "&date=" + dDate;

        if (debug ) console.debug(JSON.stringify(uri)) ;

        hourly = new Array; //({date:"" , temp: "", cond: "", icon: "",  rain: "", cloud:"", wind:""});

        Locs.httpRequest(uri, function(doc) {
            var response = JSON.parse(doc.responseText);
            for (var i = 0; i < response.weather.length ; i++) {
                var hourlyDate = new Date(response.weather[i].timestamp);
                if (hourlyDate.getHours().toLocaleString() === now.getHours().toLocaleString() ) {
                    var index = now.getHours();
                    if (debug ) console.debug(JSON.stringify(hourlyDate.getHours()));
                    if (debug ) console.debug(JSON.stringify(now.getHours()));
                    if (debug ) console.debug(JSON.stringify(i));

                    var rain =  response.weather[index].precipitation;
                    rainLabel.text =response.weather[index].precipitation_probability + "% \uf084  "  + response.weather[index].precipitation + " mm";
                    var cloud =  response.weather[index].cloud_cover;
                    cloudLabel.text =  "\uf041  " + response.weather[index].cloud_cover + " %";

                    var temp =  response.weather[index].temperature;
                    tempLabel.text =  response.weather[index].temperature + " °C" ;

                    var cond =  response.weather[index].condition ;
                    var icon =  Locs.mapIcon(response.weather[index].icon,hourly.rain,response.weather[index].condition) ;
                    iconLabel.text =  Locs.mapIcon(response.weather[index].icon,rain,response.weather[index].condition) ;

                    var wind  = response.weather[index].wind_speed;
                    windLabel.text  = "\uf050  " + response.weather[i].wind_speed;
                    hourly={temp:temp , cond: cond, icon: icon,  rain: rain, cloud:cloud, wind:wind };

                    if (debug) console.debug(JSON.stringify(hourly));

                }
            }
        });
    }

    onStatusChanged: {
        //reload();
    }

    Column {
        id: contentRow
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        spacing: Theme.paddingMedium

        Component.onCompleted: reload();

        Label {
            font.family: localFont.name
            text: name
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.primaryColor
            horizontalAlignment: "AlignHCenter"
            verticalAlignment: "AlignVCenter"
            topPadding: 48
        }

        Label {
            font.family: localFont.name
            id:tempLabel
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.highlightColor
            horizontalAlignment: "AlignHCenter"
            verticalAlignment: "AlignVCenter"
        }

        Label {
            font.family: localFont.name
            id:iconLabel
            //topPadding: 24
            //bottomPadding: 24
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraLarge + 24
            color: Theme.highlightColor
            horizontalAlignment: "AlignHCenter"
            verticalAlignment: "AlignVCenter"
        }
        Label {
            font.family: localFont.name
            id:rainLabel
            topPadding: 4
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
            horizontalAlignment: "AlignHCenter"
            verticalAlignment: "AlignVCenter"
        }
        Label {
            font.family: localFont.name
            id:cloudLabel
            topPadding: 4
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
            horizontalAlignment: "AlignHCenter"
            verticalAlignment: "AlignVCenter"
        }
        Label {
            font.family: localFont.name
            id:windLabel
            topPadding: 4
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.highlightColor
            horizontalAlignment: "AlignHCenter"
            verticalAlignment: "AlignVCenter"
        }

    }

    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: 'image://theme/icon-cover-refresh'
            onTriggered: reload();
        }
    }

}


