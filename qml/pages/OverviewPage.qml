/*
  Copyright (C) 2021 Mark Washeim
  Contact: blueprint@poetaster.de


*/

/* requests: https://api.brightsky.dev/
weather?lat=52.52&lon=13.41&date=2021-04-30 */

/* types
{
    weather: [
        {
            timestamp: "2021-05-01T00:00:00+02:00",
            source_id: 6894,
            precipitation: 0,
            pressure_msl: 1014.8,
            sunshine: null,
            temperature: 7.4,
            wind_direction: 60,
            wind_speed: 5,
            cloud_cover: 100,
            dew_point: 4,
            relative_humidity: null,
            visibility: 45000,
            wind_gust_direction: 90,
            wind_gust_speed: 16.9,
            condition: "dry",
            fallback_source_ids: {9 items},
            icon: "cloudy"
        }
    ],
    sources: [
        {
            id: 6894,
            dwd_station_id: "00433",
            observation_type: "historical",
            lat: 52.4675,
            lon: 13.4021,
            height: 48,
            station_name: "Berlin-Tempelhof",
            wmo_station_id: "10384",
            first_record: "2010-01-01T00:00:00+00:00",
            last_record: "2021-04-30T23:00:00+00:00",
            distance: 5869
        },
        {11 items},
        {11 items}
    ]

}


*/

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../delegates"
import "../js/locations.js" as Locs

Page {
    id: page
    property string name;
    property string lat;
    property string lon;
    property string headerDate;
    property string dDay;
    property string dMonth;
    property string dYear;
    property var weather;
    property var now;

    function addDays(tNow,days) {
      var date = new Date (tNow.valueOf());
      date.setDate(date.getDate() + days);
      return date;
    }

    function reload(){
        if (name === "") { name="Berlin" ;}
        if (lat === "") { lat="52.52"; }
        if (lon ==="") { lon="13.41"  ;}

        if (dDay === ""){
            now = new Date();
        }
        dDay = now.getDate();
        dMonth = (now.getMonth()+1) ;
        dYear = now.getFullYear() ; //"../png/"+ weather.weather[11].icon + ".svg.png"

        var passDate = dYear + "-" + dMonth;
        //console.debug(passDate);
        headerDate = now.toLocaleString('de-DE');
        headerDate = headerDate.split(dYear)[0];
        //headerDate = now.toLocaleString('de-DE', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});

        listModel.clear();

        for (var j = 0; j < 5; j++) {
            var dDate = passDate + "-" + addDays(now,j).getDate() ;
            var uri = "https://api.brightsky.dev/weather?lat=" + lat + "&lon=" + lon + "&date=" + dDate;

            //console.debug(JSON.stringify(uri));
            Locs.httpRequest(uri, function(doc) {
                var response = JSON.parse(doc.responseText);
                weather = response;
                var dailyIcon =  response.weather[11].icon ;
                var dailyLow =  Locs.dailyMin(response.weather,"temperature");
                var dailyHigh =  Locs.dailyMax(response.weather,"temperature");
                var dailyRain =  Locs.dailyTotal(response.weather ,"precipitation");
                var dailyCloud =  Locs.dailyAvg(response.weather ,"cloud_cover");
                var dailyWind=  Locs.dailyAvg(response.weather ,"wind_speed");
                var daily = {icon: dailyIcon , temperatureHigh:  dailyHigh, temperatureLow: dailyLow,
                            totalRain: dailyRain, cloud_cover:dailyCloud, wind_speed:dailyWind};

                listModel.append(daily);

                //console.debug(JSON.stringify(listModel[0]));
            });
       }
    }

    allowedOrientations: Orientation.Portrait
    anchors.fill: parent

    Component.onCompleted: page.reload();

    /*onStatusChanged: {

        if (PageStatus.Activating) {
            //console.debug(listModel.count)
            if (listModel.count < 1) {
                page.reloadDetails();
            }
        }
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
    } */

    PageHeader {
        id: vDate
        title: name + " : " + headerDate
    }
    SilicaFlickable {

        anchors.fill: parent
        quickScroll: true

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
                    page.reload();
                }
            }
        }

        SilicaListView {
            anchors.fill: parent
            //anchors.top: vDate.bottom
            topMargin: 200
            //x: Theme.horizontalPageMargin
            width: parent.width
            height: 2000
            id: listView
            model:   ListModel {
                id: listModel
                /*function update() {
                    reload()
                }
                Component.onCompleted:update() */
            }
            delegate: ForecastItem {
                id:delegate
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("DailyDetails.qml"), { "name": name, "lat": lat, "lon": lon, "now": now });
                }
            }
            spacing: 2
            VerticalScrollDecorator {flickable: listView}
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("Next")
                onClicked: {
                    now.setDate(now.getDate() + 1);
                    console.debug(now);
                    page.reload();
                }
            }
        }

    }
}
