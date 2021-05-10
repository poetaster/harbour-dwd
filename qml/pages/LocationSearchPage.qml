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

Page {
    property var cities;

    id: searchPage
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        searchField.forceActiveFocus();
        fetchCities();
    }
    function fetchCities() {
        Locs.httpRequest("https://brightsky.dev/demo/cities.json", function(doc) {
            var response = JSON.parse(doc.responseText);
            listModel.clear();
            cities = response;
            for (var i = 0; i < response.length && i < 2500; i++) {
                listModel.append(response[i]);
                //console.debug(JSON.stringify(cities[i]))
            };
        });
    }
    function search(string) {
        var ret = [];
        //console.debug(JSON.stringify(cities[0]));
        //listModel.clear();
        for (var i = 0; i < cities.length; i++) {
            if (string !== "" && cities[i].name.indexOf(string) >= 0) {
                ret.push({"name": cities[i].name});
                listModel.append(cities[i])
                //console.debug(JSON.stringify(cities[i].name));
                //console.debug(JSON.stringify(listModel.count));
            }
            if (ret.length === 50) break;
        }
        return ret;
    }

    anchors.fill: parent

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PageHeader {
            id: header
            title: qsTr("Choose Location")
        }

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
        }
        Column {
            id: column
            width: parent.width
            anchors.top: searchField.bottom

            SilicaListView {
                id:sListview
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: 2000
                //spacing: Theme.paddingSmall
                model:   ListModel {
                    id: listModel
                    function update() {
                        clear()
                        if (searchField.text != "") {
                            searchPage.search(searchField.text);
                        }
                    }
                    //Component.onCompleted:update()
                }
                delegate: ListItem {
                    Label {
                        text: model.name
                        truncationMode: TruncationMode.Fade
                    }
                    onClicked: {
                        Store.addLocation(model);
                        //pageStack.pop()
                        pageStack.push(Qt.resolvedUrl("OverviewPage.qml"), {
                                           "name": name,
                                           "lat": lat,
                                           "lon": lon});
                    }
                }
                spacing: 2
                VerticalScrollDecorator { flickable: sListview}
            }
        }
    }
}
