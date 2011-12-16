//
//  PdSettingsViewController.m
//  PdSettings
//
//  Created by Richard Eakin on 18/09/11.
//  Copyright 2011 Blarg. All rights reserved.
//

#import "PdSettingsViewController.h"
#import "PdBase.h"
#import "PdFile.h"
#import "PdAudioController.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kFramePadding = 12.0;
static const CGFloat kButtonFontSize = 12.0;
static const CGFloat kLabelHeight = 20.0;
static const CGFloat kPickerFirstComponentProportion = 0.33333333;
static const CGFloat kPickerOtherComponentsProportion = 0.22222222;

typedef enum {
	SettingsPickerComponentSampleRate,
	SettingsPickerComponentNumberInputChannels,
	SettingsPickerComponentNumberOutputChannels,
	SettingsPickerComponentNumberTicks,
	SettingsPickerNumberComponents
} SettingsPickerComponent;

@interface PdSettingsViewController ()

@property (nonatomic, retain) PdAudioController *audioController;
@property (nonatomic, retain) PdFile *patch;
@property (nonatomic, retain) NSArray *settingsArray;
@property (nonatomic, retain) UIButton *activeButton;
@property (nonatomic, retain) UIButton *reloadButton;
@property (nonatomic, retain) UIButton *ambientAudioButton;
@property (nonatomic, retain) UIButton *allowMixingButton;
@property (nonatomic, retain) UIPickerView *settingsPicker;
@property (nonatomic, retain) UISegmentedControl *patchSelector;

- (void)configureAudio; // this is where PdAudioController's configure method is called and audio properties are actually set
- (void)layoutInterface;
- (void)layoutLabels;
- (void)activeButtonWasTapped:(UIButton *)sender;
- (void)reloadButtonWasTapped:(UIButton *)sender;
- (void)ambientButtonWasTapped:(UIButton *)sender;
- (void)allowMixingButtonWasTapped:(UIButton *)sender;
- (void)patchSelectorChanged:(UISegmentedControl *)sender;
- (UILabel *)addLabelWithText:(NSString *)text;
- (UIButton *)addButtonWithText:(NSString *)text selector:(SEL)selector;
- (void)fillSettingsArray;
- (void)indicateSettingsChanged;
- (void)updatePickerSettings;
- (int)pickerValueForComponent:(SettingsPickerComponent)component;
- (void)setPickerValue:(int)value component:(SettingsPickerComponent)component animated:(BOOL)animated;

@end


@implementation PdSettingsViewController

@synthesize audioController = audioController_,
patch = patch_,
settingsArray = settingsArray_,
activeButton = activeButton_,
reloadButton = reloadButton_,
settingsPicker = settingsPicker_,
patchSelector = patchSelector_,
ambientAudioButton = ambientAudioButton_,
allowMixingButton = allowMixingButton_;

#pragma mark - Init / Dealloc

- (id)init {
	self = [super init];
	if (self) {
		[PdBase setDelegate:self];
		[PdBase subscribe:@"test-value"];
		self.audioController = [[[PdAudioController alloc] init] autorelease];
		[self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES mixingEnabled:NO]; // well known settings
		[self fillSettingsArray];
	}
	return self;
}

- (void)dealloc {
	self.audioController = nil;
	self.patch = nil;
	self.activeButton = nil;
	self.reloadButton = nil;
	self.ambientAudioButton = nil;
    self.allowMixingButton = nil;
	self.patchSelector = nil;
	self.settingsArray = nil;
	[super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor darkGrayColor];
	
	self.activeButton = [self addButtonWithText:@"Inactive" selector:@selector(activeButtonWasTapped:)];
	[self.activeButton setTitle:@"Active" forState:UIControlStateSelected];
    
	self.reloadButton = [self addButtonWithText:@"Reload Settings" selector:@selector(reloadButtonWasTapped:)];
	self.reloadButton.enabled = NO;
	
	self.ambientAudioButton = [self addButtonWithText:@"Ambient Audio" selector:@selector(ambientButtonWasTapped:)];
	self.allowMixingButton = [self addButtonWithText:@"Allow Mixing" selector:@selector(allowMixingButtonWasTapped:)];
	
	self.settingsPicker = [[[UIPickerView alloc] init] autorelease];
	self.settingsPicker.delegate = self;
	self.settingsPicker.dataSource = self;
	self.settingsPicker.showsSelectionIndicator = YES;
	
	self.patchSelector = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"testoutput.pd", @"testinput.pd", nil]] autorelease];
    self.patchSelector.segmentedControlStyle = UISegmentedControlStyleBezeled;
    self.patchSelector.tintColor = [UIColor colorWithRed:54.0/255.0 green:56.0/255.0 blue:96.0/255.0 alpha:1.0];
    self.patchSelector.selectedSegmentIndex = 0;
    [self.patchSelector addTarget:self action:@selector(patchSelectorChanged:) forControlEvents:UIControlEventValueChanged];
	[self patchSelectorChanged:self.patchSelector];
    
	[self.view addSubview:self.settingsPicker];
	[self.view addSubview:self.patchSelector];
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self layoutInterface];
	[self layoutLabels];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self updatePickerSettings];
	[self.audioController print];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	for (UIView *view in self.view.subviews) {
		if ([view isKindOfClass:[UILabel class]]) {
			[view removeFromSuperview];
		}
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self layoutInterface];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self layoutLabels];
}

