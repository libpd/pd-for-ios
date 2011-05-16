//
//  RootViewController.m
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

#import "RootViewController.h"
#import "PdBase.h"
#import "PdFile.h"
#import "PdArray.h"

static NSString *const kPatchName = @"wavetable.pd";
static NSString *const kWaveTableName = @"wavetable";

@interface RootViewController ()

@property (nonatomic, retain) PdFile *patch;

@end

@implementation RootViewController

@synthesize patch = patch_;

#pragma mark -
#pragma mark Setup

- (void) loadView {
    [super loadView];
    self.patch = [PdFile openFileNamed:kPatchName path:[[NSBundle mainBundle] bundlePath]];
    
    // testing array methods:
    int arraySize = [PdBase arraySizeForArrayNamed:kWaveTableName];
    NSLog(@"--- array name: %@, size: %d ---", kWaveTableName, arraySize);
    
    PdArray *wavetable = [[[PdArray alloc] init] autorelease];
    [wavetable readArrayNamed:kWaveTableName];
    for (int i = 0; i < [wavetable size]; i++) {
        NSLog(@"[%d] %f", i, [wavetable floatAtIndex:i]);
    }
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
- (void) viewWillAppear:(BOOL)animated {
 
}
*/

#pragma mark -
#pragma mark Controller Management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
}

- (void)dealloc {
    self.patch = nil;
    [super dealloc];
}

@end
