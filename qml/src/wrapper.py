import pyotherside

from libband.device import BandDevice
from libband.weather import WeatherService
from libband.timeservice import TimeService


class FishBand:
    device = None
    services = []

    def weather_service(self):
        weather_services = [
            x for x in self.services if isinstance(x, WeatherService)]
        return weather_services[0] if len(weather_services) else None

    def set_location(self, latitude, longitude):
        weather_service = self.weather_service()
        pyotherside.send("DebugSetLocation", weather_service != None)
        if weather_service:
            weather_service.set_location(longitude, latitude)

    def select_device(self, mac_address):
        """Sets a device, move services to new device"""
        self.device = BandDevice(mac_address)
        if self.services:
            for service in self.services:
                service.band = self.device
        else:
            time_service = TimeService(self.device)
            weather_service = WeatherService(self.device)

            self.services = [time_service, weather_service]

        self.device.connect()
        self.device.get_device_info()
        self.device.get_serial_number()

    def sync(self):
        if self.device:
            self.device.sync(self.services)
            pyotherside.send("Sync", ["OK", "Finished"])
        else:
            pyotherside.send("Sync", ["Error", "No device selected"])


app = FishBand()