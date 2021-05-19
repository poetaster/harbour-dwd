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


// Measures

Cloud cover	%	%
Dew point	°C	K
Precipitation	mm	kg / m²
Pressure	hPa	Pa
Relative humidity	%	%
Sunshine	min	s
Temperature	°C	K
Visibility	m	m
Wind direction	°	°
Wind speed	km / h	m / s
Wind gust direction	°	°
Wind gust speed	km / h	m / s

// Internal icons

            Image {
                id: icon
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: labelColumn.verticalCenter
                visible: model.status !== Weather.Loading
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                source: model.weatherType.length > 0 ? "image://theme/icon-m-weather-" + model.weatherType
                                                       + (highlighted ? "?" + Theme.highlightColor : "")
                                                     : ""
            }

*/


import QtQuick 2.6
import Sailfish.Silica 1.0

ListItem {
    contentHeight: contentRow.height + separatorBottom.height
    function localDate (timestamp) {
                date.toLocaleString('de-de', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'});
    }


    Row {
        id: contentRow
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        spacing: Theme.paddingSmall

        Column {
            id: column
            width: parent.width / 3
            spacing: Theme.paddingSmall
            Label {
                visible: index < listView.count
                text: model.timestamp.split('T')[1].split('+')[0].split(':')[0] + ":00";
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color:
                    if( index % 2 === 0){
                        return Theme.highlightColor
                    } else {
                        return Theme.primaryColor
                    }
            }
            Label {
                text: model.temperature + " °C"
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                //color: Theme.highlightColor
            }

        }
        Column {
            id: column2
            width: parent.width / 3
            spacing: Theme.paddingSmall
            Image {
                id: weatherImage
                width:120
                height:120
                x: Theme.horizontalPageMargin
                source:
                    if ( model.icon === "cloudy" && parseFloat(model.precipitation) > 0.0 ) {
                     return "../png/showers.svg.png";
                    } else if ( model.icon === "partly-cloudy-day" && parseFloat(model.precipitation) > 0.1 ) {
                     return "../png/partly-cloudy-day-showers.svg.png";
                    } else {
                     return "../png/"+ model.icon + ".svg.png";
                    }

                //source: "image://theme/icon-m-right?" + Theme.highlightColor
                /* source: model.weatherType.length > 0 ? "image://theme/icon-m-weather-" + model.weatherType
                                                       + (highlighted ? "?" + Theme.highlightColor : "")
                                                     : ""*/
            }
            Label {
                text: model.cloud_cover + "% cloud  " + model.precipitation + " mm"
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                //color: Theme.highlightColor
            }
            /*Label {
                text:  model.icon
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                //color: Theme.highlightColor
            }*/
        }
        Column {
            id: column3
            width: parent.width / 3
            spacing: Theme.paddingSmall
            Label {
                text: model.wind_speed + " km/h " + model.wind_direction + " °"
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                //color: Theme.highlightColor
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

    Separator {
        id: separatorBottom
        //visible: index < listView.count
        x: Theme.horizontalPageMargin
        width: 1 //parent.width - 2*x
        //color: Theme.hightlightColor
    }
}

