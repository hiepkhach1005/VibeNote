// Vibe app icon renderer. Usage: swift render-icons.swift <output-dir>
// Renders 1024x1024 PNG icons for every Vibe app using the shared style spec
// documented in VIBE_ICON_STYLE.md (Apple-native: solid hue plate, white glyph).
import AppKit
import CoreGraphics

// MARK: - Design tokens

let S: CGFloat = 1024
let plate = CGRect(x: 100, y: 100, width: 824, height: 824)
let plateRadius: CGFloat = 185
let stroke: CGFloat = 60

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

let space = CGColorSpace(name: CGColorSpace.sRGB)!
func gradient(_ colors: [CGColor]) -> CGGradient {
    CGGradient(colorsSpace: space, colors: colors as CFArray, locations: nil)!
}

/// One hue per app: light top, deep bottom, plus a "ink" shade used for details on white.
struct Palette { let top: UInt32; let bottom: UInt32; let ink: UInt32 }

let white = rgb(0xFFFFFF)
let paperShade = rgb(0xE9EAEF)

// MARK: - Helpers

func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: S - y) }   // top-left origin
func R(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
    CGRect(x: x, y: S - y - h, width: w, height: h)
}
func rounded(_ r: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
}
func stroked(_ p: CGPath, _ w: CGFloat = stroke) -> CGPath {
    p.copy(strokingWithWidth: w, lineCap: .round, lineJoin: .round, miterLimit: 1)
}

/// White glyph layer with the single soft contact shadow every Vibe icon uses.
func glyph(_ ctx: CGContext, _ path: CGPath, _ color: CGColor = white, shadow: Bool = true) {
    ctx.saveGState()
    if shadow { ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 18, color: rgb(0x000000, 0.18)) }
    ctx.addPath(path); ctx.setFillColor(color); ctx.fillPath()
    ctx.restoreGState()
}

func fill(_ ctx: CGContext, _ path: CGPath, _ color: CGColor) { glyph(ctx, path, color, shadow: false) }

func drawPlate(_ ctx: CGContext, _ pal: Palette) {
    let p = rounded(plate, plateRadius)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 24, color: rgb(0x000000, 0.28))
    ctx.addPath(p); ctx.setFillColor(rgb(pal.bottom)); ctx.fillPath()
    ctx.restoreGState()

    ctx.saveGState()
    ctx.addPath(p); ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(pal.top), rgb(pal.bottom)]),
                           start: CGPoint(x: 0, y: plate.maxY), end: CGPoint(x: 0, y: plate.minY), options: [])
    // Hairline top highlight, the only "material" effect.
    ctx.addPath(rounded(plate.insetBy(dx: 1.5, dy: 1.5), plateRadius - 1.5))
    ctx.setLineWidth(3); ctx.replacePathWithStrokedPath(); ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(0xFFFFFF, 0.35), rgb(0xFFFFFF, 0)]),
                           start: CGPoint(x: 0, y: plate.maxY), end: CGPoint(x: 0, y: plate.midY), options: [])
    ctx.restoreGState()
}

// MARK: - Glyphs

func vibeShot(_ ctx: CGContext, _ pal: Palette) {
    let a: CGFloat = 268, b: CGFloat = 756, arm: CGFloat = 140, r: CGFloat = 64
    let corners = CGMutablePath()
    for (x, y, dx, dy) in [(a, a, 1.0, 1.0), (b, a, -1.0, 1.0), (a, b, 1.0, -1.0), (b, b, -1.0, -1.0)] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
        corners.move(to: P(x, y + dy * arm))
        corners.addArc(tangent1End: P(x, y), tangent2End: P(x + dx * arm, y), radius: r)
        corners.addLine(to: P(x + dx * arm, y))
    }
    glyph(ctx, stroked(corners))
    let k: CGFloat = 1.2, cx: CGFloat = 512, cy: CGFloat = 512
    let pts: [(CGFloat, CGFloat)] = [(30, -150), (-95, 25), (-5, 25), (-35, 150), (95, -30), (5, -30)]
    let bolt = CGMutablePath()
    bolt.addLines(between: pts.map { P(cx + $0.0 * k, cy + $0.1 * k) }); bolt.closeSubpath()
    glyph(ctx, stroked(bolt, 26).union(bolt))
}

