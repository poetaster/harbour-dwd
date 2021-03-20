import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    contentHeight: contentRow.height + separatorBottom.height

    Row {
        id: contentRow
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        spacing: Theme.paddingSmall

        Column {
            id: column
            width: parent.width - parent.spacing
            spacing: Theme.paddingSmall
            Label {
                text: model.by

                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
            }
            Label {
                text: model.comms
                /* text:
                {
                    if (model.text)
                        return model.text
                    else
                        return model.descendants
                } */

                textFormat: Text.StyledText
                width: parent.width
                wrapMode: Text.WordWrap
                linkColor: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                onLinkActivated: {
                    Qt.openUrlExternally(link)
                }

            }
        }
    }
    Text {}

    Separator {
        id: separatorBottom
        //visible: index < listView.count
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        color: Theme.primaryColor
    }
}
