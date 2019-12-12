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

import AVFoundation
import UIKit
import Vision
import AudioToolbox


protocol CaptureManagerDelegate: class {
  func processCapturedImage(image: UIImage)
  
  
}


class FaceDetectionViewController: UIViewController {
  
  var leftimage : UIImage!
  var rightimage : UIImage!
  
  var imageNew : UIImage!
  
  
  fileprivate var selectedImage: UIImage! {
    didSet {
//        performSegue(withIdentifier: "gotoScreen", sender: self)
      
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "gotoScreen" {
      if let vc = segue.destination as? SecondViewController {
        vc.leftimage = imageNew
//        vc.rightimage = rightimage
      }
    }
  }
  
  
  func DistanceBetweenPoints(firstPoint : CGPoint , secondPoint : CGPoint , isWidth : Bool) -> CGFloat {
    
    if isWidth {
      if firstPoint.x > secondPoint.x {
        return firstPoint.x - secondPoint.x
      }
      else {
        return secondPoint.x - firstPoint.x
      }
    }
    else {
      if firstPoint.y > secondPoint.y {
        return firstPoint.y - secondPoint.y
      }
      else {
        return secondPoint.y - firstPoint.y
      }
    }
  }
  
//  func toggleFlash() {
//    guard let device = AVCaptureDevice.default(for: AVMediaType.video)
//      else {return}
//
//    if device.hasTorch {
//      do {
//        try device.lockForConfiguration()
//        if device.torchMode == AVCaptureDevice.TorchMode.on {
//          device.flashMode = .on
//          device
//
//          device.torchMode = AVCaptureDevice.TorchMode.off
//          //AVCaptureDevice.TorchModeAVCaptureDevice.TorchMode.off
//        } else {
//          do {
//            try device.setTorchModeOn(level: 1.0)
//            device.flashMode = .on
//          } catch {
//            print(error)
//          }
//        }
//        device.unlockForConfiguration()
//      } catch {
//        print(error)
//      }
//    }
//  }

  
  
  
  func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) ->UIImage? {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      return nil
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
    guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
      return nil
    }
    guard let cgImage = context.makeImage() else {
      return nil
    }
    let image = UIImage(cgImage: cgImage, scale: 1, orientation:.leftMirrored)
    CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    return image
  }
  
  
  var sequenceHandler = VNSequenceRequestHandler()

  @IBOutlet var faceView: FaceView!
  @IBOutlet var laserView: LaserView!
  @IBOutlet var faceLaserLabel: UILabel!
  
  weak var delegate: CaptureManagerDelegate?
  
  let session = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  
  let dataOutputQueue = DispatchQueue(
    label: "video data queue",
    qos: .userInitiated,
    attributes: [],
    autoreleaseFrequency: .workItem)

  @IBAction func gotoScreen(_ sender: Any) {
    
    
    performSegue(withIdentifier: "gotoScreen", sender: self)
    
  }
  
  func gotoNewScreen(){
    self.session.stopRunning()
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    DispatchQueue.main.async {
      
      
      self.performSegue(withIdentifier: "gotoScreen", sender: self)
    }
    
  }
  
  
  var faceViewHidden = false
  var maxX: CGFloat = 0.0
  var midY: CGFloat = 0.0
  var maxY: CGFloat = 0.0
  
  
  override func viewWillAppear(_ animated: Bool) {
     session.startRunning()
     flashActive()
  }


  override func viewDidLoad() {
//    navigationController?.isNavigationBarHidden = true
    
    super.viewDidLoad()
    
    configureCaptureSession()
    
    laserView.isHidden = true
    
    maxX = view.bounds.maxX
    midY = view.bounds.midY
    maxY = view.bounds.maxY
    
   
  
  }
}



// MARK: - Gesture methods

extension FaceDetectionViewController {
  @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
    faceView.isHidden.toggle()
    laserView.isHidden.toggle()
    faceViewHidden = faceView.isHidden
    
