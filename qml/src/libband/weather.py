from __future__ import unicode_literals
import uuid
import struct
import requests
import geocoder
from datetime import datetime, timedelta
from . import NOTIFICATION_TYPES
from . import layouts
from .tiles import WEATHER
from .commands import PUSH_NOTIFICATION
import pyotherside


PAGE_IDS = [
    uuid.UUID("76150e97-94cd-4d55-847f-ba7e9fc408e6"),  # Last page
    uuid.UUID("7fd73cec-edbc-4c3a-b9b4-acde22951131"),
    uuid.UUID("b646345d-1ea4-4872-b2df-b9a610a1b2f6"),
    uuid.UUID('d7b88c9f-5e41-4097-8520-d52c1b2a3b6d'),
    uuid.UUID('e688378e-ac25-4264-ba53-b3fd9c67eaad'),
    uuid.UUID('c05f126f-f5fb-4d9a-88b6-e21c07b475d3'),
    uuid.UUID('d0e2bf8a-a2e1-4617-8bba-d60d7b400c34'),
    uuid.UUID('b92dcd02-21f2-4208-970a-4bfc9861947e'),
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
    28: 1,  # Clear
    29: 1,  # Mostly Clear
}


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
        pyotherside.send("ForecastDebug", [self.lat, self.lon, self.place])
        response = requests.get(url)

        try:
            response = response.json()
        except:
            return
        response = self.parse_weather_forecast(response)
        self.last_update = datetime.now()

        forecasts = [
            layouts.MultilineTextLayout.serialize_as_update(
                PAGE_IDS[0], {
                    "line_1": "Last updated",
                    "line_2": self.last_update.strftime("%m/%d %H:%M"),
                    "line_3": self.place
                }),
        ]

        for i, forecast in enumerate(response):
            forecasts.append(layouts.HeaderSecondaryLargeIconAndMetricLayout.
                             serialize_as_update(PAGE_IDS[i+1], forecast))

        return self.push_forecast(forecasts)

    def parse_weather_forecast(self, response):
        weather = response.get("responses", [])[0].get("weather", [])[0]
        current = weather.get("current")
        forecasts = weather.get("forecast", {}).get("days", [])
        now_icon = current.get("icon", 0)
        weather_args = [{
            "header": "Now",
            "separator": "|",
            "secondary": current.get("cap", ""),
            "largeIcon": ICON_MAP.get(now_icon, now_icon),
            "metric": "%d" % current.get("temp", 0) + "\xb0",
        }]
        pyotherside.send("Debug", [now_icon, str(type(now_icon))])
        now = datetime.now()

        pyotherside.send("Debug", [(x.get("icon"), x.get("cap", "")) for x in forecasts])

        weather_args += [{
            "header": (now + timedelta(days=i)).strftime("%A") if i > 0 else "Today",
            "largeIcon": ICON_MAP.get(day.get("icon"), day.get("icon")),
            "metric": "%d" % day.get("tempHi", 0) + "\xb0",
            "secondary_metric": "/%d" % day.get("tempLo", 0) + "\xb0"
        } for i, day in enumerate(forecasts)]
        return reversed(weather_args)

    def push_forecast(self, forecasts):
        self.band.clear_tile(WEATHER)

        update_prefix = NOTIFICATION_TYPES["GenericUpdate"]
        update_prefix += WEATHER.bytes_le

        success = False
        for forecast in forecasts:
            packet = update_prefix + forecast
            self.band.send(
                PUSH_NOTIFICATION + struct.pack("<i", len(packet)))
            success, result = self.band.send_for_result(packet)
        return success
