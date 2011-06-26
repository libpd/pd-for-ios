//
//  PdArray.m
//  libpd
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

#import "PdArray.h"
#import "PdBase.h"

@interface PdArray ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) float *array;
@property (nonatomic, assign) int size;

@end

@implementation PdArray

@synthesize array = array_;
@synthesize name = name_;
@synthesize size = size_;

#pragma mark -
#pragma mark - Init / Dealloc

+ (id)arrayNamed:(NSString *)arrayName {
  PdArray *pdArray = [[[self alloc] init] autorelease];
  if (pdArray) {
    pdArray.size = [PdBase arraySizeForArrayNamed:arrayName];
    if (pdArray.size <= 0) {
      return nil;
    }
    pdArray.array = calloc(pdArray.size, sizeof(float));
    pdArray.name = arrayName;
    [pdArray read];
  }
  return pdArray;
}

- (void)dealloc {
  free(self.array);
  self.array = nil;
  self.name = nil;
  [super dealloc];
}

#pragma mark -
#pragma mark Public

- (void)read {
  if (self.array) {
		[PdBase copyArrayNamed:self.name withOffset:0 toArray:self.array count:self.size];
  }
}

- (void)write {
  if (self.array) {
		[PdBase copyArray:self.array toArrayNamed:self.name withOffset:0 count:self.size];
  }
}

- (float)floatAtIndex:(int)index {
  [self read]; // TODO: only grab the specific float and put it in the local array. but, nothing uses this yet..
  return [self localFloatAtIndex:index];
}

- (float)localFloatAtIndex:(int)index {
  if (self.array && index >= 0 && index < self.size) {
    return self.array[index];
  } else {
    return 0; // in the spirit of pd's tabread
  }
}

- (void)setFloat:(float)value atIndex:(int)index {
  if ([self setLocalFloat:value atIndex:index]) {
		[PdBase copyArray:(self.array+index) toArrayNamed:self.name withOffset:index count:1];
  }
}

- (BOOL)setLocalFloat:(float)value atIndex:(int)index {
  if (self.array && index >= 0 && index < self.size) {
    self.array[index] = value;
    return YES;
  }
  return NO;
}

@end