    if faceViewHidden {
      faceLaserLabel.text = "Lasers"
    } else {
      faceLaserLabel.text = "Face"
    }
  }
}

// MARK: - Video Processing methods

extension FaceDetectionViewController {
  
  func flashActive() {
    
    if let currentDevice = AVCaptureDevice.default(for: AVMediaType.video), currentDevice.hasTorch {
      do {
        try currentDevice.lockForConfiguration()
        let torchOn = !currentDevice.isTorchActive
        try currentDevice.setTorchModeOn(level:1.0)//Or whatever you want
        currentDevice.torchMode = torchOn ? .on : .off
        currentDevice.unlockForConfiguration()
      } catch {
        print("error")
      }
    }
  }
  
  
  func configureCaptureSession() {
    // Define the capture device we want to use
    guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                               for: .video,
                                               position: .back) else {
      fatalError("No front video camera available")
    }
    

    
    
    // Connect the camera to the capture session input
    do {
      let cameraInput = try AVCaptureDeviceInput(device: camera)
      session.addInput(cameraInput)
    } catch {
      fatalError(error.localizedDescription)
    }
    
    // Create the video data output
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    
    // Add the video output to the capture session
    session.addOutput(videoOutput)
    
    let videoConnection = videoOutput.connection(with: .video)
    videoConnection?.videoOrientation = .portrait
    
    // Configure the preview layer
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = .resizeAspectFill
    previewLayer.frame = view.bounds
    view.layer.insertSublayer(previewLayer, at: 0)
  }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

var image2 : UIImage?


extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    // 1
    
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      return
    }
    // 2
    let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)

    // 3
    do {
      try sequenceHandler.perform(
        [detectFaceRequest],
        on: imageBuffer,
        orientation: .leftMirrored
        )
    } catch {
      print(error.localizedDescription)
    }

    guard let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else {
      return
    }
    let pointlefteye = faceView.pointlefteye
    let pointrighteye = faceView.pointrightEye
    
    if pointlefteye.count > 0 && pointrighteye.count > 0 {
      
      print("left : 0 -> \(pointlefteye[0])")
      print("left : 4 -> \(pointlefteye[4])")
      print("Width : \(view.bounds.width)")
      
    let lefteyeWidth = DistanceBetweenPoints(firstPoint: pointlefteye[0], secondPoint: pointlefteye[4], isWidth: true)
    let lefteyeHeight = DistanceBetweenPoints(firstPoint: pointlefteye[2], secondPoint: pointlefteye[6], isWidth: false)
    let leftEyeDistanceToView = view.bounds.width - pointlefteye[0].x
    
      let f = lefteyeHeight / lefteyeWidth
      
      
      if pointlefteye[0].x > 0  && f > 0.25 && leftEyeDistanceToView < 75 && pointrighteye[12].x < 75 {
        imageNew = outputImage
        faceView.clear()
        gotoNewScreen()
    
      }
    }
//    let faceDetector = FaceDetector()
    
//    faceDetector.highlightFaces(for: self.selectedImage) {[weak self] (resultImage) in
//      DispatchQueue.main.async {
//        self!.leftimage = faceDetector.leftImage
//        self!.rightimage = faceDetector.rightImage
//
//        self!.performSegue(withIdentifier: "gotoScreen", sender: self)
//      }
//    }
    
   
    
    
   
    
    
    
    
    
    
  }
  
  
}

extension FaceDetectionViewController {
  func convert(rect: CGRect) -> CGRect {
    // 1
    let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)

