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
#import "PdAudioController.h"

@interface PdTestAppDelegate()

@property (nonatomic, retain) PdAudioController *audioController;
- (void) openAndRunTestPatch;

@end

@implementation PdTestAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize audioController;

#pragma mark -
#pragma mark Application lifecycle

extern void lrshift_tilde_setup(void);

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

	// load our audio controller
	self.audioController = [[[PdAudioController alloc] init] autorelease];
	[self.audioController configureAmbientWithSampleRate:44100 numberChannels:2 mixingEnabled:YES];
	
	// set AppDelegate as PdRecieverDelegate to recieve messages from Libpd
	[PdBase setDelegate:self];
		
	// initialize extern lrshift~ - note this extern must be statically linked with the app; 
	// externs can not be loaded dynamically on iOS
	lrshift_tilde_setup();  
	
	[self openAndRunTestPatch]; 
	[self.audioController print];
	
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
	return YES;
}

- (void)openAndRunTestPatch {
	// open patch located in app bundle
	void *x = [PdBase openFile:@"LoopWithExtern.pd" path:[[NSBundle mainBundle] bundlePath]];
	[self.audioController setActive:YES];
}

// receivePrint delegate method to receive "print" messages from Libpd
// for simplicity we are just sending print messages to the debugging console
- (void)receivePrint:(NSString *)message {
	NSLog(@"(pd) %@", message);
}

- (void)setAudioActive:(BOOL)active {
	[self.audioController setActive:active];
}

- (void)dealloc {
    [viewController release];
    self.window = nil;
	self.audioController = nil;
    [super dealloc];
}

@end
