import uuid

CARGO_SERVICE_PORT = 4
CARGO_SERVICE_UUID = "a502ca97-2ba5-413c-a4e0-13804e47b38f"
TIMEOUT = 2

BUFFER_SIZE = 8192

NOTIFICATION_TYPES = {
    "Sms": b"\x01",
    "Email": b"\x02",
    "IncomingCall": b"\x0B",
    "AnsweredCall": b"\x0c",
    "MissedCall": b"\x0D",
    "HangupCall": b"\x0E",
    "Voicemail": b"\x0F",
    "CalendarEventAdd": b"\x10",
    "CalendarClear": b"\x11",
    "Messaging": b"\x12",
    "GenericDialog": b"\x64",
    "GenericUpdate": b"\x65",
    "GenericClearTile": b"\x66",
    "GenericClearPage": b"\x67"
}