    // 2
    let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)

    // 3
    return CGRect(origin: origin, size: size.cgSize)
  }

  // 1
  func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
    
    
    // 2
    let absolute = point.absolutePoint(in: rect)

    // 3
    let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)

    // 4
    return converted
  }

  func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
    guard let points = points else {
      return nil
    }

    return points.compactMap { landmark(point: $0, to: rect) }
  }
  
  func updateFaceView(for result: VNFaceObservation) {
//    defer {
      DispatchQueue.main.async {
        self.faceView.setNeedsDisplay()
        
      }
//    }

    let box = result.boundingBox
    faceView.boundingBox = convert(rect: box)

    guard let landmarks = result.landmarks else {
      return
    }

    if let leftEye = landmark(
      points: landmarks.leftEye?.normalizedPoints,
      
      to: result.boundingBox) {
      faceView.leftEye = leftEye
      
//     print( landmarks.leftEye?.pointsInImage(imageSize: faceView.bounds.size))
//      print(  VNImagePointForFaceLandmarkPoint(landmarks.leftEye?[0], faceView.boundingBox, faceView.bounds.width , faceView.bounds.height))
//      
      
    }
    
//    if let landmark = landmarks.leftEye {
//      for i in 0...landmark.pointCount - 1 { // last point is 0,0
//        let point = landmark.normalizedPoints[i]
////
////          print(CGPoint(x:  CGFloat(point.x) * faceView.bounds.width, y: CGFloat(point.y) * faceView.bounds.height))
//        
//      }
//    }
    

    if let rightEye = landmark(
      points: landmarks.rightEye?.normalizedPoints,
      to: result.boundingBox) {
      faceView.rightEye = rightEye
    }

    if let leftEyebrow = landmark(
      points: landmarks.leftEyebrow?.normalizedPoints,
      to: result.boundingBox) {
      faceView.leftEyebrow = leftEyebrow
    }

    if let rightEyebrow = landmark(
      points: landmarks.rightEyebrow?.normalizedPoints,
      to: result.boundingBox) {
      faceView.rightEyebrow = rightEyebrow
    }

    if let nose = landmark(
      points: landmarks.nose?.normalizedPoints,
      to: result.boundingBox) {
      faceView.nose = nose
    }

    if let outerLips = landmark(
      points: landmarks.outerLips?.normalizedPoints,
      to: result.boundingBox) {
      faceView.outerLips = outerLips
    }

    if let innerLips = landmark(
      points: landmarks.innerLips?.normalizedPoints,
      to: result.boundingBox) {
      faceView.innerLips = innerLips
    }

    if let faceContour = landmark(
      points: landmarks.faceContour?.normalizedPoints,
      to: result.boundingBox) {
      faceView.faceContour = faceContour
    }
  }

  // 1
  func updateLaserView(for result: VNFaceObservation) {
    // 2
    laserView.clear()

    // 3
    let yaw = result.yaw ?? 0.0

    // 4
    if yaw == 0.0 {
      return
    }

    // 5
    var origins: [CGPoint] = []

    // 6
    if let point = result.landmarks?.leftPupil?.normalizedPoints.first {
      let origin = landmark(point: point, to: result.boundingBox)
      origins.append(origin)
    }

    // 7
    if let point = result.landmarks?.rightPupil?.normalizedPoints.first {
      let origin = landmark(point: point, to: result.boundingBox)
      origins.append(origin)
    }

    // 1
    let avgY = origins.map { $0.y }.reduce(0.0, +) / CGFloat(origins.count)

    // 2
    let focusY = (avgY < midY) ? 0.75 * maxY : 0.25 * maxY

    // 3
    let focusX = (yaw.doubleValue < 0.0) ? -100.0 : maxX + 100.0

    // 4
    let focus = CGPoint(x: focusX, y: focusY)

    // 5
    for origin in origins {
      let laser = Laser(origin: origin, focus: focus)
      laserView.add(laser: laser)
    }

    // 6
    DispatchQueue.main.async {
      self.laserView.setNeedsDisplay()
    }
  }

  func detectedFace(request: VNRequest, error: Error?) {
    // 1
    guard
      let results = request.results as? [VNFaceObservation],
      let result = results.first
      
      
      else {
        // 2
        faceView.clear()
        return
    }

    if faceViewHidden {
      updateLaserView(for: result)
    } else {
      updateFaceView(for: result)
    }
  }
}






