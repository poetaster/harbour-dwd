/*
 * This file is part of harbour-dwd.
 * Copyright (C) 2023 <blueprint@poetaster.de> Mark Washeim
 *
 * harbour-dwd is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-dwd is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-meteoswiss.  If not, see <http://www.gnu.org/licenses/>.
 *
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
    property var oindex

    function updateModel(index){

        console.log("func index: " + index)

        for (var i = 0; i < 24; i++) {
            switch( index ) {
               case 0 : {
                   listModel.insert(i, model0.get(i))
                   break
               }
               case 1 : {
                   listModel.insert(i, model1.get(i))
                   break
               }
               case 2 : {
                   listModel.insert(i, model2.get(i))
                   break
               }
               case 3 : {
                   listModel.insert(i,model3.get(i))
                   break
               }
               case 4 :  {
                   listModel.insert(i, model4.get(i))
                   break
               }
               default : if (debug) console.log("none")

            }
        }

    }
    function reloadDetails(){
        if (name === "") { name="Berlin" }
        if (lat === "") { lat="52.52" }
        if (lon ==="") { lon="13.41"  }

        if (debug) console.debug("daily: "+dailyDate)
        if (debug) console.debug("oindex: "+oindex)

        // update the listModel from previously obtained values.
        updateModel(oindex)

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

        if (listModel.count > 23){
            if (debug) console.log("cached")
            if (debug) console.log(listModel.count)

            /*
            for (var i = 0; i < weather.length && i < 30; i++) {
                //console.debug(JSON.stringify(response.weather[i]));
                if (debug) console.debug(weather[i]);
                listModel.append(weather[i]);
            };
            */

        } else {

            var uri = "https://api.brightsky.dev/weather?tz="+tzname + "&lat=" + lat + "&lon=" + lon + "&date=" + passDate //+ "&max_dist=5000";
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

    }

    allowedOrientations: Orientation.Portrait

    ListModel {
        id: listModel
    }
    Component.onCompleted: {
        /*
          we do this in the ListView
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
                    listModel.clear()
                    reloadDetails()
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
                    listModel.clear()
                    oindex+=1
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
                //only update view if we have full count
                if (listModel.count === 24){
                    var time = new Date();
                    // only move if it's current day
                    if (time.toLocaleString(locale, "ddd MMM dd") === headerDate) {
                        tindex = time.toTimeString(Locale.LongFormat).split(':')[0]
                        if (debug) console.debug(tindex)
                        // set the index first
                        listView.currentIndex = tindex
                        listView.positionViewAtEnd()
                        listView.positionViewAtIndex(tindex, ListView.Beginning)
                    }
                }
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


