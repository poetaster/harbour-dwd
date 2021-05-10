/*

*/

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: back
    //width: parent.width - 2*x
    Label {
        anchors.top: back.top
        anchors.horizontalCenter: parent.horizontalCenter
        id: label
        text: qsTr("Deutscher") + "\n"  +
                qsTr("Wetter") + "\n" +
                qsTr("Dienst");
    }
    Image {

        id:hnImage
        anchors.centerIn: parent
        source: "/usr/share/icons/hicolor/86x86/apps/harbour-dwd.png"
        //source: Qt.resolvedUrl("harbour-dwd.png")
        //anchors.fill: parent

    }

    /*CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: 'image://theme/icon-cover-refresh'
            //onTriggered: firstpage.label.text = '0'
        }
    }*/

}


