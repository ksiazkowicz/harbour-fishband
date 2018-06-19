/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import watchfish 1.0
import "apps"
import "pages"
import "."

ApplicationWindow
{
    id: application
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    NotificationMonitor {
        id: monitor
        property variant blacklist: ["store-client", "com.spotify.music"]
        onNotification: function (notification) {
            // check if is on blacklist
            if (blacklist.indexOf(notification.owner) != -1)
                return
            if (blacklist.indexOf(notification.originPackage) != -1)
                return

            // get summary and body
            var summary = notification.previewSummary;
            if (!summary)
                summary = notification.summary;
            var body = notification.previewBody;
            if (!body)
                body = notification.body;

            // check if is SMS
            if (notification.category === "x-nemo.messaging.sms.preview") {
                bandController.sendNotification(
                            summary, body, BandConstants.smsApp,
                            BandConstants.flagMessaging)
                return;
            }

            // check if is email
            if (notification.category === "x-nemo.email") {
                bandController.sendNotification(
                            summary, body, BandConstants.mailApp,
                            BandConstants.flagMessaging)
                return;
            }

            // check if is messenger
            if (notification.owner === "aliendalvik") {
                if (notification.originPackage === "com.facebook.orca")
                    bandController.sendNotification(
                                summary, body, BandConstants.messengerApp,
                                BandConstants.flagMessaging)
                    return;
            }

            // push notification
            bandController.sendNotification(
                        summary, body, BandConstants.feedApp,
                        BandConstants.flagMessaging)
        }
    }

    MusicApp {}
    PhoneApp {}
    WeatherApp {}

    BandController {
        id: bandController
    }
}


