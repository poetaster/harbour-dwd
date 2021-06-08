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
 * along with harbour-dwd.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../js/locations.js" as Locs
import "../js/storage.js" as Store
import "../delegates"

Page {
    id: startPage

    property var cities;
    property var now;

    property string dDay;
    property string dMonth;
    property string dYear;
    property var debug;

    allowedOrientations: Orientation.Portrait

    Component.onCompleted: {
        //searchField.forceActiveFocus();
        //now = new Date();
        //now = now.toLocaleString('de-DE')
        //fetchCities();
    }

    function fetchCities() {
        debug = true;
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

    anchors.fill: parent

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
            title: qsTr("Stored Locations")
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
            SilicaListView {
                id:listView

                width: parent.width - 2*x
                height: 500

                //spacing: Theme.paddingSmall
                model:   ListModel {
                    id: listModel
                    function update() {
                        fetchCities()
                    }
                    Component.onCompleted:update()
                }
                delegate: LocationItem {
                    id:locations

                }
                spacing: 2
                VerticalScrollDecorator { flickable: sListview}
            }
        }
    }
}
