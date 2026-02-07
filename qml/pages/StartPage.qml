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
 * along with harbour-dwd.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../js/locations.js" as Locs
import "../js/storage.js" as Store
import "../delegates"
import "../js/locales.js" as TZ

Page {
    FontLoader {
        id: localFont
        source: "../png/weathericons-regular-webfont.ttf"
    }
    id: startPage

    property bool deletingItems

    property var cities
    property var now

    property string name
    property string lat
    property string lon
    property var hourly

    property string dDay
    property string dMonth
    property string dYear
    property bool debug: false

    allowedOrientations: Orientation.Portrait
    anchors.fill: parent

    Component.onCompleted: {
        //searchField.forceActiveFocus();
        //now = new Date();
        //now = now.toLocaleString('de-DE')
        //fetchCities();
    }

    function fetchCities() {
        debug = false;
        var response = Store.getLocationsList();
        listModel.clear();
        if (response.length > 0) {
            for (var i = 0; i < response.length && i < 500; i++) {
                var location = Store.getLocationData(response[i]);
                listModel.append(location);
                if (debug) console.debug(JSON.stringify(location))
            }
        } else {
            pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"),{});
        }
        now = new Date();
    }

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

                    var rain =  Locs.localNum(response.weather[index].precipitation)
                    var rain_prob =  response.weather[index].precipitation_probability
                    rainLabel.text =  "\uf084  "  + Locs.localNum(response.weather[index].precipitation) + " mm";
                    //rainLabel.text = response.weather[index].precipitation_probability + "% \uf084  "  + response.weather[index].precipitation + " mm";
                    var cloud =  response.weather[index].cloud_cover;
                    cloudLabel.text =  "\uf041  " + response.weather[index].cloud_cover + " %";

                    var temp =  Locs.localNum(response.weather[index].temperature);
                    tempLabel.text =  Locs.localNum(response.weather[index].temperature) + " °C" ;

                    var cond =  response.weather[index].condition ;
                    var icon =  Locs.mapIcon(response.weather[index].icon,hourly.rain,response.weather[index].condition) ;
                    iconLabel.text =  Locs.mapIcon(response.weather[index].icon,rain,response.weather[index].condition) ;

                    var wind  = Locs.localNum(response.weather[index].wind_speed);
                    windLabel.text  = "\uf050  " + Locs.localNum(response.weather[i].wind_speed) + " km/h";
                    hourly={temp:temp , cond: cond, icon: icon,  rain: rain, cloud:cloud, wind:wind };

                    if (debug) console.debug(JSON.stringify(hourly));

                }
            }
        });
    }

    onStatusChanged: {
        if (PageStatus.Activating) {
            if (debug) console.debug(listModel.count)
             fetchCities();

        }
       }

    SilicaFlickable {
        anchors.fill: parent
       // contentHeight: column.height
        //contentWidth: column.width; contentHeight: column.height
        PageHeader {
            id: header
            title: qsTr("Current Conditions")
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
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
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    startPage.fetchCities();
                }
            }

        }

        Column {
            id: column
            width: parent.width
             anchors.top: header.bottom
             /*Text{
                id:textone
                width: parent.width - 2*x
                height: 200
                x: Theme.horizontalPageMargin
                text:now.toLocaleString('de-DE').split(now.getFullYear())[0]
                color: Theme.primaryColor
                font.pixelSize:Theme.fontSizeLarge
             }*/

        Label {
            font.family: localFont.name
            text: name
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeLarge
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
            font.pixelSize: Theme.fontSizeHuge
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
            font.pixelSize: Theme.fontSizeSmall
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
            font.pixelSize: Theme.fontSizeSmall
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
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            horizontalAlignment: "AlignHCenter"
            verticalAlignment: "AlignVCenter"
        }


       Component.onCompleted:reload()

        }
        SectionHeader{
            id:listHeader
            anchors.top: column.bottom
            text: qsTr("Stored Locations")
            font.pixelSize: Theme.fontSizeLarge
        }
        SilicaListView {
            anchors.top: listHeader.bottom
            anchors.bottom: parent.bottom
            //Component.onCompleted:reload()
            id:listView
            //anchors.fill: parent
            height: contentItem.childrenRect.height / 2
            width: parent.width - 2*x

            //spacing: Theme.paddingSmall
            model:   ListModel {
                id: listModel
               onModelReset:  fetchCities()

            }
            delegate: LocationItem {
                id:locations
            }
            spacing: 2
            VerticalScrollDecorator { flickable: listView}
        }
    }
}
