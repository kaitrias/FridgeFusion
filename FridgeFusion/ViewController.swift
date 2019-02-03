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
    
    let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "setupCaptureSession")
    
    var resultHistoryList = [Food]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeGestureRecognizer.delegate = self
        swipeGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.left
        swipeGestureRecognizer.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("here")
        
        guard let myView = swipeGestureRecognizer.view,
            let otherView = otherGestureRecognizer.view else { return false }
        
        return gestureRecognizer == swipeGestureRecognizer &&
            otherView.isDescendant(of: myView)
    }
    
    @IBAction func startCaptureSession(_ sender: Any) {
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        
        //add camera to view
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) {
            (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            if let item = results.first(where: {$0.identifier == "banana"}) {
                if item.confidence > 0.80 {
                    print(item.identifier, item.confidence)
                    let message: String = item.identifier + "found?"
                    let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: nil))
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    private func setupActionSheet() {
    }

}

