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
import Sailfish.Silica 1.0

import "../js/locations.js" as Locs
import "../js/storage.js" as Store
import "../delegates"

Page {
    property var cities;

    id: startPage
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        //searchField.forceActiveFocus();
        fetchCities();
    }

    function fetchCities() {
        var response = Store.getLocationsList();
        console.debug(JSON.stringify(response))
        listModel.clear();
        if (response.length > 0) {
            for (var i = 0; i < response.length && i < 500; i++) {
                var location = Store.getLocationData(response[i]);
                listModel.append(location);
                console.debug(JSON.stringify(location))
            }
        } else {
            pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"),{});
        }
    }

    anchors.fill: parent

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

            SilicaListView {
                id:listView
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: 1000
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