#pragma mark - PdReceiverDelegate

- (void)receivePrint:(NSString *)message {
	RLog(@"%@", message);
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return SettingsPickerNumberComponents;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[self.settingsArray objectAtIndex:component] count];
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	CGFloat totalWidth = self.settingsPicker.frame.size.width - kFramePadding * 2;
	if (component == SettingsPickerComponentSampleRate) {
		return floor(totalWidth * kPickerFirstComponentProportion);
	}
	return floor(totalWidth * kPickerOtherComponentsProportion);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[self.settingsArray objectAtIndex:component] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	// if the user selects inputs > 0, make sure to disable the
	// ambient audio button
	if (component == SettingsPickerComponentNumberInputChannels && [self pickerValueForComponent:SettingsPickerComponentNumberInputChannels] > 0) {
		self.ambientAudioButton.selected = NO;
	}
	
	// number of ticks can be changed while the audio unit is running, without it needing to be recreated, so it has a different configure method
	if (component == SettingsPickerComponentNumberTicks) {
		int ticks = [self pickerValueForComponent:SettingsPickerComponentNumberTicks];
		PdAudioStatus status = [self.audioController configureTicksPerBuffer:ticks];
		if (status == PdAudioPropertyChanged) {
			RLog(@"Could not configure ticksPerBuffer = %d, instead got %d", ticks, self.audioController.ticksPerBuffer);
			[self setPickerValue:self.audioController.ticksPerBuffer component:SettingsPickerComponentNumberTicks animated:YES];
		}
	} else {
		[self indicateSettingsChanged];
	}
}


#pragma mark - Private (UI)

- (void)layoutInterface {
	const CGFloat kButtonHeight = 34.0;
	const CGFloat kPSWidth = 300.0;
	const CGFloat kActiveButtonWidth = 70.0;
	const CGFloat kReloadButtonWidth = 120.0;
	const CGFloat kButtonSpacer = 10.0;
	const CGFloat kPickerHeight = 162.0;
	CGSize viewSize = self.view.bounds.size;
    
	self.settingsPicker.frame =  CGRectMake(0.0, viewSize.height - kPickerHeight, viewSize.width, kPickerHeight);
	
	CGFloat psXOffset = (viewSize.width - kPSWidth) * 0.5;
	CGFloat psYOffset = self.settingsPicker.frame.origin.y - kButtonHeight - 26.0;
	self.patchSelector.frame = CGRectIntegral(CGRectMake(psXOffset, psYOffset, kPSWidth, kButtonHeight));
	
	self.activeButton.frame = CGRectMake(kFramePadding, kFramePadding, kActiveButtonWidth, kButtonHeight);
	CGFloat rButtonXOffset = viewSize.width - kFramePadding - kReloadButtonWidth;
	self.reloadButton.frame = CGRectMake(rButtonXOffset, kFramePadding, kReloadButtonWidth, kButtonHeight);
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		self.ambientAudioButton.frame = CGRectMake(self.reloadButton.frame.origin.x,
                                                   self.reloadButton.frame.origin.y + kButtonHeight + kButtonSpacer,
                                                   kReloadButtonWidth,
                                                   kButtonHeight);
		self.allowMixingButton.frame = CGRectMake(self.reloadButton.frame.origin.x,
                                                  self.reloadButton.frame.origin.y + 2 * (kButtonHeight + kButtonSpacer),
                                                  kReloadButtonWidth,
                                                  kButtonHeight);
	} else {
		self.ambientAudioButton.frame = CGRectMake(self.reloadButton.frame.origin.x - self.reloadButton.frame.size.width - kButtonSpacer,
                                                   self.reloadButton.frame.origin.y,
                                                   kReloadButtonWidth,
                                                   kButtonHeight);
		self.allowMixingButton.frame = CGRectMake(self.reloadButton.frame.origin.x - 2 * (self.reloadButton.frame.size.width + kButtonSpacer),
                                                  self.reloadButton.frame.origin.y,
                                                  kReloadButtonWidth,
                                                  kButtonHeight);
	}
    
}

