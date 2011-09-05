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
#import "SampleListener.h"
#import "PdDispatcher.h"

@implementation DispatcherSampleAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window.rootViewController = self.viewController;
    [window makeKeyAndVisible];
    
    pdDispatcher = [[PdDispatcher alloc] init];
    [PdBase setDelegate:pdDispatcher];
    
	pdAudio = [[PdAudio alloc] initWithSampleRate:44100.0 andTicksPerBuffer:32
                         andNumberOfInputChannels:1 andNumberOfOutputChannels:2];
    
    [viewController pdSetup:pdDispatcher];
    
    return YES;
}

- (void)dealloc {
    [pdAudio release];
    [PdBase setDelegate:nil];
    [pdDispatcher release];
    [window release];
    [viewController release];
    [super dealloc];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [pdAudio play];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [pdAudio pause];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
