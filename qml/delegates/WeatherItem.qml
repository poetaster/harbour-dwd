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
}

*/


import QtQuick 2.6
import Sailfish.Silica 1.0
import "../js/locations.js" as Locs
ListItem {


    FontLoader {
        id: localFont
        source: "../png/weathericons-regular-webfont.ttf"
    }
    contentHeight: contentRow.height + separatorBottom.height + 8
    //opacity: !((index) & 1) ? Theme.opacityHigh : Theme.opacityLow
    Rectangle {
        height: contentRow.height + separatorBottom.height
        width:parent.width
        id:wrapper
        opacity: !((index) & 1) ? 0.7 : 1.0
        color: !((index) & 1) ? Theme.darkPrimaryColor : "transparent" //Theme.darkPrimaryColor
        Row {
            id: contentRow
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            spacing: Theme.paddingSmall
            Column {
                id: column
                width: parent.width * .30
                spacing: Theme.paddingMedium
                Text {
                    visible: index < listView.count
                    text: model.timestamp.split('T')[1].split('+')[0].split(':')[0] + ":00";
                    //text: model.timestamp;
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    //color: ((index % 2 === 0 ) ) ? Theme.highlightColor : Theme.primaryColor
                    color: Theme.primaryColor
                }
                Label {
                    text: model.temperature + " °C"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.highlightColor
                }

            }
            Column {
                id: column2
                width: parent.width * .30
                spacing: Theme.paddingMedium
                Label {
                    topPadding: 24
                    bottomPadding: 24
                    text:  Locs.mapIcon(model.icon,model.precipitation,model.condition)
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraLarge + 24
                    color: Theme.highlightColor
                    //horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }

                /*Image {
                    id: weatherImage
                    width:120
                    height:120
                    x: Theme.horizontalPageMargin
                    source:
                        if ( model.icon === "cloudy" && parseFloat(model.precipitation) > 0.2 ) {
                            return "../png/showers.svg.png";
                        } else if ( model.icon === "partly-cloudy-day" && parseFloat(model.precipitation) > 0.2 ) {
                            return "../png/partly-cloudy-day-showers.svg.png";
                        } else {
                            return "../png/"+ model.icon + ".svg.png";
                        }

                    //source: "image://theme/icon-m-right?" + Theme.highlightColor
                }*/

                /*Label {
                    text: model.cloud_cover + "% cloud  " + model.precipitation + " mm"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                }*/
            }
            Column {
                id: column3
                width: parent.width * .40
                spacing: Theme.paddingMedium
                Label {
                    topPadding: 8
                    //text: model.cloud_cover + "% \uf013 " +parseFloat(model.precipitation) + " mm \uf084 "
                    text: parseFloat(model.precipitation) + " mm \uf084 " + model.cloud_cover + "% \uf013 "
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.primaryColor
                }
                Text {
                    text: model.wind_speed + " km/h \uf050 " + model.wind_direction + " °"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.primaryColor
                }
                Label {
                    text: model.pressure_msl + " hPa"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    //color: Theme.highlightColor
                }

            }
        }
    }

    Separator {
        id: separatorBottom
        //visible: index < listView.count
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        height: 8 //parent.width - 2*x
        color: Theme.secondaryColor
        opacity: 0.0
    }
}

