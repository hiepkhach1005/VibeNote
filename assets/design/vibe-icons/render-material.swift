// Vibe app icons, "Material" set. Usage: swift render-material.swift <output-dir>
// Light skeuomorphism: real paper, glass, metal objects resting on a matte tinted plate.
// Style rules live in VIBE_ICON_STYLE.md (section "Material set").
import AppKit
import CoreGraphics

// MARK: - Tokens

let S: CGFloat = 1024
let plate = CGRect(x: 100, y: 100, width: 824, height: 824)
let plateRadius: CGFloat = 185
let space = CGColorSpace(name: CGColorSpace.sRGB)!

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
func grad(_ c: [CGColor], _ l: [CGFloat]? = nil) -> CGGradient {
    CGGradient(colorsSpace: space, colors: c as CFArray, locations: l)!
}
func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: S - y) }
func R(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect { CGRect(x: x, y: S - y - h, width: w, height: h) }
func rounded(_ r: CGRect, _ rad: CGFloat) -> CGPath { CGPath(roundedRect: r, cornerWidth: rad, cornerHeight: rad, transform: nil) }
func stroked(_ p: CGPath, _ w: CGFloat, cap: CGLineCap = .round) -> CGPath {
    p.copy(strokingWithWidth: w, lineCap: cap, lineJoin: .round, miterLimit: 1)
}

struct Seeded { var s: UInt64; mutating func next() -> CGFloat { s = s &* 6364136223846793005 &+ 1442695040888963407; return CGFloat(s >> 33) / CGFloat(1 << 31) } }

// MARK: - Material primitives

/// Two-layer physical shadow: tight contact + wide ambient.
func objectShadow(_ ctx: CGContext, _ path: CGPath, lift: CGFloat = 1) {
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -30 * lift), blur: 60 * lift, color: rgb(0x000000, 0.30))
    ctx.addPath(path); ctx.setFillColor(rgb(0x000000)); ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -6 * lift), blur: 10 * lift, color: rgb(0x000000, 0.35))
    ctx.addPath(path); ctx.setFillColor(rgb(0x000000)); ctx.fillPath()
    ctx.restoreGState()
}

