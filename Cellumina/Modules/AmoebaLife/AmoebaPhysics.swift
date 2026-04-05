//
//  AmoebaPhysics.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 06/02/26.
//


import CoreGraphics

enum AmoebaPhysics {

    static func organicBlobPath(center: CGPoint, baseRadius: CGFloat, points: Int, wobble: CGFloat, time: CGFloat, stretchDir: CGVector, stretchAmount: CGFloat) -> CGPath {
        let p = max(8, points)
        var pts: [CGPoint] = []
        pts.reserveCapacity(p)

        let sLen = max(0.0001, sqrt(stretchDir.dx*stretchDir.dx + stretchDir.dy*stretchDir.dy))
        let sx = stretchDir.dx / sLen
        let sy = stretchDir.dy / sLen

        for i in 0..<p {
            let a = (CGFloat(i) / CGFloat(p)) * (.pi * 2)

            let noise = sin(a * 3 + time * 1.2) * 0.6 + sin(a * 7 - time * 0.9) * 0.4
            let rWobble = 1 + wobble * noise

            let dx = cos(a)
            let dy = sin(a)
            let dot = max(0, dx*sx + dy*sy)
            let rStretch = 1 + stretchAmount * dot

            let r = baseRadius * rWobble * rStretch
            pts.append(CGPoint(x: center.x + dx * r, y: center.y + dy * r))
        }

        let path = CGMutablePath()
        guard pts.count >= 4 else { return path }

        path.move(to: pts[0])
        for i in 0..<pts.count {
            let p0 = pts[(i - 1 + pts.count) % pts.count]
            let p1 = pts[i]
            let p2 = pts[(i + 1) % pts.count]
            let p3 = pts[(i + 2) % pts.count]

            let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
            let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)

            path.addCurve(to: p2, control1: c1, control2: c2)
        }

        path.closeSubpath()
        return path
    }

    static func insetPath(_ path: CGPath, inset: CGFloat) -> CGPath {
        let box = path.boundingBoxOfPath
        let cx = box.midX
        let cy = box.midY

        let sx = max(0.01, (box.width - inset*2) / max(1, box.width))
        let sy = max(0.01, (box.height - inset*2) / max(1, box.height))

        var t = CGAffineTransform(translationX: -cx, y: -cy)
        t = t.scaledBy(x: sx, y: sy)
        t = t.translatedBy(x: cx, y: cy)

        return path.copy(using: &t) ?? path
    }
}
