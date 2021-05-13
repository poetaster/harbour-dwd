import QtQuick 2.6
import Sailfish.Silica 1.0

import "../js/storage.js" as Store

ListItem {

    contentHeight: contentRow.height + separatorBottom.height
    function localDate (timestamp) {
        date.toLocaleString('de-de', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});
    }

    Row {
        y:200
        id: contentRow
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        spacing: Theme.paddingSmall
        Button {
            //text: model.timestamp.split('t')[1].split('+')[0];
            text: model.name
            width: parent.width / 2
            //color: Theme.highlightColor
            color: Theme.primaryColor
            opacity: 0.5
            onClicked: {
                pageStack.push(Qt.resolvedUrl("../pages/OverviewPage.qml"), {
                                   "name": name,
                                   "lat": lat,
                                   "lon": lon});
            }
        }
        Button {
            id: deleteMe
            color: Theme.primaryColor
            opacity: 0.5
            //OpacityRampEffect
                x: Theme.horizontalPageMargin
            Image {
                //x: Theme.horizontalPageMargin
                x: Theme.paddingMedium
                y: Theme.paddingSmall
                source: "image://theme/icon-m-delete?"  // + Theme.highlightColor
            }
            text: qsTr("Delete")
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
        //visible: index < listView.count
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        color: Theme.darkSecondaryColor
    }
}
