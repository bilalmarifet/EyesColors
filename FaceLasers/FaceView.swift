/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Vision

class FaceView: UIView {
  var leftEye: [CGPoint] = []
  var rightEye: [CGPoint] = []
  var leftEyebrow: [CGPoint] = []
  var rightEyebrow: [CGPoint] = []
  var nose: [CGPoint] = []
  var outerLips: [CGPoint] = []
  var innerLips: [CGPoint] = []
  var faceContour: [CGPoint] = []

  var boundingBox = CGRect.zero
  
  func clear() {
    leftEye = []
    rightEye = []
    leftEyebrow = []
    rightEyebrow = []
    nose = []
    outerLips = []
    innerLips = []
    faceContour = []
    pointlefteye = []
    boundingBox = .zero
    pointlefteye = []
    pointrightEye = []
    
    DispatchQueue.main.async {
      self.setNeedsDisplay()
    }
  }
  var pointlefteye : [CGPoint] = []
  var pointrightEye : [CGPoint] = []
  
  override func draw(_ rect: CGRect) {
    // 1
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    
    guard let contextForLeftEyes = UIGraphicsGetCurrentContext() else {
      return
    }
    
    guard let contextForRightEyes = UIGraphicsGetCurrentContext() else {
      return
    }
    // 2
    context.saveGState()

    // 3
    defer {
      context.restoreGState()
    }

    // 4
    context.addRect(boundingBox)

    // 5
    UIColor.red.setStroke()

    // 6
    context.strokePath()

    // 1
    UIColor.white.setStroke()

    if !leftEye.isEmpty {
      // 2
      
      context.addLines(between: leftEye)

      // 3
      context.closePath()

      // 4
      context.strokePath()
    }
    
    
    if !leftEye.isEmpty {
      // 2
      
      contextForLeftEyes.addLines(between: leftEye)
    
      
      
      // 
      contextForLeftEyes.closePath()
      
      // 4
      pointlefteye = (contextForLeftEyes.path?.getPathElementsPoints())!
      
      print("leftEye count : \(pointlefteye.count)")
      print(pointlefteye)
      if pointlefteye[0].x < CGFloat(100){
        print(pointlefteye)
      }
      
      
    }
    
    if !rightEye.isEmpty {
      
      contextForRightEyes.addLines(between: rightEye)

    
     
      contextForRightEyes.closePath()
      
        pointrightEye = (contextForRightEyes.path?.getPathElementsPoints())!
      print("leftEye count : \(pointrightEye.count)")
      print(pointrightEye)
      
      
    }
    
    
    
    
    

    if !rightEye.isEmpty {
      context.addLines(between: rightEye)
      context.closePath()
      context.strokePath()
    }

    if !leftEyebrow.isEmpty {
      context.addLines(between: leftEyebrow)
      context.strokePath()
    }

    if !rightEyebrow.isEmpty {
      context.addLines(between: rightEyebrow)
      context.strokePath()
    }

    if !nose.isEmpty {
      context.addLines(between: nose)
      context.strokePath()
    }

    if !outerLips.isEmpty {
      context.addLines(between: outerLips)
      context.closePath()
      context.strokePath()
    }

    if !innerLips.isEmpty {
      context.addLines(between: innerLips)
      context.closePath()
      context.strokePath()
    }

    if !faceContour.isEmpty {
      context.addLines(between: faceContour)
      context.strokePath()
    }
  }
}









extension CGPath {
  func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
    typealias Body = @convention(block) (CGPathElement) -> Void
    let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
      let body = unsafeBitCast(info, to: Body.self)
      body(element.pointee)
    }
    //print(MemoryLayout.size(ofValue: body))
    let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
    self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
  }
  func getPathElementsPoints() -> [CGPoint] {
    var arrayPoints : [CGPoint]! = [CGPoint]()
    self.forEach { element in
      switch (element.type) {
      case CGPathElementType.moveToPoint:
        arrayPoints.append(element.points[0])
      case .addLineToPoint:
        arrayPoints.append(element.points[0])
      case .addQuadCurveToPoint:
        arrayPoints.append(element.points[0])
        arrayPoints.append(element.points[1])
      case .addCurveToPoint:
        arrayPoints.append(element.points[0])
        arrayPoints.append(element.points[1])
        arrayPoints.append(element.points[2])
      default: break
      }
    }
    return arrayPoints
  }
  func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
    var arrayPoints : [CGPoint]! = [CGPoint]()
    var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
    self.forEach { element in
      switch (element.type) {
      case CGPathElementType.moveToPoint:
        arrayPoints.append(element.points[0])
        arrayTypes.append(element.type)
      case .addLineToPoint:
        arrayPoints.append(element.points[0])
        arrayTypes.append(element.type)
      case .addQuadCurveToPoint:
        arrayPoints.append(element.points[0])
        arrayPoints.append(element.points[1])
        arrayTypes.append(element.type)
        arrayTypes.append(element.type)
      case .addCurveToPoint:
        arrayPoints.append(element.points[0])
        arrayPoints.append(element.points[1])
        arrayPoints.append(element.points[2])
        arrayTypes.append(element.type)
        arrayTypes.append(element.type)
        arrayTypes.append(element.type)
      default: break
      }
    }
    return (arrayPoints,arrayTypes)
  }
}
