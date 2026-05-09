import QtQuick 2.6
import Sailfish.Silica 1.0

import "../js/storage.js" as Store

ListItem {
    //property var now;
    //contentHeight: contentRow.height + separatorBottom.height
    function localDate (timestamp) {
        timestamp.toLocaleString('de-de', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});
    }
    function remove() {
        //root.deletingItems = true
        remorseDelete(function() {
            //Store.delCoverLocation(model.location_id);
            Store.removeLocation(model.location_id);
            fetchCities();
        })
    }
    /*
    root.deletingItems = true
    var remorse = Remorse.popupAction(
                root, "Cleared",
                function() {
                    listModel.clear()
                })
    remorse.canceled.connect(function() { root.deletingItems = false })
    */
    onClicked: {
        Store.setCoverLocation(model.location_id);
        //reload();
        modelStateConnector.changedLocation()
        pageStack.animatorPush(Qt.resolvedUrl("../pages/OverviewPage.qml"), {
                           "name":name,
                           "lat":lat,
                           "lon":lon});
    }

    ListView.onRemove: animateRemoval()
    enabled: !root.deletingItems
    opacity: enabled ? 1.0 : 0.0
    Behavior on opacity { FadeAnimator {}}

    menu: Component {
        ContextMenu {
            MenuItem {
                text: qsTr("Delete")
                onClicked: remove()
            }
        }
    }

    Label {
        x: Theme.horizontalPageMargin
        width: parent.width - 2 * x
        anchors.verticalCenter: parent.verticalCenter
        text: model.name
        truncationMode: TruncationMode.Fade
        font.capitalization: Font.Capitalize
        font.pixelSize: Theme.fontSizeLarge
    }
    Item {
        x: Theme.horizontalPageMargin
        width: parent.width / 4
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        //visible: reorder_mode
        IconButton {
           id: mvup_btn
           icon.source: "image://theme/icon-m-up?" + (pressed? Theme.highlightColor: Theme.primaryColor)
           onClicked: listModel.move( index, index-1, 1 )
           anchors.left: parent.left
           anchors.verticalCenter: parent.verticalCenter
       }
       IconButton {
           id: mvdw_btn
           icon.source: "image://theme/icon-m-down?" + (pressed? Theme.highlightColor: Theme.primaryColor)
           onClicked: listModel.move( index, index+1, 1 )
           anchors.left: mvup_btn.right
           //anchors.margins: Theme.paddingSmall
           anchors.verticalCenter: parent.verticalCenter
       }
    }
}
