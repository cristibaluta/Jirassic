//
//  AppDelegate.m
//
//  Created by Cristian Baluta on 18/03/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSString *appIdentifier = @"com.jirassic.macos";
    
    BOOL alreadyRunning = NO;
    for (NSRunningApplication *app in [NSWorkspace sharedWorkspace].runningApplications) {
        if ([app.bundleIdentifier isEqualToString:appIdentifier]) {
            alreadyRunning = YES;
            break;
        }
    }
    if (!alreadyRunning) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self 
                                                            selector:@selector(terminate) 
                                                                name:@"killme" 
                                                              object:appIdentifier];
        
        BOOL launched = [[NSWorkspace sharedWorkspace] launchApplication:@"Jirassic.app"];
        NSLog(@"Jirassic launched %i", launched);
        
//        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
//        NSURL *url = [NSURL fileURLWithPath:[workspace fullPathForApplication:@"Jirassic.app"]];
//        NSLog(@"Jirassic url %@", url);
//        NSError *error = nil;
////        NSArray *arguments = @[@"launchedByLauncher"];
//        NSDictionary *config = @{NSWorkspaceLaunchConfigurationEnvironment: @{@"launchedByLauncher": @YES}};
//        [workspace launchApplicationAtURL:url
//                                  options:NSWorkspaceLaunchDefault
//                            configuration:config
//                                    error:&error];
    } else {
        [self terminate];
    }
}

- (void)terminate {
    [NSApp terminate:nil];
}

@end
