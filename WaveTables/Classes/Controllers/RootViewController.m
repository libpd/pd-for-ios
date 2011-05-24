//
//  RootViewController.m
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

#import "RootViewController.h"
#import "WaveTableView.h"
#import "PdFile.h"
#import "PdArray.h"

static NSString *const kPatchName = @"wavetable.pd";
static NSString *const kWaveTableName = @"wavetable";

@interface RootViewController ()

@property (nonatomic, retain) PdFile *patch;
@property (nonatomic, retain) WaveTableView *waveTableView;
@property (nonatomic, retain) UIToolbar *toolBar;

- (void)setupWavetable;
- (void)setupToolbar;
- (void)layoutWavetable;

- (void)printButtonTapped:(id)sender;

@end

@implementation RootViewController

@synthesize patch = patch_;
@synthesize waveTableView = waveTableView_;
@synthesize toolBar = toolBar_;

#pragma mark -
#pragma mark Init / Dealloc

- (void)dealloc {
    self.patch = nil;
    self.waveTableView = nil;
	self.toolBar = nil;
    [super dealloc];
}


- (void) loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	
	[PdBase setDelegate:self];
    
    self.patch = [PdFile openFileNamed:kPatchName path:[[NSBundle mainBundle] bundlePath]];
	
	[self setupWavetable];
	[self setupToolbar];
}

- (void) viewWillAppear:(BOOL)animated {
    [self layoutWavetable];
}

#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutWavetable];
}

#pragma mark -
#pragma mark PdReceiverDelegate

- (void)receivePrint:(NSString *)message {
	//printf("[pd console] %s \n", [message cStringUsingEncoding:NSASCIIStringEncoding]);
	NSLog(@"[pd console] %@", message);
}

#pragma mark -
#pragma mark Private (User Interface)

- (void)setupWavetable {
	// testing array methods:
    int arraySize = [PdBase arraySizeForArrayNamed:kWaveTableName];
    NSLog(@"--- array name: %@, size: %d ---", kWaveTableName, arraySize);
    
    PdArray *wavetable = [[[PdArray alloc] init] autorelease];
    [wavetable readArrayNamed:kWaveTableName];
    
    self.waveTableView = [[[WaveTableView alloc] initWithWavetable:wavetable] autorelease];
    self.waveTableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
	
	[self.view addSubview:self.waveTableView];
}

- (void)setupToolbar {
	self.toolBar = [[[UIToolbar alloc] init] autorelease];
	self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.toolBar.barStyle = UIBarStyleBlack;
	
	UIBarButtonItem *printButton = [[[UIBarButtonItem alloc] initWithTitle:@"Print"
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(printButtonTapped:)] autorelease];

    UIBarButtonItem *blargButton = [[[UIBarButtonItem alloc] initWithTitle:@"Blarg"
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(blargButtonTapped:)] autorelease];

	[self.toolBar setItems:[NSArray arrayWithObjects:printButton, blargButton, nil]];
	
	[self.toolBar sizeToFit];
	[self.view addSubview:self.toolBar];
}

- (void)layoutWavetable {
    // this ratio a nice number that allows the wavetable to be of maximum size on an ipad in landscape 
    // in portriate, it will just try to fit in the screen with the same ratio, but alot smaller
    static const CGFloat kRatioWidthToHeight = 1.375; 
    static const CGFloat kPadding = 10;

    CGSize viewSize = self.view.bounds.size;
   // CGFloat viewRatio = viewSize.width / viewSize.height;
    
    CGFloat height, width, padding;
    if (viewSize.width > viewSize.height) {
        // padding will be around the top and bottom, also need to make room for the toolbar
		CGFloat toolBarHeight = self.toolBar.frame.size.height;
        height = viewSize.height - toolBarHeight - 2.0 * kPadding;
        width = round(height * kRatioWidthToHeight);
        padding = round((viewSize.width - width) / 2.0);
        self.waveTableView.frame = CGRectMake(padding, toolBarHeight + kPadding, width, height);
        
    } else {
        // padding will be around left and right
        width = viewSize.width - 2.0 * kPadding;
        height = round(width / kRatioWidthToHeight);
        padding = round((viewSize.height - height) / 2.0);
        self.waveTableView.frame = CGRectMake(kPadding, padding, width, height);
    }
    [self.waveTableView setNeedsDisplay];
}

#pragma mark -
#pragma mark Private (Action Handlers)

- (void)printButtonTapped:(id)sender {
	// this will print out the array contents from within the pd patch:
	[PdBase sendBangToReceiver:[NSString stringWithFormat:@"%d-print-table", self.patch.dollarZero]];
	
	// print the contents of our PdArray:
	DLog(@"wavetable elements:");
	for (int i = 0; i < self.waveTableView.wavetable.length; i++) {
		DLog(@"[%d, %f]", i, [self.waveTableView.wavetable floatAtIndex:i]);
	}
	
}

- (void)blargButtonTapped:(id)sender {
    // DEBUG: write 1 element with value 2.
    PdArray *array = self.waveTableView.wavetable;

	DLog(@"(before) wavetable elements:");
	for (int i = 0; i < array.length; i++) {
		DLog(@"[%d, %f]", i, [array floatAtIndex:i]);
	}
	[PdBase sendBangToReceiver:[NSString stringWithFormat:@"%d-print-table", self.patch.dollarZero]];

    [array setFloat:2.0 atIndex:3];

    DLog(@"\n\n(after) wavetable elements:");
	for (int i = 0; i < self.waveTableView.wavetable.length; i++) {
		DLog(@"[%d, %f]", i, [self.waveTableView.wavetable floatAtIndex:i]);
	}
	[PdBase sendBangToReceiver:[NSString stringWithFormat:@"%d-print-table", self.patch.dollarZero]];
}

@end
