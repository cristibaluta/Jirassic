//
//  Created by Cristian Baluta on 27/06/2018.
//  Copyright © 2018 Baluta Cristian. All rights reserved.
//

import Foundation
import StoreKit

enum StoreProduct: String, RCPreferencesProtocol {
    
    case git = "com.jirassic.macos.git.6months"
    case jiraTempo = "com.jirassic.macos.jiratempo.6months"
    case full = "com.jirassic.macos.full.6months"
    
    func defaultValue() -> Any {
        switch self {
        case .git:           return false
        case .jiraTempo:     return false
        case .full:          return false
        }
    }
}

class Store {
    
    static let shared = Store()
    private let localPref = RCPreferences<StoreProduct>()
    private var products = [SKProduct]()
    
    init() {
        getProducts { (success) in }
    }
    
    var isGitPurchased: Bool {
        return true
        return localPref.bool(.full) || localPref.bool(.git)
    }
    
    var isJiraTempoPurchased: Bool {
        return localPref.bool(.full) || localPref.bool(.jiraTempo)
    }
    
    func getProduct(_ product: StoreProduct, _ completion: @escaping (SKProduct?) -> Void) {
        
        guard let skProduct = products.filter({$0.productIdentifier == product.rawValue}).first else {
            getProducts { (success) in
                if success {
                    self.getProduct(product, completion)
                } else {
                    completion(nil)
                }
            }
            return
        }
        completion(skProduct)
    }
    
    private func getProducts(_ completion: @escaping (Bool) -> Void) {
        
        var productIdentifiers = Set<ProductIdentifier>()
        productIdentifiers.insert(StoreProduct.full.rawValue)
        
        IAP.requestProducts(productIdentifiers) { (response, error) in
            if let products = response?.products, !products.isEmpty {
                self.products = products
                RCLog(products)
                completion(true)
                
            } else if let _ = response?.invalidProductIdentifiers {
                completion(false)
            } else {
                // Some error happened
                completion(false)
            }
        }
    }
    
    func purchase(product: StoreProduct, _ completion: @escaping (Bool) -> Void) {
        
        IAP.purchaseProduct(product.rawValue, handler: { (productIdentifier, error) in
            
            if let product = StoreProduct(rawValue: productIdentifier ?? "") {
                
                self.localPref.set(true, forKey: product)
                completion(true)
                
            } else if let error = error as NSError? {
                if error.code == SKError.Code.paymentCancelled.rawValue {
                    // User cancelled
                    print("purchase cancelled")
                } else {
                    // Some error happened
                }
                completion(false)
            }
        })
    }
    
    func restore(_ completion: @escaping (Bool) -> Void) {
        
        IAP.restorePurchases({ (productIdentifiers, error) in
            
            RCLog("Restored products: \(productIdentifiers)")
            if let error = error as NSError? {
                if error.code == SKError.Code.paymentCancelled.rawValue {
                    // User cancelled
                    print("canceled")
                } else {
                    // Some error happened
                }
                completion(false)
            } else {
                // Reset all products
                self.localPref.set(false, forKey: .full)
                // Set purchased to true for purchased items
                for productIdentifier in productIdentifiers.reversed() {
                    if let product = StoreProduct(rawValue: productIdentifier) {
                        self.localPref.set(true, forKey: product)
                    }
                }
                completion(true)
            }
        })
    }
}
