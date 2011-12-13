//
//  DispatcherSampleAppDelegate.m
//  DispatcherSample
//
//  Copyright (c) 2011 Peter Brinkmann (peter.brinkmann@gmail.com)
//
//  For information on usage and redistribution, and for a DISCLAIMER OF ALL
//  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
//

#import "DispatcherSampleAppDelegate.h"
#import "DispatcherSampleViewController.h"
#import "PdBase.h"
#import "PdDispatcher.h"

@implementation DispatcherSampleAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window.rootViewController = self.viewController;
    [window makeKeyAndVisible];
    
    dispatcher = [[PdDispatcher alloc] init];
    [PdBase setDelegate:dispatcher];
    
	audioController = [[PdAudioController alloc] init];
    [audioController configureAmbientWithSampleRate:44100 numberChannels:2 mixingEnabled:YES];
    [audioController print];
    
    [viewController pdSetup];
    
    audioController.active = YES;
    return YES;
}

- (void)dealloc {
    [audioController release];
    [PdBase setDelegate:nil];
    [dispatcher release];
    [window release];
    [viewController release];
    [super dealloc];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
