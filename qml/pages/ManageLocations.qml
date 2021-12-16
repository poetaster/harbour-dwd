/*
 * This file is part of harbour-dwd.
 * Copyright (C) 2021 <blueprint@poetaster.de> Mark Washeim
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

import QtQuick 2.6
import QtPositioning 5.2
import Sailfish.Silica 1.0

import "../js/locations.js" as Locs
import "../js/storage.js" as Store
import "../delegates"
Page {

    property var cities
    property variant coordinate
    property var debug: true
    property var now
    property var coord
    property var lat
    property var lon
    property var name

    id: managePage
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        //fetchStoredCities();
    }
    function titleCase(str) {
        //str.toLowerCase().replace('/\b(\w)/g');
        //return str.toUpperCase();
        str = str.toLowerCase();
        var words = str.split(' ');
        var results = [];
        for (var i = 0; i < words.length; i++) {
            var letter = words[i].charAt(0).toUpperCase();
            results.push(letter + words[i].slice(1));
        }
        return results.join(' ');
    }

    function printableMethod(method) {
        if (method === PositionSource.SatellitePositioningMethods)
            return "Satellite";
        else if (method === PositionSource.NoPositioningMethods)
            return "Not available"
        else if (method === PositionSource.NonSatellitePositioningMethods)
            return "Non-satellite"
        else if (method === PositionSource.AllPositioningMethods)
            return "Multiple"
        return "source error";
    }
    /*
    "id": 4732,
    "dwd_station_id": null,
    "observation_type": "forecast",
    "lat": 48.92,
    "lon": 11.52,
    "height": 500.0,
    "station_name": "SWIS-PUNKT",
    "wmo_station_id": "X218",
    "first_record": "2021-06-23T10:00:00+00:00",
    "last_record": "2021-07-03T11:00:00+00:00",
    "distance": 4470.0
      */

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

    function gpsLocations() {
        debug = false;
        var uri = "https://api.brightsky.dev/sources?lat=" + lat + "&lon=" + lon + "&max_dist=30000";
        if (debug) console.debug(JSON.stringify(uri))
        Locs.httpRequest(uri, function(doc) {
            var response = JSON.parse(doc.responseText);
            listModel.clear();
            cities = response.sources;
            for (var i = 0; i < cities.length && i < 2500; i++) {
                if (cities[i].observation_type === "forecast") {
                    listModel.append(cities[i]);
                    if (debug) console.debug(JSON.stringify(cities[i]))
                }
            };
        });
    }
    function search(string) {
        var ret = [];
        if (debug) console.debug(JSON.stringify(cities[0]));
        listModel.clear();
        for (var i = 0; i < cities.length; i++) {
            if (string !== "" && cities[i].name.indexOf(string) >= 0) {

                ret.push({"name": cities[i].name});
                listModel.append(cities[i])
                //if(debug) console.debug(JSON.stringify(i));

                if(debug) console.debug(JSON.stringify(cities[i].name));
                //if(debug) console.debug(JSON.stringify(listModel.count));
            }
            if (ret.length === 50) break;
        }
        return ret;
    }

    PositionSource {
        id: positionSource
        //active: true

        onPositionChanged: {
            coord = positionSource.position.coordinate;
            if (debug) console.log("Coordinate:", coord.longitude, coord.latitude);
            lat = coord.latitude;
            lon = coord.longitude;

        }

        onSourceErrorChanged: {
            if (sourceError == PositionSource.NoError)
                return
            if (debug) console.log("Source error: " + sourceError)
            activityText.fadeOut = true
            stop()
        }

        /*onUpdateTimeout: {
            activityText.fadeOut = true
        }*/
    }

    SilicaFlickable {
        id:container
        anchors.fill: parent
        contentHeight: column.height
        //contentHeight: contentItem.childrenRect.heighta

        PageHeader {
            id: header
            title: qsTr("Position (GPS) Locations")
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
                text: qsTr("Add Locations")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"),{});
                }
            }
            MenuItem {
                text: qsTr("Start")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("StartPage.qml"),{});
                }
            }
        }

        Column {
            id: column
            y:60
            spacing: 10
            width: parent.width
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
            Label {
                id: posText
                font.bold: true
                padding:Theme.paddingLarge
                text: "Longitude: "+ coord.longitude + "\n" + "Latitude: " + coord.latitude
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
            Text {
                id: activityText;
                color: Theme.backgroundGlowColor
                font.bold: true
                padding:Theme.paddingLarge
                property bool fadeOut: false
                visible: true
                text: {
                    if (fadeOut)
                        return qsTr("Timeout occurred!")
                    else if (positionSource.active)
                       // this will, given source is marked active always be true
                       // why this is different than in 3.4, I don't know
                        return qsTr("Retrieving update...")
                    else
                        return ""
                }

                Timer {
                    id: fadeoutTimer; repeat: false; interval: 3000; running: activityText.fadeOut
                    onTriggered: { activityText.fadeOut = false; }
                }
            }
            /* Consider adding a search by Lat/Long
        SearchField {
            placeholderText: qsTr("Search")
            id: searchField
            width: parent.width
            anchors.top: header.bottom
            inputMethodHints: Qt.ImhNoPredictiveText

            onTextChanged: listModel.update()
            EnterKey.onClicked: {
                if (text != "") searchField.focus = false
            }
        }*/
            SilicaListView {
                //anchors.top: header.bottom
                id:listView
                leftMargin: Theme.paddingLarge
                topMargin: Theme.paddingLarge
                width: parent.width - 2*x
                height: contentItem.childrenRect.height - 200
                //anchors.horizontalCenter:  parent.horizontalCenter
                model:   ListModel {
                    id: listModel
                    function update() {
                        gpsLocations()
                    }

                    Component.onCompleted:update()
                }

                delegate: ListItem {
                    Label {
                        text: titleCase(model.station_name) + " - " + model.distance + qsTr(" meters")
                        truncationMode: TruncationMode.Fade
                    }
                    onClicked: {
                        var location = {"name": titleCase( model.station_name ), "lon": lon, "lat": lat}
                        Store.addLocation(location);
                        pageStack.pop()
                        /* pageStack.push(Qt.resolvedUrl("OverviewPage.qml"), {
                                           "name": name,
                                           "lat": lat,
                                           "lon": lon}); */
                    }
                }
                spacing: 2
                //VerticalScrollDecorator { flickable: listView}
                VerticalScrollDecorator {}
                ScrollDecorator { color: palette.primaryColor }
            }


        }
        VerticalScrollDecorator {}
        ScrollDecorator { color: palette.primaryColor }

        Button {
                id: locateButton
                text: "Locate & update"
                anchors.top: column.bottom
                anchors.left: column.left
                visible: true
                onClicked: {
                    if (positionSource.supportedPositioningMethods ===
                            PositionSource.NoPositioningMethods) {
                        //positionSource.nmeaSource = "nmealog.txt";
                        //sourceText.text = "(filesource): " + printableMethod(positionSource.supportedPositioningMethods);
                    }
                    positionSource.update();
                    gpsLocations();
                }
        }
        Text {id: sourceText; color: "white"; font.bold: true;
            anchors.top: locateButton.bottom
            anchors.left: locateButton.left
            text: "Source: " + printableMethod(positionSource.supportedPositioningMethods); style: Text.Raised; styleColor: "black";
            visible: false
        }


    }
}
