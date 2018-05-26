import QtQuick 2.0
import Nemo.Configuration 1.0
import io.thp.pyotherside 1.4


Item {
    id: bandController
    property alias deviceName: deviceConf.deviceName
    property alias deviceLanguage: deviceConf.deviceLanguage
    property alias deviceSerialNumber: deviceConf.deviceSerialNumber
    property bool isSyncing: false
    property bool deviceSelected: false
    property alias lastSync: deviceConf.lastSync

    signal musicControlPlay;
    signal musicControlPrev;
    signal musicControlNext;
    signal musicControlVolUp;
    signal musicControlVolDown;

    function selectDevice(macAddress) {
        python.call("wrapper.app.select_device", [macAddress],
                    function () {})

        deviceSelected = true;

        if (macAddress !== deviceConf.macAddress)
            deviceConf.macAddress = macAddress

        updateMusicTile("NA", "NA", "NA")
    }

    function sync() {
        if (gps.position) {
            var coordinate = gps.position.coordinate
            if (!isNaN(coordinate.longitude))
                python.call('wrapper.app.set_location', [
                                coordinate.latitude, coordinate.longitude
                            ], function() {})
        }
        isSyncing = true
        python.call('wrapper.app.sync', [], function() {})
    }

    function updateMusicTile(title, artist, album) {
        python.call("wrapper.app.device.push_music_update", [
                        title, artist, album, ], function () {})
    }

    function smsNotification(summary, body) {
        python.call("wrapper.app.device.sms_notification", [summary, body]);
    }

    function mailNotification(summary, body) {
        python.call("wrapper.app.device.mail_notification", [summary, body])
    }

    function messengerNotification(summary, body) {
        python.call("wrapper.app.device.messenger_notification", [summary,
                                                                  body])
    }

    function regularNotification(summary, body) {
        python.call("wrapper.app.device.regular_notification", [
                        notification.sender, summary + " " + body])
    }

    function setTheme(base, highlight, lowlight, secondaryText, highContrast,
                      muted) {
        python.call("wrapper.app.device.set_theme", [[
            base, highlight, lowlight, secondaryText, highContrast, muted
        ], ], function() {})
    }

    ConfigurationGroup {
        id: deviceConf
        path: "/apps/harbour-fishband"
        property string macAddress: ""
        property string deviceName: "Your Band"
        property string deviceLanguage: "N/A"
        property string deviceSerialNumber: "N/A"
        property date lastSync
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('src'));
            importModule('wrapper', function () {});
            gps.start()
            setHandler("Sync", function (arguments) {
                var status = arguments[0]
                var message = arguments[1]
                if (status === "OK" && message === "Finished") {
                    bandController.isSyncing = false;
                    bandController.lastSync = new Date();
                } else {
                    bandController.isSyncing = false;
                    console.log(status, message)
                }
            })
            setHandler("device_name", function(name) {
                bandController.deviceName = name;
            })
            setHandler("device_language", function (language) {
                bandController.deviceLanguage = language
            })
            setHandler("device_serial_number", function (serial_number) {
                bandController.deviceSerialNumber = serial_number
            })

            setHandler("MusicControl", function (command) {
                console.log(command)
                if (command === "playButtonText") musicControlPlay();
                if (command === "prevButtonText") musicControlPrev();
                if (command === "nextButtonText") musicControlNext();
                if (command === "VolumeUp") musicControlVolUp();
                if (command === "VolumeDown") musicControlVolDown();
            })

            setHandler("PushService", function (message) {
                console.log("opcode: " + message.opcode)
                console.log("guid: " + message.guid)
                console.log("command: " + message.command)
                console.log("tile name: " + message.tile_name)
            })

            if (deviceConf.macAddress)
                selectDevice(deviceConf.macAddress)
        }

        onError: console.log('python error: ' + traceback);
        onReceived:  console.log('got message from python: ' + data);
    }
}
