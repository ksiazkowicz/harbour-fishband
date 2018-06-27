import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: delegate
    property string icon: ""
    property string value: ""
    property string title: ""
    height: Theme.iconSizeLarge
    x: Theme.horizontalPageMargin
    width: parent.width - 2*x

    Image {
        id: delegateIcon
        source: delegate.icon
        width: Theme.iconSizeLarge
        height: Theme.iconSizeLarge
        sourceSize.width: Theme.iconSizeLarge
        sourceSize.height: Theme.iconSizeLarge
    }
    Column {
        anchors {
            verticalCenter: delegateIcon.verticalCenter
            left: delegateIcon.right
            right: parent.right
            leftMargin: Theme.paddingMedium
        }

        Label {
            truncationMode: TruncationMode.Fade
            text: delegate.title
        }
        Label {
            truncationMode: TruncationMode.Fade
            color: Theme.secondaryColor
            text: delegate.value
        }
    }
}
