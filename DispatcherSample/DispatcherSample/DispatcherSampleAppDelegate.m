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
@synthesize pdDispatcher;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window.rootViewController = self.viewController;
    [window makeKeyAndVisible];
    
    pdDispatcher = [[PdDispatcher alloc] init];
    [PdBase setDelegate:pdDispatcher];
    
#if TARGET_IPHONE_SIMULATOR	
	int ticksPerBuffer = 8;
#else
    int ticksPerBuffer = 32;
#endif
    
	pdAudio = [[PdAudio alloc] initWithSampleRate:44100 andTicksPerBuffer:ticksPerBuffer
                         andNumberOfInputChannels:2 andNumberOfOutputChannels:2];
    
    [viewController pdSetup];
    
    [pdAudio play];
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
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
