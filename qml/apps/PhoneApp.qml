import QtQuick 2.0
import watchfish 1.0
import ".."


App {
    property int callId: 5
    property bool answered: false
    guid: BandConstants.phoneApp
    onPushReceived: {
        if (message.command === "reply") {
            console.log("TODO: Send SMS to " + message.call_id + ": " + message.text)
        }
    }

    VoiceCallManager {
        id: callManager
        onActiveVoiceCallChanged: {
            if (activeVoiceCall) {
                // increment call ID
                callId += 1;
                answered = false;

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
                bandController.callApp('PhoneApp', 'incoming_call', [callId, person])
                activeVoiceCall.statusChanged.connect(function () {
                    if (activeVoiceCall.status == 1)
                        answered = true;

                    if (activeVoiceCall.status == 7 && !answered) {
                        bandController.callApp('PhoneApp', 'missed_call', [callId, person])
                    }
                })
            }
        }
    }
}
