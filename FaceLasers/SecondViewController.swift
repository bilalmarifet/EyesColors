//
//  SecondViewController.swift
//  FaceVision
//
//  Created by Bilal oğuz Marifet on 16.09.2019.
//  Copyright © 2019 Igor K. All rights reserved.
//

import UIKit



class SecondViewController: UIViewController {
  var left2image : UIImage!
  var rightimage : UIImage!
 var leftimage : UIImage!
  
  fileprivate var selectedImage: UIImage! 
   
   
  
    @IBOutlet weak var left: UIImageView!
    
    
    
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "gotoScreen" {
      if let vc = segue.destination as? ThirdViewController {
        vc.leftimage = left2image
        vc.rightimage = rightimage
      }
    }
  }
  
  func newgoto(){
    performSegue(withIdentifier: "gotoScreen", sender: self)
  }

  @IBAction func goto(_ sender: Any) {
    newgoto()
  }
  
  @IBOutlet weak var buttonProp: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
//      left.transform = CGAffineTransform(rotationAngle:.pi/2)
      
     

    }
  
  override func viewWillAppear(_ animated: Bool) {
    
    
    buttonProp.isHidden = true
    let newImage = UIImage(cgImage: leftimage.cgImage!, scale: leftimage.scale, orientation: .up)
      left.image = newImage
     selectedImage = newImage
    
    let faceDetector = FaceDetector()
    DispatchQueue.global().async {
      faceDetector.highlightFaces(for: self.selectedImage) { (resultImage) in
        DispatchQueue.main.async {
          self.left2image = faceDetector.leftImage
          self.rightimage = faceDetector.rightImage
          self.buttonProp.isHidden = false
          
        }
      }
    }
    
    
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SecondViewController: CaptureManagerDelegate {
  func processCapturedImage(image: UIImage) {
    self.left.image = image
  }
}

