//
//  PdSettingsViewController.m
//  PdSettings
//
//  Created by Richard Eakin on 18/09/11.
//  Copyright 2011 Blarg. All rights reserved.
//

#import "RootViewController.h"
#import "PdBase.h"
#import "PdFile.h"
#import "PdAudioController.h"
#import <QuartzCore/QuartzCore.h>

@interface RootViewController ()

@property (nonatomic, retain) PdAudioController *audioController;

@end


@implementation RootViewController

#pragma mark - Init / Dealloc

- (id)init {
	self = [super init];
	if (self) {
		[PdBase setDelegate:self];
		[PdBase subscribe:@"test-value"];
		self.audioController = [[[PdAudioController alloc] init] autorelease];
		[self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES mixingEnabled:NO]; // well known settings
	}
	return self;
}

- (void)dealloc {
	self.audioController = nil;
	[super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor darkGrayColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - PdReceiverDelegate

- (void)receivePrint:(NSString *)message {
	RLog(@"%@", message);
}

@end
