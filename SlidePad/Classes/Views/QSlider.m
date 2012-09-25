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

#import "QSlider.h"

static const CGFloat kThresholdForTouchRelease = 50.0;

@interface QSlider ()

- (BOOL)pointIsWithinBounds:(CGPoint)point;
- (void)mapPointToValue:(CGPoint)point;
- (void)drawRoundedRectFrame:(CGContextRef)context;

@end

@implementation QSlider

@synthesize orientation = orientation_;

#pragma mark - Init / Dealloc

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.fillColor = QCONTROL_DEFAULT_FILL_COLOR;
        self.frameColor = QCONTROL_DEFAULT_FRAME_COLOR;
        self.orientation = RQSliderOrientationHorizontal;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.frameColor.CGColor);
    
    CGRect frame = self.bounds;

    float pos = ((self.value - self.minimumValue) * frame.size.width) / (self.maximumValue - self.minimumValue);

    // Draw filled region
    CGRect fillRect = CGRectMake(1.0, 1.0, pos, frame.size.height - 1.0);
    CGContextSetLineWidth(context, 1.0);

    CGContextAddRect(context, fillRect);
    CGContextFillPath(context);
    
    CGContextSetLineWidth(context, 6.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, pos, frame.origin.y + 4);
    CGContextAddLineToPoint(context, pos, frame.size.height - 4);
    CGContextStrokePath(context);
    
    CGContextSetLineWidth(context, 2.0);
    [self drawRoundedRectFrame:context];
}

- (void)drawRoundedRectFrame:(CGContextRef)context {
    CGRect rrect = self.bounds; 
    CGFloat radius = 8.0; 
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect); 
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect); 
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context); 
    CGContextStrokePath(context);
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
	
    [self mapPointToValue:pos];
    [self setNeedsDisplay]; // TODO: the drawing commands in drawRect don't get erased by this command only
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
	if ([self pointIsWithinBounds:pos]) {
		[self mapPointToValue:pos];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

#pragma mark - Mapping

- (void) mapPointToValue: (CGPoint)point {
	
    float length, x, val;
    if (self.orientation == RQSliderOrientationHorizontal) {
        if (point.x < 0.0) {
            val = self.minimumValue;
        } else if (point.x > self.bounds.size.width) {
            val = self.maximumValue;
        } else {
            val =  self.minimumValue + (point.x * (self.maximumValue - self.minimumValue)) / self.bounds.size.width;
            self.value = val;
        }
    } else {
        if (point.y < 0.0) {
            val = self.minimumValue;
        } else if (point.y > self.bounds.size.height) {
            val = self.maximumValue;
        } else {
            val =  self.minimumValue + (point.y * (self.maximumValue - self.minimumValue)) / self.bounds.size.height;
        }
    }
}

- (BOOL)pointIsWithinBounds:(CGPoint)point {
	if (point.x < -kThresholdForTouchRelease || point.x > self.bounds.size.width + kThresholdForTouchRelease || 
		point.y < -kThresholdForTouchRelease || point.y > self.bounds.size.height + kThresholdForTouchRelease) {
		return NO;
	} else {
		return YES;
	}
}

@end
