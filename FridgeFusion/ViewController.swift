//
//  ViewController.swift
//  FridgeFusion
//
//  Created by Kaito Trias on 2/1/19.
//  Copyright © 2019 Kaito Trias. All rights reserved.
//

import UIKit
import AVKit
import Vision
import CoreImage


class ViewController: UITableViewController,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate,
    UIGestureRecognizerDelegate
{
    
    let imagePickerController = UIImagePickerController()
    let imageChoiceSheet = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeGestureRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    func presentCaptureViewController() {
        let transition = CATransition.init()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: nil)
        
        guard let captureViewController = storyboard?.instantiateViewController(withIdentifier: "CaptureViewController") as? CaptureViewController else {
            return
        }
        present(captureViewController, animated: false, completion: nil)
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        presentCaptureViewController()
    }
    
    @IBAction func startCaptureSession(_ sender: Any) {
        presentCaptureViewController()
    }
    
    private func setupActionSheet() {
    }

}

