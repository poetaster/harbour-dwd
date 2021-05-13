/*
  Copyright (C) 2021 Mark Washeim
  Contact: blueprint@poetaster.de


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



    function reloadDetails(){
        if (name === "") { name="Berlin" ;}
        if (lat === "") { lat="52.52"; }
        if (lon ==="") { lon="13.41"  ;}

        if (dDay === ""){
            now = new Date();
        }
        dDay = now.getDate();
        dMonth = (now.getMonth()+1) ;
        dYear = now.getFullYear() ;

        var passDate = dYear + "-" + dMonth + "-" + dDay;
        //console.debug(passDate);
        headerDate = now.toLocaleString('de-DE');
        headerDate = headerDate.split(dYear)[0];
        //headerDate = now.toLocaleString('de-DE', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});

        var uri = "https://api.brightsky.dev/weather?lat=" + lat + "&lon=" + lon + "&date=" + passDate;
        Locs.httpRequest(uri, function(doc) {
            var response = JSON.parse(doc.responseText);
            weather = response;
            for (var i = 0; i < response.weather.length && i < 30; i++) {
                //console.debug(JSON.stringify(response.weather[i]));
                //listModel.append(response.weather[i]);
            };
        });
    }

    allowedOrientations: Orientation.All
    anchors.fill: parent
    Component.onCompleted: page.reloadDetails();

    ListModel {
        id: listModel
    }
    /*onStatusChanged: {
                page.reloadDetails();

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
        //title: name + " : " + dMonth + " " + dDay
        title: name + " : " + headerDate
    }
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

            MouseArea {
                id:area1
                width: parent.width
                height: 2000
                Row {
                   height: 2000
                   id:contentRow
                    width: parent.width
                    Column {
                        topPadding:  120
                        id: column1
                        width: parent.width / 2
                        spacing: Theme.paddingSmall
                        leftPadding: 30
                        Label {
                            id:lowTemp
                            height:100
                            text: qsTr("Low") + ": "  + Locs.dailyMin(weather.weather,"temperature") + " °C"
                        }
                        Image {
                            id: weatherImage
                            width:120
                            height:120
                            //source: "image://theme/icon-m-right?" + Theme.highlightColor
                            source: "../png/"+ weather.weather[11].icon + ".svg.png"
                            x: Theme.horizontalPageMargin
                            /* source: model.weatherType.length > 0 ? "image://theme/icon-m-weather-" + model.weatherType
                                                           + (highlighted ? "?" + Theme.highlightColor : "")
                                                         : ""*/
                        }
                        Label {
                            id:highTemp
                            height:100
                            text: "High: " + Locs.dailyMax(weather.weather ,"temperature") + " °C"
                        }
                    }
                    Column {
                        id: column2
                        width: parent.width / 2
                        spacing: Theme.paddingSmall
                        topPadding:  120
                        Label {
                            id:totalRain
                            height:100
                            leftPadding: 30
                            text: "Rain: " + Locs.dailyTotal(weather.weather ,"precipitation") + " mm"
                        }
                        Label {
                            id:avgWind
                            height:100
                            leftPadding: 30
                            text: "Avg Temp: " + Locs.dailyAvg(weather.weather ,"temperature") + " C"
                        }
                        Label {
                            id:avgCloud
                            height:100
                            leftPadding: 30
                            text: "Avg. Cloud: " + Locs.dailyAvg(weather.weather ,"cloud_cover") + ""
                        }
                    }
                }
                     onClicked: {
                      pageStack.push(Qt.resolvedUrl("DailyDetails.qml"), { "name": name, "lat": lat, "lon": lon});
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
    }
}
