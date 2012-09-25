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

#import "QRadioDial.h"

static const CGFloat kEdgeSpacer = 6.0;

static const CGFloat kPiOverTwo = 1.5707963267948966;
static const CGFloat kTwoPi = 6.283185307179586;

@interface QRadioDial ()

@property (nonatomic, retain) UILabel *valueLabel;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) CGFloat outerRadius;
@property (nonatomic, assign) CGFloat innerRadius;

- (void)mapPointToValue:(CGPoint)point;

@end

@implementation QRadioDial

@synthesize valueLabel = valueLabel_;
@synthesize numSections = numSections_;
@synthesize section = section_;
@synthesize outerRadius = outerRadius_;
@synthesize innerRadius = innerRadius_;

#pragma mark - Init / Dealloc

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.valueLabel = [[[UILabel alloc] init] autorelease];
		self.valueLabel.backgroundColor = [UIColor clearColor];
		self.valueLabel.textColor = self.frameColor;
        self.valueLabel.textAlignment = UITextAlignmentCenter;
        self.valueLabel.text = [NSString stringWithFormat:@"0"]; // this is what self.value starts at
		[self addSubview:self.valueLabel];
        
        self.numSections = 4;
        self.value = NSIntegerMin; // if value == 0 is initially passed in, we still want it to be considered, so set value_ to something else
	}
    return self;
}

- (void) dealloc {
	self.valueLabel = nil;
	[super dealloc];
}

#pragma mark - View Methods

- (void)layoutSubviews {
	[super layoutSubviews];
    CGSize viewSize = self.frame.size;
    
    self.outerRadius = (viewSize.width < viewSize.height ? viewSize.width / 2.0 : viewSize.height / 2.0);
	self.innerRadius = self.outerRadius / 3.0;

    self.valueLabel.frame = CGRectIntegral(CGRectMake((viewSize.width - self.innerRadius) / 2.0,
                                                      (viewSize.height - self.innerRadius) / 2.0,
                                                      self.innerRadius,
                                                        self.innerRadius));
    self.valueLabel.font = [UIFont boldSystemFontOfSize:30]; // TODO: size this according to innerRadious size
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGRect frame = self.bounds;
    CGFloat radius = self.outerRadius;
    CGFloat innerRadius = self.innerRadius;
    float pos = ((self.value - self.minimumValue) * frame.size.width) / (self.maximumValue - self.minimumValue);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.frameColor.CGColor);
    CGContextSetLineWidth(context, 2.0);
    
    // Draw Inner and Outer circle frames
	CGContextAddArc(context, radius, radius, innerRadius, 0, kTwoPi, 1);
    CGContextStrokePath(context);

	CGContextAddArc(context, radius, radius, radius - 1.0, 0, kTwoPi, 1);
    CGContextStrokePath(context);
	
	// Draw the selected section
    CGFloat sectionRadians = kTwoPi / self.numSections;
	CGFloat angleA = self.section * sectionRadians + kPiOverTwo;
	CGFloat angleB = angleA + sectionRadians;
	CGContextAddArc(context, radius, radius, radius - kEdgeSpacer, angleA, angleB, 0); // outer arc
	CGContextAddArc(context, radius, radius, innerRadius + kEdgeSpacer, angleB, angleA, -1); // inner arc
	CGContextFillPath(context);
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    [self mapPointToValue:pos];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    [self mapPointToValue:pos];
    [self setNeedsDisplay];
}

#pragma mark - Mapping

// TODO: check if point is within the middle circle, if yes then don't update
- (void)mapPointToValue:(CGPoint)point {
    CGSize viewSize = self.bounds.size;

    // first convert to a point ranging from 1:1 in x and y, where point = (0,0) is the center
    // Then I switch y and x, and also flip y, so that the 0 quadrant is mapped to the bottom left.
    float y = 1.0 - (point.x * 2.0 / viewSize.width);
    float x = (point.y * 2.0 / viewSize.height) - 1.0;

    CGFloat sectionRadians = kTwoPi / self.numSections;
    float theta = atan2(y, x);
    if (theta < 0) {
        theta += kTwoPi; 
    }
    self.section =  (int)(theta / sectionRadians);
    
    CGFloat valuePerSection = (self.maximumValue - self.minimumValue) / (self.numSections - 1);
    self.value = valuePerSection * self.section + self.minimumValue;

}

#pragma mark - Overridden Getters / Setters

- (void)setValue:(float)f {
    if (fabs(self.value - f) > 0.0001) {
		[super setValue:f];
        self.valueLabel.text = [NSString stringWithFormat:@"%d", (int)f];
        self.section = (int)(f - self.minimumValue) * (self.numSections - 1) / (self.maximumValue - self.minimumValue);
        
        [self.valueLabel setNeedsDisplay];
        [self setNeedsDisplay];
        
        if (self.valueTarget && self.valueAction) {
            [self.valueTarget performSelector:self.valueAction withObject:self];
        }
    }
}

@end
