import json
import pyotherside

from libband.device import BandDevice
from libband.notifications import MessagingNotification
from libband.apps.profile import ProfileService
from libband.apps.metrics import MetricsService
from libband.apps.calendar import CalendarService
from libband.apps.weather import WeatherService
from libband.apps.time import TimeService
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

    def messaging_notification(self, title, body, tile, flag=None):
        notification = MessagingNotification(tile, title, body)
        if flags:
            notification.notification_type = flag
        self.device.send_notification(notification)

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
            metrics_service = MetricsService(self.device)
            phone_service = PhoneService(self.device)
            profile_service = ProfileService(self.device)
            calendar_service = CalendarService(self.device)
            music_service = MusicService(self.device)

            self.services = {
                "TimeService": time_service,
                "WeatherApp": weather_service,
                "MetricsApp": metrics_service,
                "PhoneApp": phone_service,
                "ProfileApp": profile_service,
                "CalendarApp": calendar_service,
                "MusicApp": music_service
            }
        self.device.services = self.services
        self.device.connect()

    def sync(self):
        if self.device:
            self.device.sync()
            self.device.wrapper.send('profile', self.services['ProfileApp'].profile.__dict__())

            return True
        return False

app = FishBand()
