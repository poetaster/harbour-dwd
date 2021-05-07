/*
 * This file is part of harbour-dwd.
 * Copyright (C) 2021  blueprint@poetaster.de Mark Washeim
 *
 * This is free software: you can redistribute it and/or modify
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


Page {
    id: overviewPage
    allowedOrientations: Orientation.All



    SilicaListView {
        id: locationsListView
        anchors.fill: parent

        property int itemCount: locationsModel.count
        onItemCountChanged: if (itemCount === 0) placeholder.enabled = true;

        ListModel { id: locationsModel }
        model: locationsModel

        header: PageHeader { title: qsTr("DWD") }
        VerticalScrollDecorator { flickable: locationsListView }

        PullDownMenu {
            Component.onCompleted: {
                overviewPage.dataUpdated.connect(function(newData, locationId) {
                    var readyList = Object.keys(meteoApp.dataIsReady).map(function(k) { return meteoApp.dataIsReady[k]; });
                    if (readyList.every(function(k) { return k ? true : false; })) {
                        busy = false
                    }
                });
                meteoApp.dataIsLoading.connect(function() { busy = true; });
            }

            MenuItem {
                text: qsTr("About")
                onClicked: About.pushAboutPage(pageStack)
            }

            MenuItem {
                text: qsTr("Add location")
                onClicked: pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"))
            }

            MenuItem {
                text: qsTr("Refresh")
                visible: locationsModel.count > 0
                onClicked: {
                    meteoApp.refreshData(undefined, false);
                }
            }

            Label {
                id: clockLabel
                text: new Date().toLocaleString(Qt.locale(), meteoApp.dateTimeFormat)
                color: Theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        ViewPlaceholder {
            id: placeholder
            enabled: (locationsModel.count === 0 && Storage.getLocationsCount() === 0)
            text: qsTr("Add a location first")
            hintText: qsTr("Pull down to add items")
        }

    }

}
