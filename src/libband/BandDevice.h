#ifndef BANDDEVICE_H
#define BANDDEVICE_H

#include <QBluetoothAddress>
#include <QBluetoothSocket>


class BandDevice : public QObject
{
    Q_OBJECT
public:
    explicit BandDevice(QObject *parent = nullptr);
    ~BandDevice();

signals:
    void connected();
    void disconnected();

public slots:
    Q_INVOKABLE void send(const QString &message);
    Q_INVOKABLE void start(QString macAddress);
    Q_INVOKABLE void stop();

    void onError(QBluetoothSocket::SocketError error);

private:
    QBluetoothSocket *socket;

};

#endif // BANDDEVICE_H
