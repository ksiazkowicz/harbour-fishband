import pyotherside
import dbus
import dbus.mainloop.glib
from gi.repository import GObject
from unidecode import unidecode


blacklist = ["com.spotify.music", "store-client", ]


def push_notification(bus, message):
    keys = ["app_name", "replaces_id", "app_icon", "summary",
            "body", "actions", "hints", "expire_timeout"]
    message_args = message.get_args_list()
    if len(message_args) == 8:
        notification = dict([
            (keys[i], message_args[i]) for i in range(8)
        ])
        hints = notification.get("hints", {})
        category = hints.get("category", "")
        owner = hints.get("x-nemo-owner", "")

        if str(owner) in blacklist:
            return

        summary = unidecode(
            hints.get("x-nemo-preview-summary", "") or
            notification.get("summary", ""))
        body = unidecode(
            hints.get("x-nemo-preview-body", "") or
            notification.get("body", ""))

        if category == "x-nemo.messaging.sms.preview":
            # send SMS notification
            pyotherside.send("sms", [summary, body])
        elif category == "x-nemo.email":
            # send Email notification
            pyotherside.send("mail", [summary, body])
        else:
            # send anything else
            app_name = unidecode(notification.get("app_name", ""))
            content = u"%s %s" % (summary, body)
            package = hints.get("x-nemo-origin-package", "")

            if owner == "aliendalvik":
                if str(package) in blacklist:
                    return

            if owner == "aliendalvik":
                if package == "com.facebook.orca":
                    pyotherside.send("messenger", [summary, body])
                else:
                    pyotherside.send("feed", [app_name, content])
            else:
                pyotherside.send("feed", [app_name, contentr])
        print("Done")
        print("================")

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

bus = dbus.SessionBus()
bus.add_match_string(
    "type='method_call',interface='org.freedesktop.Notifications'"
    ",member='Notify',eavesdrop=true")
bus.add_message_filter(push_notification)

# GObject.MainLoop().run()
