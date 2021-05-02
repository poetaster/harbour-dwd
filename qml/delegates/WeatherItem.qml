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

ListItem {
    contentHeight: contentRow.height + separatorBottom.height

    Row {
        id: contentRow
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        spacing: Theme.paddingSmall

        Column {
            id: column
            width: parent.width - parent.spacing
            spacing: Theme.paddingSmall

            Label {
                text: "Time:" + model.timestamp
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall

            }

            Label {
                text: model.icon
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
            }

        }
    }

    Separator {
        id: separatorBottom
        //visible: index < listView.count
        x: Theme.horizontalPageMargin
        width: parent.width - 2*x
        color: Theme.primaryColor
    }
}

