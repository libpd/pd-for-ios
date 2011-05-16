//
//  AppDelegate.m
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

#import "WaveTablesAppDelegate.h"
#import "RootViewController.h"

@interface WaveTablesAppDelegate ()

@property (nonatomic, retain) PdAudio *pdAudio;

@end

@implementation WaveTablesAppDelegate

@synthesize window = window_;
@synthesize viewController = viewController_;
@synthesize pdAudio = pdAudio_;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    self.viewController = [[[RootViewController alloc] init] autorelease];
    
#if TARGET_IPHONE_SIMULATOR	
	int ticksPerBuffer = 512 / [PdBase getBlockSize]; // apparently the only way to get clean audio output with the simulator
#else
    int ticksPerBuffer = 64;
#endif
	
	self.pdAudio = [[PdAudio alloc] initWithSampleRate:44100 andTicksPerBuffer:ticksPerBuffer andNumberOfInputChannels:2 andNumberOfOutputChannels:2];
	
	[PdBase computeAudio:YES];
	[self.pdAudio play];	
    [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    self.viewController = nil;
    self.window = nil;
    self.pdAudio = nil;
    [super dealloc];
}


@end
