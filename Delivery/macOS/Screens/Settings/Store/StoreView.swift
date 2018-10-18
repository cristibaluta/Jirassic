//
//  StoreView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class StoreView: NSView {

    @IBOutlet private var butBuy: NSButton!
    @IBOutlet private var descriptionTextField: NSTextField!
    
    private let localPreferences = RCPreferences<LocalPreferences>()
    private let store = Store.shared
    
    @IBAction func handleBuyButton (_ sender: NSButton) {
        store.purchase(product: .full) { [weak self] (success) in
            if success {
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        store.getProduct(.full) { skProduct in
            if let product = skProduct {
                DispatchQueue.main.async {
                    self.butBuy.title = "Buy for \(product.localizedPrice() ?? "$x")"
                    self.descriptionTextField.stringValue = "Purchase Git and Jira Tempo support for \(product.localizedPrice() ?? "$x") for 6 months"
                }
            }
        }
    }
}
