//
//  ViewController.swift
//  FridgeFusion
//
//  Created by Kaito Trias on 2/1/19.
//  Copyright © 2019 Kaito Trias. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
    UINavigationControllerDelegate, UIImagePickerControllerDelegate,
UITableViewDataSource, UITableViewDelegate {
    
    let imagePickerController = UIImagePickerController()
    let imageChoiceSheet = UIAlertController()
    
    var resultHistoryList = [Food]()
    
    @IBAction func launchCamera(_ sender: Any) {
        present(imageChoiceSheet, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActionSheet()
    }
    
    private func setupActionSheet() {
        self.imagePickerController.sourceType = .camera
        self.present(self.imagePickerController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < resultHistoryList.count else {
            return UITableViewCell()
        }
        
        guard let historyCell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as? HistoryCell else {
            return UITableViewCell()
        }
        
        let result = resultHistoryList[indexPath.row]
        
        historyCell.titleLabel.text = result.title
        return historyCell
    }

}

