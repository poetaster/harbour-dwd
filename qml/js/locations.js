/*
 * This file is part of harbour-dwd.
 * Copyright (C) 2021 blueprint@poetaster.de Mark Washeim
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
 * along with harbour-dwd.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

//.import "cities.js" as Cities
/*
                        showRequestInfo("Headers -->");
                        showRequestInfo(doc.getAllResponseHeaders ());
                        showRequestInfo("Last modified -->");
                        showRequestInfo(doc.getResponseHeader ("Last-Modified"));
*/

function httpRequest(url, callback) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState === XMLHttpRequest.DONE) {
            callback(doc);
        }
    }
    doc.open("GET", url);
    doc.send();

}

function loadJSON(file, callback) {

   var xobj = new XMLHttpRequest();
   //xobj.overrideMimeType("application/json");
   xobj.open('GET', file, true);
   xobj.onreadystatechange = function () {
       if (xobj.readyState === XMLHttpRequest.DONE) {
           callback(xobj);
       }
         /*if (xobj.readyState == 4 && xobj.status == "200") {
           // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
           callback(xobj.responseText);
         }*/

   };
    xobj.open("GET",file)
   xobj.send();
}
/*  This json doc function takes and returns an index to the callback.
 * This permits it to be called in a loop.
 */

function httpRequestIndex(url, index, callback) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState === XMLHttpRequest.DONE) {
            callback(index,doc);
        }
    }
    doc.open("GET", url);
    doc.send();
}

function extractDaily(response) {
        var dailyDate = response.weather[0].timestamp;
        var dailyIcon =  response.weather[11].icon ;
        var dailyLow =  Locs.dailyMin(response.weather,"temperature");
        var dailyHigh =  Locs.dailyMax(response.weather,"temperature");
        var dailyRain =  Locs.dailyTotal(response.weather ,"precipitation");
        var dailyCloud =  Locs.dailyAvg(response.weather ,"cloud_cover");
        var dailyWind=  Locs.dailyAvg(response.weather ,"wind_speed");
        var daily = {dailyDate: dailyDate, icon: dailyIcon , temperatureHigh:  dailyHigh, temperatureLow: dailyLow,
                    totalRain: dailyRain, cloud_cover:dailyCloud, wind_speed:dailyWind};
    return daily;
}
function mapIcon(icon,precipitation,condition) {
// condition - dry┃fog┃rain┃sleet┃snow┃hail┃thunderstorm┃
// icon - clear-day┃clear-night┃partly-cloudy-day┃partly-cloudy-night┃cloudy┃fog┃wind┃rain┃sleet┃snow┃hail┃thunderstorm┃

    if ((icon === "partly-cloudy-day" || icon === "partly-cloudy-night")
            && (condition === "rain" || condition === "snow")
            &&   precipitation > 0.2 ) {
        icon = icon + '-' + condition;
    }
    if (icon === "cloudy"  && (condition === "rain" || condition === "snow") && precipitation > 0.2) {
        icon = icon + '-' + condition;
    }
   //console.debug(JSON.stringify(precipitation))
    var iconMapping = {
        'clear-day': '\uf00d',
        //'clear-night': '\uf02e',
        //'clear-night': '\uf077',
        'clear-night': '\uf02e\uf077',
        'partly-cloudy-day': '\uf002',
        'partly-cloudy-day-rain': '\uf009',
        'partly-cloudy-day-rain': '\uf009',
        'partly-cloudy-day-snow': '\uf00a',
        //'partly-cloudy-night': '\uf083',
        'partly-cloudy-night': '\uf086',
        'partly-cloudy-night-rain': '\uf029',
        'partly-cloudy-night-snow': '\uf067',
        'cloudy': '\uf013',
        'cloudy-rain': '\uf01a',
        'cloudy-snow': '\uf01b',
        'fog': '\uf014',
        'wind': '\uf050',
        'rain': '\uf019',
        'sleet': '\uf0b3',
        'snow': '\uf038',
        'hail': '\uf015',
        'thunderstorm': '\uf01e'
    }
    //console.debug(iconMapping[iconName])
    return iconMapping[icon]
}

function addDays(aDate,days) {
    var date = new Date (aDate.valueOf());
    date.setDate(date.getDate() + days);
    return date;
}

function getDetails(token) {
    return {
        name: name,
        latitude: lat,
        longitude: lon,
    }
}
function search(string) {
    var ret = [];
    for (var i = 0; i < Locations.LocationsList.length; i++) {
        if (string !== "" && Locations.LocationsList[i].indexOf(string) >= 0) {
            ret.push({"name": Locations.LocationsList[i]});
        }
        if (ret.length === 50) break;
    }
    return ret;
}

