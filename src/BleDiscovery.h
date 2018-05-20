#ifndef BLEDISCOVERY_H
#define BLEDISCOVERY_H

#include <QObject>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothDeviceInfo>


class BleDiscovery : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ getRunning NOTIFY runningChanged)

public:
    explicit BleDiscovery(QObject *parent = nullptr);
    ~BleDiscovery();

private:
    QBluetoothDeviceDiscoveryAgent *m_discoveryAgent;
    bool m_running;

signals:
    void newDevice(QString name, QString macAddress);
    void runningChanged();

public slots:
    void deviceDiscovered(const QBluetoothDeviceInfo&);
    void discoveryFinished();
    Q_INVOKABLE void startDiscovery();
    Q_INVOKABLE void stopDiscovery();

    bool getRunning();
};

#endif // BLEDISCOVERY_H
