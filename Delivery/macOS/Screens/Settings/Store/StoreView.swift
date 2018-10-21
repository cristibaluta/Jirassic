//
//  StoreView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class StoreView: NSView {

    @IBOutlet private var butBuyAll: NSButton!
    @IBOutlet private var butRestore: NSButton!
    @IBOutlet private var progressIndicatorAll: NSProgressIndicator!
    @IBOutlet private var progressIndicatorRestore: NSProgressIndicator!
    @IBOutlet private var priceTextField: NSTextField!
    @IBOutlet private var descriptionAllTextField: NSTextField!
    
    private let localPreferences = RCPreferences<LocalPreferences>()
    private let store = Store.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressIndicatorAll.isHidden = true
        progressIndicatorRestore.isHidden = true
        refresh()
    }
    
    @IBAction func handleBuyAllButton (_ sender: NSButton) {
        butBuyAll.isHidden = true
        progressIndicatorAll.isHidden = false
        progressIndicatorAll.startAnimation(sender)
        store.purchase(product: .full) { [weak self] (success) in
            DispatchQueue.main.async {
                if success {
                    self?.progressIndicatorAll.isHidden = true
                    self?.progressIndicatorAll.stopAnimation(nil)
                    self?.refresh()
                }
            }
        }
    }
    
    @IBAction func handleRestoreButton (_ sender: NSButton) {
        butRestore.isHidden = true
        progressIndicatorRestore.isHidden = false
        progressIndicatorRestore.startAnimation(sender)
        store.restore() { [weak self] (success) in
            DispatchQueue.main.async {
                if success {
                    self?.butRestore.isHidden = false
                    self?.progressIndicatorRestore.isHidden = true
                    self?.progressIndicatorRestore.stopAnimation(nil)
                }
            }
        }
    }
    
    private func refresh() {
        butBuyAll.isHidden = store.isGitPurchased && store.isJiraTempoPurchased
        butRestore.isHidden = store.isGitPurchased && store.isJiraTempoPurchased
        descriptionAllTextField.stringValue = "Try for 30 days for free, after that you will be charged every 6 months. The subscription can be disabled from your App Store account.\n\nWhat's included in the subscription:\n• Git plugin will let you see commits made with Git in the daily reports\n• Jira Tempo plugin will let you save daily reports directly to Jira Tempo"
        
        store.getProduct(.full) { [weak self] skProduct in
            if let product = skProduct {
                DispatchQueue.main.async {
                    self?.priceTextField.stringValue = product.localizedPrice() ?? ""
                }
            }
        }
    }
}
