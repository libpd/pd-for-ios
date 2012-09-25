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

#import <UIKit/UIKit.h>

@class PolyPatchController;

@interface Fingerboard : UIView

@property (nonatomic, assign) float minPitch;
@property (nonatomic, assign) float maxPitch;
@property (nonatomic, assign) float numNotes;
@property (nonatomic, assign) NSInteger numVoices;
@property (nonatomic, assign) BOOL drawNoteLabels;
@property (nonatomic, assign) BOOL quantizePitch;

@property (nonatomic, retain) UIColor *sharpNoteColor;
@property (nonatomic, retain) UIColor *touchColor;

@property (nonatomic, assign) PolyPatchController *polyPatchController; // weak reference to the pd patch controller

- (void)updateAllVoices; // resends audio params to Pd
- (void)mute; // turn off all voices
- (void)reset; // last resort reset method

@end
