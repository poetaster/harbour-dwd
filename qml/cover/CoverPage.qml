/*

*/

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: back
    //width: parent.width - 2*x
    Label {
        anchors.top: back.top
        id: label
        text: qsTr("Hacker News")
    }
    Image {

        id:hnImage
        anchors.centerIn: parent
        source: "/usr/share/icons/hicolor/86x86/apps/harbour-HackerNews.png"
        //anchors.fill: parent

    }

    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: 'image://theme/icon-cover-refresh'
            //onTriggered: firstpage.label.text = '0'
        }
    }

}


