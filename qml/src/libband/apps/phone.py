import binascii
from .app import App
from libband.tiles import CALLS


class PhoneService(App):
    app_name = "Phone Service"
    guid = CALLS

    def push(self, guid, command, message):
        message = super().push(guid, command, message)
        if message:
            if command == binascii.unhexlify("00000000000000004201000000000000000000000000"):
                message["command"] = "hangup"
        
        return message
