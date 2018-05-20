import struct
from .helpers import serialize_text

FORECAST = 1
TEXT = 0

ELEMENT_TEXT = 3001
ELEMENT_ICON = 3101


def make_item(item_type, line, index, content="", icon_id=None):
    """
    Returns item serialized as HHHcxcxcxcxcxcxcx...

    :param item_type: element item, text or icon
    :param line: position, which line
    :param index: position, which spot
    :param content: item text (if text)
    :param icon_id: item icon ID (if icon)
    """
    position = line*10 + index
    argument = len(content) if not icon_id else icon_id
    item = struct.pack("HHH", item_type, position, argument)
    if content:
        item += serialize_text(content)
    return item
