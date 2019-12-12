//
//  SecondViewController.swift
//  FaceVision
//
//  Created by Bilal oğuz Marifet on 16.09.2019.
//  Copyright © 2019 Igor K. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
  
  @IBOutlet weak var right: UIImageView!
  @IBOutlet weak var left: UIImageView!
  
  
  
  var leftimage : UIImage!
  var rightimage : UIImage!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    right.image = rightimage
    left.image = leftimage
    
    
    // Do any additional setup after loading the view.
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
