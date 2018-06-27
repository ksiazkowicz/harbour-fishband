import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
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

            SectionHeader { text: "Status" }
            DetailItem {
                label: "Cargo Service"
                value: bandController.cargoServiceStatus
            }
            DetailItem {
                label: "Push Service"
                value: bandController.pushServiceStatus
            }
        }
    }
}


