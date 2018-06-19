#include "BandDevice.h"
#include <QDebug>

BandDevice::BandDevice(QObject *parent) : QObject(parent), socket(0)
{

}

BandDevice::~BandDevice()
{
    stop();
}

void BandDevice::stop()
{
    delete socket;
    socket = 0;
}

void BandDevice::start(QString macAddress)
{
    if (socket)
        stop();

    // Connect to service
    socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol);
    socket->connectToService(QBluetoothAddress(macAddress), 4);

    qDebug() << QBluetoothAddress(macAddress);

    connect(socket, SIGNAL(connected()), this, SIGNAL(connected()));
    connect(socket, SIGNAL(disconnected()), this, SIGNAL(disconnected()));
    connect(socket, SIGNAL(error(QBluetoothSocket::SocketError)), this, SLOT(onError(QBluetoothSocket::SocketError)));
}

void BandDevice::onError(QBluetoothSocket::SocketError error)
{
    qDebug() << error;
}

void BandDevice::send(const QString& message)
{
    socket->write(QByteArray::fromHex(message.toLatin1()));
}
