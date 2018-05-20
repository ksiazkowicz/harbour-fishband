import QtQuick 2.0
import Sailfish.Silica 1.0
import FishBand 1.0


Page
{
    id: screen

    ListModel {
        id: devicesModel
    }

    BluetoothDiscovery
    {
        id: bleDiscovery
        onNewDevice: devicesModel.append({
                             "name": name,
                             "macAddress": macAddress
                         });
        Component.onCompleted: startDiscovery()
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height

        Column
        {
            id: column
            width: screen.width
            spacing: Theme.paddingLarge

            PullDownMenu
            {
                MenuItem
                {
                    text: bleDiscovery.running ? qsTr("Stop search") : qsTr("Start search")
                    onClicked: {
                        if (bleDiscovery.running)
                            bleDiscovery.stopDiscovery();
                        else {
                            devicesModel.clear()
                            bleDiscovery.startDiscovery();
                        }
                    }
                }
            }

            PageHeader { title: qsTr("Choose your Band") }

            ProgressBar
            {
                 anchors { left: parent.left; right: parent.right }
                 visible: bleDiscovery.running
                 label: qsTr("Discovering nearby devices...")
                 indeterminate: true
            }

            Repeater
            {
                model: devicesModel

                delegate: ListItem
                {
                    onClicked: {
                        bandController.selectDevice(macAddress);
                        pageStack.pop();
                    }

                    Image {
                        id: bluetoothIcon
                        source: "image://Theme/icon-m-bluetooth-device"
                        anchors {
                            left: parent.left
                            top: parent.top
                            topMargin: Theme.paddingSmall
                            leftMargin: Theme.horizontalPageMargin
                        }
                        width: Theme.iconSizeMedium
                        height: width
                    }

                    Label
                    {
                        id: device
                        anchors
                        {
                           left: bluetoothIcon.right
                           verticalCenter: parent.verticalCenter
                           leftMargin: Theme.paddingSmall
                        }
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.primaryColor
                        text: name
                    }
                }
            }
        }
    }
}
