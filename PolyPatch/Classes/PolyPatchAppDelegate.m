//
//  PolyPatchAppDelegate.m
//  PolyPatch
//
//  Created by Richard Eakin on 01/23/11.
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

#import "PolyPatchAppDelegate.h"
#import "PolyPatchViewController.h"

@interface PolyPatchAppDelegate ()

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) PolyPatchViewController *viewController;
@property (nonatomic, retain) PdAudio *pdAudio;

@end

@implementation PolyPatchAppDelegate

@synthesize window = window_;
@synthesize viewController = viewController_;
@synthesize pdAudio = pdAudio_;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

#if TARGET_IPHONE_SIMULATOR	
	int ticksPerBuffer = 512 / [PdBase getBlockSize]; // apparently the only way to get clean audio output with the simulator
#else
    int ticksPerBuffer = 64;
#endif
	
	self.pdAudio = [[PdAudio alloc] initWithSampleRate:44100 andTicksPerBuffer:ticksPerBuffer andNumberOfInputChannels:2 andNumberOfOutputChannels:2];
	
//	[PdBase setDelegate:self];
	[PdBase computeAudio:YES];
	[self.pdAudio play];	

	self.viewController = [[[PolyPatchViewController alloc] init] autorelease];
    [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];

	return YES;
}

- (void)receivePrint:(NSString *)message {
	// NSLog seems to bog down the audio loop, so we use printf instead, a more direct approach for debug output
	printf("%s %s \n", __PRETTY_FUNCTION__, [message cStringUsingEncoding:NSASCIIStringEncoding]);
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	self.viewController = nil;
	self.window = nil;
	self.pdAudio = nil;
    [super dealloc];
}


@end
