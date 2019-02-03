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
    AVCaptureVideoDataOutputSampleBufferDelegate
{
    
    let imagePickerController = UIImagePickerController()
    let imageChoiceSheet = UIAlertController()
    
    var resultHistoryList = [Food]()
    
    @IBAction func startCaptureSession(_ sender: Any) {
        setupCaptureSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActionSheet()
        setupTableView()
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
                    let message: String = item.identifier + " found?"
                    let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.addFood(item: item.identifier)
                    })
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    func addFood(item: String) {
        self.resultHistoryList.append(Food(title: item))
    }
    
    private func setupTableView() {
        tableView.allowsSelection = false
        
        // Again, standard.
        tableView.dataSource = self
        tableView.delegate = self
        
        // This is how to get rid of those empty cells at the bottom.
        tableView.tableFooterView = UIView()
    }
    
    private func setupActionSheet() {
    }
    
/*    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row < resultHistoryList.count else {
            return UITableViewCell()
        }
        
        guard let historyCell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as? HistoryCell else {
            return UITableViewCell()
        }
        
        // Get the appropriate Result object from our list.
        let result = resultHistoryList[indexPath.row]
        
        // Now that we've verified, we can use the historyCell.
        historyCell.titleLabel.text = result.title
        
        return historyCell
    }*/

}

