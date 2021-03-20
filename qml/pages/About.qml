/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator { flickable: flickable }

        Column {
            id: column

            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - (2 * Theme.paddingLarge)
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Hacker News, News Reader"
            }
            Label {
                text: "Version 1.0.0"
                color: Theme.primaryColor
                wrapMode: TextEdit.WordWrap
                width: parent.width
            }
            Label {

                width: parent.width - (2 * Theme.paddingLarge)
                wrapMode: Text.WrapWord
                text: "Viewer: https://news.ycombinator.com/"
            }
            Label {
                text: "Contact the poetaster, <a href=\"mailto:blueprint@poetaster.de?subject=About%20Hackernews%20SailfishOS\">blueprint@poetaster.de</a>"
                color: Theme.primaryColor
                linkColor: "#ffffff"
                wrapMode: TextEdit.WordWrap
                width: parent.width
                font.pixelSize: units.fx("small")
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }
            Label {
                text: "Source code available in <a href=\"https://github.com/poetaster/harbour-hackernews\">github</a> under the terms of GPLv3 license."
                color: Theme.primaryColor
                linkColor: "#ffffff"
                wrapMode: TextEdit.WordWrap
                width: parent.width
                font.pixelSize: units.fx("small")
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }
            }

        } // Column
    }
}






