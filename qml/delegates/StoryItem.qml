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
                /*{
                    if (model.title)
                        return model.title
                    else
                        return model.text
                }*/
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall

            }

            Label {
                text: model.comms

                width: parent.width
                wrapMode: Text.WordWrap

                font.pixelSize: Theme.fontSizeSmall
            }
            /*Label {
                //text: model.comms
                text: {
                    if (model.comms)
                        return model.comms
                    else
                        return model.descendants
                }
                textFormat: Text.RichText
                width: parent.width
                wrapMode: Text.WordWrap

                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
            }*/
        }
    }

    Separator {
        id: separatorBottom
        //visible: index < listView.count
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        color: Theme.primaryColor
    }
}
