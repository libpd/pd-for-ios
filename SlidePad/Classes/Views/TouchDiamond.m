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

#import "TouchDiamond.h"

#define DIAMOND_WIDTH 40.0
#define DIAMOND_HEIGHT 100.0

@implementation TouchDiamond

@synthesize touchIndex = touchIndex_;

- (id)initWithIndex:(NSInteger)touchIndex {
    [self init];
    self.touchIndex = touchIndex;
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0.0, 0.0, DIAMOND_WIDTH * 0.8, DIAMOND_HEIGHT * 0.4)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)displayAnimated {
	[UIView animateWithDuration:0.2
						  delay:0.0
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 self.bounds = CGRectMake(0.0, 0.0, DIAMOND_WIDTH, DIAMOND_HEIGHT);
					 } completion:nil];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(c, 1.0, 0.3, 0.0, 0.5);
    CGContextSetRGBStrokeColor(c, 1.0, 0.0, 0.0, 0.75);
    CGContextSetLineWidth(c, 1.0);
    
    float midx = CGRectGetMidX(self.bounds);
    float midy = CGRectGetMidY(self.bounds);
    float maxx = CGRectGetWidth(self.bounds);
    float maxy = CGRectGetHeight(self.bounds);
    
    CGPoint diamond[8] = {
		CGPointMake(0.0, midy), CGPointMake(midx, maxy ),
        CGPointMake(midx, maxy), CGPointMake(maxx, midy),
        CGPointMake(maxx, midy), CGPointMake(midx, 0.0),
        CGPointMake(midx, 0.0), CGPointMake(0.0, midy)
	};
    
    CGContextAddLines(c, diamond, 8);
    CGContextDrawPath(c, kCGPathFillStroke);
}


@end
