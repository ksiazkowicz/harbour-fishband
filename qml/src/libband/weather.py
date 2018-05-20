from __future__ import unicode_literals
import struct
import requests
import geocoder
from datetime import datetime, timedelta
from . import NOTIFICATION_TYPES
from . import layouts
from .tiles import WEATHER
from .commands import PUSH_NOTIFICATION
import pyotherside


NO_IDEA_YET = [
    (3735, 30229, 38093, 19797, 32644, 32442, 50335, 58888),
    (15596, 32727, 60860, 19514, 46265, 57004, 38178, 12561),
    (13405, 46662, 7844, 18546, 57266, 42681, 41232, 63154),
    (35999, 55224, 24129, 16535, 8325, 11477, 10779, 27963),
    (14222, 59016, 44069, 16996, 21434, 64947, 26524, 44522),
    (4719, 49247, 62971, 19866, 46728, 7394, 46087, 54133),
    (49034, 53474, 41697, 17943, 47755, 3542, 16507, 13324),
    (52482, 47405, 8690, 16904, 2711, 64587, 24984, 32404),
]

# icons: 1 - Stars (Clear)
#        5 - Snow with rain
#        7 - Fog
#        8 - Some strips (???)
#        9 - Windy

ICON_MAP = {
    1: 0,   # Sunny
    2: 0,   # Mostly Sunny
    3: 0,   # Partly Sunny
    4: 2,   # Mostly Cloudy
    5: 2,   # Cloudy
    19: 3,  # Light Rain
    20: 6,  # Light Snow
    23: 3,  # Rain Showers
    24: 0,  # Mostly Sunny
    27: 4,  # Storms
    28: 0,  # Partly Sunny
}


def serialize_last_update(when, where):
    notification = layouts.make_item(
        layouts.ELEMENT_TEXT, 1, 1, "Last updated")
    notification += layouts.make_item(layouts.ELEMENT_TEXT, 2, 1, when)
    notification += layouts.make_item(layouts.ELEMENT_TEXT, 3, 1, where)

    result = struct.pack("HH", len(notification), layouts.TEXT)
    result += struct.pack("H"*len(NO_IDEA_YET[0]), *NO_IDEA_YET[0])
    result += struct.pack("H", 0) + notification
    return result


def serialize_forecast(something, day, weather_type, icon,
                       temp_high=None, temp_low=None):
    notification = layouts.make_item(layouts.ELEMENT_TEXT, 1, 1, day)

    if weather_type:
        notification += layouts.make_item(layouts.ELEMENT_TEXT, 1, 2, "|")
        notification += layouts.make_item(layouts.ELEMENT_TEXT, 1, 3,
                                          weather_type)

    notification += layouts.make_item(layouts.ELEMENT_ICON, 2, 1,
                                      icon_id=ICON_MAP.get(icon, icon))
    notification += layouts.make_item(layouts.ELEMENT_TEXT, 2, 2,
                                      temp_high + "\xb0")

    if temp_low:
        notification += layouts.make_item(layouts.ELEMENT_TEXT, 2, 3,
                                          "/" + temp_low + "\xb0")

    result = struct.pack("HH", len(notification), layouts.FORECAST)
    result += struct.pack("H"*len(something), *something)
    result += struct.pack("H", 0) + notification
    return result


class WeatherService:
    band = None
    lat = 0
    lon = 0
    last_update = None
    days = 6
    units = "C"
    place = "TODO: add geocoding"

    def __init__(self, band):
        self.band = band

    def __str__(self):
        return "Weather Service"
    
    def __unicode__(self):
        return "Weather Service"

    def set_location(self, lon, lat):
        self.lat = lat
        self.lon = lon
        place = geocoder.opencage([lat, lon],
                                  key='bcd0f9d2b4204fbd8d7bf301df1f920a',
                                  method='reverse')
        self.place = "%s, %s" % (place.city, place.country)

    def sync(self):
        url = "http://service.weather.microsoft.com/weather/summary/%s" \
              ",%s?days=%s&units=%s&appid=3FB8A36C-B005-4332-96F1-CAFA" \
              "D7A25D2C&formcode=KAPP" % (
                      self.lat, self.lon, self.days, self.units)
        response = requests.get(url)

        try:
            response = response.json()
        except:
            return
        response = self.parse_weather_forecast(response)
        self.last_update = datetime.now()

        forecasts = [
            serialize_last_update(
                self.last_update.strftime("%m/%d %H:%M"), self.place),
        ]

        for i, forecast in enumerate(response):
            forecasts.append(serialize_forecast(NO_IDEA_YET[i+1], **forecast))

        return self.push_forecast(forecasts)

    def parse_weather_forecast(self, response):
        weather = response.get("responses", [])[0].get("weather", [])[0]
        current = weather.get("current")
        forecasts = weather.get("forecast", {}).get("days", [])
        weather_args = [{
            "day": "Now",
            "weather_type": current.get("cap", ""),
            "icon": current.get("icon", 0),
            "temp_high": "%d" % current.get("temp", 0),
        }]
        now = datetime.now()
        weather_args += [{
            "day": (now + timedelta(days=i)).strftime("%A") if i > 0 else "Today",
            "weather_type": None,
            "icon": day.get("icon"),
            "temp_high": "%d" % day.get("tempHi", 0),
            "temp_low": "%d" % day.get("tempLo", 0)
        } for i, day in enumerate(forecasts)]
        return reversed(weather_args)

    def push_forecast(self, forecasts):
        self.band.clear_tile(WEATHER)

        update_prefix = NOTIFICATION_TYPES["GenericUpdate"] + b"\x00"
        update_prefix += WEATHER.bytes_le

        success = False
        for forecast in forecasts:
            packet = update_prefix + forecast
            self.band.send(
                PUSH_NOTIFICATION + struct.pack("<i", len(packet)))
            success, result = self.band.send_for_result(packet)
        return success
