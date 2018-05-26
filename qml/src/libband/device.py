from __future__ import print_function
import bluetooth
import time
import struct
import binascii
import uuid
import json
import pyotherside
import threading
from datetime import datetime

from . import layouts
from .helpers import serialize_text, bytes_to_text
from .commands import SERIAL_NUMBER_REQUEST, PUSH_NOTIFICATION, \
                      GET_TILES_NO_IMAGES, PROFILE_GET_DATA_APP, \
                      SET_THEME_COLOR, START_STRIP_SYNC_END, \
                      START_STRIP_SYNC_START
from .filetimes import convert_back
from .tiles import FEED, EMAIL, SMS, CALLS, FBMESSENGER, MUSIC_CONTROL
from . import CARGO_SERVICE_PORT, PUSH_SERVICE_PORT, TIMEOUT, BUFFER_SIZE, \
              NOTIFICATION_TYPES


NOW_PLAYING_PAGE = uuid.UUID("132e8f71-04a1-40e1-8d92-6e15214a80e2")
CONTROLS_PAGE = uuid.UUID("84c43f9d-90c9-4efb-8aa6-d673617d3ac4")
VOLUME_PAGE = uuid.UUID("545024f9-ccec-4962-8c21-e3835cf6b506")


def decode_color(color):
    return {
        "r": color >> 16 & 255,
        "g": color >> 8 & 255,
        "b": color & 255
    }


def cuint32_to_hex(color):
    return "#{0:02x}{1:02x}{2:02x}".format(color >> 16 & 255, 
                                           color >> 8 & 255, 
                                           color & 255)


def encode_color(alpha, r, g, b):
    return (alpha << 24 | r << 16 | g << 8 | b)