function dailyTotal(weather, key) {
    var total = 0;
        //console.debug(JSON.stringify(weather));
    for (var i = 0; i < weather.length; i++) {
             total += weather[i][key];
    }
    //console.debug(parseFloat(total).toPrecision(2))
    return parseFloat(total).toPrecision(2);
}

function dailyAvg(weather, key) {
    return dailyTotal(weather, key) / weather.length;
}

function dailyMax(weather, key) {
    var current = dailyAvg(weather,key);
    for (var i = 0; i < weather.length; i++) {
             if ( weather[i][key] > current ) {
                 current = weather[i][key];
             }
    }
    return current;
}

function dailyMin(weather, key) {
    var current = dailyMax(weather,key);
    for (var i = 0; i < weather.length; i++) {
             if ( weather[i][key] < current ) {
                 current = weather[i][key];
             }
    }
    return current;
}
/*
}.wi-day-sunny:before{content:"\f00d"
}.wi-day-cloudy:before{content:"\f002"
}.wi-day-cloudy-gusts:before{content:"\f000"
}.wi-day-cloudy-windy:before{content:"\f001"
}.wi-day-fog:before{content:"\f003"
}.wi-day-hail:before{content:"\f004"
}.wi-day-haze:before{content:"\f0b6"
}.wi-day-lightning:before{content:"\f005"
}.wi-day-rain:before{content:"\f008"
}.wi-day-rain-mix:before{content:"\f006"
}.wi-day-rain-wind:before{content:"\f007"
}.wi-day-showers:before{content:"\f009"
}.wi-day-sleet:before{content:"\f0b2"
}.wi-day-sleet-storm:before{content:"\f068"
}.wi-day-snow:before{content:"\f00a"
}.wi-day-snow-thunderstorm:before{content:"\f06b"
}.wi-day-snow-wind:before{content:"\f065"
}.wi-day-sprinkle:before{content:"\f00b"
}.wi-day-storm-showers:before{content:"\f00e"
}.wi-day-sunny-overcast:before{content:"\f00c"
}.wi-day-thunderstorm:before{content:"\f010"a
}.wi-night-clear:before{content:"\f02e"
}.wi-night-alt-cloudy:before{content:"\f086"
}.wi-night-alt-cloudy-gusts:before{content:"\f022"
}.wi-night-alt-cloudy-windy:before{content:"\f023"
}.wi-night-alt-hail:before{content:"\f024"
}.wi-night-alt-lightning:before{content:"\f025"
}.wi-night-alt-rain:before{content:"\f028"
}.wi-night-alt-rain-mix:before{content:"\f026"
}.wi-night-alt-rain-wind:before{content:"\f027"
}.wi-night-alt-showers:before{content:"\f029"
}.wi-night-alt-sleet:before{content:"\f0b4"
}.wi-night-alt-sleet-storm:before{content:"\f06a"
}.wi-night-alt-snow:before{content:"\f02a"
}.wi-night-alt-snow-thunderstorm:before{content:"\f06d"
}.wi-night-alt-snow-wind:before{content:"\f067"
}.wi-night-alt-sprinkle:before{content:"\f02b"
}.wi-night-alt-storm-showers:before{content:"\f02c"
}.wi-night-alt-thunderstorm:before{content:"\f02d"
}.wi-night-cloudy:before{content:"\f031"
}.wi-night-cloudy-gusts:before{content:"\f02f"
}.wi-night-cloudy-windy:before{content:"\f030"
}.wi-night-fog:before{content:"\f04a"
}.wi-night-hail:before{content:"\f032"
}.wi-night-lightning:before{content:"\f033"
}.wi-night-partly-cloudy:before{content:"\f083"
}.wi-night-rain:before{content:"\f036"
}.wi-night-rain-mix:before{content:"\f034"
}.wi-night-rain-wind:before{content:"\f035"
}.wi-night-showers:before{content:"\f037"
}.wi-night-sleet:before{content:"\f0b3"
}.wi-night-sleet-storm:before{content:"\f069"
}.wi-night-snow:before{content:"\f038"
}.wi-night-snow-thunderstorm:before{content:"\f06c"
}.wi-night-snow-wind:before{content:"\f066"
}.wi-night-sprinkle:before{content:"\f039"
}.wi-night-storm-showers:before{content:"\f03a"
}.wi-night-thunderstorm:before{content:"\f03b"
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