func linear(_ ctx: CGContext, _ path: CGPath, _ g: CGGradient, from a: CGPoint, to b: CGPoint) {
    ctx.saveGState(); ctx.addPath(path); ctx.clip()
    ctx.drawLinearGradient(g, start: a, end: b, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    ctx.restoreGState()
}
func vertical(_ ctx: CGContext, _ path: CGPath, _ colors: [CGColor], _ locs: [CGFloat]? = nil) {
    let b = path.boundingBoxOfPath
    linear(ctx, path, grad(colors, locs), from: CGPoint(x: b.midX, y: b.maxY), to: CGPoint(x: b.midX, y: b.minY))
}
func solid(_ ctx: CGContext, _ path: CGPath, _ c: CGColor) {
    ctx.saveGState(); ctx.addPath(path); ctx.setFillColor(c); ctx.fillPath(); ctx.restoreGState()
}

/// Fine grain (paper fibres / matte coating).
func grain(_ ctx: CGContext, _ path: CGPath, amount: CGFloat, seed: UInt64, count: Int = 26000) {
    var rnd = Seeded(s: seed)
    let b = path.boundingBoxOfPath
    ctx.saveGState(); ctx.addPath(path); ctx.clip()
    for _ in 0..<count {
        let x = b.minX + rnd.next() * b.width, y = b.minY + rnd.next() * b.height
        let dark = rnd.next() > 0.5
        ctx.setFillColor(dark ? rgb(0x000000, amount * rnd.next()) : rgb(0xFFFFFF, amount * rnd.next()))
        ctx.fill(CGRect(x: x, y: y, width: 1.6, height: 1.6))
    }
    ctx.restoreGState()
}

/// Brushed aluminium: base gradient + hairline streaks along one axis.
func brushedMetal(_ ctx: CGContext, _ path: CGPath, seed: UInt64, base: [CGColor], horizontal: Bool = true) {
    vertical(ctx, path, base)
    var rnd = Seeded(s: seed)
    let b = path.boundingBoxOfPath
    ctx.saveGState(); ctx.addPath(path); ctx.clip()
    for _ in 0..<1400 {
        let t = rnd.next(), a = rnd.next() * 0.10
        ctx.setFillColor(rnd.next() > 0.5 ? rgb(0xFFFFFF, a) : rgb(0x000000, a * 0.7))
        if horizontal {
            ctx.fill(CGRect(x: b.minX + rnd.next() * b.width * 0.6, y: b.minY + t * b.height, width: b.width * (0.3 + rnd.next()), height: 1.2))
        } else {
            ctx.fill(CGRect(x: b.minX + t * b.width, y: b.minY + rnd.next() * b.height * 0.6, width: 1.2, height: b.height * (0.3 + rnd.next())))
        }
    }
    ctx.restoreGState()
}

/// Inner bevel: light edge on top, dark edge at the bottom.
func bevel(_ ctx: CGContext, _ path: CGPath, width: CGFloat = 4, light: CGFloat = 0.7, dark: CGFloat = 0.25) {
    let b = path.boundingBoxOfPath
    ctx.saveGState(); ctx.addPath(path); ctx.clip()
    ctx.addPath(path); ctx.setLineWidth(width * 2); ctx.replacePathWithStrokedPath(); ctx.clip()
    ctx.drawLinearGradient(grad([rgb(0xFFFFFF, light), rgb(0xFFFFFF, 0), rgb(0x000000, 0), rgb(0x000000, dark)], [0, 0.35, 0.65, 1]),
                           start: CGPoint(x: b.midX, y: b.maxY), end: CGPoint(x: b.midX, y: b.minY), options: [])
    ctx.restoreGState()
}

/// Specular glass reflection: a soft diagonal band clipped to `path`.
func glassGloss(_ ctx: CGContext, _ path: CGPath, strength: CGFloat = 0.28) {
    let b = path.boundingBoxOfPath
    let band = CGMutablePath()
    band.move(to: CGPoint(x: b.minX, y: b.maxY))
    band.addLine(to: CGPoint(x: b.minX + b.width * 0.62, y: b.maxY))
    band.addLine(to: CGPoint(x: b.minX + b.width * 0.30, y: b.minY))
    band.addLine(to: CGPoint(x: b.minX, y: b.minY))
    band.closeSubpath()
    ctx.saveGState(); ctx.addPath(path); ctx.clip()
    linear(ctx, band, grad([rgb(0xFFFFFF, strength), rgb(0xFFFFFF, strength * 0.25)]),
           from: CGPoint(x: b.minX, y: b.maxY), to: CGPoint(x: b.midX, y: b.minY))
    ctx.restoreGState()
}

func rotate(_ ctx: CGContext, deg: CGFloat, around c: CGPoint) {
    ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: deg * .pi / 180); ctx.translateBy(x: -c.x, y: -c.y)
}

// MARK: - Plate (shared)

struct Tint { let top: UInt32; let bottom: UInt32 }

func drawPlate(_ ctx: CGContext, _ t: Tint, seed: UInt64) {
    let p = rounded(plate, plateRadius)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: rgb(0x000000, 0.35))
    ctx.addPath(p); ctx.setFillColor(rgb(t.bottom)); ctx.fillPath()
    ctx.restoreGState()
    vertical(ctx, p, [rgb(t.top), rgb(t.bottom)])
    // Soft top light falloff, like a lamp above the desk.
    ctx.saveGState(); ctx.addPath(p); ctx.clip()
    ctx.drawRadialGradient(grad([rgb(0xFFFFFF, 0.22), rgb(0xFFFFFF, 0)]),
                           startCenter: P(512, 120), startRadius: 0, endCenter: P(512, 120), endRadius: 700, options: [])
    ctx.restoreGState()
    grain(ctx, p, amount: 0.05, seed: seed, count: 30000)
    bevel(ctx, p, width: 3, light: 0.45, dark: 0.3)
}

// MARK: - VibeNote: ruled legal pad + pencil

