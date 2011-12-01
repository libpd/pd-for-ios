//
//  DispatcherSampleViewController.m
//  DispatcherSample
//
//  Copyright (c) 2011 Peter Brinkmann (peter.brinkmann@gmail.com)
//
//  For information on usage and redistribution, and for a DISCLAIMER OF ALL
//  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
//

#import "DispatcherSampleAppDelegate.h"
#import "DispatcherSampleViewController.h"
#import "SampleListener.h"

#define APP_DELEGATE ((DispatcherSampleAppDelegate *)[UIApplication sharedApplication].delegate)

@implementation DispatcherSampleViewController

@synthesize fooLabel;
@synthesize barLabel;

-(void)pdSetup {
    PdDispatcher *dispatcher = (PdDispatcher *)[PdBase delegate];
    SampleListener *listener = [[SampleListener alloc] initWithLabel:fooLabel];
    [dispatcher addListener:listener forSource:@"foo"];
    [listener release];
    listener = [[SampleListener alloc] initWithLabel:barLabel];
    [dispatcher addListener:listener forSource:@"bar"];
    [listener release];
    listener = [[SampleListener alloc] initWithLabel:nil];
    [dispatcher addListener:listener forSource:@"baz"];
    [listener release];
    
	[PdBase openFile:@"sample.pd" path:[[NSBundle mainBundle] resourcePath]];
}

- (void)dealloc {
    [fooLabel release];
    [barLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
