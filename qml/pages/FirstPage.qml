/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    page.httpRequest("https://hacker-news.firebaseio.com/v0/topstories.json", function(doc) {
                        var response = JSON.parse(doc.responseText);
                        listModel.clear();
                        for (var i = 0; i < response.length && i < 20; i++) {
                            var storyIndex = response[i];
                            page.httpRequest("https://hacker-news.firebaseio.com/v0/item/" + storyIndex + ".json", function(doc) {
                                var story = JSON.parse(doc.responseText);
                                listModel.append(story);
                            });
                        }
                    });
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
            model: listModel;
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
                                       "storyTitle": title});
                }
            }

            VerticalScrollDecorator {}
        }


        /*PullDownMenu{

        }*/
    }
}


