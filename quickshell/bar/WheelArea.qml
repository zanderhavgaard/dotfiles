import QtQuick

// MouseArea that turns wheel input into whole steps: one per mouse-wheel
// notch (120), with a touchpad's many small deltas added up to the same
// instead of each counting as a step. Horizontal scrolling is ignored.
MouseArea {
    signal scrolled(int steps)

    property real wheelAccum: 0

    onWheel: wheel => {
        wheelAccum += wheel.angleDelta.y;
        const steps = Math.trunc(wheelAccum / 120);
        if (steps === 0) return;
        wheelAccum -= steps * 120;
        scrolled(steps);
    }
}
