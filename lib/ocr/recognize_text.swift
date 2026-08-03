import AppKit
import Foundation
import Vision

guard CommandLine.arguments.count == 2 else {
  fputs("usage: recognize_text.swift IMAGE_PATH\n", stderr)
  exit(2)
}

let url = URL(fileURLWithPath: CommandLine.arguments[1])
guard let image = NSImage(contentsOf: url) else {
  fputs("image could not be opened\n", stderr)
  exit(3)
}

var rect = CGRect(origin: .zero, size: image.size)
guard let cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
  fputs("image could not be converted\n", stderr)
  exit(4)
}

let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate
request.usesLanguageCorrection = true
request.recognitionLanguages = ["ja-JP", "en-US"]

let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
try handler.perform([request])

let lines = (request.results ?? []).compactMap { observation in
  observation.topCandidates(1).first?.string
}

print(lines.joined(separator: "\n"))
