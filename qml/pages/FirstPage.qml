/*
  Copyright (C) 2021 Mark Washeim
  Contact: blueprint@poetaster.de


*/

/* types
  story item
  https://hacker-news.firebaseio.com/v0/item/26455058.json
{

    "by": "harporoeder",
    "descendants": 7,
    "id": 26455058,
    "kids": [
        26455852,
        26455399
    ],
    "score": 63,
    "time": 1615727266,
    "title": "EBPFSnitch: An eBPF based Linux Application Firewall",
    "type": "story",
    "url": "https://github.com/harporoeder/ebpfsnitch"

}
comment item
{

    "by": "XorNot",
    "id": 26455399,
    "kids": [
        26455454,
        26455981,
        26455555,
        26455715,
        26455644,
        26456079
    ],
    "parent": 26455058,
    "text": "This looks spectacular! Finally! This is functionality I&#x27;ve desperately wanted on Linux desktop. Link that up with with some of the SELinux on-demand tools and you have a plausible way to run untrusted binaries without the overhead of completely containerizing them up front.",
    "time": 1615729821,
    "type": "comment"

}
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../delegates"

Page {
    id: page

    function httpRequest(url, callback) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                callback(doc);
            }
        }
        doc.open("GET", url);
        doc.send();
    }
    function reloadStories(){
        page.httpRequest("https://hacker-news.firebaseio.com/v0/topstories.json", function(doc) {
            var response = JSON.parse(doc.responseText);
            listModel.clear();
            for (var i = 0; i < response.length && i < 20; i++) {
                var storyIndex = response[i];
                page.httpRequest("https://hacker-news.firebaseio.com/v0/item/" + storyIndex + ".json", function(doc) {
                    var story = JSON.parse(doc.responseText);
                    console.debug(JSON.stringify(story));
                    listModel.append(story);
                });
            }
        });
    }
    onStatusChanged: {
        if (PageStatus.Activating) {
          page.reloadStories();
        }
        /*
        switch (status) {
            case PageStatus.Activating:
                indicator.visible = true;
                errorMsg.visible = false;
                timetableDesc.title = qsTr("Searching...");
                fahrplanBackend.getTimeTable();
                break;
            case PageStatus.Deactivating:
                errorMsg.visible = false;
                fahrplanBackend.parser.cancelRequest();
                break;
        }
        */
    }
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    page.reloadStories();
                }
            }
        }

        ListModel {
            id: listModel

        }


        SilicaListView {

            width: parent.width
            anchors.bottom: parent.bottom
            //anchors.top: header.bottom
            id: listView
            model: listModel
            anchors.fill: parent

            header: PageHeader {
                title: qsTr("HackerNews")
            }
            //text: descendants  + ":  " + title + " " + kids.count

            delegate: NewsItem {
                id: delegate

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ShowStory.qml"), {
                                       "storyBy": by,
                                       "storyUrl": url,
                                       "storyId": id,
                                       //"storyText": text,
                                       "storyTitle": title});
                }
            }

            VerticalScrollDecorator {}
        }


        /*PullDownMenu{

        }*/
    }
}


