import QtQuick 2.0
import watchfish 1.0
import ".."


App {
    guid: BandConstants.musicApp
    onPushReceived: {
        if (message.command === "playButtonText")
            musicController.playPause();
        if (message.command === "prevButtonText")
            musicController.previous();
        if (message.command === "nextButtonText")
            musicController.next();
        if (message.command === "VolumeUp")
            musicController.volumeUp();
        if (message.command === "VolumeDown")
            musicController.volumeDown();
    }
    onInterpreterReady: updateMetadata()

    function updateMetadata() {
        if (ready) {
            var title = musicController.title;
            var artist = musicController.artist;
            var album = musicController.album;
            if (musicController.status === 0) {
                title = "N/A";
                artist = "N/A";
                album = "N/A";
            }

            bandController.callApp(
                        "MusicApp", "metadata_update", [title, artist, album])
        }
    }

    MusicController {
        id: musicController
        onMetadataChanged: updateMetadata()
        onStatusChanged: updateMetadata()
    }
}
