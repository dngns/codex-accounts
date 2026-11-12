// SPDX-License-Identifier: MIT
// Packages the approved imagegen artwork. No image generation or network at build time.
import AppKit
import CryptoKit

let sourceData = try Data(contentsOf: URL(fileURLWithPath: "assets/AppIcon-source.png"))
let approvedHash = "b3c85f5b668ee0bc81cb3d2ee2c270c62eeea05db4c3e4abed485bdcdbc124b1"
let hash = SHA256.hash(data: sourceData).map { String(format: "%02x", $0) }.joined()
guard hash == approvedHash,
      let representation = NSBitmapImageRep(data: sourceData),
      representation.pixelsWide == 1254, representation.pixelsHigh == 1254,
      representation.hasAlpha else {
    fatalError("Approved icon source changed. Review the artwork and provenance before packaging.")
}
let source = NSImage(size: NSSize(width: 1254, height: 1254))
source.addRepresentation(representation)
let destination = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? ".build/icon", isDirectory: true)
let iconset = destination.appendingPathComponent("AppIcon.iconset", isDirectory: true)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

func png(size: Int) -> Data {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
                                  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                  isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    bitmap.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSGraphicsContext.current!.imageInterpolation = .high
    // Preserve the approved monogram; fit it to the macOS tile and clip stray outer pixels.
    let tileInset = CGFloat(size) * 80 / 1024
    let tileRadius = CGFloat(size) * 196 / 1024
    NSBezierPath(roundedRect: NSRect(x: tileInset, y: tileInset,
                                    width: CGFloat(size) - tileInset*2, height: CGFloat(size) - tileInset*2),
                 xRadius: tileRadius, yRadius: tileRadius).addClip()
    let inset = CGFloat(size) * 56 / 1024
    source.draw(in: NSRect(x: inset, y: inset, width: CGFloat(size) - inset*2, height: CGFloat(size) - inset*2),
                from: .zero, operation: .sourceOver, fraction: 1)
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
print("Packaged approved double-C artwork into ten PNG sizes and ICNS. Source SHA-256: \(hash)")
