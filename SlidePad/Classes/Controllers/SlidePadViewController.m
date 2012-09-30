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

#import "SlidePadViewController.h"
#import "AppDelegate.h"

#import "PolyPatchController.h"
#import "Fingerboard.h"
#import "QSlider.h"
#import "QRadioDial.h"

#import "PdBase.h"
#import "PdFile.h"

static const int kSynthNumVoices = 5;
static const float kSynthFreqRamptime = 50.0;
static NSString *const kSynthFreqRamptimeReceiver = @"synth-freq-ramptime";

#define TOGGLE_OFF_COLOR [UIColor darkGrayColor]
#define TOGGLE_ON_COLOR [UIColor colorWithRed:0.0 green:0.5 blue:0.5 alpha:1.0]

@interface SlidePadViewController ()

@property (nonatomic, retain) PolyPatchController *polyPatchController;
@property (nonatomic, retain) UIButton *playToggle;
@property (nonatomic, retain) UIButton *quantizeToggle;
@property (nonatomic, retain) UISegmentedControl *patchSelector;
@property (nonatomic, retain) QSlider *freqSlider;
@property (nonatomic, retain) UILabel *loadLabel;
@property (nonatomic, retain) QRadioDial *transposeDial;
@property (nonatomic, retain) Fingerboard *fingerboard;
@property (nonatomic, retain) NSArray *patches; // all the base names of synth patches (all contain [throw~])
@property (nonatomic, retain) PdFile *mainPatch; // contains the [catch~] and post effects, global tables

- (void)playTogglePressed:(UIButton *)sender;
- (void)quantizeTogglePressed:(UIButton *)sender;
- (void)sliderChanged:(QSlider *)sender;
- (void)patchSelectorChanged:(UISegmentedControl *)sender;

- (void)openPatchVoicesWithPatchNamed:(NSString *)patchName;
- (UIButton *)newButton;
- (UILabel *)newLabel;
- (void)formatLoadLabel;

@end

@implementation SlidePadViewController

@synthesize polyPatchController = polyPatchController_;
@synthesize playToggle = playToggle_;
@synthesize quantizeToggle = quantizeToggle_;
@synthesize patchSelector = patchSelector_;
@synthesize freqSlider = freqSlider_;
@synthesize loadLabel = loadLabel_;
@synthesize loadPercentage = loadPercentage_;
@synthesize transposeDial = transposeDial_;
@synthesize fingerboard = fingerboard_;
@synthesize patches = patches_;

#pragma mark - Dealloc

- (void)dealloc {
	self.polyPatchController = nil;
    self.playToggle = nil;
	self.quantizeToggle = nil;
	self.patchSelector = nil;
    self.freqSlider = nil;
	self.transposeDial = nil;
	self.fingerboard = nil;
    self.patches = nil;
	self.loadLabel = nil;
    [super dealloc];
}

#pragma mark - View management

