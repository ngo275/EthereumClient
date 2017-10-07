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

    private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    lazy var keyStore: GethKeyStore = {
        let ks = GethNewKeyStore("\(datadir)/keystore", GethLightScryptN, GethLightScryptP)
        return ks!
    }()
    lazy var gethNode: GethNode = {
        let config = GethNewNodeConfig()!
        config.setEthereumNetworkID(4) // Doesn't matter, but best to set it to 4, Rinkeby
        config.setEthereumGenesis(GethRinkebyGenesis()) // get Rinkeby genesis block
        
        var error: NSError?
        let gethNode = GethNewNode("\(datadir)/Rinkeby", config, &error)
        return gethNode!
    }()
    lazy var gethClient: GethEthereumClient = {
        let gethClient = try! gethNode.getEthereumClient()
        return gethClient
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startMining()
        
        getBalance()
    }
    
    func createAccount() {
        // Create a new account with the specified encryption passphrase.
        try! keyStore.newAccount("Creation password")
    }
    
    func exportKey(_ account: GethAccount) -> Data {
        // Export the newly created account with a different passphrase. The returned
        // data from this method invocation is a JSON encoded, encrypted key-file.
        let jsonKey = try! keyStore.exportKey(account, passphrase: "Creation password", newPassphrase: "Export password")
        return jsonKey
    }
    
    func updateAccount(_ account: GethAccount) {
        // Update the passphrase on the account created above inside the local keystore.
        try! keyStore.update(account, passphrase: "Creation password", newPassphrase: "Update password")
    }
    
    func deleteAccount(_ account: GethAccount) {
        // Delete the account updated above from the local keystore.
        try! keyStore.delete(account, passphrase: "Update password")
    }
    
    func importAccount(key: Data) {
        // Import back the account we've exported (and then deleted) above with yet
        // again a fresh passphrase.
        try! keyStore.importKey(key, passphrase: "Export password", newPassphrase: "Import password")
    }
    
    func startMining() {
        try! gethNode.start()
        gethClient = try! gethNode.getEthereumClient()
    }
    
    func getBalance() {
        var error: NSError?
        let address = GethNewAddressFromHex("0x0af03db4Ab73cEbaA2340Cb2b2aF68Bd960978DD", &error)
        let balance = try! gethClient.getBalanceAt(GethNewContext(), account: address!, number: 0)
        print("Balance: \(balance.getInt64())") // "Balance: 3287744026290448384" Expected: 21734488100000000000 (Wei)
    }


}

