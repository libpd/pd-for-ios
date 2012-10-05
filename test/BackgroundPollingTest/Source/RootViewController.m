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

// create a timer using GCD:
// source: http://developer.apple.com/library/ios/#documentation/General/Conceptual/ConcurrencyProgrammingGuide/GCDWorkQueues/GCDWorkQueues.html#//apple_ref/doc/uid/TP40008091-CH103-SW2
static dispatch_source_t CreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block) {
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
	if (timer) {
		dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
		dispatch_source_set_event_handler(timer, block);
		dispatch_resume(timer);
	}
	return timer;
}

@interface RootViewController ()

@property (nonatomic, retain) PdAudioController *audioController;
@property (nonatomic) dispatch_source_t dispatchTimer;

- (void)setupMessageHandling;
- (void)initiateMessaging;

@end


@implementation RootViewController

#pragma mark - Init / Dealloc

- (void)dealloc {
	self.audioController = nil;
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		self.audioController = [[[PdAudioController alloc] init] autorelease];
		[self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:NO mixingEnabled:NO];
		self.audioController.active = YES;

		[self setupMessageHandling];
		[self initiateMessaging];
	}
	return self;
}

- (void)setupMessageHandling {
	NSLog(@"this is the main thread.");

	[PdBase setAutoPollsMessages:NO];
	[PdBase setDelegate:self];
	[PdBase subscribe:@"test-value"];

	[PdBase openFile:@"testoutput.pd" path:[[NSBundle mainBundle] bundlePath]];
}

- (void)initiateMessaging {
	int timeIntervalSeconds = 1;
	int leewayMilliseconds = 10;
	self.dispatchTimer = CreateDispatchTimer(timeIntervalSeconds * NSEC_PER_SEC, leewayMilliseconds * NSEC_PER_MSEC, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[PdBase pollMessages];
	});
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
	NSLog(@"print: %@", message);
}

- (void)receiveFloat:(float)received fromSource:(NSString *)source {
	NSLog(@"float source: %@, value: %f", source, received);
}

@end
