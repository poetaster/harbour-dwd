/*
 * This file is part of harbour-dwd.
 * Copyright (C) 2021 <blueprint@poetaster.de> Mark Washeim
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

import QtQuick 2.6
import Sailfish.Silica 1.0

import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0

import "../js/locations.js" as Locs
import "../js/storage.js" as Store
import "../delegates"


Page {
    property bool debug: false
    property string lat
    property string dailyDate
    property string name
    property string lon
    property string rurl

    onStatusChanged: {

        if (PageStatus.Activating) {
            rurl= "https://www.rainviewer.com/map.html?loc=" + lat + "00," + lon +"00,5&oFa=0&oC=1&oU=0&oCS=1&oF=0&oAP=1&c=1&o=83&lm=1&layer=radar&sm=1&sn=1&undefined=1"
            if (debug) console.debug(rurl)
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
    id:radarView
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        WebView {
            /* This will probably be required from 4.4 on. */
            Component.onCompleted: {
                WebEngineSettings.setPreference("security.disable_cors_checks", true, WebEngineSettings.BoolPref)
                //WebEngineSettings.setPreference("security.fileuri.strict_origin_policy", false, WebEngineSettings.BoolPref)
            }
            id: webView
            anchors.fill: parent
            //url: "https://www.rainviewer.com/map.html?loc=" + lat + "00," + lon +"00,5&oFa=0&oC=1&oU=0&oCS=1&oF=0&oAP=1&c=1&o=83&lm=1&layer=radar&sm=1&sn=1&undefined=1"
            url: rurl
        }

    }

}