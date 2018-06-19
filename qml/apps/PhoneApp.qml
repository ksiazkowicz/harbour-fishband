import QtQuick 2.0
import watchfish 1.0
import ".."


App {
    guid: BandConstants.phoneApp
    onPushReceived: {
        if (message.command === "hangup")
            callManager.activeVoiceCall.hangup()
    }

    VoiceCallManager {
        id: callManager
        onActiveVoiceCallChanged: {
            if (activeVoiceCall) {
                // process only incoming calls
                if (activeVoiceCall.status !== 5)
                    return;

                // try to get person by phone number
                var person = callManager.findPersonByNumber(activeVoiceCall.lineId);

                // use "Private Number" or phone number as callback
                if (!person) {
                    if (!activeVoiceCall.lineId)
                        person = "Private Number";
                    else person = lineId;
                }

                // send notification
                bandController.sendNotification(
                            person, "Incoming Call", BandConstants.phoneApp,
                            BandConstants.flagMessaging)
                /*activeVoiceCall.statusChanged.connect(function () {
                    console.log(handlerId)
                    console.log(providerId)
                    console.log(status)
                    console.log(statusText)
                })*/
            }
        }
    }
}
