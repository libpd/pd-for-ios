//
//  WaveTableView.m
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

#import "WaveTableView.h"
#import "PdArray.h"
#import <QuartzCore/QuartzCore.h>

@interface WaveTableView ()

@property (nonatomic, retain) PdArray *wavetable;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, retain) UIColor *arrayColor;
@property (nonatomic, assign) int lastX; // the last [x,y] set written to the PdArray *wavetable (used for interpolation)
@property (nonatomic, assign) float lastY; // the last [x,y] set written to the PdArray *wavetable (used for interpolation)
@property (nonatomic, assign) BOOL dragging; // indicates whether the user is currently dragging a finder across the device

- (void)updateArrayWithPoint:(CGPoint)point;

@end

@implementation WaveTableView

@synthesize wavetable = wavetable_;
@synthesize borderColor = borderColor_;
@synthesize arrayColor = arrayColor_;
@synthesize lastX = lastX_;
@synthesize lastY = lastY_;
@synthesize dragging = dragging_;

#pragma mark -
#pragma mark Init / Dealloc

- (id)initWithWavetable:(PdArray *)pdArray {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.borderColor = [UIColor darkGrayColor];
        self.layer.borderColor = self.borderColor.CGColor;
        self.layer.borderWidth = 1.0;
        
        self.arrayColor = [UIColor blackColor];
        
        self.wavetable = pdArray;
        
        self.lastX = -1; // set so any new point will not be the same as the last
    }
    return self;
}

- (void)dealloc {
    self.wavetable = nil;
    self.borderColor = nil;
    self.arrayColor = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
//    DLog(@"bounds: %@, rect: %@", NSStringFromCGRect(bounds), NSStringFromCGRect(rect));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0); // TODO: verify it is on an even pixel

    // draw wavetable
    if (self.wavetable) {
        CGContextSetStrokeColorWithColor(context, [self.arrayColor CGColor]);
        
        CGFloat scaleX = bounds.size.width / self.wavetable.length; // the wavetable spans the entire view
        CGFloat scaleY = bounds.size.height * 0.5; // values in the array are normalized to 1.0
        
        // TODO: only draw in updated rect
        CGContextMoveToPoint(context, 0.0, [self.wavetable floatAtIndex:0] * scaleY);
        for (int i = 0; i < self.wavetable.length; i++) {
            CGFloat y = (1 - [self.wavetable floatAtIndex:i]) * scaleY;
            CGContextAddLineToPoint(context, i * scaleX, y);
//            DLog(@"drawing point at: %f, %f", i * scaleX, y);
        }
        CGContextStrokePath(context);
    }
}

#pragma mark -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.dragging = NO;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self updateArrayWithPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.dragging = YES;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if([self hitTest:point withEvent:event] == self) {
        [self updateArrayWithPoint:point];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.dragging = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.dragging = NO;
}

#pragma mark -
#pragma mark Private

- (void)updateArrayWithPoint:(CGPoint)point {
    int index = (int) (point.x * (float)self.wavetable.length / self.bounds.size.width);
    if(self.lastX != index) {
        float value = (point.y * -2.0 / self.bounds.size.height) + 1.0;
        int numPoints = abs(self.lastX - index);
        if (self.dragging && numPoints > 1) {
            //draw a line from lastPoint.x to point.x and feed it to self.wavetable
            float incr = (self.lastY - value) / (float)(self.lastX - index);
            int currentIndex = self.lastX;
            if (index > self.lastX) { // going forward
                for (int i = 0; i < numPoints; i++) {
                    currentIndex++;
                    self.lastY += incr;
                    [self.wavetable setFloat:self.lastY atIndex:currentIndex];
                }
            } else {
                for (int i = 0; i < numPoints; i++) {
                    currentIndex--;
                    self.lastY -= incr;
                    [self.wavetable setFloat:self.lastY atIndex:currentIndex];
                }
            }
        } else {
            // no need to interpolate so just draw one point and store the last calculated value
            [self.wavetable setFloat:value atIndex:index];
            self.lastY = value;
        }
        
        [self setNeedsDisplay];
    }
    self.lastX = index; // store the last index so that we can smoothly begin no matter where the next touched point is
}

@end
