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

#import "PolyPatchController.h"
#import "PdFile.h"

@interface PolyPatchController ()

@property (nonatomic, copy) NSString *patchName;
@property (nonatomic, retain) NSMutableArray *patches;

@end

@implementation PolyPatchController

@synthesize patchName = patchName_;
@synthesize patches = patches_;

#pragma mark - Init / Dealloc

- (id)init {
	self = [super init];
	if (self) {
		self.patches = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	self.patchName = nil;
	self.patches = nil;
	[super dealloc];
}

#pragma mark - Open / Close Patches

- (void)closePatches {
	self.patches = [NSMutableArray array]; // they will be closed in PdFile's dealloc
}

- (void)openPatchesNamed:(NSString *)name path:(NSString *)path instances:(int)numInstances {
	self.patchName = name;
	for (int i = 0; i < numInstances; i++) {
		[self.patches addObject:[PdFile openFileNamed:name path:path]];
	}
}

- (int)dollarZeroForInstance:(int)instance {
	if (instance >= [self.patches count]) {
		return -1;
	} 
	PdFile *patch = [self.patches objectAtIndex:instance];
	return  [patch dollarZero];
}

@end

