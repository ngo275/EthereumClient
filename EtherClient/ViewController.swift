//
//  ViewController.swift
//  EtherClient
//
//  Created by Shuichi Nagao on 2017/10/06.
//  Copyright © 2017 Shuichi Nagao. All rights reserved.
//

import UIKit
import Geth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GethManager.shared.startMining()
    }

    @IBAction func didButtonTapped(_ sender: Any) {
        GethManager.shared.getBalance()
    }
    
}

