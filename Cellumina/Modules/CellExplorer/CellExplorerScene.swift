//
//  CellExplorerScene.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 05/02/26.
//

import SpriteKit
import UIKit

final class CellExplorerScene: SKScene {

    var onOrganelleTapped: ((String) -> Void)?

    private let root = SKNode()
    private let clippedWorld = SKNode()

    private var crop = SKCropNode()
    private var maskNode = SKShapeNode()

    private var cytoplasm: SKShapeNode?
    private var membraneStroke: SKNode?
    private var wallStroke: SKShapeNode?

    private var currentCell: ExplorerCellType = .animal
    private var didConfigure = false

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .clear
        view.allowsTransparency = true
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)

        if didConfigure, size.width > 10, size.height > 10 {
            rebuild()
        }
    }

    func configure() {
        guard !didConfigure else {
            return
        }
        didConfigure = true

        // center = (0,0), left = -w/2, right = +w/2
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = .resizeFill

        removeAllChildren()
        addChild(root)
    }

    func setViewport(size newSize: CGSize) {
        guard newSize.width > 10, newSize.height > 10 else {
            return
        }
        guard didConfigure else {
            return
        }

        if self.size != newSize {
            self.size = newSize
            rebuild()
        }
    }

    func load(cell: ExplorerCellType) {
        currentCell = cell
        rebuild()
    }

    // MARK: - rebuild
    private func rebuild() {
        guard didConfigure else {
            return
        }
        guard size.width > 10, size.height > 10 else {
            return
        }

        root.removeAllChildren()
        clippedWorld.removeAllChildren()

        crop = SKCropNode()
        maskNode = SKShapeNode()
        crop.maskNode = maskNode

        root.addChild(crop)
        crop.addChild(clippedWorld)

        cytoplasm = nil
        membraneStroke = nil
        wallStroke = nil

        switch currentCell {
            case .animal: buildAnimal()
            case .plant: buildPlant()
            case .bacteria: buildBacteria()
        }
        animateLife()
    }

    // MARK: - build animal
    private func buildAnimal() {
        let mid = CGPoint.zero

        let rect = CGRect(x: mid.x - 260, y: mid.y - 180, width: 520, height: 360)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 120)

        applyMask(path)

        let cyto = SKShapeNode(path: path.cgPath)
        cyto.fillColor = UIColor.systemTeal.withAlphaComponent(0.12)
        cyto.strokeColor = .clear
        cyto.zPosition = 0
        clippedWorld.addChild(cyto)
        cytoplasm = cyto

        let out = roundedStrokeTexture(
            size: rect.size,
            cornerRadius: 120,
            lineWidth: 10,
            stroke: UIColor.brown
        )

        let membrane = SKSpriteNode(texture: out.texture)
        membrane.size = out.spriteSize    
        membrane.position = mid
        membrane.zPosition = 50
        membrane.alpha = 1.0
        root.addChild(membrane)
        membraneStroke = membrane
        
        addNucleus(at: CGPoint(x: mid.x + 120, y: mid.y - 5), into: clippedWorld)
        addER(at: CGPoint(x: mid.x + 110, y: mid.y - 125), into: clippedWorld)
        addGolgi(at: CGPoint(x: mid.x - 150, y: mid.y - 35), into: clippedWorld)

        addMitochondrion(at: CGPoint(x: mid.x - 170, y: mid.y + 95), into: clippedWorld)
        addMitochondrion(at: CGPoint(x: mid.x - 40, y: mid.y + 120), into: clippedWorld)
        addMitochondrion(at: CGPoint(x: mid.x - 170, y: mid.y - 120), into: clippedWorld)
        addMitochondrion(at: CGPoint(x: mid.x + 40, y: mid.y + 120), into: clippedWorld)

        addLysosome(at: CGPoint(x: mid.x + 190, y: mid.y + 110), into: clippedWorld)
        addLysosome(at: CGPoint(x: mid.x + 190, y: mid.y - 120), into: clippedWorld)
        addLysosome(at: CGPoint(x: mid.x - 10, y: mid.y - 140), into: clippedWorld)

        addRibosomes(in: rect.insetBy(dx: 30, dy: 30), into: clippedWorld)
    }

    
    // MARK: - build plant
    private func buildPlant() {
        let mid = CGPoint.zero

        let rect = CGRect(x: mid.x - 300, y: mid.y - 190, width: 600, height: 380)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 70)

        applyMask(path)

        let cyto = SKShapeNode(path: path.cgPath)
        cyto.fillColor = UIColor.systemGreen.withAlphaComponent(0.10)
        cyto.strokeColor = .clear
        cyto.zPosition = 0
        clippedWorld.addChild(cyto)
        cytoplasm = cyto

        let wall = SKShapeNode(path: path.cgPath)
        wall.fillColor = .clear
        wall.strokeColor = UIColor.systemGreen.withAlphaComponent(0.95)
        wall.lineWidth = 16
        wall.lineCap = .round
        wall.lineJoin = .round
        wall.isAntialiased = true
        wall.zPosition = 60
        root.addChild(wall)
        wallStroke = wall

        let inner = SKShapeNode(path: path.cgPath)
        inner.fillColor = .clear
        inner.strokeColor = UIColor.systemGreen.withAlphaComponent(0.35)
        inner.lineWidth = 6
        inner.lineCap = .round
        inner.lineJoin = .round
        inner.isAntialiased = true
        inner.zPosition = 59
        root.addChild(inner)

        let vac = SKShapeNode(rectOf: CGSize(width: 330, height: 240), cornerRadius: 46)
        vac.fillColor = UIColor.systemCyan.withAlphaComponent(0.25)
        vac.strokeColor = UIColor.white.withAlphaComponent(0.16)
        vac.lineWidth = 3
        vac.position = CGPoint(x: mid.x + 90, y: mid.y - 5)
        vac.zPosition = 5
        vac.name = "vacuole"
        setTapKey(vac, "vacuole")
        clippedWorld.addChild(vac)

        addNucleus(at: CGPoint(x: mid.x - 190, y: mid.y + 80), into: clippedWorld)
        addGolgi(at: CGPoint(x: mid.x + 170, y: mid.y + 120), into: clippedWorld)
        addER(at: CGPoint(x: mid.x - 40, y: mid.y - 135), into: clippedWorld)

        addChloroplast(at: CGPoint(x: mid.x - 10, y: mid.y + 115), into: clippedWorld)
        addChloroplast(at: CGPoint(x: mid.x + 220, y: mid.y + 20), into: clippedWorld)
        addChloroplast(at: CGPoint(x: mid.x + 220, y: mid.y - 120), into: clippedWorld)
        addChloroplast(at: CGPoint(x: mid.x - 230, y: mid.y - 110), into: clippedWorld)

        addMitochondrion(at: CGPoint(x: mid.x - 60, y: mid.y + 10), into: clippedWorld)
        addMitochondrion(at: CGPoint(x: mid.x - 140, y: mid.y - 30), into: clippedWorld)

        addRibosomes(in: rect.insetBy(dx: 120, dy: 120), into: clippedWorld)
    }

    
    // MARK: - build bacteria
    private func buildBacteria() {
        let mid = CGPoint.zero

        let padX: CGFloat = 36
        let padY: CGFloat = 34

        let maxW = max(520, size.width  - padX * 2)
        let maxH = max(220, size.height - padY * 2)

        let bodyW = min(640, maxW * 0.78)
        let bodyH = min(260, maxH * 0.42)

        let rect = CGRect(
            x: mid.x - bodyW / 2,
            y: mid.y - bodyH / 2,
            width: bodyW,
            height: bodyH
        )

        let corner = bodyH / 2
        let path = UIBezierPath(roundedRect: rect, cornerRadius: corner)

        applyMask(path)

        let fill = SKShapeNode(path: path.cgPath)
        fill.fillColor = UIColor.systemYellow.withAlphaComponent(0.55)
        fill.strokeColor = .clear
        fill.zPosition = 0
        clippedWorld.addChild(fill)
        cytoplasm = fill

        let capsule = SKShapeNode(path: path.cgPath)
        capsule.fillColor = .clear
        capsule.strokeColor = UIColor.systemCyan.withAlphaComponent(0.35)
        capsule.lineWidth = max(10, bodyH * 0.06)
        capsule.lineCap = .round
        capsule.lineJoin = .round
        capsule.isAntialiased = true
        capsule.zPosition = 60
        root.addChild(capsule)

        let wall = SKShapeNode(path: path.cgPath)
        wall.fillColor = .clear
        wall.strokeColor = UIColor.systemOrange.withAlphaComponent(0.70)
        wall.lineWidth = max(7, bodyH * 0.045)
        wall.lineCap = .round
        wall.lineJoin = .round
        wall.isAntialiased = true
        wall.zPosition = 61
        root.addChild(wall)

        let dna = SKShapeNode(path: dnaPath(width: bodyW * 0.55, height: bodyH * 0.42).cgPath)
        dna.strokeColor = UIColor.systemRed.withAlphaComponent(0.65)
        dna.lineWidth = max(3, bodyH * 0.018)
        dna.position = CGPoint(x: mid.x - bodyW * 0.06, y: mid.y)
        dna.zPosition = 6
        dna.name = "nucleoid"
        setTapKey(dna, "nucleoid")
        clippedWorld.addChild(dna)
        
        

        let plasmid = SKShapeNode(circleOfRadius: max(16, bodyH * 0.10))
        plasmid.strokeColor = UIColor.systemGreen.withAlphaComponent(0.75)
        plasmid.lineWidth = max(4, bodyH * 0.020)
        plasmid.position = CGPoint(x: mid.x + bodyW * 0.30, y: mid.y - bodyH * 0.14)
        plasmid.zPosition = 6
        plasmid.name = "plasmid"
        setTapKey(plasmid, "plasmid")
        clippedWorld.addChild(plasmid)

        addRibosomes(in: rect.insetBy(dx: bodyW * 0.06, dy: bodyH * 0.10), into: clippedWorld)
        let attach = CGPoint(x: rect.maxX - bodyH * 0.01, y: rect.midY + bodyH * 0.06)

        let rightEdge = (size.width / 2) - 18
        let available = max(40, rightEdge - attach.x)

        let target = min(bodyW * 0.28, available * 0.88)

        let flag = SKShapeNode(
            path: flagellumInsidePathLeft(length: target, amplitude: max(12, bodyH * 0.08)).cgPath
        )
        flag.strokeColor = UIColor.brown.withAlphaComponent(0.82)
        flag.lineWidth = max(7, bodyH * 0.045)
        flag.lineCap = .round
        flag.lineJoin = .round
        flag.isAntialiased = true
        flag.zPosition = 70
        flag.name = "flagellum"
        setTapKey(flag, "flagellum")

        flag.position = CGPoint(x: attach.x + target, y: attach.y)
        root.addChild(flag)
        
        addPiliAroundBacteria(rect: rect, cornerRadius: corner)
    }

    // MARK: - mask
    private func applyMask(_ path: UIBezierPath) {
        maskNode = SKShapeNode(path: path.cgPath)
        maskNode.fillColor = .white
        maskNode.strokeColor = .clear
        crop.maskNode = maskNode
    }

    // MARK: - Organelle Nodes
    private func addNucleus(at p: CGPoint, into parent: SKNode) {
        let nucleus = SKShapeNode(circleOfRadius: 64)
        nucleus.fillColor = UIColor.systemRed.withAlphaComponent(0.55)
        nucleus.strokeColor = UIColor.white.withAlphaComponent(0.18)
        nucleus.lineWidth = 3
        nucleus.position = p
        nucleus.zPosition = 10
        nucleus.name = "nucleus"
        setTapKey(nucleus, "nucleus")
        parent.addChild(nucleus)

        let nucleolus = SKShapeNode(circleOfRadius: 22)
        nucleolus.fillColor = UIColor.systemRed.withAlphaComponent(0.78)
        nucleolus.strokeColor = .clear
        nucleolus.position = CGPoint(x: 12, y: -6)
        nucleolus.zPosition = 11
        nucleolus.name = "nucleolus"
        setTapKey(nucleolus, "nucleolus")
        nucleus.addChild(nucleolus)
    }
    
    private func addPiliAroundBacteria(rect: CGRect, cornerRadius: CGFloat) {
        let count = 80

        let bodyH = rect.height

        let lenMin = max(10, bodyH * 0.08)
        let lenMax = max(14, bodyH * 0.11)

        let lineW = max(2.0, bodyH * 0.012)
        let spikeColor = UIColor.systemOrange.withAlphaComponent(0.85)

        let piliZ: CGFloat = 66
        let hitZ: CGFloat = 67

        let pts = capsulePolylinePoints(rect: rect, cornerRadius: cornerRadius, segmentsPerQuarter: 22)
        let cum = cumulativeLengths(pts)
        guard let total = cum.last, total > 0 else { return }

        let skipX = rect.maxX - max(14, rect.height * 0.12)

        for i in 0..<count {
            let jitter = CGFloat.random(in: -0.35...0.35)
            let d = (CGFloat(i) + 0.5) / CGFloat(count) * total + jitter
            guard let s = samplePoint(on: pts, cum: cum, d: d.truncatingRemainder(dividingBy: total)) else { continue }

            if s.p.x > skipX {
                continue
            }

            var nx = -s.tangent.dy
            var ny =  s.tangent.dx
            
            let cx = rect.midX
            let cy = rect.midY
            let vx = s.p.x - cx
            let vy = s.p.y - cy
            if (nx * vx + ny * vy) < 0 {
                nx = -nx; ny = -ny
            }

            let nlen = max(0.0001, sqrt(nx*nx + ny*ny))
            nx /= nlen; ny /= nlen

            let baseOut = max(6, bodyH * 0.04)
            let base = CGPoint(x: s.p.x + nx * baseOut, y: s.p.y + ny * baseOut)

            let tilt = CGFloat.random(in: -0.25...0.25)
            let c = cos(tilt), ss = sin(tilt)
            let tx = nx * c - ny * ss
            let ty = nx * ss + ny * c

            let len = CGFloat.random(in: lenMin...lenMax)
            let end = CGPoint(x: base.x + tx * len, y: base.y + ty * len)

            let p = UIBezierPath()
            p.move(to: base)
            p.addLine(to: end)

            let spike = SKShapeNode(path: p.cgPath)
            spike.strokeColor = spikeColor
            spike.lineWidth = lineW
            spike.lineCap = .round
            spike.isAntialiased = true
            spike.zPosition = piliZ
            root.addChild(spike)

            let hitR = max(14, bodyH * 0.075)
            let hit = SKShapeNode(circleOfRadius: hitR)
            hit.fillColor = .clear
            hit.strokeColor = .clear
            hit.position = base
            hit.zPosition = hitZ
            hit.name = "pili"
            setTapKey(hit, "pili")
            root.addChild(hit)
        }
    }

    private func angleWrap(_ x: CGFloat) -> CGFloat {
        var a = x
        while a > .pi { a -= 2 * .pi }
        while a < -.pi { a += 2 * .pi }
        return a
    }
    
    
    private struct PathSamplePoint {
        let p: CGPoint
        let tangent: CGVector
    }

    private func flattenedPoints(from path: CGPath) -> [CGPoint] {
        var pts: [CGPoint] = []

        path.applyWithBlock { elementPtr in
            let e = elementPtr.pointee
            switch e.type {
                case .moveToPoint:
                    pts.append(e.points[0])
                case .addLineToPoint:
                    pts.append(e.points[0])
                case .addQuadCurveToPoint:
                    pts.append(e.points[1])
                case .addCurveToPoint:
                    pts.append(e.points[2])
                case .closeSubpath:
                    break
            @unknown default:
                break
            }
        }
        return pts
    }

    private func capsulePolylinePoints(rect: CGRect, cornerRadius: CGFloat, segmentsPerQuarter: Int = 18) -> [CGPoint] {
        let r = min(cornerRadius, min(rect.width, rect.height) / 2)

        let left = rect.minX
        let right = rect.maxX
        let top = rect.maxY
        let bottom = rect.minY

        let tl = CGPoint(x: left + r,  y: top - r)
        let tr = CGPoint(x: right - r, y: top - r)
        let br = CGPoint(x: right - r, y: bottom + r)
        let bl = CGPoint(x: left + r,  y: bottom + r)

        func arc(center: CGPoint, start: CGFloat, end: CGFloat) -> [CGPoint] {
            let n = segmentsPerQuarter
            return (0...n).map { i in
                let t = CGFloat(i) / CGFloat(n)
                let a = start + (end - start) * t
                return CGPoint(x: center.x + cos(a) * r, y: center.y + sin(a) * r)
            }
        }

        var points: [CGPoint] = []

        points.append(CGPoint(x: tl.x, y: top))
        points.append(CGPoint(x: tr.x, y: top))

        points += arc(center: tr, start: .pi/2, end: 0)

        points.append(CGPoint(x: right, y: br.y))
        points.append(CGPoint(x: right, y: tr.y))

        points += arc(center: br, start: 0, end: -.pi/2)

        points.append(CGPoint(x: bl.x, y: bottom))
        points.append(CGPoint(x: br.x, y: bottom))
        points += arc(center: bl, start: -.pi/2, end: -.pi)

        points.append(CGPoint(x: left, y: tl.y))
        points.append(CGPoint(x: left, y: bl.y))

        // top-left corner: 180° -> 90°
        points += arc(center: tl, start: .pi, end: .pi/2)

        return points
    }

    private func cumulativeLengths(_ pts: [CGPoint]) -> [CGFloat] {
        guard pts.count > 1 else { return [0] }
        var cum: [CGFloat] = [0]
        cum.reserveCapacity(pts.count)
        var total: CGFloat = 0
        for i in 1..<pts.count {
            let dx = pts[i].x - pts[i-1].x
            let dy = pts[i].y - pts[i-1].y
            total += sqrt(dx*dx + dy*dy)
            cum.append(total)
        }
        return cum
    }

    private func samplePoint(on pts: [CGPoint], cum: [CGFloat], d: CGFloat) -> PathSamplePoint? {
        guard pts.count > 1, let total = cum.last, total > 0 else { return nil }

        let target = max(0, min(d, total))
        var idx = 1
        while idx < cum.count && cum[idx] < target { idx += 1 }
        if idx >= pts.count { return nil }

        let prev = pts[idx-1]
        let next = pts[idx]
        let segLen = max(0.0001, cum[idx] - cum[idx-1])
        let t = (target - cum[idx-1]) / segLen

        let x = prev.x + (next.x - prev.x) * t
        let y = prev.y + (next.y - prev.y) * t

        let tx = (next.x - prev.x) / segLen
        let ty = (next.y - prev.y) / segLen

        return PathSamplePoint(p: CGPoint(x: x, y: y), tangent: CGVector(dx: tx, dy: ty))
    }

    private func addER(at p: CGPoint, into parent: SKNode) {
        let er = SKShapeNode(path: erPath(width: 270, height: 120).cgPath)
        er.strokeColor = UIColor.systemIndigo.withAlphaComponent(0.55)
        er.lineWidth = 6
        er.position = p
        er.zPosition = 8
        er.name = "er"
        setTapKey(er, "er")
        parent.addChild(er)
    }

    private func addGolgi(at p: CGPoint, into parent: SKNode) {
        let g = SKShapeNode(path: golgiPath().cgPath)
        g.strokeColor = UIColor.systemMint.withAlphaComponent(0.8)
        g.lineWidth = 9
        g.position = p
        g.zPosition = 8
        g.name = "golgi"
        setTapKey(g, "golgi")
        parent.addChild(g)
    }

    private func addMitochondrion(at p: CGPoint, into parent: SKNode) {
        let n = SKShapeNode(rectOf: CGSize(width: 92, height: 50), cornerRadius: 25)
        n.fillColor = UIColor.systemOrange.withAlphaComponent(0.85)
        n.strokeColor = UIColor.white.withAlphaComponent(0.18)
        n.lineWidth = 2
        n.position = p
        n.zPosition = 7
        n.name = "mitochondrion"
        setTapKey(n, "mitochondrion")
        parent.addChild(n)

        let folds = SKShapeNode(path: mitoFolds(width: 60, height: 22).cgPath)
        folds.strokeColor = UIColor.white.withAlphaComponent(0.25)
        folds.lineWidth = 2
        folds.position = CGPoint(x: -6, y: -2)
        folds.zPosition = 8
        n.addChild(folds)
    }

    private func addChloroplast(at p: CGPoint, into parent: SKNode) {
        let c = SKShapeNode(rectOf: CGSize(width: 98, height: 56), cornerRadius: 28)
        c.fillColor = UIColor.systemGreen.withAlphaComponent(0.60)
        c.strokeColor = UIColor.white.withAlphaComponent(0.18)
        c.lineWidth = 2
        c.position = p
        c.zPosition = 7
        c.name = "chloroplast"
        setTapKey(c, "chloroplast")
        parent.addChild(c)

        let stacks = SKShapeNode(path: thylakoidStacks().cgPath)
        stacks.strokeColor = UIColor.white.withAlphaComponent(0.25)
        stacks.lineWidth = 2
        stacks.position = CGPoint(x: -8, y: -6)
        stacks.zPosition = 8
        c.addChild(stacks)
    }

    private func addLysosome(at p: CGPoint, into parent: SKNode) {
        let n = SKShapeNode(circleOfRadius: 16)
        n.fillColor = UIColor.systemYellow.withAlphaComponent(0.65)
        n.strokeColor = UIColor.white.withAlphaComponent(0.14)
        n.lineWidth = 2
        n.position = p
        n.zPosition = 7
        n.name = "lysosome"
        setTapKey(n, "lysosome")
        parent.addChild(n)
    }

    private func addRibosomes(in bounds: CGRect, into parent: SKNode) {
        let points: [CGPoint] = [
            .init(x: bounds.midX - 160, y: bounds.midY + 60),
            .init(x: bounds.midX - 120, y: bounds.midY + 20),
            .init(x: bounds.midX - 80,  y: bounds.midY - 40),
            .init(x: bounds.midX - 20,  y: bounds.midY + 80),
            .init(x: bounds.midX + 20,  y: bounds.midY - 90),
            .init(x: bounds.midX + 80,  y: bounds.midY + 40),
            .init(x: bounds.midX + 140, y: bounds.midY - 30),
            .init(x: bounds.midX + 170, y: bounds.midY + 70),
        ]

        let hitRadius: CGFloat = 14
        let visualRadius: CGFloat = 6.2

        for p in points {
            let hit = SKShapeNode(circleOfRadius: hitRadius)
            hit.fillColor = .clear
            hit.strokeColor = .clear
            hit.position = p
            hit.zPosition = 6
            hit.name = "ribosome"
            setTapKey(hit, "ribosome")

            let dot = SKShapeNode(circleOfRadius: visualRadius)
            dot.fillColor = UIColor.systemPurple.withAlphaComponent(0.75)
            dot.strokeColor = UIColor.white.withAlphaComponent(0.10)
            dot.lineWidth = 1
            dot.zPosition = 7
            hit.addChild(dot)

            parent.addChild(hit)
        }
    }

    // MARK: - animations
    private func animateLife() {
        if let cyto = cytoplasm {
            cyto.removeAction(forKey: "breath")
            let a = SKAction.fadeAlpha(to: cyto.alpha * 0.85, duration: 1.6)
            a.timingMode = .easeInEaseOut
            let b = SKAction.fadeAlpha(to: min(1.0, cyto.alpha * 1.05), duration: 1.6)
            b.timingMode = .easeInEaseOut
            cyto.run(.repeatForever(.sequence([a, b])), withKey: "breath")
        }

        for node in clippedWorld.children {
            guard node.userData?["orgKey"] != nil else {
                continue
            }
            node.removeAction(forKey: "float")

            let dx = CGFloat.random(in: -6...6)
            let dy = CGFloat.random(in: -6...6)
            let t = Double.random(in: 1.8...2.8)

            let move1 = SKAction.moveBy(x: dx, y: dy, duration: t)
            move1.timingMode = .easeInEaseOut
            let move2 = SKAction.moveBy(x: -dx, y: -dy, duration: t)
            move2.timingMode = .easeInEaseOut

            node.run(.repeatForever(.sequence([move1, move2])), withKey: "float")
        }

        if let mem = membraneStroke {
            mem.removeAction(forKey: "pulse")
            let up = SKAction.fadeAlpha(to: 0.70, duration: 1.8)
            up.timingMode = .easeInEaseOut
            let down = SKAction.fadeAlpha(to: 0.50, duration: 1.8)
            down.timingMode = .easeInEaseOut
            mem.run(.repeatForever(.sequence([up, down])), withKey: "pulse")
        }

        if let wall = wallStroke {
            wall.removeAction(forKey: "wallPulse")
            let up = SKAction.fadeAlpha(to: 0.95, duration: 2.2)
            up.timingMode = .easeInEaseOut
            let down = SKAction.fadeAlpha(to: 0.75, duration: 2.2)
            down.timingMode = .easeInEaseOut
            wall.run(.repeatForever(.sequence([up, down])), withKey: "wallPulse")
        }
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else {
            return
        }
        let loc = t.location(in: root)
        let hits = root.nodes(at: loc)

        let tappables = hits.compactMap { n -> SKNode? in
            guard n.userData?["orgKey"] != nil else { return nil }
            return n
        }

        if let best = tappables.max(by: { $0.zPosition < $1.zPosition }),
           let key = best.userData?["orgKey"] as? String {
            pulse(best)
            onOrganelleTapped?(key)
        }
    }

    private func setTapKey(_ node: SKNode, _ key: String) {
        node.userData = (node.userData ?? NSMutableDictionary())
        node.userData?["orgKey"] = key
    }

    private func pulse(_ node: SKNode) {
        node.removeAction(forKey: "pulse")
        node.userData = (node.userData ?? NSMutableDictionary())
        let baseX = (node.userData?["baseScaleX"] as? CGFloat) ?? node.xScale
        let baseY = (node.userData?["baseScaleY"] as? CGFloat) ?? node.yScale
        node.userData?["baseScaleX"] = baseX
        node.userData?["baseScaleY"] = baseY

        let up = SKAction.scaleX(to: baseX * 1.12, y: baseY * 1.12, duration: 0.10)
        up.timingMode = .easeOut

        let down = SKAction.scaleX(to: baseX, y: baseY, duration: 0.16)
        down.timingMode = .easeIn

        node.run(.sequence([up, down]), withKey: "pulse")
    }
    
    private func roundedStrokeTexture(size: CGSize, cornerRadius: CGFloat, lineWidth: CGFloat, stroke: UIColor) -> (texture: SKTexture, spriteSize: CGSize) {
        let pad: CGFloat = max(18, lineWidth * 2)
        let spriteSize = CGSize(width: size.width + pad * 2, height: size.height + pad * 2)

        let renderer = UIGraphicsImageRenderer(size: spriteSize)
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.fill(CGRect(origin: .zero, size: spriteSize))

            let r = CGRect(x: pad, y: pad, width: size.width, height: size.height)
                .insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)

            let path = UIBezierPath(roundedRect: r, cornerRadius: cornerRadius)
            path.lineWidth = lineWidth
            path.lineCapStyle = .round
            path.lineJoinStyle = .round

            stroke.setStroke()
            path.stroke()
        }

        let tex = SKTexture(image: img)
        tex.filteringMode = .linear
        return (tex, spriteSize)
    }

    // MARK: - Path of organelles
    private func erPath(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let p = UIBezierPath()
        let steps = 7
        for i in 0..<steps {
            let y = CGFloat(i) * (height / CGFloat(steps-1)) - height/2
            p.move(to: CGPoint(x: -width/2, y: y))
            p.addCurve(to: CGPoint(x: width/2, y: y),
                       controlPoint1: CGPoint(x: -width/4, y: y - 16),
                       controlPoint2: CGPoint(x: width/4, y: y + 16))
        }
        return p
    }

    private func golgiPath() -> UIBezierPath {
        let p = UIBezierPath()
        p.move(to: CGPoint(x: -120, y: -10))
        p.addCurve(to: CGPoint(x: 120, y: -10),
                   controlPoint1: CGPoint(x: -60, y: -50),
                   controlPoint2: CGPoint(x: 60, y: 30))
        p.move(to: CGPoint(x: -110, y: 16))
        p.addCurve(to: CGPoint(x: 110, y: 16),
                   controlPoint1: CGPoint(x: -50, y: -20),
                   controlPoint2: CGPoint(x: 50, y: 55))
        p.move(to: CGPoint(x: -95, y: 40))
        p.addCurve(to: CGPoint(x: 95, y: 40),
                   controlPoint1: CGPoint(x: -40, y: 0),
                   controlPoint2: CGPoint(x: 40, y: 80))
        return p
    }

    private func dnaPath(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let p = UIBezierPath()
        let steps = 40
        p.move(to: CGPoint(x: -width/2, y: 0))
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = (-width/2) + t * width
            let y = sin(t * 6 * .pi) * height/2
            p.addLine(to: CGPoint(x: x, y: y))
        }
        return p
    }
    
    private func flagellumOutsidePathRight(length: CGFloat, amplitude: CGFloat) -> UIBezierPath {
        let p = UIBezierPath()
        p.move(to: CGPoint(x: 0, y: 0))

        let steps = 18
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = t * length
            let y = sin(t * 3.2 * .pi) * amplitude
            p.addLine(to: CGPoint(x: x, y: y))
        }
        return p
    }

    private func flagellumInsidePathLeft(length: CGFloat, amplitude: CGFloat) -> UIBezierPath {
        let p = UIBezierPath()
        p.move(to: CGPoint(x: 0, y: 0))
        let steps = 18
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = -t * length
            let y = sin(t * 3.2 * .pi) * amplitude
            p.addLine(to: CGPoint(x: x, y: y))
        }
        return p
    }

    private func mitoFolds(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let p = UIBezierPath()
        p.move(to: CGPoint(x: -width/2, y: -height/4))
        p.addCurve(to: CGPoint(x: width/2, y: -height/4),
                   controlPoint1: CGPoint(x: -width/4, y: -height/2),
                   controlPoint2: CGPoint(x: width/4, y: 0))
        p.move(to: CGPoint(x: -width/2, y: height/4))
        p.addCurve(to: CGPoint(x: width/2, y: height/4),
                   controlPoint1: CGPoint(x: -width/4, y: 0),
                   controlPoint2: CGPoint(x: width/4, y: height/2))
        return p
    }

    private func thylakoidStacks() -> UIBezierPath {
        let p = UIBezierPath()
        for i in 0..<4 {
            let y = CGFloat(i) * 8
            p.move(to: CGPoint(x: -28, y: -12 + y))
            p.addLine(to: CGPoint(x: 28, y: -12 + y))
        }
        return p
    }
}