- (void)layoutLabels {
	CGSize viewSize = self.view.bounds.size;
	const CGFloat kPSLabelWidth = 100.0;
    
	CGFloat pickerLabelsYOffset = viewSize.height - self.settingsPicker.frame.size.height - kLabelHeight;
	CGFloat drawingWidth = viewSize.width - kFramePadding * 2;
	CGFloat xOffset = kFramePadding + 2;
	UILabel *srLabel = [self addLabelWithText:@"samplerate"];
	srLabel.frame = CGRectIntegral(CGRectMake(xOffset,
											  pickerLabelsYOffset,
											  drawingWidth * kPickerFirstComponentProportion,
											  kLabelHeight));
	
	UILabel *insLabel = [self addLabelWithText:@"ins"];
	xOffset += kPickerFirstComponentProportion * drawingWidth + 2;
	insLabel.frame = CGRectIntegral(CGRectMake(xOffset,
											   pickerLabelsYOffset,
											   drawingWidth * kPickerOtherComponentsProportion,
											   kLabelHeight));
	
	UILabel *outsLabel = [self addLabelWithText:@"outs"];
	xOffset += kPickerOtherComponentsProportion * drawingWidth;
	outsLabel.frame = CGRectIntegral(CGRectMake(xOffset,
												pickerLabelsYOffset,
												drawingWidth * kPickerOtherComponentsProportion,
												kLabelHeight));
	UILabel *ticksLabel = [self addLabelWithText:@"ticks"];
	xOffset += kPickerOtherComponentsProportion * drawingWidth;
	ticksLabel.frame = CGRectIntegral(CGRectMake(xOffset,
												 pickerLabelsYOffset,
												 drawingWidth * kPickerOtherComponentsProportion,
												 kLabelHeight));
    
	UILabel *psLabel = [self addLabelWithText:@"patch selector"];
	psLabel.textAlignment = UITextAlignmentCenter;
	CGFloat psLabelYOffset = self.patchSelector.frame.origin.y - kLabelHeight - 2;
	psLabel.frame = CGRectIntegral(CGRectMake((viewSize.width - kPSLabelWidth) * 0.5,
											  psLabelYOffset,
											  kPSLabelWidth,
											  kLabelHeight));
}

- (UILabel *)addLabelWithText:(NSString *)text {
	UILabel *label = [[[UILabel alloc] init] autorelease];
	[self.view addSubview:label];
	label.text = text;
	label.textColor = [UIColor lightGrayColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:14];
	return label;
}

