//
//  RootViewController.m
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

#import "RootViewController.h"
#import "WaveTableView.h"
#import "PdBase.h"
#import "PdFile.h"
#import "PdArray.h"

static NSString *const kPatchName = @"wavetable.pd";
static NSString *const kWaveTableName = @"wavetable";

@interface RootViewController ()

@property (nonatomic, retain) PdFile *patch;
@property (nonatomic, retain) WaveTableView *waveTableView;

- (void)layoutWavetable;

@end

@implementation RootViewController

@synthesize patch = patch_;
@synthesize waveTableView = waveTableView_;
@synthesize maxWidth = maxWidth_;

#pragma mark -
#pragma mark Init / Dealloc

- (void)dealloc {
    self.waveTableView = nil;
    self.patch = nil;
    [super dealloc];
}


- (void) loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.patch = [PdFile openFileNamed:kPatchName path:[[NSBundle mainBundle] bundlePath]];
    
    // testing array methods:
    int arraySize = [PdBase arraySizeForArrayNamed:kWaveTableName];
    NSLog(@"--- array name: %@, size: %d ---", kWaveTableName, arraySize);
    
    PdArray *wavetable = [[[PdArray alloc] init] autorelease];
    [wavetable readArrayNamed:kWaveTableName];
    
    self.waveTableView = [[[WaveTableView alloc] initWithWavetable:wavetable] autorelease];
    self.waveTableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.waveTableView];
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
#pragma mark Private

- (void)layoutWavetable {
    // this ratio a nice number that allows the wavetable to be of maximum size on an ipad in landscape 
    // in portriate, it will just try to fit in the screen with the same ratio, but alot smaller
    static const CGFloat kRatioWidthToHeight = 1.375; 
    static const CGFloat kPadding = 10;

    CGSize viewSize = self.view.bounds.size;
   // CGFloat viewRatio = viewSize.width / viewSize.height;
    
    CGFloat height, width, padding;
    if (viewSize.width > viewSize.height) {
        // padding will be around the top and bottom
        height = viewSize.height - 2.0 * kPadding;
        width = round(height * kRatioWidthToHeight);
        padding = round((viewSize.width - width) / 2.0);
        self.waveTableView.frame = CGRectMake(padding, kPadding, width, height);
        
    } else {
        // padding will be around left and right
        width = viewSize.width - 2.0 * kPadding;
        height = round(width / kRatioWidthToHeight);
        padding = round((viewSize.height - height) / 2.0);
        self.waveTableView.frame = CGRectMake(kPadding, padding, width, height);
    }
    [self.waveTableView setNeedsDisplay];
}


@end
