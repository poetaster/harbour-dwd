/*
 * This file is part of harbour-dwd.
 * Copyright (C) 2021  blueprint@poetaster.de based on code from
 * Copyright (C) 2018-2019  Mirian Margiani (harbour-meteoswiss)
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-dwd.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

.pragma library
.import QtQuick.LocalStorage 2.0 as LS


function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

var initialized = false

function getDatabase() {
    var db = LS.LocalStorage.openDatabaseSync("harbour-dwd", "1.0", "DWD Location Cache", 10000);

    if (!initialized) {
        initialized = true;
        doInit(db);
    }

    return db;
}

function doInit(db) {
    // Database tables: (primary key in all-caps)
    // locations: LOCATION_ID, name, latitude, longitude
    // settings: SETTING, value

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS locations(\
            location_id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL,\
            lat REAL NOT NULL, lon REAL NOT NULL)');
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT NOT NULL PRIMARY KEY, value TEXT)');
    });
}

function simpleQuery(query, values, getSelectedCount) {
    var db = getDatabase();
    var res = undefined;
    values = defaultFor(values, []);

    if (!query) {
        console.log("error: empty query");
        return undefined;
    }

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql(query, values);

            if (rs.rowsAffected > 0) {
                res = rs.rowsAffected;
            } else {
                res = 0;
            }

            if (getSelectedCount === true) {
                res = rs.rows.length;
            }
        });
    } catch(e) {
        console.log("error in query: '"+ e +"', values=", values);
        res = undefined;
    }

    return res;
}

function vacuumDatabase() {
    var db = getDatabase();

    try {
        db.transaction(function(tx) {
            // VACUUM cannot be executed inside a transaction, but the LocalStorage
            // module cannot execute queries without one. Thus we have to manually
            // end the transaction from inside the transaction...
            var rs = tx.executeSql("END TRANSACTION;");
            var rs2 = tx.executeSql("VACUUM;");
        });
    } catch(e) {
        console.log("error in query: '"+ e);
    }
}

function addLocation(locationData) {
    var lat = defaultFor(locationData.lat, 0);
    var lon = defaultFor(locationData.lon, 0);
    var name = defaultFor(locationData.name, null);
    var id =  getLocationsCount() + 10;
    var res = simpleQuery('INSERT INTO locations VALUES (?,?,?,?);', [id, name, lat, lon ]);
    if (res !== 0 && !res) {
        console.log("error: failed to save location " + name + " to db");
    }
    return res;
}

function removeLocation(locationId) {
    var res = simpleQuery('DELETE FROM locations WHERE location_id=?;', [locationId]);
    if (!res) {
        console.log("error: failed to remove location " + locationId + " from db");
    }

    return res;
}

function getCoverLocation() {
    var db = getDatabase();
    var res = 0;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM settings WHERE setting="cover_location" LIMIT 1;');

            if (rs.rows.length > 0) {
                res = parseInt(rs.rows.item(0).value, 10);
            } else {
                res = 0;
            }
        });
    } catch(e) {
        console.log("error while loading cover location data");
        return 0;
    }

    return res;
}

function getNextCoverLocation(locationId) {
    var db = getDatabase();
    var res = 0;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations WHERE location_id > ? ORDER BY location_id LIMIT 1;', [locationId]);

            if (rs.rows.length === 0) {
                rs = tx.executeSql('SELECT * FROM locations ORDER BY location_id LIMIT 1;');

                if (rs.rows.length === 0) {
                    res = 0;
                    console.log("failed to get next cover location: no locations available");
                    return res;
                }
            }

            res = rs.rows.item(0).location_id;
        });
    } catch(e) {
        console.log("error while loading next cover location");
        return 0;
    }

    return res;
}

function setCoverLocation(locationId) {
    var db = getDatabase();
    var res = undefined;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', ['cover_location', locationId]);

            if (rs.rowsAffected > 0) {
                res = rs.rowsAffected;
            } else {
                res = 0;
            }
        });
    } catch(e) {
        console.log("error in query:", values)
        res = undefined;
    }

    if (res !== 0 && !res) {
        console.log("error: failed to save cover settings")
    }

    return res;
}

function getLocationsList() {
    var db = getDatabase();
    var res = [];

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations;', []);

            for (var i = 0; i < rs.rows.length; i++) {
                res.push(rs.rows.item(i).location_id);
            }
        });
    } catch(e) {
        console.log("error while loading locations list")
    }

    return res;
}

function getLocationsCount() {
    var db = getDatabase();
    var res = 0;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations;', []);
            res = rs.rows.length;
        });
    } catch(e) {
        console.log("error while loading locations count")
    }

    return res;
}

function getLocationData(locationId) {
    var db = getDatabase();
    var res = [];

    try {
        db.transaction(function(tx) {
            var rs = undefined;

            if (locationId) {
                rs = tx.executeSql('SELECT * FROM locations WHERE location_id=?;', [locationId]);
            } else {
                rs = tx.executeSql('SELECT * FROM locations ORDER BY name ASC;');
            }

            for (var i = 0; i < rs.rows.length; i++) {
                res.push({
                    locationId: rs.rows.item(i).location_id,
                    lat: rs.rows.item(i).lat,
                    lon: rs.rows.item(i).lon,
                    name: rs.rows.item(i).name,
                });
            }
        });
    } catch(e) {
        console.log("error while loading locations data for " + locationId)
        return [];
    }

    return res;
}

