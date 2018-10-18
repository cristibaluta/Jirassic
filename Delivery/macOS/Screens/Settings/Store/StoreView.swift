//
//  StoreView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class StoreView: NSView {

    @IBOutlet private var butBuyGit: NSButton!
    @IBOutlet private var butBuyJiraTempo: NSButton!
    @IBOutlet private var butBuyAll: NSButton!
    @IBOutlet private var butRestore: NSButton!
    @IBOutlet private var descriptionGitTextField: NSTextField!
    @IBOutlet private var descriptionJiraTempoTextField: NSTextField!
    @IBOutlet private var descriptionAllTextField: NSTextField!
    
    private let localPreferences = RCPreferences<LocalPreferences>()
    private let store = Store.shared
    
    @IBAction func handleBuyGitButton (_ sender: NSButton) {
        store.purchase(product: .git) { [weak self] (success) in
            if success {
                
            }
        }
    }
    
    @IBAction func handleBuyJiraTempoButton (_ sender: NSButton) {
        store.purchase(product: .jiraTempo) { [weak self] (success) in
            if success {
                
            }
        }
    }
    
    @IBAction func handleBuyAllButton (_ sender: NSButton) {
        store.purchase(product: .full) { [weak self] (success) in
            if success {
                
            }
        }
    }
    
    @IBAction func handleRestoreButton (_ sender: NSButton) {
        store.restore() { [weak self] (success) in
            if success {
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionGitTextField.stringValue = "Git support will let you see commits made with Git in the daily reports"
        descriptionJiraTempoTextField.stringValue = "Jira Tempo support will let you save daily reports directly to Jira Tempo"
        descriptionAllTextField.stringValue = "Subscription to Git and Jira Tempo support for 6 months. This purchase will renew automatically and can be disabled from your App Store account."
        
        store.getProduct(.full) { skProduct in
            if let product = skProduct {
                DispatchQueue.main.async {
                    self.butBuyAll.title = "Buy for \(product.localizedPrice() ?? "$x")"
                }
                
                self.store.getProduct(.git) { skProduct in
                    if let product = skProduct {
                        DispatchQueue.main.async {
                            self.butBuyGit.title = "Buy for \(product.localizedPrice() ?? "$x")"
                        }
                    }
                }
                self.store.getProduct(.jiraTempo) { skProduct in
                    if let product = skProduct {
                        DispatchQueue.main.async {
                            self.butBuyJiraTempo.title = "Buy for \(product.localizedPrice() ?? "$x")"
                        }
                    }
                }
            }
        }
    }
}
