//
//  RootViewController.m
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

/**
 * This software is copyrighted by Richard Eakin. 
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

#import "RootViewController.h"
#import "WaveTableView.h"
#import "PdFile.h"
#import "PdArray.h"

static NSString *const kWavetablePatchName = @"wavetable.pd";
static NSString *const kResynthesisPatchName = @"resynthesis.pd";
static NSString *const kPdArrayName = @"%d-array"; // decimal parameter is the $0 arg
@interface RootViewController ()

@property (nonatomic, retain) PdFile *patch;
@property (nonatomic, retain) WaveTableView *waveTableView;
@property (nonatomic, retain) UIToolbar *toolBar;

- (void)setupWavetable;
- (void)setupToolbar;
- (void)layoutWavetable;
- (void)openPatch:(NSString *)name;
- (void)setVolume:(CGFloat)volume; // in db normalized to 100 = 1 rms

- (void)printButtonTapped:(UIBarButtonItem *)sender;
- (void)resetButtonTapped:(UIBarButtonItem *)sender;
- (void)patchSelectorChanged:(UISegmentedControl *)sender;
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
	[self setupToolbar]; // this will also select a patch from the patchSelector, thereby opening the patch
}

- (void)viewWillAppear:(BOOL)animated {
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
	DLog(@"%@", message);
}

#pragma mark -
#pragma mark Private (User Interface)

- (void)setupWavetable {
    if (!self.patch) {
        DLog(@"Error, no patch loaded.");
        return;
    }
    NSString *arrayName = [NSString stringWithFormat:kPdArrayName, self.patch.dollarZero];
    int arraySize = [PdBase arraySizeForArrayNamed:arrayName];
    DLog(@"--- array name: %@, size: %d ---", arrayName, arraySize);
    
    PdArray *wavetable = [PdArray arrayNamed:arrayName];
    
    if (self.waveTableView) {
        [self.waveTableView removeFromSuperview];
    }
    
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
																	action:@selector(printButtonTapped:)]
                                    autorelease];

    UIBarButtonItem *resetButton = [[[UIBarButtonItem alloc] initWithTitle:@"Reset"
																	 style:UIBarButtonItemStyleBordered
																	target:self
																	action:@selector(resetButtonTapped:)]
                                    autorelease];
    
    UIBarButtonItem *spaceButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil]
                                    autorelease];

    UISegmentedControl *patchControl = [[[UISegmentedControl alloc] initWithItems:
                                          [NSArray arrayWithObjects:@"Wavetable", @"Resynthesis", nil]]
                                         autorelease];
    
    patchControl.segmentedControlStyle = UISegmentedControlStyleBar;
    patchControl.tintColor = [UIColor darkGrayColor];
	patchControl.selectedSegmentIndex = 0;
    [patchControl addTarget:self action:@selector(patchSelectorChanged:) forControlEvents:UIControlEventValueChanged];
	[self patchSelectorChanged:patchControl];
	
    UIBarButtonItem *patchControlButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:patchControl] autorelease];
    
	[self.toolBar setItems:[NSArray arrayWithObjects:printButton,
                            resetButton,
                            spaceButton,
                            patchControlButtonItem,
                            nil]];
	
	[self.toolBar sizeToFit];
	[self.view addSubview:self.toolBar];
}

// this ratio is a nice number that allows the wavetable to be of maximum size on an ipad in
// landscape and portrait.
// It will just try to fit in the screen with the same ratio, but alot smaller
- (void)layoutWavetable {
    static const CGFloat kRatioWidthToHeight = 1.375; 
    static const CGFloat kPadding = 10;
    CGSize viewSize = self.view.bounds.size;
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
#pragma mark Private (Utilities)

// note: if our patch is already set and we assign a new value here, the old
// PdFile will be deallocated, which causes the patch to be closed.
- (void)openPatch:(NSString *)name {
    self.patch = [PdFile openFileNamed:name path:[[NSBundle mainBundle] bundlePath]];
    
    [self setupWavetable];
    [self layoutWavetable];
	[self setVolume:90];
}

- (void)setVolume:(CGFloat)volume {
    if (volume < 0.0) {
        volume = 0.0;
    } else if (volume > 100.0) {
        volume = 100.0;
    }
    [PdBase sendFloat:volume toReceiver:[NSString stringWithFormat:@"%d-volume", self.patch.dollarZero]];
}

#pragma mark -
#pragma mark Private (Action Handlers)

// this will print out the array contents from within the pd patch,
// and also print the contents of our PdArray
- (void)printButtonTapped:(UIBarButtonItem *)sender {
	[PdBase sendBangToReceiver:[NSString stringWithFormat:@"%d-print-table", self.patch.dollarZero]];
	
	DLog(@"wavetable elements:");
	for (int i = 0; i < self.waveTableView.wavetable.size; i++) {
		DLog(@"[%d, %f]", i, [self.waveTableView.wavetable floatAtIndex:i]);
	}
}

- (void)resetButtonTapped:(UIBarButtonItem *)sender {
    DLog(@"sending reset message to the patch");
    [PdBase sendBangToReceiver:@"reset"];

    [self.waveTableView.wavetable read]; // updates the local array
    [self.waveTableView setNeedsDisplay];
}

- (void)patchSelectorChanged:(UISegmentedControl *)sender {
    NSString *patchName;
    CGFloat minY, maxY;
    switch (sender.selectedSegmentIndex) {
        case 0:
            patchName = kWavetablePatchName;
            minY = -1.0;
            maxY = 1.0;
            break;
        case 1:
            patchName = kResynthesisPatchName;
            minY = 0.0;
            maxY = 1.0;
            break;
        default:
            return;
    }
	DLog(@"selected patch named: %@", patchName);
    if ([self.patch.baseName isEqualToString:patchName]) {
        DLog(@"%@ already open, returning.", patchName);
        return;
    }
	DLog(@"minY = %2.1f, maxY = %2.1f", patchName, minY, maxY);
    [self openPatch:patchName];
    self.waveTableView.minY = minY;
    self.waveTableView.maxY = maxY;
}

@end
