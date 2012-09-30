/*
 Copyright (c) 2012, Richard Eakin

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that
 the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this list of conditions and
 the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
 the following disclaimer in the documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#import "AppDelegate.h"
#import "SlidePadBasicViewController.h"
#import "PdAudioController.h"

@interface AppDelegate ()

@property (nonatomic, retain) SlidePadBasicViewController *viewController;
@property (nonatomic, retain) PdAudioController *audioController;

- (void)setupPd;

@end

@implementation AppDelegate

@synthesize window = window_;
@synthesize viewController = viewController_;
@synthesize audioController = audioController_;

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    self.viewController = [[[SlidePadBasicViewController alloc] init] autorelease];
	self.window.rootViewController = self.viewController;
    
	[self setupPd];
	
    [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];
	return YES;
}

- (void)setupPd {
	// Configure a typical audio session with 2 output channels
	self.audioController = [[[PdAudioController alloc] init] autorelease];
	PdAudioStatus status = [self.audioController configurePlaybackWithSampleRate:44100
																  numberChannels:2
																	inputEnabled:NO
																   mixingEnabled:NO];
	if (status == PdAudioError) {
		RLog(@"Error! Could not configure PdAudioController");
	} else if (status == PdAudioPropertyChanged) {
		RLog(@"Warning: some of the audio parameters were not accceptable.");
	} else {
		RLog(@"Audio Configuration successful.");
	}

	// log actually settings
	[self.audioController print];

	// set AppDelegate as PdRecieverDelegate to recieve messages from pd
    [PdBase setDelegate:self];

	// recieve all [send load-meter] messages from pd
	[PdBase subscribe:@"load-meter"];

	// open one instance of the load-meter patch and forget about it
	[PdBase openFile:@"load-meter.pd" path:[[NSBundle mainBundle] bundlePath]];
}

#pragma mark - PdRecieverDelegate

// handle [print] messages from pd
- (void)receivePrint:(NSString *)message {
    NSLog(@"Pd Console: %@", message);
}

// handle subscribed float messages from pd
- (void)receiveFloat:(float)received fromSource:(NSString *)source {
	if ([source isEqualToString:@"load-meter"]) {
		self.viewController.loadPercentage = (int)received;
	}
}

#pragma mark - Accessors

- (BOOL)isPlaying {
    return playing_;
}

- (void)setPlaying:(BOOL)newState {
    if( newState == playing_ )
		return;

	playing_ = newState;
	self.audioController.active = playing_;
}

#pragma mark - UIApplicationDelegate

- (void)applicationWillResignActive:(UIApplication *)application {
	self.playing = NO;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	self.playing = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
	self.playing = NO;
}

- (void)dealloc {
    self.viewController = nil;
	self.audioController = nil;
    self.window = nil;
    [super dealloc];
}

@end
