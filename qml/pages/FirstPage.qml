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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../delegates"
import "../js/locations.js" as Locs

Page {
    id: page
    property string name;
    property string lat;
    property string lon;

    function reloadStories(){
        if (name === "") { name="Berlin" ;}
        if (lat === "") { lat="52.52"; }
        if (lon ==="") { lon="13.41"  ;}

        var now = new Date();
        var passDate = now.getFullYear() + "-" + (now.getMonth()+1) + "-" + now.getDate();
        // const dateStr = date.toISOString().split('T')[0];

        var uri = "https://api.brightsky.dev/weather?lat=" + lat + "&lon=" + lon + "&date=" + passDate;
        //console.debug(uri);
        Locs.httpRequest(uri, function(doc) {
            var response = JSON.parse(doc.responseText);
            listModel.clear();
            for (var i = 0; i < response.weather.length && i < 30; i++) {
                //console.debug(JSON.stringify(response.weather[i]));
                //console.debug(response.weather[i]);
                listModel.append(response.weather[i]);
            };
        });
    }

    ListModel {
        id: listModel
    }
    onStatusChanged: {

        if (PageStatus.Activating) {
            //console.debug(listModel.count)
            if (listModel.count < 1) {
                page.reloadStories();
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
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

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
                    page.reloadStories();
                }
            }
        }

        SilicaListView {
            width: parent.width
            anchors.bottom: parent.bottom
            //anchors.top: header.bottom
            id: listView
            model: listModel
            anchors.fill: parent

            header: PageHeader {
                title: qsTr("DeutscherWetterDienst")
            }
            //text: descendants  + ":  " + title + " " + kids.count


            delegate: WeatherItem{
                id: delegate

                /*onClicked: {
                    pageStack.push(Qt.resolvedUrl("ShowStory.qml"), {
                                       "storyBy": by,
                                       "storyUrl": url,
                                       "storyId": id,
                                       //"storyText": text,
                                       "storyTitle": title});
                }*/
            }

            VerticalScrollDecorator {}
        }


        /*PullDownMenu{

        }*/
    }
}


