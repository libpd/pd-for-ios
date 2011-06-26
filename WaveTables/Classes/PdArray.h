//
//  PdArray.h
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

/*  Description:
 *  PdArray is a class to simplify the array read/write API by encapsulating
 *  a local c float array.  One begins by reading the pd array, which mirrors
 *  that array locally and provides methods to write to just the local array,
 *  write to both local and pd's array, and read/write methods for synchronizing
 *  the two arrays.  You get or set floats one at a time and boundaries are checked.
 *  
 *  Writing to only the local array may be useful if you want to update many
 *  elements (i.e. in a for loop) and don't want to incur the synchronization
 *  overhead of PdBase's array accessor methods.
 */

#import <Foundation/Foundation.h>

@interface PdArray : NSObject {
    float *array_;
    NSString *name_;
    int size_;
}

@property (nonatomic, copy, readonly) NSString *name; // the name of the array in pd
@property (nonatomic, assign, readonly) int size;     // size of the pd array

// read the entire contents of a pd array given a name, locally storing the array.
// sets size of local array = maximum length, offset = 0
+ (id)arrayNamed:(NSString *)arrayName;

// (re)read the entire contents of a pd array, provided it was already set with +arrayNamed:
- (void)read;

// write the local array to the pd array
- (void)write;

// retrieve a float from pd's array at the given index.
// returns 0.0 if beyond the boundaries of the array.
- (float)floatAtIndex:(int)index;

// retrieve a float from the local array at the given index.
// returns 0.0 if beyond the boundaries of the array.
- (float)localFloatAtIndex:(int)index;

// set a single float value in both the local array and pd's array
- (void)setFloat:(float)value atIndex:(int)index;

// set a single float value only in the local array. returns NO if it could not set because of bad parameters
- (BOOL)setLocalFloat:(float)value atIndex:(int)index;

@end
