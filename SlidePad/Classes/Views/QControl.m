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

#import "QControl.h"

@interface QControl ()

@end

@implementation QControl

@synthesize valueAction = valueAction_;
@synthesize valueTarget = valueTarget_;
@synthesize fillColor = fillColor_;
@synthesize frameColor = frameColor_;
@synthesize minimumValue = minimumValue_;
@synthesize maximumValue = maximumValue_;
@synthesize value = value_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.fillColor = QCONTROL_DEFAULT_FILL_COLOR;
        self.frameColor = QCONTROL_DEFAULT_FRAME_COLOR;
		self.backgroundColor = [UIColor clearColor];
		
		self.minimumValue = 0.0;
        self.maximumValue = 1.0;
		
    }
    return self;
}

- (void)dealloc {
    self.fillColor = nil;
    self.frameColor = nil;
	[super dealloc];
}

#pragma mark - Public 

- (void) addValueTarget:(id)target action:(SEL)action {
	self.valueTarget = target;
	self.valueAction = action;
}

#pragma mark -
#pragma mark Overridden getters / setters

- (void)setValue:(float)f {
    value_ = f;
    if (self.valueTarget) {
        [self.valueTarget performSelector:self.valueAction withObject:self];
    }
    [self setNeedsDisplay];
}

@end
