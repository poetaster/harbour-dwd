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
import "../js/locales.js" as TZ

Page {
    id: detailsPage
    property bool debug: false
    property string name
    property string lat
    property string lon
    property var now
    property var weather
    property string dailyDate
    property string headerDate
    property string weatherDetails
    property var index
    property var locale: Qt.locale()
    property var tindex

    function reloadDetails(){
        if (name === "") { name="Berlin" }
        if (lat === "") { lat="52.52" }
        if (lon ==="") { lon="13.41"  }

        if (debug) console.debug("daily: "+dailyDate)

        if (dailyDate === "") {
            now = new Date();
        } else {
            now = new Date(dailyDate);
        }
        if (debug) console.debug("now: " + now);
        // console.debug(now.toLocaleDateString('de-DE', {timezone: 'long', weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'}));

        //var time = new Date();
        //if (debug) console.debug(time.toTimeString(Locale.LongFormat).split(':')[0] ) ;
        //tindex = time.toTimeString(Locale.LongFormat).split(':')[0]  ;

        // print(Date.fromLocaleString(locale, dateTimeString, "ddd yyyy-MM-dd hh:mm:ss"));
        // if (debug) console.log(now.toISOString().split('T')[1].split('+')[0].split(':')[0] + ":00");

        var tz = TZ.jstz.determine() ;// Determines the time zone of the browser client
        var tzname = tz.name() // Returns the name of the time zone eg "Europe/Berlin"
        if (debug) console.debug(tz.name());

        var passDate = now.toISOString().replace(/T.*/,'') ;
        if (debug) console.debug("passDate: "+passDate);
        var dYear = now.getFullYear() ;

        // header display date
        // headerDate = now.toLocaleString().split(dYear)[0]
        headerDate = now.toLocaleString(locale, "ddd MMM dd");

        // not being used yet
        if (weatherDetails !== ""){
            for (var i = 0; i < weather.length && i < 30; i++) {
                //console.debug(JSON.stringify(response.weather[i]));
                if (debug) console.debug(weather[i]);
                listModel.append(weather[i]);
            };
        } else {

            var uri = "https://api.brightsky.dev/weather?tz="+tzname + "&lat=" + lat + "&lon=" + lon + "&date=" + passDate;
            if (debug) console.debug(uri);

            Locs.httpRequest(uri, function(doc) {
                var response = JSON.parse(doc.responseText);
                //weather = response;
                listModel.clear();
                for (var i = 0; i < response.weather.length && i < 30; i++) {
                    //if (debug) console.debug(response.weather[i].condition);
                    listModel.append(response.weather[i]);
                };
            });
        }

        // set position in listView after all elements appended.
        //listView.positionViewAtIndex(tindex, ListView.Beginning)
    }

    allowedOrientations: Orientation.Portrait

    ListModel {
        id: listModel
    }
    Component.onCompleted: {
        /*
        var time = new Date();
        if (debug) console.debug(time.toTimeString(Locale.LongFormat).split(':')[0] )
        tindex = time.toTimeString(Locale.LongFormat).split(':')[0]
        listView.positionViewAtIndex(tindex, ListView.Beginning)
        listView.positionViewAtEnd()
        */
    }
    onStatusChanged: {

        if (PageStatus.Activating) {
            //console.debug(listModel.count)
            if (listModel.count < 1) {
                detailsPage.reloadDetails();
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
                text: qsTr("Refresh")
                onClicked: {
                    reloadDetails();
                }
            }
            MenuItem {
                text: qsTr("Rain Radar")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("RadarView.qml"), { "name": name, "lat": lat, "lon": lon, "dailyDate": dailyDate   });
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
                    reloadDetails();
                }
            }
        }

        SilicaListView {
            header: PageHeader {
                id: vDate
                title: name + " : " + headerDate
            }
            highlightFollowsCurrentItem: true
            onCountChanged:  {
                var time = new Date();
                if (debug) console.debug(time.toTimeString(Locale.LongFormat).split(':')[0] )
                tindex = time.toTimeString(Locale.LongFormat).split(':')[0]
                // set the index first
                listView.currentIndex = tindex
                listView.positionViewAtIndex(tindex, ListView.Beginning)
            }
            anchors.fill: parent
            //width: parent.width
            //height: contentItem.childrenRect.heigh
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


