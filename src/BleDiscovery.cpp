#include "BleDiscovery.h"

BleDiscovery::BleDiscovery(QObject *parent) : QObject(parent)
{
    m_discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);

    connect(m_discoveryAgent, SIGNAL(deviceDiscovered(const QBluetoothDeviceInfo&)),
            this, SLOT(deviceDiscovered(const QBluetoothDeviceInfo&)));
    connect(m_discoveryAgent, SIGNAL(finished()), this, SLOT(discoveryFinished()));
}


BleDiscovery::~BleDiscovery()
{
    // send signal to QML just in case
    m_running = false;
    emit runningChanged();

    // stop and delete discovery agent
    m_discoveryAgent->stop();
    delete m_discoveryAgent;
}


void BleDiscovery::startDiscovery() {
    m_discoveryAgent->start();
    m_running = true;
    emit runningChanged();
}

void BleDiscovery::stopDiscovery() {
    m_discoveryAgent->stop();
    m_running = false;
    emit runningChanged();
}


void BleDiscovery::deviceDiscovered(const QBluetoothDeviceInfo &info) {
    emit newDevice(info.name(), info.address().toString());
}


void BleDiscovery::discoveryFinished() {
    m_running = false;
    emit runningChanged();
}


bool BleDiscovery::getRunning() {
    return m_running;
}
