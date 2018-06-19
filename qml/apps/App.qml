import QtQuick 2.0

Item {
    id: app
    property bool ready: false
    property string guid: ""
    signal pushReceived(variant message)
    signal interpreterReady

    Connections {
        target: bandController
        onPushServiceReceived: {
            // check GUID first
            if (message.guid !== guid)
                return;

            // emit signal
            app.pushReceived(message)
        }
        onInterpreterReady: {
            app.interpreterReady()
            app.ready = true
        }
    }
}
