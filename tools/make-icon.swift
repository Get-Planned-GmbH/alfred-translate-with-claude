// Renders the workflow icon: swift tools/make-icon.swift src/icon.png
import AppKit

let size: CGFloat = 512
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.png"
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
  NSColor(deviceRed: r / 255, green: g / 255, blue: b / 255, alpha: a)
}

// Background: rounded square with a diagonal gradient
let bg = NSBezierPath(roundedRect: NSRect(x: 24, y: 24, width: 464, height: 464), xRadius: 104, yRadius: 104)
NSGradient(starting: rgb(79, 70, 229), ending: rgb(20, 184, 166))!.draw(in: bg, angle: -45)

// Speech bubble with a tail
func bubble(_ rect: NSRect, tailLeft: Bool, fill: NSColor) {
  let p = NSBezierPath(roundedRect: rect, xRadius: 44, yRadius: 44)
  let tail = NSBezierPath()
  let x = tailLeft ? rect.minX + 56 : rect.maxX - 56
  let dir: CGFloat = tailLeft ? -1 : 1
  tail.move(to: NSPoint(x: x - 26 * dir, y: rect.minY + 2))
  tail.line(to: NSPoint(x: x + 24 * dir, y: rect.minY - 46))
  tail.line(to: NSPoint(x: x + 22 * dir, y: rect.minY + 2))
  tail.close()
  fill.setFill()
  p.fill()
  tail.fill()
}

func label(_ s: String, in rect: NSRect, color: NSColor, font: NSFont) {
  let style = NSMutableParagraphStyle()
  style.alignment = .center
  let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: style]
  let h = (s as NSString).size(withAttributes: attrs).height
  (s as NSString).draw(in: NSRect(x: rect.minX, y: rect.midY - h / 2, width: rect.width, height: h), withAttributes: attrs)
}

let back = NSRect(x: 214, y: 196, width: 222, height: 200)
let front = NSRect(x: 76, y: 116, width: 222, height: 200)
bubble(back, tailLeft: false, fill: rgb(255, 255, 255, 0.35))
label("文", in: back, color: .white, font: NSFont.systemFont(ofSize: 124, weight: .bold))
bubble(front, tailLeft: true, fill: .white)
label("A", in: front, color: rgb(67, 56, 202), font: NSFont.systemFont(ofSize: 136, weight: .heavy))

NSGraphicsContext.current = nil
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