func vibeNote(_ ctx: CGContext) {
    let pad = R(250, 214, 500, 610)
    let padPath = rounded(pad, 26)
    // Stacked sheets underneath for thickness.
    for i in (1...3).reversed() {
        let r = pad.offsetBy(dx: CGFloat(i) * 2, dy: -CGFloat(i) * 5)
        solid(ctx, rounded(r, 26), rgb(i % 2 == 0 ? 0xE6DFCB : 0xF4EEDC))
    }
    objectShadow(ctx, rounded(pad.offsetBy(dx: 6, dy: -15), 26))
    for i in (1...3).reversed() {
        let r = pad.offsetBy(dx: CGFloat(i) * 2, dy: -CGFloat(i) * 5)
        solid(ctx, rounded(r, 26), rgb(i % 2 == 0 ? 0xE2DAC4 : 0xF6F0DF))
    }
    vertical(ctx, padPath, [rgb(0xFFFDF5), rgb(0xFAF3DD)])
    grain(ctx, padPath, amount: 0.07, seed: 11, count: 22000)
    ctx.saveGState(); ctx.addPath(padPath); ctx.clip()
    // Ruled lines + red margin
    for i in 0..<10 {
        let y = 360 + CGFloat(i) * 46
        solid(ctx, CGPath(rect: R(250, y, 500, 3), transform: nil), rgb(0x7FB2E5, 0.75))
    }
    solid(ctx, CGPath(rect: R(326, 300, 3, 530), transform: nil), rgb(0xE5484D, 0.75))
    solid(ctx, CGPath(rect: R(332, 300, 2, 530), transform: nil), rgb(0xE5484D, 0.35))
    // Handwriting-ish graphite strokes
    var rnd = Seeded(s: 5)
    for (row, len) in [(0, 300.0), (1, 340.0), (2, 220.0), (3, 280.0)] as [(Int, CGFloat)] {
        let base = 360 + CGFloat(row) * 46 - 8
        let s = CGMutablePath()
        var x: CGFloat = 352
        s.move(to: P(x, base))
        while x < 352 + len {
            let nx = x + 14 + rnd.next() * 10
            s.addQuadCurve(to: P(nx, base - 4 + rnd.next() * 3), control: P((x + nx) / 2, base - 18 - rnd.next() * 10))
            x = nx
        }
        solid(ctx, stroked(s, 4.5), rgb(0x3A3A40, 0.78))
    }
    // Paper curl shading at the bottom-right
    ctx.drawRadialGradient(grad([rgb(0x000000, 0.10), rgb(0x000000, 0)]),
                           startCenter: P(750, 824), startRadius: 0, endCenter: P(750, 824), endRadius: 260, options: [])
    ctx.restoreGState()
    // Glued binding strip (leatherette, amber)
    let strip = CGPath(roundedRect: R(244, 200, 512, 96), cornerWidth: 22, cornerHeight: 22, transform: nil)
    objectShadow(ctx, strip, lift: 0.25)
    vertical(ctx, strip, [rgb(0xFFC24A), rgb(0xF29A0C), rgb(0xD97C00)], [0, 0.6, 1])
    grain(ctx, strip, amount: 0.12, seed: 21, count: 9000)
    bevel(ctx, strip, width: 3, light: 0.6, dark: 0.35)
    // Stitching
    let stitch = CGMutablePath()
    stitch.move(to: P(270, 276)); stitch.addLine(to: P(730, 276))
    ctx.saveGState()
    ctx.addPath(stitch); ctx.setLineWidth(3.5); ctx.setLineDash(phase: 0, lengths: [14, 10])
    ctx.setStrokeColor(rgb(0xFFF1CF, 0.85)); ctx.strokePath()
    ctx.restoreGState()

    // Pencil lying diagonally
    ctx.saveGState()
    rotate(ctx, deg: 38, around: P(560, 590))
    let L: CGFloat = 520, W: CGFloat = 54, x0: CGFloat = 300, y0: CGFloat = 563
    let bodyRect = R(x0 + 90, y0, L - 150, W)
    let body = CGPath(rect: bodyRect, transform: nil)
    objectShadow(ctx, CGPath(rect: R(x0, y0, L, W), transform: nil), lift: 0.6)
    // Hexagonal body: three facets
    vertical(ctx, body, [rgb(0xFFD866), rgb(0xFFC21A), rgb(0xF5A300), rgb(0xFFC93A), rgb(0xD98200)], [0, 0.3, 0.5, 0.7, 1])
    solid(ctx, CGPath(rect: R(x0 + 90, y0 + W * 0.33, L - 150, 2), transform: nil), rgb(0xFFFFFF, 0.35))
    solid(ctx, CGPath(rect: R(x0 + 90, y0 + W * 0.66, L - 150, 2), transform: nil), rgb(0x8A4B00, 0.25))
    // Sharpened wood cone
    let cone = CGMutablePath()
    cone.move(to: P(x0 + 90, y0)); cone.addLine(to: P(x0 + 6, y0 + W / 2)); cone.addLine(to: P(x0 + 90, y0 + W)); cone.closeSubpath()
    vertical(ctx, cone, [rgb(0xF4D3A6), rgb(0xE2B47A), rgb(0xC48A4C)])
    // Scalloped cut edge
    for i in 0..<3 {
        let cy = y0 + W / 6 + CGFloat(i) * W / 3
        solid(ctx, CGPath(ellipseIn: R(x0 + 82, cy - W / 6, 16, W / 3), transform: nil), rgb(i == 1 ? 0xFFCF3F : 0xF3AE18))
    }
    let lead = CGMutablePath()
    lead.move(to: P(x0 + 34, y0 + W / 2 - 10)); lead.addLine(to: P(x0 + 6, y0 + W / 2)); lead.addLine(to: P(x0 + 34, y0 + W / 2 + 10)); lead.closeSubpath()
    vertical(ctx, lead, [rgb(0x6B6B72), rgb(0x2A2A30)])
    // Metal ferrule
    let ferrule = CGPath(rect: R(x0 + L - 60, y0 - 2, 56, W + 4), transform: nil)
    brushedMetal(ctx, ferrule, seed: 3, base: [rgb(0xF4F4F6), rgb(0xB9BCC4), rgb(0xE4E6EA), rgb(0x8E929B)], horizontal: false)
    for i in 0..<4 { solid(ctx, CGPath(rect: R(x0 + L - 52 + CGFloat(i) * 12, y0 - 2, 3, W + 4), transform: nil), rgb(0x000000, 0.18)) }
    // Eraser
    let eraser = rounded(R(x0 + L - 6, y0, 58, W), 14)
    vertical(ctx, eraser, [rgb(0xFFA4AE), rgb(0xF0707E), rgb(0xD45363)])
    grain(ctx, eraser, amount: 0.1, seed: 9, count: 1500)
    ctx.restoreGState()
}

