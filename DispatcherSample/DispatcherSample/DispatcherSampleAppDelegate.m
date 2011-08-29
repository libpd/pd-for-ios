//
//  DispatcherSampleAppDelegate.m
//  DispatcherSample
//
//  Created by Peter Brinkmann on 8/28/11.
//  Copyright 2011. All rights reserved.
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
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
	pdAudio = [[PdAudio alloc] initWithSampleRate:44100.0 andTicksPerBuffer:32
                         andNumberOfInputChannels:1 andNumberOfOutputChannels:2];
    
    PdDispatcher *dispatcher = [[PdDispatcher alloc] init];
    SampleListener *listener = [[SampleListener alloc] initWithLabel:@"foo"];
    [dispatcher addListener:listener forSource:@"foo"];
    [listener release];
    listener = [[SampleListener alloc] initWithLabel:@"bar"];
    [dispatcher addListener:listener forSource:@"bar"];
    [listener release];
    [PdBase setDelegate:dispatcher];
    [dispatcher release];
    
	patch = [PdBase openFile:@"sample.pd" path:[[NSBundle mainBundle] bundlePath]];
    [PdBase computeAudio:YES];
    
    return YES;
}

- (void)dealloc {
    [pdAudio release];
    [PdBase closeFile:patch];
    [PdBase setDelegate:nil];
    [window release];
    [viewController release];
    [super dealloc];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [pdAudio pause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {\
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [pdAudio play];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
