/*
            image {
                id: icon
                x: theme.horizontalpagemargin
                anchors.verticalcenter: labelcolumn.verticalcenter
                visible: model.status !== weather.loading
                width: theme.iconsizemedium
                height: theme.iconsizemedium
                source: model.weathertype.length > 0 ? "image://theme/icon-m-weather-" + model.weathertype
                                                       + (highlighted ? "?" + theme.highlightcolor : "")
                                                     : ""
            }

*/

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../js/storage.js" as Store
//import "../js/storage.js" as Store

ListItem {

    contentHeight: contentrow.height + separatorBottom.height
    function localDate (timestamp) {
        date.toLocaleString('de-de', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});
    }

    Row {
        y: 200
        id: contentrow
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        spacing: Theme.paddingMedium //xmpp clients on macos
        Button {
            //text: model.timestamp.split('t')[1].split('+')[0];
            text: model.name
            width: parent.width / 2
            //color: Theme.highlightColor
            color: Theme.primaryColor
            onClicked: {
                 pageStack.push(Qt.resolvedUrl("../pages/OverviewPage.qml"), {
                                    "name": name,
                                    "lat": lat,
                                    "lon": lon});
            }
        }
        Button {
            id: deleteMe
            //text: qsTr("Delete")
            Image {
              source: "image://theme/icon-m-delete?"  // + Theme.highlightColor
            }
            onClicked: {
                //console.debug(model.locationId);
                Store.removeLocation(model.locationId);
                fetchCities();
            }
        }

    }
    Separator {
        y: 200
        id: separatorBottom
        visible: index < listView.count
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        color: Theme.backgroundGlowColor
    }
}