// MARK: - VibePhoto: polaroid on the desk

func vibePhoto(_ ctx: CGContext) {
    // Second polaroid behind, rotated the other way
    ctx.saveGState()
    rotate(ctx, deg: 9, around: P(512, 520))
    let back = rounded(R(270, 220, 480, 560), 10)
    objectShadow(ctx, back, lift: 0.6)
    vertical(ctx, back, [rgb(0xF7F5EF), rgb(0xE9E6DD)])
    solid(ctx, CGPath(rect: R(300, 250, 420, 400), transform: nil), rgb(0x30343F))
    ctx.restoreGState()

    ctx.saveGState()
    rotate(ctx, deg: -6, around: P(512, 530))
    let card = rounded(R(262, 214, 500, 600), 10)
    objectShadow(ctx, card)
    vertical(ctx, card, [rgb(0xFFFFFF), rgb(0xF5F3EC)])
    grain(ctx, card, amount: 0.05, seed: 41, count: 14000)
    bevel(ctx, card, width: 2, light: 0.8, dark: 0.12)
    // Photo emulsion: sunset over hills
    let photo = R(294, 246, 436, 420)
    let ph = CGPath(rect: photo, transform: nil)
    vertical(ctx, ph, [rgb(0x2B5C9E), rgb(0x8E7CC3), rgb(0xF29E7C), rgb(0xFFD08A)], [0, 0.4, 0.75, 1])
    ctx.saveGState(); ctx.addPath(ph); ctx.clip()
    ctx.drawRadialGradient(grad([rgb(0xFFF4D6, 1), rgb(0xFFD58A, 0.9), rgb(0xFFB060, 0)], [0, 0.35, 1]),
                           startCenter: P(560, 540), startRadius: 0, endCenter: P(560, 540), endRadius: 180, options: [])
    let far = CGMutablePath()
    far.move(to: P(294, 580)); far.addCurve(to: P(730, 560), control1: P(420, 500), control2: P(600, 600)); far.addLine(to: P(730, 666)); far.addLine(to: P(294, 666)); far.closeSubpath()
    vertical(ctx, far, [rgb(0x6A5A9A), rgb(0x3E3A6E)])
    let near = CGMutablePath()
    near.move(to: P(294, 620)); near.addCurve(to: P(730, 600), control1: P(460, 560), control2: P(560, 660)); near.addLine(to: P(730, 666)); near.addLine(to: P(294, 666)); near.closeSubpath()
    vertical(ctx, near, [rgb(0x2C2A4E), rgb(0x16152B)])
    // Film vignette + slight fade
    ctx.drawRadialGradient(grad([rgb(0x000000, 0), rgb(0x000000, 0.35)]),
                           startCenter: CGPoint(x: photo.midX, y: photo.midY), startRadius: 160,
                           endCenter: CGPoint(x: photo.midX, y: photo.midY), endRadius: 340, options: [])
    solid(ctx, ph, rgb(0xFFF3E0, 0.06))
    ctx.restoreGState()
    grain(ctx, ph, amount: 0.12, seed: 77, count: 12000)
    // Inner edge of print
    ctx.saveGState(); ctx.addPath(ph); ctx.setStrokeColor(rgb(0x000000, 0.25)); ctx.setLineWidth(2); ctx.strokePath(); ctx.restoreGState()
    glassGloss(ctx, card, strength: 0.18)
    ctx.restoreGState()

    // Piece of washi tape holding it
    ctx.saveGState()
    rotate(ctx, deg: -14, around: P(512, 206))
    let tape = CGPath(rect: R(432, 180, 160, 58), transform: nil)
    objectShadow(ctx, tape, lift: 0.12)
    solid(ctx, tape, rgb(0x5FCF8A, 0.82))
    for i in 0..<8 { solid(ctx, CGPath(rect: R(440 + CGFloat(i) * 20, 180, 8, 58), transform: nil), rgb(0xFFFFFF, 0.18)) }
    grain(ctx, tape, amount: 0.15, seed: 88, count: 2500)
    ctx.restoreGState()
}

