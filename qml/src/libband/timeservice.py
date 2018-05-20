import struct
from datetime import datetime
from .commands import FACILITIES, make_command
from .filetimes import convert_back


class TimeService:
    band = None

    def __init__(self, band):
        self.band = band

    def __str__(self):
        return "Time Service   "
    
    def __unicode__(self):
        return "Time Service   "

    def sync(self):
        new_device_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
        self.band.send(make_command(
            FACILITIES["LibraryTime"], False, 1) + struct.pack("<I", 8))
        result, response = self.band.send_for_result(
            struct.pack("<Q", convert_back(new_device_time)))
        return result
    
    def get_device_time(self):
        result, responses = self.band.send_for_result(make_command(
            FACILITIES["LibraryTime"], True, 2) + struct.pack("<I", 16))
        if result:
            return struct.unpack("H"*8, responses[0])
