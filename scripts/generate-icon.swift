// SPDX-License-Identifier: MIT
// Original project artwork, drawn from geometry; no third-party image or font input.
import AppKit

struct Shape {
    let x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, radius: CGFloat
    let hex: String
    var path: NSBezierPath {
        NSBezierPath(roundedRect: NSRect(x: x, y: y, width: width, height: height),
                     xRadius: radius, yRadius: radius)
    }
    var svg: String {
        "<rect x=\"\(x)\" y=\"\(y)\" width=\"\(width)\" height=\"\(height)\" rx=\"\(radius)\" fill=\"#\(hex)\"/>"
    }
}

func color(_ hex: String) -> NSColor {
    let rgb = UInt32(hex, radix: 16)!
    return NSColor(srgbRed: CGFloat((rgb >> 16) & 255) / 255,
                   green: CGFloat((rgb >> 8) & 255) / 255,
                   blue: CGFloat(rgb & 255) / 255, alpha: 1)
}

// Coordinates are shared by the editable SVG and every PNG representation.
let tile = Shape(x: 80, y: 80, width: 864, height: 864, radius: 196, hex: "16171F")
let shapes = [
    // Two open windows with a clean separation at their overlap.
    Shape(x: 216, y: 236, width: 416, height: 352, radius: 64, hex: "B5A3FF"),
    Shape(x: 246, y: 266, width: 356, height: 292, radius: 35, hex: "1E1B30"),
    Shape(x: 246, y: 330, width: 356, height: 22, radius: 0, hex: "B5A3FF"),
    Shape(x: 368, y: 390, width: 464, height: 400, radius: 88, hex: "15161F"),
    Shape(x: 392, y: 414, width: 416, height: 352, radius: 64, hex: "85EAD0"),
    Shape(x: 422, y: 444, width: 356, height: 292, radius: 35, hex: "142A28"),
    Shape(x: 422, y: 508, width: 356, height: 22, radius: 0, hex: "85EAD0")
]

let destination = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? ".build/icon", isDirectory: true)
let fm = FileManager.default
let iconset = destination.appendingPathComponent("AppIcon.iconset", isDirectory: true)
try fm.createDirectory(at: iconset, withIntermediateDirectories: true)
let svg = """
<!-- SPDX-License-Identifier: MIT -->
<!-- Original Codex Accounts project artwork -->
<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024" role="img" aria-labelledby="title desc">
<title id="title">Codex Accounts — independent profile launcher</title>
<desc id="desc">Two overlapping open session windows in lavender and mint on a graphite rounded square.</desc>
<defs><linearGradient id="background" x1="0" y1="0" x2="0" y2="1"><stop stop-color="#292B38"/><stop offset="1" stop-color="#0D0E15"/></linearGradient></defs>
<rect x="80" y="80" width="864" height="864" rx="196" fill="url(#background)"/>
\(shapes.map(\.svg).joined(separator: "\n"))
</svg>

"""
try svg.write(to: destination.appendingPathComponent("AppIcon.svg"), atomically: true, encoding: .utf8)

func png(size: Int) throws -> Data {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
                                  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                  isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    bitmap.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let transform = NSAffineTransform()
    transform.translateX(by: 0, yBy: CGFloat(size))
    transform.scaleX(by: CGFloat(size) / 1024, yBy: -CGFloat(size) / 1024)
    transform.concat()
    NSGradient(starting: color("292B38"), ending: color("0D0E15"))!.draw(in: tile.path, angle: 90)
    for shape in shapes { color(shape.hex).setFill(); shape.path.fill() }
    NSGraphicsContext.restoreGraphicsState()
    return bitmap.representation(using: .png, properties: [:])!
}

for points in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let suffix = scale == 2 ? "@2x" : ""
        try png(size: points * scale).write(to: iconset.appendingPathComponent("icon_\(points)x\(points)\(suffix).png"))
    }
}
try png(size: 1024).write(to: destination.appendingPathComponent("AppIcon.png"))
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", iconset.path, "-o", destination.appendingPathComponent("AppIcon.icns").path]
try task.run()
task.waitUntilExit()
guard task.terminationStatus == 0 else { fatalError("iconutil failed") }
print("Generated original SVG, PNG, iconset and ICNS in \(destination.path)")