- (void) loadView {
    [super loadView];

	// open the main patch, which contains a [catch~] and other post-effects
	self.mainPatch = [PdFile openFileNamed:@"main.pd" path:[[NSBundle mainBundle] bundlePath]];

	// this guy will hold the voice patches
	self.polyPatchController = [[[PolyPatchController alloc] init] autorelease];

    // UI Setup:
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playToggle = [self newButton];
    [self.playToggle addTarget:self action:@selector(playTogglePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.playToggle setTitle:@"DSP Off" forState:UIControlStateNormal];
    [self.playToggle setTitle:@"DSP On" forState:UIControlStateSelected];

	self.quantizeToggle = [self newButton];
    [self.quantizeToggle addTarget:self action:@selector(quantizeTogglePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.quantizeToggle setTitle:@"Quantize Off" forState:UIControlStateNormal];
    [self.quantizeToggle setTitle:@"Quantize On" forState:UIControlStateSelected];

    self.patches = [NSArray arrayWithObjects:@"classicsub-voice.pd", @"wavetabler-voice.pd", nil];

    self.patchSelector = [[[UISegmentedControl alloc] initWithItems:
                                          [NSArray arrayWithObjects:@"Classic Sub", @"Wavetabler", nil]]
                                          autorelease];

    self.patchSelector.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    self.patchSelector.segmentedControlStyle = UISegmentedControlStyleBar;
    self.patchSelector.tintColor = [UIColor darkGrayColor];
    self.patchSelector.selectedSegmentIndex = 0;
    [self.patchSelector addTarget:self action:@selector(patchSelectorChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.freqSlider = [[[QSlider alloc] init] autorelease];
    self.freqSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;

    self.freqSlider.minimumValue = 0.0;
    self.freqSlider.maximumValue = 100.0;
    [self.freqSlider setValue:50.0];
    [self.freqSlider addValueTarget:self action:@selector(sliderChanged:)];

	self.loadLabel = [self newLabel];
	self.loadLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[self formatLoadLabel];
    
	self.transposeDial = [[[QRadioDial alloc] init] autorelease];
	self.transposeDial.minimumValue = -3.0;
	self.transposeDial.maximumValue = 3.0;
    self.transposeDial.numSections = 7;
    self.transposeDial.value = 0;
	[self.transposeDial addValueTarget:self action:@selector(transposeChanged:)];

    self.fingerboard = [[[Fingerboard alloc] init] autorelease];
    self.fingerboard.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	self.fingerboard.numVoices = kSynthNumVoices;
	self.fingerboard.polyPatchController = self.polyPatchController; // currently need a reference to this to send messages

    [self.view addSubview:self.patchSelector];
    [self.view addSubview:self.freqSlider];
	[self.view addSubview:self.loadLabel];
    [self.view addSubview:self.playToggle];
    [self.view addSubview:self.quantizeToggle];
	[self.view addSubview:self.transposeDial];
    [self.view addSubview:self.fingerboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	[self.playToggle sizeToFit];
	[self.quantizeToggle sizeToFit];

    
    float vh = CGRectGetHeight(self.view.bounds);
    float vw = CGRectGetWidth(self.view.bounds);
    
    float kSpacer = 10.0;
    float kWidgetHeight = vh * 0.05;

    // top 5% of the view, to the left
    self.playToggle.frame = CGRectMake(kSpacer,
                                       kSpacer, 
                                       self.playToggle.frame.size.width,
                                       kWidgetHeight);

	float quantizeToggleOffset = self.playToggle.frame.origin.x + self.playToggle.frame.size.width + kSpacer;
	self.quantizeToggle.frame = CGRectMake(quantizeToggleOffset,
										   kSpacer,
										   self.quantizeToggle.frame.size.width,
										   kWidgetHeight);

    // Patch Selector: top 5% of view, right 1/3
    self.patchSelector.frame = CGRectMake(vw * 0.666,
                                          kSpacer,
                                          vw * 0.333 - kSpacer,
                                          kWidgetHeight);
    
    // Frequency Slider: next 5%, left half of screen
    self.freqSlider.frame = CGRectMake(kSpacer, 
                                       kWidgetHeight + kSpacer * 2.0,
                                       vw * 0.5 - kSpacer,
                                       kWidgetHeight);

	// Load Label: below Patch Selector (right side)
    self.loadLabel.frame = CGRectMake(self.patchSelector.frame.origin.x,
									  self.freqSlider.frame.origin.y,
									  self.patchSelector.frame.size.width,
									  kWidgetHeight);


	// Transpose Dial: next 5% - the edge of the the top half, perfect circle
	CGFloat transposeDialHeight = vw * 0.5 - kSpacer * 5 - kWidgetHeight * 2;
	self.transposeDial.frame = CGRectMake(kSpacer,
										  (kWidgetHeight + kSpacer) * 2 + kSpacer,
										  transposeDialHeight,
										  transposeDialHeight);

    // bottom half of screen
    self.fingerboard.frame =  CGRectMake(kSpacer,
                                         vh * 0.5,
                                         vw - kSpacer * 2, 
                                         vh * 0.5 - kSpacer);

	// fire initial state after views are loaded and laid out
	[self patchSelectorChanged:self.patchSelector];
	[self playTogglePressed:self.playToggle];
	[self sliderChanged:self.freqSlider];
	[self transposeChanged:self.transposeDial];
}

- (void)viewDidUnload {
	[super viewDidUnload];

	// the patch is loaded along with the view, so make sure to cleanup if the view is unloaded.
	self.mainPatch = nil;
	self.patches = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - Control Events

- (void)sliderChanged:(QSlider *)sender {
    [PdBase sendFloat:sender.value toReceiver:@"vcf-cutoff"];
}

- (void)transposeChanged:(QRadioDial *)sender {
	Fingerboard *fingerboard = self.fingerboard;
    fingerboard.minPitch = 48 + round(sender.value) * 12;
    fingerboard.maxPitch = fingerboard.minPitch + fingerboard.numNotes;
    [fingerboard setNeedsDisplay];
	[fingerboard updateAllVoices];
}

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

- (void)quantizeTogglePressed:(UIButton *)sender {
    if([sender isSelected]){
		sender.backgroundColor = TOGGLE_OFF_COLOR;
		sender.selected = NO;
    } else {
		sender.backgroundColor = TOGGLE_ON_COLOR;
		sender.selected = YES;
    }
	self.fingerboard.quantizePitch = sender.selected;
}

- (void)patchSelectorChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex > [self.patches count]) {
        RLog(@"Error: patch selector is too large");
        return;
    }
    NSString *patchName = [self.patches objectAtIndex:sender.selectedSegmentIndex];
    RLog(@"patch selected: %@", patchName); 

    if ([patchName isEqualToString:self.polyPatchController.patchName]) {
        return;
    }

	// make sure all voices are silent before switching
	[self.fingerboard mute];

	// begin opening patches only after the current patches have finished being muted
	[self performSelector:@selector(openPatchVoicesWithPatchNamed:) withObject:patchName afterDelay:kSynthFreqRamptime / 1000.0];
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

- (void)openPatchVoicesWithPatchNamed:(NSString *)patchName {
    if (self.polyPatchController.patchName) {
		[self.polyPatchController closePatches];
    }

	[self.polyPatchController openPatchesNamed:patchName path:[[NSBundle mainBundle] bundlePath] instances:kSynthNumVoices];
    [PdBase sendFloat:kSynthFreqRamptime toReceiver:kSynthFreqRamptimeReceiver];
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
	label.textColor = QCONTROL_DEFAULT_FRAME_COLOR;
	label.textAlignment = UITextAlignmentRight;
	return label;
}

- (void)formatLoadLabel {
	self.loadLabel.text = [NSString stringWithFormat:@"cpu load: %d%%", self.loadPercentage];
}

@end
