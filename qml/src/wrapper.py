import json
import pyotherside

from libband.device import BandDevice
from libband.apps.weather import WeatherService
from libband.apps.timeservice import TimeService
from libband.apps.music import MusicService
from libband.apps.phone import PhoneService


class PyOtherSideWrapper:
    def print(self, *args, **kwargs):
        pyotherside.send("print", [args, json.dumps(kwargs)])

    def send(self, signal, args):
        pyotherside.send(signal, args)

    def atexit(self, func):
        pyotherside.atexit(func)


class FishBand:
    device = None
    services = {}

    def call(self, service_name, method, args):
        service = self.services.get(service_name, None)
        if service:
            getattr(service, method)(*args)

    def select_device(self, mac_address):
        """Sets a device, move services to new device"""
        self.device = BandDevice(mac_address)
        self.device.wrapper = PyOtherSideWrapper()
        if self.services:
            for name, service in self.services.items():
                service.band = self.device
        else:
            time_service = TimeService(self.device)
            weather_service = WeatherService(self.device)
            music_service = MusicService(self.device)
            phone_service = PhoneService(self.device)

            self.services = {
                "TimeService": time_service,
                "WeatherApp": weather_service,
                "MusicApp": music_service,
                "PhoneApp": phone_service,
            }
        self.device.services = self.services

        self.device.connect()
        info = self.device.get_device_info()
        serial_number = self.device.get_serial_number()
        info["serial_number"] = serial_number
        pyotherside.send("info", info)

    def sync(self):
        if self.device:
            self.device.sync()
            return True
        return False

app = FishBand()
