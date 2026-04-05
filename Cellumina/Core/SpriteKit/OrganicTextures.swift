//
//  OrganicTextures.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 04/02/26.
//


import UIKit
import SpriteKit

enum OrganicTextures {

    static func blob(size: CGSize, tint: UIColor, strokeAlpha: CGFloat = 0.55, fillAlpha: CGFloat = 0.18, wobble: CGFloat = 0.22) -> SKTexture {
        let r = UIGraphicsImageRenderer(size: size)
        let img = r.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.fill(rect)

            let inset = min(size.width, size.height) * 0.08
            let path = blobPath(in: rect.insetBy(dx: inset, dy: inset), wobble: wobble)

            ctx.cgContext.addPath(path.cgPath)
            ctx.cgContext.setFillColor(tint.withAlphaComponent(fillAlpha).cgColor)
            ctx.cgContext.fillPath()

            ctx.cgContext.addPath(path.cgPath)
            ctx.cgContext.setStrokeColor(tint.withAlphaComponent(strokeAlpha).cgColor)
            ctx.cgContext.setLineWidth(max(2, min(size.width, size.height) * 0.03))
            ctx.cgContext.strokePath()

            let hl = UIBezierPath(ovalIn: CGRect(x: rect.midX - rect.width*0.18, y: rect.midY - rect.height*0.22,
                                                width: rect.width*0.22, height: rect.height*0.16))
            ctx.cgContext.addPath(hl.cgPath)
            ctx.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.16).cgColor)
            ctx.cgContext.fillPath()
        }
        return SKTexture(image: img)
    }

    static func glowDot(size: CGSize, tint: UIColor) -> SKTexture {
        let r = UIGraphicsImageRenderer(size: size)
        let img = r.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.fill(rect)

            let c = CGPoint(x: rect.midX, y: rect.midY)
            let maxR = max(rect.width, rect.height) / 2

            for i in stride(from: 1.0, through: 0.2, by: -0.2) {
                let rr = maxR * i
                let a = CGFloat(i) * 0.35
                let p = UIBezierPath(ovalIn: CGRect(x: c.x-rr, y: c.y-rr, width: rr*2, height: rr*2))
                ctx.cgContext.addPath(p.cgPath)
                ctx.cgContext.setFillColor(tint.withAlphaComponent(a).cgColor)
                ctx.cgContext.fillPath()
            }
        }
        return SKTexture(image: img)
    }

    static func organelleDot(size: CGSize, tint: UIColor) -> SKTexture {
        let r = UIGraphicsImageRenderer(size: size)
        let img = r.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.fill(rect)

            let dot = UIBezierPath(ovalIn: rect.insetBy(dx: rect.width*0.12, dy: rect.height*0.12))
            ctx.cgContext.addPath(dot.cgPath)
            ctx.cgContext.setFillColor(tint.withAlphaComponent(0.88).cgColor)
            ctx.cgContext.fillPath()

            ctx.cgContext.addPath(dot.cgPath)
            ctx.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.35).cgColor)
            ctx.cgContext.setLineWidth(max(1.5, rect.width * 0.06))
            ctx.cgContext.strokePath()
        }
        return SKTexture(image: img)
    }

    private static func blobPath(in rect: CGRect, wobble: CGFloat) -> UIBezierPath {
        let points = 11
        let cx = rect.midX
        let cy = rect.midY
        let rx = rect.width / 2
        let ry = rect.height / 2
        let p = UIBezierPath()

        for i in 0..<points {
            let t = CGFloat(i) / CGFloat(points)
            let ang = t * 2 * .pi
            let noise = (sin(ang * 2.7) + cos(ang * 1.9)) * 0.5
            let wob = 1 + noise * wobble

            let x = cx + cos(ang) * rx * wob
            let y = cy + sin(ang) * ry * wob

            if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
            else { p.addLine(to: CGPoint(x: x, y: y)) }
        }

        p.close()
        return p
    }
}
