import QtQuick 2.15
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../services"
import "../widgets/osd"

// OsdWindow — On-screen display HUD overlay for Volume, Mic Mute, and Brightness
PanelWindow {
    id: root

    // Cover full screen so the HUD card can float centered
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None


    visible: isShowing || fadeAnim.running

    property bool isShowing: false
    property string mode: "volume"    // "volume" | "mic" | "brightness"
    property real value: 0.0          // 0.0 to 1.0
    property bool isMuted: false

    AudioService {
        id: audioService
        onVolumeUpdated: (newVol, muted) => {
            root.display("volume", newVol, muted);
        }
        onMicMuteUpdated: (muted) => {
            root.display("mic", audioService.micVolume, muted);
        }
    }

    BrightnessService {
        id: brightnessService
        onBrightnessUpdated: (newBri) => {
            root.display("brightness", newBri, false);
        }
    }

    Timer {
        id: dismissTimer
        interval: 1600
        repeat: false
        onTriggered: {
            root.isShowing = false;
        }
    }

    function display(newMode: string, newVal: real, muted: bool): void {
        root.mode = newMode;
        root.value = newVal;
        root.isMuted = muted;
        root.isShowing = true;
        dismissTimer.restart();
    }

    // IPC interface for testing or external scripts
    IpcHandler {
        target: "osd"
        function showVolume(val: real): void {
            root.display("volume", val, false);
        }
        function showMute(): void {
            root.display("volume", audioService.volume, true);
        }
        function showMic(): void {
            root.display("mic", audioService.micVolume, true);
        }
        function showBrightness(val: real): void {
            root.display("brightness", val, false);
        }
        function hide(): void {
            dismissTimer.stop();
            root.isShowing = false;
        }
    }

    // Floating OSD HUD card centered in the classic lower-middle viewport
    OsdCard {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(parent.height * 0.18)

        mode: root.mode
        value: root.value
        isMuted: root.isMuted

        opacity: root.isShowing ? 1.0 : 0.0
        scale: root.isShowing ? 1.0 : 0.92

        Behavior on opacity {
            NumberAnimation {
                id: fadeAnim
                duration: 130
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            SpringAnimation {
                spring: 4.5
                damping: 0.38
                mass: 0.8
            }
        }
    }
}