// MARK: - VibeShot: glass viewfinder with chrome brackets + enamel bolt

func vibeShot(_ ctx: CGContext) {
    // Frosted glass slab
    let glass = rounded(R(220, 220, 584, 584), 110)
    objectShadow(ctx, glass, lift: 0.8)
    vertical(ctx, glass, [rgb(0xFFFFFF, 0.42), rgb(0xD8ECFF, 0.22)])
    ctx.saveGState(); ctx.addPath(glass); ctx.clip()
    ctx.drawRadialGradient(grad([rgb(0xFFFFFF, 0.35), rgb(0xFFFFFF, 0)]), startCenter: P(380, 300), startRadius: 0,
                           endCenter: P(380, 300), endRadius: 420, options: [])
    ctx.restoreGState()
    grain(ctx, glass, amount: 0.08, seed: 101, count: 16000)
    bevel(ctx, glass, width: 5, light: 0.9, dark: 0.25)
    // Chrome corner brackets
    let a: CGFloat = 282, b: CGFloat = 742, arm: CGFloat = 132
    for (x, y, dx, dy) in [(a, a, 1.0, 1.0), (b, a, -1.0, 1.0), (a, b, 1.0, -1.0), (b, b, -1.0, -1.0)] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        let c = CGMutablePath()
        c.move(to: P(x, y + dy * arm)); c.addArc(tangent1End: P(x, y), tangent2End: P(x + dx * arm, y), radius: 56); c.addLine(to: P(x + dx * arm, y))
        let s = stroked(c, 46)
        objectShadow(ctx, s, lift: 0.25)
        brushedMetal(ctx, s, seed: UInt64(x + y), base: [rgb(0xFFFFFF), rgb(0xC9CDD5), rgb(0x8C929E), rgb(0xE9ECF1), rgb(0x9DA3AE)])
        bevel(ctx, s, width: 3, light: 0.9, dark: 0.35)
    }
    // Enamel bolt
    let k: CGFloat = 1.15
    let pts: [(CGFloat, CGFloat)] = [(30, -150), (-95, 25), (-5, 25), (-35, 150), (95, -30), (5, -30)]
    let bolt = CGMutablePath()
    bolt.addLines(between: pts.map { P(512 + $0.0 * k, 512 + $0.1 * k) }); bolt.closeSubpath()
    let boltPath = stroked(bolt, 24).union(bolt)
    objectShadow(ctx, boltPath, lift: 0.45)
    vertical(ctx, boltPath, [rgb(0xFFB45E), rgb(0xFF6A3D), rgb(0xE8452A)])
    bevel(ctx, boltPath, width: 5, light: 0.85, dark: 0.4)
    glassGloss(ctx, boltPath, strength: 0.35)
}

// MARK: - VibeScreen: aluminium display with glass UI

