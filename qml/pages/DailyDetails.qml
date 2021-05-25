/*
  Copyright (C) 2021 Mark Washeim
  Contact: blueprint@poetaster.de


*/

/* requests: https://api.brightsky.dev/
weather?lat=52.52&lon=13.41&date=2021-04-30 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../delegates"
import "../js/locations.js" as Locs

Page {
    id: page
    property string name;
    property string lat;
    property string lon;
    property var now;
    property var weather;
    property string dailyDate;
    property string headerDate;
    property string weatherDetails;
    property string dDay;
    property string dMonth;
    property string dYear;
    property var index;

    function reloadDetails(){
        if (name === "") { name="Berlin" ;}
        if (lat === "") { lat="52.52"; }
        if (lon ==="") { lon="13.41"  ;}

       // console.debug("daily: "+dailyDate);
        if (dailyDate === "") {
            now = new Date();
        } else {
            now = new Date(dailyDate);
        }
        //console.debug("now: "+now);

        dDay = now.getDate();
        dMonth = (now.getMonth()+1) ;
        dYear = now.getFullYear() ;

        var passDate = dYear + "-" + dMonth + "-" + dDay;
        //console.debug(passDate);
        headerDate = now.toLocaleString().split(dYear)[0];

        //headerDate = now.toLocaleString('de-DE', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});
        if (weatherDetails !== ""){
            for (var i = 0; i < weather.length && i < 30; i++) {
                //console.debug(JSON.stringify(response.weather[i]));
                console.debug(weather[i]);
                listModel.append(weather[i]);
            };
        } else {

            var uri = "https://api.brightsky.dev/weather?lat=" + lat + "&lon=" + lon + "&date=" + passDate;
            //console.debug(uri);
            Locs.httpRequest(uri, function(doc) {
                var response = JSON.parse(doc.responseText);
                //weather = response;
                listModel.clear();
                for (var i = 0; i < response.weather.length && i < 30; i++) {
                    //console.debug(JSON.stringify(response.weather[i]));
                    //console.debug(response.weather[i]);
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
                    now.setDate(now.getDate() + 1);
                    console.debug(now);
                    page.reloadDetails();
                }
            }
        }
        /*Row {

            Label {
                topPadding:  120
                height:100
                leftPadding: 30
                id:totalRain
                text: "Rain: " + Locs.dailyTotal(weather.weather ,"precipitation") + " mm"
            }
            Label {
                topPadding:  120
                height:100
                leftPadding: 30
                id:avgWind
                text: "Avg Temp: " + Locs.dailyAvg(weather.weather ,"temperature") + " C"
            }
        }*/

        SilicaListView {
            header: PageHeader {
                id: vDate
                //title: name + " : " + dMonth + " " + dDay
                title: name + " : " + headerDate //now.toLocaleString().split(now.getFullYear())[0]
            }
            anchors.fill: parent
            //anchors.top: vDate.bottom
            //x: Theme.horizontalPageMargin
            width: parent.width
            height: 2000
            id: listView
            model: listModel
            //highlight: Rectangle { color: Theme.backgroundColor }
            delegate: WeatherItem{
                id: delegate
                /*onClicked: {
                    pageStack.push(Qt.resolvedUrl("ShowStory.qml"), {  "storyId": id });
                }*/
            }
            VerticalScrollDecorator {flickable: listView}
        }

        /*PullDownMenu{

        }*/
    }
}


