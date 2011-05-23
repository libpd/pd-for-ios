//
//  PdTestAppDelegate.m
//  PdTest02
//
//  Created by Richard Lawler on 11/22/10.
/**
 * This software is copyrighted by Richard Lawler. 
 * The following terms (the "Standard Improved BSD License") apply to 
 * all files associated with the software unless explicitly disclaimed 
 * in individual files:
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 * 1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above  
 * copyright notice, this list of conditions and the following 
 * disclaimer in the documentation and/or other materials provided
 * with the distribution.
 * 3. The name of the author may not be used to endorse or promote
 * products derived from this software without specific prior 
 * written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,   
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "PdTestAppDelegate.h"
#import "PdTestViewController.h"


@interface PdTestAppDelegate()

- (void) openAndRunTestPatch;


@end


@implementation PdTestAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize playing;



#pragma mark -
#pragma mark Application lifecycle

extern void lrshift_tilde_setup(void);

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// create and init PdAudio object
	// note: we are using the AmbientSound Audio Session Category
	// this allows this app to work properly on most older iDevices
	// but note that recoding audio input is not possible with AmbientSound Audio Sessions
	pdAudio = [[PdAudio alloc] initWithSampleRate:44100.0 andTicksPerBuffer:64 andNumberOfInputChannels:0 andNumberOfOutputChannels:2 
		andAudioSessionCategory:kAudioSessionCategory_AmbientSound];
	
	// set AppDelegate as PdRecieverDelegate to recieve messages from Libpd
	[PdBase setDelegate:self];
		
	// initialize extern lrshift~ - note this extern must be statically linked with the app; 
	// externs can not be loaded dynamically on iOS
	lrshift_tilde_setup();  
	
	[self openAndRunTestPatch]; 
	
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	
	return YES;
}

- (void) openAndRunTestPatch
{
	// open patch located in app bundle
	void *x = [PdBase openFile:@"LoopWithExtern.pd" path:[[NSBundle mainBundle] bundlePath]];
	[PdBase computeAudio:YES];
	self.playing = YES;
}

// receivePrint delegate method to receive "print" messages from Libpd
- (void)receivePrint:(NSString *)message
{
	// for simplicity we are just sending print messages to the debugging console
	NSLog(message);
}

- (BOOL)isPlaying
{
    return playing;
}

- (void)setPlaying:(BOOL)newState
{
    if( newState == playing )
		return;
	
	playing = newState;
	if( playing )
		[pdAudio play];
	else
		[pdAudio pause];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
    [viewController release];
    [window release];
    [super dealloc];
}


@end
