#include <QQmlContext>
#include <QGuiApplication>
#include <QQuickView>
#include <sailfishapp.h>
#include "watchfish/voicecallmanager.h"
#include "watchfish/voicecallhandler.h"
#include "watchfish/notificationmonitor.h"
#include "watchfish/musiccontroller.h"
#include "watchfish/notifications.h"
#include "BleDiscovery.h"

int main(int argc, char *argv[])
{
    QGuiApplication* app(SailfishApp::application(argc, argv));

    qmlRegisterType<watchfish::NotificationMonitor>("watchfish", 1, 0, "NotificationMonitor");
    qmlRegisterType<watchfish::MusicController>("watchfish", 1, 0, "MusicController");
    qmlRegisterType<VoiceCallManager>("watchfish", 1, 0, "VoiceCallManager");
    qmlRegisterType<BleDiscovery>("FishBand", 1, 0, "BluetoothDiscovery");
    // qmlRegisterType<BandDevice>("FishBand", 1, 0, "BandDevice");
    qmlRegisterUncreatableType<watchfish::Notification>("watchfish", 1, 0, "Notification", "Just because bro");
    qmlRegisterUncreatableType<VoiceCallHandler>("watchfish", 1, 0, "VoiceCallHandler", "Just because bro");
    QQuickView *view = SailfishApp::createView();
    view->setSource(SailfishApp::pathTo("qml/harbour-fishband.qml"));
    view->show();
    return app->exec();
}
