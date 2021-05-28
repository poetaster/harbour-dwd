/*
  Copyright (C) 2021 Mark Washeim
  Contact: blueprint@poetaster.de


*/

/* requests: https://api.brightsky.dev/
weather?lat=52.52&lon=13.41&date=2021-04-30 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../delegates"
import "../js/locations.js" as Locs

Page {
    id: page
    property var debug;
    property string name;
    property string lat;
    property string lon;
    property var now;
    property var weather;
    property string dailyDate;
    property string headerDate;
    property string weatherDetails;
    property var index;

    function reloadDetails(){

        debug = false;

        if (name === "") { name="Berlin" ;}
        if (lat === "") { lat="52.52"; }
        if (lon ==="") { lon="13.41"  ;}

        if (debug) console.debug("daily: "+dailyDate);

        if (dailyDate === "") {
            now = new Date();
        } else {
            now = new Date(dailyDate);
        }
        if (debug) console.debug("now: "+now);

        var passDate = now.toISOString().replace(/T.*/,'') ;
        if (debug) console.debug("passDate: "+passDate);
        var dYear = now.getFullYear() ;
        // header display date
        headerDate = now.toLocaleString().split(dYear)[0];
        // not being used yet
        if (weatherDetails !== ""){
            for (var i = 0; i < weather.length && i < 30; i++) {
                //console.debug(JSON.stringify(response.weather[i]));
                if (debug) console.debug(weather[i]);
                listModel.append(weather[i]);
            };
        } else {

            var uri = "https://api.brightsky.dev/weather?lat=" + lat + "&lon=" + lon + "&date=" + passDate;
            if (debug) console.debug(uri);

            Locs.httpRequest(uri, function(doc) {
                var response = JSON.parse(doc.responseText);
                //weather = response;
                listModel.clear();
                for (var i = 0; i < response.weather.length && i < 30; i++) {
                    if (debug) console.debug(response.weather[i]);
                    listModel.append(response.weather[i]);
                };
            });
        }
    }

    allowedOrientations: Orientation.Portrait

    ListModel {
        id: listModel
    }
    onStatusChanged: {

        if (PageStatus.Activating) {
            //console.debug(listModel.count)
            if (listModel.count < 1) {
                page.reloadDetails();
            }
         }

        /*
        switch (status) {
            case PageStatus.Activating:
                indicator.visible = true;
                errorMsg.visible = false;
                break;
            case PageStatus.Deactivating:
                errorMsg.visible = false;
                break;
        }
        */
    }
    anchors.fill: parent


    SilicaFlickable {
        anchors.fill: parent
        quickScroll: true
        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("About.qml"),{});
                }
            }
            MenuItem {
                text: qsTr("Locations")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"),{});
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    page.reloadDetails();
                }
            }
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Next")
                onClicked: {
                    now = Locs.addDays(now, 1);
                    if (debug) console.debug(now);
                    dailyDate = now;
                    page.reloadDetails();
                }
            }
        }

        SilicaListView {
            header: PageHeader {
                id: vDate
                title: name + " : " + headerDate
            }
            anchors.fill: parent
            //x: Theme.horizontalPageMargin
            width: parent.width
            height: 2000
            id: listView
            model: listModel
            delegate: WeatherItem{
                id: delegate
                /*onClicked: {
                    pageStack.push(Qt.resolvedUrl(".qml"), {  "iId": id });
                }*/
            }
            VerticalScrollDecorator {flickable: listView}
        }

    }
}