func vibeScreen(_ ctx: CGContext, _ pal: Palette) {
    let body = rounded(R(222, 254, 580, 400), 64)
    let stand = CGMutablePath()
    stand.addRect(R(482, 640, 60, 100))
    stand.addPath(rounded(R(392, 726, 240, 52), 26))
    glyph(ctx, stand)
    glyph(ctx, body)
    fill(ctx, rounded(R(262, 294, 500, 320), 30), rgb(pal.bottom))
    for (y, knob) in [(370.0, 410.0), (454.0, 620.0), (538.0, 500.0)] as [(CGFloat, CGFloat)] {
        let track = CGMutablePath()
        track.move(to: P(320, y)); track.addLine(to: P(704, y))
        fill(ctx, stroked(track, 18), rgb(0xFFFFFF, 0.4))
        glyph(ctx, CGPath(ellipseIn: R(knob - 30, y - 30, 60, 60), transform: nil))
    }
}

func vibeNote(_ ctx: CGContext, _ pal: Palette) {
    let page = CGMutablePath()
    page.move(to: P(574, 236))
    page.addLine(to: P(330, 236))
    page.addArc(tangent1End: P(266, 236), tangent2End: P(266, 300), radius: 64)
    page.addLine(to: P(266, 724))
    page.addArc(tangent1End: P(266, 788), tangent2End: P(330, 788), radius: 64)
    page.addLine(to: P(694, 788))
    page.addArc(tangent1End: P(758, 788), tangent2End: P(758, 724), radius: 64)
    page.addLine(to: P(758, 420))
    page.closeSubpath()
    glyph(ctx, page)
    // Dog-ear
    let ear = CGMutablePath()
    ear.move(to: P(574, 236)); ear.addLine(to: P(574, 372))
    ear.addArc(tangent1End: P(574, 420), tangent2End: P(622, 420), radius: 48)
    ear.addLine(to: P(758, 420)); ear.closeSubpath()
    fill(ctx, ear, paperShade)
    let lines = CGMutablePath()
    for (y, w) in [(500.0, 380.0), (590.0, 380.0), (680.0, 230.0)] as [(CGFloat, CGFloat)] {
        lines.move(to: P(346, y)); lines.addLine(to: P(346 + w, y))
    }
    fill(ctx, stroked(lines, 34), rgb(pal.ink, 0.35))
    // Caret in the app hue: the one colored detail
    let caret = CGMutablePath()
    caret.move(to: P(624, 640)); caret.addLine(to: P(624, 720))
    fill(ctx, stroked(caret, 22), rgb(pal.ink))
}

func vibePhoto(_ ctx: CGContext, _ pal: Palette) {
    let frame = R(240, 270, 544, 484)
    glyph(ctx, rounded(frame, 72))
    let inner = frame.insetBy(dx: 40, dy: 40)
    ctx.saveGState()
    ctx.addPath(rounded(inner, 36)); ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(pal.top, 0.25), rgb(pal.top, 0.45)]),
                           start: CGPoint(x: 0, y: inner.maxY), end: CGPoint(x: 0, y: inner.minY), options: [])
    fill(ctx, CGPath(ellipseIn: R(588, 352, 92, 92), transform: nil), rgb(0xFFB800))
    let back = CGMutablePath()
    back.move(to: P(470, 714)); back.addLine(to: P(612, 530)); back.addLine(to: P(800, 714)); back.closeSubpath()
    fill(ctx, stroked(back, 24).union(back), rgb(pal.top))
    let front = CGMutablePath()
    front.move(to: P(240, 714)); front.addLine(to: P(424, 470)); front.addLine(to: P(640, 714)); front.closeSubpath()
    fill(ctx, stroked(front, 24).union(front), rgb(pal.ink))
    ctx.restoreGState()
}

// MARK: - Render

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
let icons: [(String, Palette, (CGContext, Palette) -> Void)] = [
    ("VibeShot",   Palette(top: 0x5AB0FF, bottom: 0x0A6CF0, ink: 0x0A5AD0), vibeShot),
    ("VibeScreen", Palette(top: 0x8C86FF, bottom: 0x5146E0, ink: 0x4338CA), vibeScreen),
    ("VibeNote",   Palette(top: 0xFFD54A, bottom: 0xFFA00A, ink: 0xE08600), vibeNote),
    ("VibePhoto",  Palette(top: 0x5FDB8A, bottom: 0x1FAE5B, ink: 0x15924A), vibePhoto),
]
for (name, pal, draw) in icons {
    let ctx = CGContext(data: nil, width: Int(S), height: Int(S), bitsPerComponent: 8, bytesPerRow: 0,
                        space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    drawPlate(ctx, pal)
    ctx.saveGState()
    ctx.addPath(rounded(plate, plateRadius)); ctx.clip()
    draw(ctx, pal)
    ctx.restoreGState()
    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    let url = URL(fileURLWithPath: out).appendingPathComponent("\(name)-1024.png")
    try! rep.representation(using: .png, properties: [:])!.write(to: url)
    print("wrote \(url.path)")
}
