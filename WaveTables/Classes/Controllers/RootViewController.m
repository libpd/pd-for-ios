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
@property (nonatomic, assign) CGFloat maxWidth;

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
//    for (int i = 0; i < [wavetable size]; i++) {
//        NSLog(@"[%d] %f", i, [wavetable floatAtIndex:i]);
//    }
    
    self.waveTableView = [[[WaveTableView alloc] initWithWavetable:wavetable] autorelease];
    [self.view addSubview:self.waveTableView];
}

- (void) viewWillAppear:(BOOL)animated {
    CGSize viewSize = self.view.bounds.size;
    self.maxWidth = (viewSize.width > viewSize.height ? viewSize.height : viewSize.width);
    

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
    
//    static const CGFloat kRatio = 0.5; // height / width
    static const CGFloat kPadding = 20;

    // TODO: make the view expand when in landscape, so it works on both iphone and ipad
    self.waveTableView.frame = CGRectMake(kPadding,
                                          kPadding,
                                          self.view.bounds.size.width - kPadding * 2.0,
                                          self.view.bounds.size.height - kPadding * 2.0);
                                          
}

@end
