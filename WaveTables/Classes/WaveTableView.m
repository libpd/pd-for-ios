//
//  WaveTableView.m
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

#import "WaveTableView.h"
#import "PdArray.h"

@interface WaveTableView ()

@property (nonatomic, retain) PdArray *wavetable;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, retain) UIColor *arrayColor;

@end

@implementation WaveTableView

@synthesize wavetable = wavetable_;
@synthesize borderColor = borderColor_;
@synthesize arrayColor = arrayColor_;

- (id)initWithWavetable:(PdArray *)pdArray {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.borderColor = [UIColor darkGrayColor];
        self.arrayColor = [UIColor blackColor];
        
        self.wavetable = pdArray;
    }
    return self;
}

- (void)dealloc {
    self.wavetable = nil;
    self.borderColor = nil;
    self.arrayColor = nil;
    [super dealloc];
}


- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0); // TODO: verify it is on an even pixel

    // draw border
	CGContextSetStrokeColorWithColor(context, [self.borderColor CGColor]);
    CGContextAddRect(context, bounds);

    // draw 0 crossing line
    CGFloat zeroCrossingY = round(bounds.size.height * 0.5);
    CGContextMoveToPoint(context, 0.0, zeroCrossingY);
    CGContextAddLineToPoint(context, bounds.size.width, zeroCrossingY);
    
    CGContextStrokePath(context);
    
    // draw wavetable
    if (self.wavetable) {
        CGContextSetStrokeColorWithColor(context, [self.arrayColor CGColor]);
        
        CGFloat scaleX = self.bounds.size.width / self.wavetable.size; // the wavetable spans the entire view
        CGFloat scaleY = self.bounds.size.height * 0.5; // values in the array are normalized to 1.0
        
        CGContextMoveToPoint(context, 0.0, [self.wavetable floatAtIndex:0] * scaleY);
        for (int i = 0; i < self.wavetable.size; i++) {
            CGFloat y = ([self.wavetable floatAtIndex:i] + 1.0) * scaleY;
            CGContextAddLineToPoint(context, i * scaleX, y);
        }
        CGContextStrokePath(context);
    }
}


@end