class BandDevice:
    address = ""
    cargo = None
    push = None
    tiles = None
    band_language = None
    band_name = None
    serial_number = None
    push_thread = None

    def __init__(self, address):
        self.address = address
        self.push = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
        self.cargo = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
        pyotherside.atexit(self.disconnect)

        # start push thread
        self.push_thread = threading.Thread(target=self.listen_pushservice)
        self.push_thread.start()

    def push_music_update(self, title, artist, album):
        update_prefix = NOTIFICATION_TYPES["GenericUpdate"]
        update_prefix += MUSIC_CONTROL.bytes_le

        success = False

        pages = [
            layouts.MusicControlLayout.serialize_as_update(CONTROLS_PAGE),
            layouts.NowPlayingLayout.serialize_as_update(NOW_PLAYING_PAGE, {
                "title": title, "artist": artist, "album": album
            }),
            layouts.VolumeButtonsLayout.serialize_as_update(VOLUME_PAGE),
        ]

        for page in pages:
            page_update = update_prefix + page
            self.send(
                PUSH_NOTIFICATION + struct.pack("<i", len(page_update)))

            success, result = self.send_for_result(page_update)
        return success

    def listen_pushservice(self):
        self.connect_push()
        while True:
            try:
                result = self.push.recv(BUFFER_SIZE)
            except bluetooth.btcommon.BluetoothError as error:
                self.connect_push()

            opcode = struct.unpack("I", result[6:10])[0]
            guid = uuid.UUID(bytes_le=result[10:26])
            command = result[26:44]
            tile_name = bytes_to_text(result[44:84])

            pyotherside.send("PushService", {
                "opcode": opcode,
                "guid": str(guid),
                "command": str(binascii.hexlify(command)),
                "tile_name": tile_name,
            })

            if guid == MUSIC_CONTROL:
                pyotherside.send("Debug", command[-2:])
                try:
                    button_id = struct.unpack("H", command[-2:])[0]
                except:
                    # can't unpack button ID
                    return
                if CONTROLS_PAGE.bytes_le in command:
                    button = layouts.MusicControlLayout.get_key(button_id)
                    pyotherside.send("MusicControl", button)
                elif VOLUME_PAGE.bytes_le in command:
                    button = layouts.VolumeButtonsLayout.get_key(button_id)
                    pyotherside.send("MusicControl", button)

    def sync(self, services):
        for service in services:
            print("%s" % service, end='')
            result = getattr(service, "sync")()
            print("          [%s]" % ("OK" if result else "FAIL"))

        print("Sync finished")

    def connect_push(self, timeout=TIMEOUT):
        while True:
            try:
                self.push.close()
                self.push = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
                self.push.connect((self.address, CARGO_SERVICE_PORT+1))
                time.sleep(timeout)  # give it some time to connect
                break
            except bluetooth.btcommon.BluetoothError as error:
                self.push.close()
                print("Could not connect: %s" % error)
                time.sleep(timeout)

    def clear_tile(self, guid):
        notification = NOTIFICATION_TYPES["GenericClearTile"]
        notification += guid.bytes_le
        self.send(PUSH_NOTIFICATION + struct.pack("<i", len(notification)))
        self.send_for_result(notification)

    def connect(self, timeout=TIMEOUT):
        while True:
            try:
                self.cargo.close()
                self.cargo = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
                self.cargo.connect((self.address, CARGO_SERVICE_PORT))
                time.sleep(timeout)  # give it some time to connect
                break
            except bluetooth.btcommon.BluetoothError as error:
                self.cargo.close()
                print("Could not connect: %s" % error)
                time.sleep(timeout)

    def disconnect(self):
        try:
            self.cargo.close()
        except:
            pass
        try:
            self.push.close()
        except:
            pass
        print("Disconnected")

    def set_theme(self, colors):
        """
        Takes an array of 6 colors encoded as ints

        Base, Highlight, Lowlight, SecondaryText, HighContrast, Muted
        """
        pyotherside.send("GOT", colors)

        self.send_for_result(START_STRIP_SYNC_START)
        self.send(SET_THEME_COLOR)
        colors = struct.pack("I"*6, *[int(x) for x in colors])
        self.send_for_result(colors)
        self.send_for_result(START_STRIP_SYNC_END)

    def get_tiles(self):
        if not self.tiles:
            self.request_tiles()
        return self.tiles
        
    def get_serial_number(self):
        if not self.serial_number:
            # ask nicely for serial number
            result, number = self.send_for_result(SERIAL_NUMBER_REQUEST)
            if result:
                self.serial_number = str(number[0])
        pyotherside.send("device_serial_number", str(self.serial_number))
        return self.serial_number

    def get_device_info(self):
        result, info = self.send_for_result(PROFILE_GET_DATA_APP)
        if not result:
            return
        info = info[0]

        self.band_name = bytes_to_text(info[41:73])
        self.band_language = bytes_to_text(info[73:85])

        pyotherside.send("device_name", self.band_name)
        pyotherside.send("device_language", self.band_language)

        return {
            "name": self.band_name,
            "language": self.band_language
        }

    def request_tiles(self):
        result, tiles = self.send_for_result(GET_TILES_NO_IMAGES)
        tile_data = b"".join(tiles)

        tile_list = []

        # no idea what these 4 bytes are yet
        begin = 4
        # while there are tiles
        while begin + 88 <= len(tile_data):
            # get guuid
            guid = uuid.UUID(bytes_le=tile_data[begin:begin+16])
            # that thing after guuid that might be an icon (?)
            icon = tile_data[begin+16:begin+16+12]

            # get tile name
            name = bytes_to_text(tile_data[begin+28:begin+80])

            # append tile to list
            tile_list.append({
                "guid": guid,
                "icon": icon,
                # convert name to readable format
                "name": name
            })

            # move to next tile
            begin += 88
        self.tiles = tile_list

    def call_notification(self, title, text):
        self.send_notification(title, text, CALLS,
                               flags=NOTIFICATION_TYPES["Messaging"])

    def sms_notification(self, title, text):
        self.send_notification(title, text, SMS, 
                               flags=NOTIFICATION_TYPES["Messaging"])

    def mail_notification(self, title, text):
        flags = NOTIFICATION_TYPES["Email"]
        self.send_notification(title, text, EMAIL, 
                               flags=NOTIFICATION_TYPES["Messaging"])

    def regular_notification(self, title, text):
        self.send_notification(title, text, FEED)

    def messenger_notification(self, title, text):
        self.send_notification(title, text, FBMESSENGER)

    def send_notification(self, title, text, guid=None, 
                          flags=NOTIFICATION_TYPES["Messaging"]):
        if not guid:
            print("GUID not provided")
            return

        notification = flags + guid.bytes_le
        notification += struct.pack("H", len(title)*2)
        notification += struct.pack("H", len(text)*2)
        timestamp_string = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
        timestamp = convert_back(timestamp_string)

        notification += struct.pack("<Qxx", timestamp)
        notification += serialize_text(title+text)

        self.send(PUSH_NOTIFICATION + struct.pack("<i", len(notification)))
        self.send_for_result(notification)

    def send(self, packet):
        while True:
            # try to reconnect if failed
            try:
                self.cargo.send(packet)
                break
            except bluetooth.btcommon.BluetoothError as error:
                print("Connecting because %s" % error)
                self.connect()

    def response_result(self, response):
        error_code = struct.unpack("<I", response[2:6])[0]
        if error_code:
            print("Error: %s" % error_code)
        return not error_code

    def receive(self, buffer_size=BUFFER_SIZE):
        while True:
            try:
                result = self.cargo.recv(buffer_size)
                break
            except bluetooth.btcommon.BluetoothError as error:
                print("Connecting because %s" % error)
                self.connect()
        return result

    def send_for_result(self, packet, buffer_size=BUFFER_SIZE):
        results = []
        success = True

        # send packet
        self.send(packet)

        while True:
            self.cargo.settimeout(5.0)
            result = self.receive(BUFFER_SIZE)

            # check if we got final result
            if result[0:2] == b'\xfe\xa6':
                error_code = struct.unpack("<I", result[2:6])[0]
                if error_code:
                    print("Error: %s" % error_code)
                success = not error_code
                break

            # nope, more data
            results.append(result)

        # we're done
        return success, results