func vibeScreen(_ ctx: CGContext) {
    // Stand
    let neck = CGMutablePath()
    neck.move(to: P(452, 640)); neck.addLine(to: P(572, 640)); neck.addLine(to: P(592, 760)); neck.addLine(to: P(432, 760)); neck.closeSubpath()
    let foot = rounded(R(372, 748, 280, 38), 19)
    objectShadow(ctx, foot, lift: 0.4)
    brushedMetal(ctx, neck, seed: 7, base: [rgb(0x9EA3AD), rgb(0xD9DCE2), rgb(0xB4B8C1)], horizontal: false)
    brushedMetal(ctx, foot, seed: 8, base: [rgb(0xF2F3F5), rgb(0xB5B9C2)])
    bevel(ctx, foot, width: 3, light: 0.9, dark: 0.3)
    // Aluminium body
    let body = rounded(R(190, 236, 644, 430), 46)
    objectShadow(ctx, body)
    brushedMetal(ctx, body, seed: 12, base: [rgb(0xF4F5F7), rgb(0xD3D6DC), rgb(0xBFC3CB)])
    bevel(ctx, body, width: 4, light: 0.95, dark: 0.3)
    // Black glass bezel + display
    let bezel = rounded(R(212, 258, 600, 360), 30)
    solid(ctx, bezel, rgb(0x0E0F13))
    let screen = R(232, 278, 560, 320)
    let sc = rounded(screen, 14)
    vertical(ctx, sc, [rgb(0x7E73FF), rgb(0x4F3FD8), rgb(0x2A1F8F)])
    ctx.saveGState(); ctx.addPath(sc); ctx.clip()
    ctx.drawRadialGradient(grad([rgb(0xFF8AD8, 0.55), rgb(0xFF8AD8, 0)]), startCenter: P(700, 560), startRadius: 0,
                           endCenter: P(700, 560), endRadius: 320, options: [])
    ctx.restoreGState()
    // Frosted control panel on screen
    let panel = rounded(R(282, 318, 460, 240), 26)
    solid(ctx, panel, rgb(0xFFFFFF, 0.16))
    bevel(ctx, panel, width: 2, light: 0.55, dark: 0.1)
    for (y, knob, tint) in [(370.0, 420.0, 0x5AC8FA), (438.0, 610.0, 0xFF9F0A), (506.0, 500.0, 0x30D158)] as [(CGFloat, CGFloat, UInt32)] {
        solid(ctx, rounded(R(320, y - 7, 384, 14), 7), rgb(0x000000, 0.25))
        vertical(ctx, rounded(R(320, y - 7, knob - 320, 14), 7), [rgb(tint), rgb(tint, 0.8)])
        let k = CGPath(ellipseIn: R(knob - 24, y - 24, 48, 48), transform: nil)
        objectShadow(ctx, k, lift: 0.15)
        vertical(ctx, k, [rgb(0xFFFFFF), rgb(0xE4E6EB)])
        bevel(ctx, k, width: 2, light: 1, dark: 0.15)
    }
    glassGloss(ctx, bezel, strength: 0.16)
    // Camera dot
    solid(ctx, CGPath(ellipseIn: R(507, 264, 10, 10), transform: nil), rgb(0x2A2C34))
}

// MARK: - Render

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let icons: [(String, Tint, (CGContext) -> Void)] = [
    ("VibeShot",   Tint(top: 0x6FB6FF, bottom: 0x1C6FD8), vibeShot),
    ("VibeScreen", Tint(top: 0x9C97FF, bottom: 0x5146D6), vibeScreen),
    ("VibeNote",   Tint(top: 0xFFD979, bottom: 0xF0A21C), vibeNote),
    ("VibePhoto",  Tint(top: 0x7EDFA0, bottom: 0x239E5A), vibePhoto),
]
for (i, (name, tint, draw)) in icons.enumerated() {
    let ctx = CGContext(data: nil, width: Int(S), height: Int(S), bitsPerComponent: 8, bytesPerRow: 0,
                        space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    drawPlate(ctx, tint, seed: UInt64(1000 + i))
    ctx.saveGState(); ctx.addPath(rounded(plate, plateRadius)); ctx.clip()
    draw(ctx)
    ctx.restoreGState()
    let url = URL(fileURLWithPath: out).appendingPathComponent("\(name)-1024.png")
    try! NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!.write(to: url)
    print("wrote \(url.path)")
}
