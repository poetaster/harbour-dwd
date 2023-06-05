var BRIGHTSKY_URL = 'https://api.brightsky.dev/'

//const jsonViewer = new JSONViewer();
//document.getElementById('response-json').appendChild(jsonViewer.getContainer());

function dailyTotal(weather, key) {
    return weather.reduce((total, record) => total + (record[key] || 0), 0.);
}

function dailyAvg(weather, key) {
    return dailyTotal(weather, key) / weather.length;
}

function dailyMax(weather, key) {
    return weather.reduce((max, record) => record[key] >= (max || record[key]) ? record[key] : max, null);
}

function dailyMin(weather, key) {
    return weather.reduce((min, record) => record[key] <= (min || record[key]) ? record[key] : min, null);
}

function mode(arr) {
    return arr.sort((a,b) =>
                    arr.filter(v => v===a).length
                    - arr.filter(v => v===b).length
                    ).pop();
}

function setProperty(id, value) {
    const el = document.getElementById(`weather-${id}`);
    el.innerHTML = value;
}

function getWeather() {
    const lat = Number(document.getElementById('lat').value);
    const lon = Number(document.getElementById('lon').value);
    const date = document.getElementById('date').valueAsDate;
    updateLink(lat, lon, date);
    updateHeader(lat, lon, date);
    const data =  fetchWeather(lat, lon, date);
    //jsonViewer.showJSON(data, -1, 2);
    if (data.weather && data.weather.length > 0) {
        document.getElementById('no-weather-info').classList.add('is-hidden');
        updateSummary(data);
        updateHourly(data);
        document.querySelectorAll('#response-json pre > ul > li > ul > li > a')[12].click();
    } else {
        document.getElementById('no-weather-info').classList.remove('is-hidden');
    }
}

function fetchWeather(lat, lon, date) {
    const dateStr = date.toISOString().split('T')[0];
    const url = BRIGHTSKY_URL + `weather?lat=${lat}&lon=${lon}&date=${dateStr}&tz=Europe/Berlin`;
    const response =  fetch(url);
    const data = response.json();
    return data;
}

function updateLink(lat, lon, date) {
    const dateStr = date.toISOString().split('T')[0];
    document.getElementById('url-lat').innerHTML = lat;
    document.getElementById('url-lon').innerHTML = lon;
    document.getElementById('url-date').innerHTML = dateStr;
    document.getElementById('params-url').href = `${ BRIGHTSKY_URL }weather?lat=${lat}&lon=${lon}&date=${dateStr}`;
}

function updateHeader(lat, lon, date) {
    setProperty('today', date.toLocaleString('en-us', {weekday: 'long', day: 'numeric', month: 'long', year: 'numeric'}));
    const yesterday = new Date(date);
    yesterday.setDate(date.getDate() - 1);
    const tomorrow = new Date(date);
    tomorrow.setDate(date.getDate() + 1);
    setProperty('yesterday', yesterday.toLocaleString('en-us', {day: 'numeric', month: 'long'}));
    setProperty('tomorrow', tomorrow.toLocaleString('en-us', {day: 'numeric', month: 'long'}));
}

const ICON_MAPPING = {
    'clear-day': 'wi-day-sunny',
    'clear-night': 'wi-night-clear',
    'partly-cloudy-day': 'wi-day-cloudy',
    'partly-cloudy-night': 'wi-night-cloudy',
    'cloudy': 'wi-cloud',
    'fog': 'wi-fog',
    'wind': 'wi-strong-wind',
    'rain': 'wi-rain',
    'sleet': 'wi-sleet',
    'snow': 'wi-snow',
    'hail': 'wi-hail',
    'thunderstorm': 'wi-thunderstorm',
}

function updateSummary(data) {
    const sourceName = data.sources[0].station_name.replace(
                         /\B\w/g,
                         (txt) => txt.charAt(0).toLowerCase(),
                         );
    const maxTemp = dailyMax(data.weather, 'temperature');
    const minTemp = dailyMin(data.weather, 'temperature');
    const maxPrecipitation = dailyMax(data.weather, 'precipitation');
    const avgWindSpeed = dailyAvg(data.weather, 'wind_speed');
    const totalSunshine = dailyTotal(data.weather, 'sunshine');
    const totalSunshineHours = Math.floor(totalSunshine / 60);
    const totalSunshineMinutes = Math.floor(totalSunshine - 60 * totalSunshineHours);
    const avgCloudCover = dailyAvg(data.weather, 'cloud_cover');
    const avgPressure = dailyAvg(data.weather, 'pressure_msl');
    setProperty('station-name', sourceName);
    setProperty('max-temp', maxTemp.toFixed(1));
    setProperty('min-temp', minTemp.toFixed(1));
    setProperty('max-precipitation', maxPrecipitation.toFixed(1));
    setProperty('avg-wind-speed', avgWindSpeed.toFixed(1));
    setProperty('total-sunshine', `${totalSunshineHours}:${(totalSunshineMinutes < 10 ? '0' : '') + totalSunshineMinutes}`);
    setProperty('avg-cloud-cover', avgCloudCover.toFixed(0));
    setProperty('avg-pressure', avgPressure.toFixed(1));
    const icons = data.weather.map((record) => record.icon.replace('-night', '-day'));
    document.getElementById('weather-day-icon').className = `wi ${ ICON_MAPPING[mode(icons)] }`;
}

function updateHourly(data) {
    var hourly = '';
    for (let i = 4; i < data.weather.length - 1; i += 4) {
        var weather = data.weather[i];
        var timestamp = new Date(weather.timestamp).toLocaleTimeString('en-us', {hour12: false, hour: 'numeric', minute: 'numeric'});
        setProperty('hourly', hourly);
    }
}

//const dateInput = document.getElementById('date')
//document.getElementById('lat').addEventListener('input', getWeather);
//document.getElementById('lon').addEventListener('input', getWeather);

//dateInput.addEventListener('input', getWeather);
//dateInput.valueAsDate = new Date();

//document.getElementById('weather-yesterday-link').addEventListener('click', () => { dateInput.stepDown(); getWeather() });
//document.getElementById('weather-tomorrow-link').addEventListener('click', () => { dateInput.stepUp(); getWeather() });

//getWeather();
