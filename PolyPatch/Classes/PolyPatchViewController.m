//
//  PolyPatchViewController.m
//  PolyPatch
//
//  Created by Richard Eakin on 01/23/11.
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

#import "PolyPatchViewController.h"
#import "PatchTableViewCell.h"
#import "PdBase.h"
#import "PdFile.h"
#import <QuartzCore/QuartzCore.h>

//NSString *const kTestPatchName = @"test.pd"; // each patch will just print out the $0 arg every second
NSString *const kTestPatchName = @"test2.pd"; // audio blurbs with pitch control
//NSString *const kTestPatchName = @"synctest.pd"; // Patch from Brett Park that was crashing libpd because of sync issues

@interface PolyPatchViewController ()

@property (nonatomic, retain) NSMutableArray *patches;
@property (nonatomic, retain) UIButton *openButton;
@property (nonatomic, retain) UITableView *tableView;

- (void)openButtonPressed:(id)button;
- (void)testOpeningMany;

@end

@implementation PolyPatchViewController

@synthesize openButton = openButton_;
@synthesize tableView = tableView_;
@synthesize patches = patches_;

#pragma mark -
#pragma mark Init / Dealloc

- (void)dealloc {
	self.openButton = nil;
	self.tableView = nil;
	self.patches = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark View Life Cycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor blackColor];
	
	self.patches = [NSMutableArray array];

	UIButton *openButton = [UIButton buttonWithType:UIButtonTypeCustom];
	openButton.backgroundColor = [UIColor blueColor];
	openButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	openButton.layer.cornerRadius = 5.0;
	openButton.layer.borderColor = [[UIColor purpleColor] CGColor];
	openButton.layer.borderWidth = 1.0;
	[openButton setTitle:@"Open New" forState:UIControlStateNormal];
	[openButton addTarget:self action:@selector(openButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:openButton];
	self.openButton = openButton;
	
	self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped] autorelease];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.tableView.editing = YES;
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];

	//[self testOpeningMany]; 	// uncomment to test syncing issues with synctest.pd
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.openButton.frame = CGRectMake(00.0, 10.0, self.view.bounds.size.width - 0.0, 40.0);

	self.tableView.backgroundColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.3 alpha:1.0];
	self.tableView.frame = CGRectMake(0.0, 55.0, self.view.bounds.size.width, self.view.bounds.size.height - 60.0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}


#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *const kCellID = @"cell";
	PdFile *patch = [self.patches objectAtIndex:indexPath.row];

	PatchTableViewCell *cell = (PatchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellID];
	if (!cell) {
		cell = [[[PatchTableViewCell alloc] initWithDollarZeroArg:[patch dollarZero] reuseIdentifier:kCellID] autorelease];
	}
	cell.textLabel.text = [NSString stringWithFormat:@"%@ - %d", kTestPatchName, cell.dollarZero];
	return cell;
}
																										
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.patches count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		RLog(@"closing patch with dollar zero: %d", [[self.patches objectAtIndex:indexPath.row] dollarZero]);

		PdFile *patch = [self.patches objectAtIndex:indexPath.row];
		[self.patches removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
	}
}

#pragma mark -
#pragma mark Action Handlers

- (void) openButtonPressed:(id)button {
	RLog(@"opening: %@", kTestPatchName);
	
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	PdFile *patch = [PdFile openFileNamed:kTestPatchName path:bundlePath];
	if (patch) {
		RLog(@"opened patch with $0 = %d", [patch dollarZero]);
		
		[self.patches addObject:patch];
		[self.tableView reloadData];
	} else {
		RLog(@"error: couldn't open patch");
	}
}

#pragma mark -
#pragma mark Testing

// opening many patches on the fly
- (void)testOpeningMany {
	self.patches = [NSMutableArray array];

	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	int numPatches = 20;
	
	for (int i = 0; i < numPatches; i++) {
		PdFile *patch = [PdFile openFileNamed:kTestPatchName path:bundlePath];
		if (patch) {
			RLog(@"opened patch with $0 = %d, iteration %d", [patch dollarZero], i);
			
			[self.patches addObject:patch];
		} else {
			RLog(@"error: couldn't open patch, iteration %d", i);
		}
	}
	RLog(@"reloading table");
	[self.tableView reloadData];
}

@end
