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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id:root

    ListModel{
        id: model0
    }
    ListModel{
        id: model1
    }
    ListModel{
        id: model2
    }
    ListModel{
        id: model3
    }
    ListModel{
        id: model4
    }
    ListModel{
        id: model5
    }
    ListModel{
        id: model6
    }
    ListModel{
        id: model7
    }
    ListModel{
        id: model8
    }
    ListModel{
        id: model9
    }
    initialPage: Component { StartPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

}
