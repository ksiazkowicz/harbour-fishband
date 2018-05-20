import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: themePage

    SilicaGridView {
        id: grid
        width: parent.width
        height: parent.height
        anchors.fill: parent
        cellWidth: width/4
        cellHeight: width/4
        header: PageHeader { title: qsTr("Themes") }
        model: ListModel {
            ListElement {
                // Coral
                themeColor: "#d94c66"
                themeBase: 4292430950
                themeHighlight: 4293547125
                themeLowlight: 4291184483
                themeSecondaryText: 4287994781
                themeHighContrast: 4294397306
                themeMuted: 4288230212
                isAmbience: false
            }
            ListElement {
                // Cornflower
                themeColor: "#3366cc"
                themeBase: 4281558732
                themeHighlight: 4282022109
                themeLowlight: 4281427386
                themeSecondaryText: 4289177770
                themeHighContrast: 4282022109
                themeMuted: 4279780988
                isAmbience: false
            }
            ListElement {
                // Cyber
                themeColor: "#39bf6f"
                themeBase: 4281974639
                themeHighlight: 4282502778
                themeLowlight: 4281707109
                themeSecondaryText: 4288190870
                themeHighContrast: 4281852540
                themeMuted: 4281431887
                isAmbience: false
            }
            ListElement {
                // Electric
                themeColor: "#00b9f2"
                themeBase: 4278237682
                themeHighlight: 4284145919
                themeLowlight: 4278235867
                themeSecondaryText: 4288584605
                themeHighContrast: 4279095807
                themeMuted: 4278413941
                isAmbience: false
            }
            ListElement {
                // Flame
                isAmbience: false
                themeColor: '#f0530e'; themeBase: 4293939982; themeHighlight: 4294731325; themeLowlight: 4292690958; themeSecondaryText: 4288584605; themeHighContrast: 4294930248; themeMuted: 4286521115
            }
            ListElement {
                // Fuchsia
                isAmbience: false
                themeColor: "#d936d9"; themeBase: 4292425433; themeHighlight: 4294192895; themeLowlight: 4290917574; themeSecondaryText: 4288584605; themeHighContrast: 4293938169; themeMuted: 4286254980
            }
            ListElement {
                // Joule
                isAmbience: false
                themeColor: "#ffaf00"; themeBase: 4294946560; themeHighlight: 4294946560; themeLowlight: 4294547971; themeSecondaryText: 4288387736; themeHighContrast: 4294949888; themeMuted: 4288899072
            }
            ListElement {
                // Lime
                isAmbience: false
                themeColor: "#99c814"; themeBase: 4288268308; themeHighlight: 4289846038; themeLowlight: 4286162991; themeSecondaryText: 4288584605; themeHighContrast: 4288142144; themeMuted: 4283523866
            }
            ListElement {
                // Orchid
                themeColor: "#9787af"; themeBase: 4288120751; themeHighlight: 4289503169; themeLowlight: 4286477966; themeSecondaryText: 4288059033; themeHighContrast: 4290225619; themeMuted: 4285030770
            }
            ListElement {
                // Penguin
                themeColor: "#151515"; themeBase: 4279571733; themeHighlight: 4294946560; themeLowlight: 4279308561; themeSecondaryText: 4286217340; themeHighContrast: 4281348144; themeMuted: 4288899072
            }
            ListElement {
                // Violet
                isAmbience: false
                themeColor: "#7842cf"; themeBase: 4286071503; themeHighlight: 4287324658; themeLowlight: 4285087676; themeSecondaryText: 4289177514; themeHighContrast: 4287126265; themeMuted: 4282920332
            }
            ListElement {
                // Berry
                themeColor: "#771e7c"; themeBase: 4285996668; themeHighlight: 4293412351; themeLowlight: 4284160096; themeSecondaryText: 4289608902; themeHighContrast: 4287309203; themeMuted: 4285996668
            }
            ListElement {
                // Cargo
                themeColor: "#7842cf"; themeBase: 4286071503; themeHighlight: 4289227257; themeLowlight: 4284889264; themeSecondaryText: 4287646706; themeHighContrast: 4287258574; themeMuted: 4282590324
            }

            ListElement {
                isAmbience: true
            }

        }
        delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight
            MouseArea {
                anchors.fill: parent
                z: 1
                onClicked: {
                    if (isAmbience) {
                        bandController.setTheme(
                             themePage.hexToRgbA(Theme.highlightDimmerColor),
                             themePage.hexToRgbA(Theme.highlightColor),
                             themePage.hexToRgbA(Theme.secondaryHighlightColor),
                             themePage.hexToRgbA(Theme.secondaryColor),
                             themePage.hexToRgbA("#000000"),
                             themePage.hexToRgbA(Theme.highlightBackgroundColor))
                    } else {
                        bandController.setTheme(themeBase, themeHighlight,
                                                themeLowlight,
                                                themeSecondaryText,
                                                themeHighContrast, themeMuted);
                    }
                }
            }

            Rectangle {
                color: isAmbience ? Theme.highlightColor : themeColor
                anchors.fill: parent
            }
        }
    }

    function hexToRgbA(hex){
        hex = String(hex);
        var hasAlpha = hex.length === 9;
        var x = hasAlpha ? 2 : 0;

        var alpha = hasAlpha ? parseInt(hex.slice(1, 3), 16) : 255;
        var r = parseInt(hex.slice(1+x, 3+x), 16);
        var g = parseInt(hex.slice(3+x, 5+x), 16);
        var b = parseInt(hex.slice(5+x, 7+x), 16);
        return ((alpha << 24)>>>0 | (r << 16)>>>0 | (g << 8)>>>0 | b>>>0)>>>0;
    }
}


