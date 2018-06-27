import QtQuick 2.0
import watchfish 1.0
import QtPositioning 5.2
import ".."


App {
    guid: BandConstants.weatherApp
    onInterpreterReady: gps.start()

    function updatePosition(position) {
        if (ready && position.latitudeValid && position.longitudeValid) {
            bandController.callApp("WeatherApp", "set_location", [
                position.coordinate.latitude, position.coordinate.longitude
            ])
            return true;
        }
    }

    PositionSource {
        id: gps
        updateInterval: 500000
        active: false
        onPositionChanged: {
            if (updatePosition(position))
                gps.stop()
        }
    }
}
