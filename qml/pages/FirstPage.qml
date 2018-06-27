import QtQuick 2.0
import Sailfish.Silica 1.0
import "../delegates"
import ".."

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                text: qsTr("Devices")
                onClicked: pageStack.push(Qt.resolvedUrl("DevicesList.qml"))
            }

            MenuItem {
                text: qsTr("Themes")
                onClicked: pageStack.push(Qt.resolvedUrl("ThemePage.qml"))
            }

            MenuItem {
               text: qsTr("Sync")
               enabled: !bandController.isSyncing
               onClicked: bandController.sync()
           }
        }

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                id: header
                title: bandController.deviceName
            }

            HomeInfoDelegate {
                icon: "image://theme/icon-l-clock"
                title: qsTr("Last sync")
                value: bandController.lastSync ? bandController.lastSync.toLocaleString() : qsTr("Never")
            }

            HomeInfoDelegate {
                icon: "image://theme/icon-m-moon"
                title: qsTr("Last sleep: ") + bandController.lastSleepDuration
                value: bandController.lastSleepDate ? bandController.lastSleepDate.toLocaleString() : "N/A"
            }

            HomeInfoDelegate {
                icon: "image://theme/icon-l-battery"
                title: qsTr("Battery level")
                value: bandController.batteryGauge ? bandController.batteryGauge + "%" : "N/A"
            }

            HomeInfoDelegate {
                icon: "image://theme/icon-l-bluetooth"
                title: qsTr("Bluetooth status")
                value: bandController.cargoServiceStatus
            }

            Button {
                text: "subs"
                onClicked: bandController.testSubs()
            }
        }
    }
}


