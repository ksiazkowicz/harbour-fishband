import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        anchors {
            bottom: label.top
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Theme.paddingMedium
        }
        width: Theme.iconSizeExtraLarge
        height: width
        source: "image://theme/icon-m-watch"
    }

    Label {
        id: label
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Theme.horizontalPageMargin
        }
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        text: bandController.deviceName
        font.pixelSize: Theme.fontSizeLarge
    }

    Label {
        anchors {
            left: parent.left
            right: parent.right
            top: label.bottom
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
        }
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: Theme.secondaryColor
        visible: !bandController.isSyncing
        text: bandController.lastSync ? bandController.lastSync.toLocaleDateString() : "Never"
    }

    Label {
        anchors { horizontalCenter: parent.horizontalCenter; top: label.bottom }
        visible: bandController.isSyncing
        color: Theme.highlightColor
        text: "Syncing..."
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-sync"
            onTriggered: if (!bandController.isSyncing) bandController.sync()
        }
    }
}


