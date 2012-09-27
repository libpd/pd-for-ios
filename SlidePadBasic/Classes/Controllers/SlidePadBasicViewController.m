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

#import "SlidePadBasicViewController.h"

#import "PdBase.h"
#import "PdFile.h"

#import "AppDelegate.h"
#import "Fingerboard.h"

#define TOGGLE_OFF_COLOR [UIColor darkGrayColor]
#define TOGGLE_ON_COLOR [UIColor colorWithRed:0.0 green:0.5 blue:0.5 alpha:1.0]

@interface SlidePadBasicViewController ()

@property (nonatomic, retain) UIButton *playToggle;
@property (nonatomic, retain) UILabel *loadLabel;
@property (nonatomic, retain) Fingerboard *fingerboard;
@property (nonatomic, retain) PdFile *patch;

- (void)loadPatch;
- (void)formatLoadLabel;
- (void)playTogglePressed:(UIButton *)sender;

- (UIButton *)newButton;
- (UILabel *)newLabel;

@end

@implementation SlidePadBasicViewController

@synthesize playToggle = playToggle_;
@synthesize fingerboard = fingerboard_;
@synthesize loadPercentage = loadPercentage_;
@synthesize loadLabel = loadLabel_;

#pragma mark - Dealloc

- (void)dealloc {
    self.playToggle = nil;
	self.fingerboard = nil;
	self.patch = nil;
	self.loadLabel = nil;
    [super dealloc];
}

#pragma mark - View management

- (void)loadView {
    [super loadView];

	[self loadPatch];

    // UI Setup:
    self.view.backgroundColor = [UIColor blackColor];

	// add a DSP toggle
    self.playToggle = [self newButton];
    [self.playToggle addTarget:self action:@selector(playTogglePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.playToggle setTitle:@"DSP Off" forState:UIControlStateNormal];
    [self.playToggle setTitle:@"DSP On" forState:UIControlStateSelected];

	// add a label to display cpu load
	self.loadLabel = [self newLabel];
	self.loadLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[self formatLoadLabel];

	// add The Fingerboard - the guy who triggers sound
    self.fingerboard = [[[Fingerboard alloc] init] autorelease];
    self.fingerboard.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;

    [self.view addSubview:self.playToggle];
	[self.view addSubview:self.loadLabel];
    [self.view addSubview:self.fingerboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	// layout...
	
	[self.playToggle sizeToFit];

    float vh = CGRectGetHeight(self.view.bounds);
    float vw = CGRectGetWidth(self.view.bounds);
    
	const float kSpacer = 10.0;
	const float kLoadWidth = 150.0;
    float widgetHeight = vh * 0.05;

    // top 5% of the view, to the left
    self.playToggle.frame = CGRectMake(kSpacer,
                                       kSpacer, 
                                       self.playToggle.frame.size.width,
                                       widgetHeight);

	// top 5% of the view, to the right
    self.loadLabel.frame = CGRectMake(self.view.frame.size.width - kLoadWidth - kSpacer,
                                       kSpacer,
                                       kLoadWidth,
                                       widgetHeight);

    // rest of screen
    self.fingerboard.frame =  CGRectMake(kSpacer,
                                         widgetHeight + kSpacer * 4.0,
                                         vw - kSpacer * 2.0,
                                         vh - widgetHeight - kSpacer * 5.0);

	// load with DSP on:
	[self playTogglePressed:self.playToggle];
}

- (void)viewDidUnload {
	[super viewDidUnload];

	// the patch is loaded along with the view, so make sure to cleanup if the view is unloaded.
	self.patch = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - Control Events

-(void)playTogglePressed:(UIButton *)sender {
	AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    if([sender isSelected]){
		sender.backgroundColor = TOGGLE_OFF_COLOR;
		sender.selected = NO;
        [self.fingerboard reset]; // kill all voices
    } else {
		sender.backgroundColor = TOGGLE_ON_COLOR;
		sender.selected = YES;
    }
	[appDelegate setPlaying:sender.selected];
}

#pragma mark - Custom Accessors

// whenever loadPercentage is set, update the label
- (void)setLoadPercentage:(int)loadPercentage {
	if (loadPercentage_ != loadPercentage) {
		loadPercentage_ = loadPercentage;
		[self formatLoadLabel];
	}
}

#pragma mark - Private Helpers

- (void)loadPatch {
	self.patch = [PdFile openFileNamed:@"wavetabler.pd" path:[[NSBundle mainBundle] bundlePath]];
	[PdBase sendFloat:50.0 toReceiver:@"synth-freq-ramptime"]; // the amount of time to interpolate from one pitch value to another
	[PdBase sendFloat:0 toReceiver:@"synth-mag"]; // initialize as no sound
}

- (void)formatLoadLabel {
	self.loadLabel.text = [NSString stringWithFormat:@"cpu load: %d%%", self.loadPercentage];
}

- (UIButton *)newButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 8.0;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = 1.0;
    button.backgroundColor = TOGGLE_OFF_COLOR;
    button.showsTouchWhenHighlighted = YES;
	button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0);
	return button;
}

- (UILabel *)newLabel {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor colorWithRed:0.0 green:0.7 blue:0.3 alpha:1.0];
	label.textAlignment = UITextAlignmentRight;
	return label;
}

@end
