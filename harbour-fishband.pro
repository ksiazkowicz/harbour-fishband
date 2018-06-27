# The name of your application
TARGET = harbour-fishband

CONFIG += sailfishapp
QT += dbus bluetooth

PKGCONFIG += dbus-1 mpris-qt5 Qt5Contacts

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

HEADERS += src/watchfish/notificationmonitor.h \
           src/watchfish/notificationmonitor_p.h \
           src/watchfish/notifications.h \
           src/watchfish/musiccontroller.h \
           src/watchfish/voicecallmanager.h \
           src/watchfish/voicecallhandler.h \
           src/BleDiscovery.h

SOURCES += src/main.cpp \
           src/watchfish/notificationmonitor.cpp \
           src/watchfish/notifications.cpp \
           src/watchfish/musiccontroller.cpp \
           src/watchfish/voicecallmanager.cpp \
           src/watchfish/voicecallhandler.cpp \
           src/BleDiscovery.cpp

OTHER_FILES += qml/harbour-fishband.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/* \
    harbour-fishband.desktop \
    qml/pages/datadownloader.py \
    qml/src/wrapper.py \
    qml/src/libband/* \
    qml/src/notifications/*

DISTFILES += \
    qml/pages/ThemePage.qml \
    qml/BandController.qml \
    qml/Constants.qml \
    qml/qmldir \
    qml/apps/MusicApp.qml \
    qml/apps/App.qml \
    qml/apps/PhoneApp.qml \
    qml/apps/WeatherApp.qml \
    qml/apps/FeedApp.qml \
    qml/pages/DevicePage.qml \
    qml/delegates/HomeInfoDelegate.qml
