//
//  AppDelegate.m
//  cmdclauncher
//
//  Created by Cristian Baluta on 18/03/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSString *identifier = @"com.ralcr.Jirassic.osx";
    
    BOOL alreadyRunning = NO;
    for (NSRunningApplication *app in [NSWorkspace sharedWorkspace].runningApplications) {
        if ([app.bundleIdentifier isEqualToString:identifier]) {
            alreadyRunning = YES;
            break;
        }
    }
    if (!alreadyRunning) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self 
                                                            selector:@selector(terminate) 
                                                                name:@"killme" 
                                                              object:identifier];
        
        BOOL launched = [[NSWorkspace sharedWorkspace] launchApplication:@"Jirassic.app"];
        NSLog(@"Jirassic launched %i", launched);
    }
    [self terminate];
}

- (void)terminate {
    [NSApp terminate:nil];
}

@end