- (UIButton *)addButtonWithText:(NSString *)text selector:(SEL)selector {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:text forState:UIControlStateNormal];
	[button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
	
	[button setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	button.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	button.titleLabel.font = [UIFont boldSystemFontOfSize:kButtonFontSize];
	
	[button setTitleColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
	UIImage *normalImage = [[UIImage imageNamed:@"button-normal.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	[button setBackgroundImage:normalImage forState:UIControlStateNormal];
	UIImage *pressedImage = [[UIImage imageNamed:@"button-pressed.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	[button setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
	[button setBackgroundImage:pressedImage forState:UIControlStateSelected];
	
	[self.view addSubview:button];
	return button;
}

#pragma mark - Private (Selectors)

- (void)activeButtonWasTapped:(UIButton *)sender {
	sender.selected = !sender.selected;
	[self.audioController setActive:sender.selected];
}

// configure PdAudioController, then update the picker with the actual settings
- (void)reloadButtonWasTapped:(UIButton *)sender {
	RLog(@"reloading audio configuration");
	[self configureAudio];
    
	[self.reloadButton.layer removeAnimationForKey:@"shadow"];
	[self.audioController print];
	self.reloadButton.enabled = NO;
}

- (void)ambientButtonWasTapped:(UIButton *)sender {
	sender.selected = !sender.selected;
    if (sender.selected) {
        [self setPickerValue:0 component:SettingsPickerComponentNumberInputChannels animated:YES];
    }
	RLog(@"selected: %d", sender.selected);
	[self indicateSettingsChanged];
}

- (void)allowMixingButtonWasTapped:(UIButton *)sender {
	sender.selected = !sender.selected;
	RLog(@"selected: %d", sender.selected);
	[self indicateSettingsChanged];
}

#pragma mark - Private (Audio)

- (void)configureAudio {
	PdAudioStatus status;
	int sampleRate = [self pickerValueForComponent:SettingsPickerComponentSampleRate];
	int numInputs = [self pickerValueForComponent:SettingsPickerComponentNumberInputChannels];
	int numOutputs = [self pickerValueForComponent:SettingsPickerComponentNumberOutputChannels];
	
	if (self.ambientAudioButton.selected) {
		status = [self.audioController configureAmbientWithSampleRate:sampleRate numberChannels:numOutputs mixingEnabled:self.allowMixingButton.selected];
	} else {
        int numChannels = (numInputs > numOutputs) ? numInputs : numOutputs;
		status = [self.audioController configurePlaybackWithSampleRate:sampleRate numberChannels:numChannels
                                                          inputEnabled:(numInputs > 0) mixingEnabled:self.allowMixingButton.selected];
	}
	if (status == PdAudioError) {
		RLog(@"Error configuring PdAudioController");
        [self.reloadButton setTitle:@"Error!" forState:UIControlStateNormal];
	} else if (status == PdAudioPropertyChanged) {
		RLog(@"Could not configure with provided properties (samplerate: %d, numInputs: %d, numOutputs: %d)", sampleRate, numInputs, numOutputs);
		RLog(@"Instead got samplerate: %d, numChannels: %d", self.audioController.sampleRate, self.audioController.numberChannels);
        [self.reloadButton setTitle:@"Property Changed!" forState:UIControlStateNormal];
	} else {
        [self.reloadButton setTitle:@"Success!" forState:UIControlStateNormal];
    }
    [self updatePickerSettings];
}

- (void)patchSelectorChanged:(UISegmentedControl *)sender {
    NSString *name = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
	self.patch = [PdFile openFileNamed:name path:[[NSBundle mainBundle] resourcePath]];
	if (self.patch) {
		RLog(@"opened patch: %@", name);
	} else {
		RError(@"couldn't open patch: %@", name);
	}
	[PdBase sendFloat:95 toReceiver:@"mag"];
}

// TODO: test with bogus values
- (void)fillSettingsArray {
	const int kNumTickOptions = 32;
    
	NSArray *sampleratesArray = [NSArray arrayWithObjects: @"8000", @"22050", @"24000", @"32000", @"44100", @"48000", nil];
	
	NSArray *inputChannelsArray = [NSArray arrayWithObjects:@"0", @"1", @"2", nil];
	NSArray *outputChannelsArray = [NSArray arrayWithObjects:@"0", @"1", @"2", nil];
	
	NSMutableArray *ticksArray = [NSMutableArray arrayWithCapacity:kNumTickOptions];
	for (int i = 1; i <= 64; i++) {
		[ticksArray addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
	self.settingsArray = [NSArray arrayWithObjects:sampleratesArray,
						  inputChannelsArray,
						  outputChannelsArray,
						  ticksArray,
						  nil];
}

- (void)updatePickerSettings {
	[self setPickerValue:self.audioController.sampleRate component:SettingsPickerComponentSampleRate animated:YES];
	[self setPickerValue:(self.audioController.inputEnabled ? self.audioController.numberChannels : 0) component:SettingsPickerComponentNumberInputChannels animated:YES];
	[self setPickerValue:self.audioController.numberChannels component:SettingsPickerComponentNumberOutputChannels animated:YES];
	[self setPickerValue:self.audioController.ticksPerBuffer component:SettingsPickerComponentNumberTicks animated:YES];
}

- (int)pickerValueForComponent:(SettingsPickerComponent)component {
	int row = [self.settingsPicker selectedRowInComponent:component];
	NSString *value = [[self.settingsArray objectAtIndex:component] objectAtIndex:row];
	return [value intValue];
}

- (void)setPickerValue:(int)value component:(SettingsPickerComponent)component animated:(BOOL)animated {
	NSString *valueString = [NSString stringWithFormat:@"%d", value];
	NSArray *componentArray = [self.settingsArray objectAtIndex:component];
	int row = 0;
	for (NSString *pickerValue in componentArray) {
		if ([valueString isEqualToString:pickerValue]) {
			[self.settingsPicker selectRow:row inComponent:component animated:animated];
			return;
		}
		row++;
	}
	// if we made it here, there was a problem
	RLog(@"* ERROR * could not find a value equal to %d in component %d", value, component);
}

- (void)indicateSettingsChanged {
	if (!self.reloadButton.enabled) {
		self.reloadButton.enabled = YES;
        [self.reloadButton setTitle:@"Reload Settings" forState:UIControlStateNormal];
        
		self.reloadButton.layer.shadowRadius = 5.0;
		self.reloadButton.layer.shadowColor = [UIColor cyanColor].CGColor;
		self.reloadButton.layer.shadowOpacity = 0.0;
		self.reloadButton.layer.shadowOffset = CGSizeMake(0.0, 0.0);
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"]; 
		animation.fromValue = [NSNumber numberWithFloat:0.0];
		animation.toValue = [NSNumber numberWithFloat:0.4];
		animation.autoreverses = YES;
		animation.duration = .4;
		animation.repeatCount = NSIntegerMax;
		[self.reloadButton.layer addAnimation:animation forKey:@"shadow"];
	}
}

@end
