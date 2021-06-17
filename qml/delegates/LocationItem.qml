import QtQuick 2.6
import Sailfish.Silica 1.0

import "../js/storage.js" as Store

ListItem {
    //property var now;
    contentHeight: contentRow.height + separatorBottom.height
    function localDate (timestamp) {
        timestamp.toLocaleString('de-de', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});
    }

    Row {
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
                Store.setCoverLocation(model.location_id);
                pageStack.push(Qt.resolvedUrl("../pages/OverviewPage.qml"), {
                                   "name":name,
                                   "lat":lat,
                                   "lon":lon});
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
                if (debug) console.debug(model.location_id);

                Store.delCoverLocation(model.location_id);
                Store.removeLocation(model.location_id);
                fetchCities();
            }
        }

    }
    Separator {
        id: separatorBottom
        visible: index < listView.count
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        color: Theme.darkSecondaryColor
    }
}
