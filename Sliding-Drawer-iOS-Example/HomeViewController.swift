//
//  ViewController.swift
//  Sliding-Drawer-iOS-Example
//
//  Created by Christophe ISHIMWE NGABO on 11/11/2021.
//

import UIKit

class HomeViewController: UIViewController {

    public var homeDelegate: HomeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func menuPressed(_ sender: UIBarButtonItem) {
        homeDelegate?.menuDidClicked()
    }
    
}

