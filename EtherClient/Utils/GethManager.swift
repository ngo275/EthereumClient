//
//  GethManager.swift
//  EtherClient
//
//  Created by Shuichi Nagao on 2017/10/09.
//  Copyright © 2017 Shuichi Nagao. All rights reserved.
//

import Foundation
import Geth

class GethManager {
    
    static let shared = GethManager()
    
    private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    lazy var keyStore: GethKeyStore = {
        let ks = GethNewKeyStore("\(datadir)/keystore", GethLightScryptN, GethLightScryptP)
        return ks!
    }()
    
    lazy var gethNode: GethNode = {
        var error: NSError?
        let config = GethNewNodeConfig()!
        config.setEthereumNetworkID(4) // Doesn't matter, but best to set it to 4, Rinkeby
        config.setEthereumGenesis(GethRinkebyGenesis()) // get Rinkeby genesis block
        let gethNode = GethNewNode("\(datadir)/Rinkeby", config, &error)
        return gethNode!
    }()
    
    var gethClient: GethEthereumClient!
    
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
        let address = try! keyStore.getAccounts().get(0).getAddress()
        let balance = try! gethClient.getBalanceAt(GethNewContext(), account: address, number: -1)
        print("Balance: \(balance.getInt64())") // "Balance: 3287744026290448384" Expected: 21734488100000000000 (Wei)
    }
    
}
