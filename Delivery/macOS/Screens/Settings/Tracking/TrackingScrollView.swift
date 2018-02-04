//
//  TrackingScrollView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class TrackingScrollView: NSScrollView {
    
    private var trackingView: TrackingView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var views: NSArray?
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: String(describing: TrackingView.self)),
                                 owner: nil,
                                 topLevelObjects: &views)
//        RCLog(views)
        if let v = views {
            for view in v {
                if let tv = view as? TrackingView {
                    trackingView = tv
                    self.addSubview(tv)
                }
            }
        }
    }
    
    func showSettings (_ settings: SettingsTracking) {
        trackingView!.showSettings(settings)
    }
    
    func settings() -> SettingsTracking {
        return trackingView!.settings()
    }
    
    func save() {
        
    }
}

