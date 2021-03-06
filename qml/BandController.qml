import QtQuick 2.0
import Nemo.Configuration 1.0
import io.thp.pyotherside 1.4


Item {
    id: bandController
    property var profile: {}
    property alias deviceName: deviceConf.deviceName
    property alias deviceLanguage: deviceConf.deviceLanguage
    property alias deviceSerialNumber: deviceConf.deviceSerialNumber
    property bool isSyncing: false
    property bool deviceSelected: false
    property alias lastSync: deviceConf.lastSync

    property string cargoServiceStatus: "N/A"
    property string pushServiceStatus: "N/A"

    property string batteryGauge: ""

    property alias lastSleepDuration: deviceConf.lastSleepDuration
    property alias lastSleepCalories: deviceConf.lastSleepCalories
    property alias lastSleepHeartRate: deviceConf.lastSleepHeartRate
    property alias lastSleepDate: deviceConf.lastSleepDate
    property alias lastWorkoutDuration: deviceConf.lastWorkoutDuration
    property alias lastWorkoutDate: deviceConf.lastWorkoutDate
    property alias lastWorkoutCalories: deviceConf.lastWorkoutCalories
    property alias lastWorkoutAvgHeartrate: deviceConf.lastWorkoutAvgHeartrate

    signal pushServiceReceived(variant message)
    signal interpreterReady

    function selectDevice(macAddress) {
        python.call("wrapper.app.select_device", [macAddress],
                    function () {})

        deviceSelected = true;

        if (macAddress !== deviceConf.macAddress)
            deviceConf.macAddress = macAddress
    }

    function callApp(appName, method, args, callback) {
        python.call("wrapper.app.call", [appName, method, args], callback);
    }

    function sync() {
        isSyncing = true
        python.call('wrapper.app.sync', [], function(result) {
            isSyncing = false;
            if (result)
                bandController.lastSync = new Date();
        })
    }

    function sendNotification(title, body, tile, flag) {
        python.call("wrapper.app.messaging_notification",
                    [title, body, tile, flag])
    }

    function setTheme(base, highlight, lowlight, secondaryText, highContrast,
                      muted) {
        python.call("wrapper.app.device.set_theme", [[
            base, highlight, lowlight, secondaryText, highContrast, muted
        ], ], function() {})
    }

    function testSubs() {
        python.call("wrapper.app.device.subscribe", [38, ], function() {})
    }

    ConfigurationGroup {
        id: deviceConf
        path: "/apps/harbour-fishband"
        property string macAddress: ""
        property string deviceName: "Your Band"
        property string deviceLanguage: "N/A"
        property string deviceSerialNumber: "N/A"
        property date lastSync
        property string lastSleepDuration: "N/A"
        property string lastSleepCalories: "-"
        property string lastSleepHeartRate: "-"
        property date lastSleepDate
        property string lastWorkoutDuration: "N/A"
        property date lastWorkoutDate
        property string lastWorkoutCalories: "-"
        property string lastWorkoutAvgHeartrate: "-"
        property string lastWorkoutFeeling: "-"
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('src'));
            importModule('wrapper', function () {});
            setHandler("info", function (info) {
                bandController.deviceName = info.name;
                bandController.deviceLanguage = info.language;
                bandController.deviceSerialNumber = info.serial_number;
            })

            setHandler("profile", function (profile) {
                bandController.deviceName = profile.name;
                bandController.deviceLanguage = profile.locale.name;
                bandController.profile = profile;
            })

            setHandler("print", function (arguments) {
                var args = arguments[0];
                console.log(args.concat())
            })

            setHandler("PushService", function (message) {
                bandController.pushServiceReceived(message);
                console.log("opcode: " + message.opcode)
                console.log("guid: " + message.guid)
                console.log("command: " + message.command)
                console.log("tile name: " + message.tile_name)
            })

            setHandler("Sensor::Battery", function (data) {
                batteryGauge = data;
            })

            setHandler("Stats::Sleep", function (message) {
                bandController.lastSleepDate = message.start_time;
                bandController.lastSleepCalories = message.calories_burned;
                bandController.lastSleepDuration = message.time_asleep;
                bandController.lastSleepHeartRate = message.resting_heart_rate;
            })

            setHandler("Stats::Workout", function (message) {
                bandController.lastWorkoutDate = message.start_time;
                bandController.lastWorkoutCalories = message.calories_burned;
                bandController.lastWorkoutDuration = message.duration;
                bandController.lastWorkoutAvgHeartrate = message.avg_heartrate;
            })

            setHandler("Status", function (data) {
                var port = data[0];
                var message = data[1];

                switch (port) {
                case 4:
                    if (message === "Disconnected")
                        isSyncing = false;
                    if (message === "Connected") {
                        // subscribe battery gauge
                        // python.call("wrapper.app.device.subscribe", [38, ], function() {})
                    }

                    cargoServiceStatus = message;
                    break;
                case 5:
                    pushServiceStatus = message;
                    break;
                }
                console.log(port + ": " + message);
            })

            if (deviceConf.macAddress)
                selectDevice(deviceConf.macAddress)

            interpreterReady();
        }

        onError: console.log('python error: ' + traceback);
        onReceived:  console.log('got message from python: ' + data);
    }
}
