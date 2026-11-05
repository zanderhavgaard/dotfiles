import QtQuick
import qs

// Seigaiha (青海波) wave pattern: rows of overlapping concentric half-circles.
Canvas {
    id: root

    property real radius: 20
    property color ground: Theme.sumiInk3
    property color ink: Theme.waveBlue1

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        const r = radius;
        ctx.reset();
        ctx.fillStyle = ground;
        ctx.fillRect(0, 0, width, height);
        ctx.lineWidth = r * 0.09;
        ctx.strokeStyle = ink;

        // back rows first so each row overlaps the one above it
        let row = 0;
        for (let y = -r; y <= height + r; y += r / 2, row++) {
            const offset = row % 2 ? r : 0;
            for (let x = -2 * r + offset; x <= width + 2 * r; x += 2 * r) {
                ctx.beginPath();
                ctx.arc(x, y, r, 0, Math.PI * 2);
                ctx.fill();
                for (const f of [0.92, 0.72, 0.52, 0.32]) {
                    ctx.beginPath();
                    ctx.arc(x, y, r * f, Math.PI, 2 * Math.PI);
                    ctx.stroke();
                }
            }
        }
    }
}
