//
//  Math.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 04/02/26.
//


import CoreGraphics

enum Math {
    static func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat { a + (b - a) * t }
    static func clamp(_ x: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat { min(max(x, lo), hi) }
}
