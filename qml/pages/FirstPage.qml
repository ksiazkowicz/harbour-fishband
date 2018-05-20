import QtQuick 2.0
import Sailfish.Silica 1.0

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

            SectionHeader { text: "Info" }
            DetailItem {
                label: "Last sync"
                value: bandController.lastSync ? bandController.lastSync.toLocaleString() : "Never"
            }
            DetailItem {
                label: "Language"
                value: bandController.deviceLanguage
            }
            DetailItem {
                label: "Serial Number"
                value: bandController.deviceSerialNumber
            }
        }
    }
}


