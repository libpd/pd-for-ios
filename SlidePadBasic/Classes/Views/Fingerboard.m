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

#import "PdBase.h"
#import "Fingerboard.h"
#import "TouchDiamond.h"
#import "PdFile.h"

#define RECEIVER_FREQ @"synth-freq"
#define RECEIVER_MAG @"synth-mag"

#define DEFAULT_SHARP_NOTES_COLOR [UIColor colorWithRed:0.0 green:0.5 blue:0.5 alpha:1.0]
#define DEFAULT_OTHER_NOTES_COLOR [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]

static const CGFloat kThresholdForTouchRelease = 0.0;

@interface Fingerboard ()

@property (nonatomic, retain) TouchDiamond *monoTouch;

- (CGFloat)mapXToPitch:(CGFloat)x; // minPitch mapped to x = 0, maxPitch to x = self.frame.size.width
- (CGFloat)mapYToMag:(CGFloat)y; // y is flipped so the top of the view (origin) = full magnitude, while bottom = 0

- (void)sendParamsOff;
- (void)sendParamsWithPoint:(CGPoint)point;
- (BOOL)pointIsWithinBounds:(CGPoint)point;

@end


@implementation Fingerboard

@synthesize monoTouch = monoTouch_;

@synthesize minPitch = minPitch_;
@synthesize maxPitch = maxPitch_;
@synthesize numNotes = numNotes_;
@synthesize drawNoteLabels = drawNoteLabels_;

@synthesize sharpNoteColor = sharpNoteColor_;

#pragma mark - Setup

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.minPitch = 36.0; 
        self.maxPitch = 60.0;
        self.numNotes = self.maxPitch - self.minPitch;
        
        self.drawNoteLabels = YES;
		self.clipsToBounds = YES;
        self.backgroundColor = DEFAULT_OTHER_NOTES_COLOR;
        self.sharpNoteColor = DEFAULT_SHARP_NOTES_COLOR;
        
        self.layer.borderColor = self.sharpNoteColor.CGColor;
        self.layer.borderWidth = 2.0;
    }
    return self;
}

- (void)dealloc {
    self.monoTouch = nil;
    self.sharpNoteColor = nil;
    [super dealloc];
}

#pragma mark - Public

- (void)mute {
	[self sendParamsOff];
}

- (void)reset {
    if (self.monoTouch) {
        [self.monoTouch removeFromSuperview];
        self.monoTouch = nil;
    }
    [self sendParamsOff];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    float nNotes = self.numNotes;
    float noteWidth = self.frame.size.width / self.numNotes;
    
    // ***** create a layer for sharp notes *****
    CGRect noteRect = CGRectMake(0.0, 0.0, noteWidth, CGRectGetHeight(self.bounds));
    CGLayerRef noteLayer = CGLayerCreateWithContext (context, noteRect.size, NULL);
    CGContextRef noteContext = CGLayerGetContext (noteLayer);
    CGContextSetFillColorWithColor(noteContext, self.sharpNoteColor.CGColor);
    CGContextFillRect(noteContext, noteRect);
    
    // ***** create a layer for line notes (C's and F's).  *****
    CGLayerRef lineLayer = CGLayerCreateWithContext (context, noteRect.size, NULL);
    CGContextRef lineContext = CGLayerGetContext (lineLayer);
    CGContextSetStrokeColorWithColor(lineContext, self.sharpNoteColor.CGColor);
    CGContextBeginPath(lineContext);
    CGContextMoveToPoint(lineContext, 0.0, 0.0);
    CGContextAddLineToPoint(lineContext, 0.0, noteRect.size.height);
    CGContextClosePath(lineContext);
    CGContextStrokePath(lineContext);
    
    
    // ***** set up text for midi number *****

	const float kTextColorGrayLevel = 0.75;
    CGContextSelectFont (context, "Helvetica", 12, kCGEncodingMacRoman);
    CGContextSetRGBFillColor(context, kTextColorGrayLevel, kTextColorGrayLevel, kTextColorGrayLevel, 1.0);
    CGContextSetTextDrawingMode (context, kCGTextFill); 
    CGAffineTransform textFlip = CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(context, textFlip);
    
    
    int nm, ns;
    CGPoint notePoint = CGPointZero;

    for (int n = 0; n < nNotes; n++) {
        ns = n + self.minPitch;
        nm = ns % 12;
        if (nm == 1 || nm == 3 || nm == 6 || nm == 8 || nm == 10) {
			// draw the sharp notes
            notePoint.x = n * noteWidth;
            CGContextDrawLayerAtPoint (context, notePoint, noteLayer);
        }            
        else if (nm == 0 || nm == 5) {
			// draw the lines in between consecutive 'white' keys
            notePoint.x = n * noteWidth;
            CGContextDrawLayerAtPoint (context, notePoint, lineLayer);
        }
        if (self.drawNoteLabels) {
            NSString *noteLabel = [NSString stringWithFormat:@"%d", ns];
            CGContextShowTextAtPoint (context, 
                                      n * noteWidth + 3.0, 
                                      self.bounds.size.height - 4.0,
                                      [noteLabel UTF8String], 
                                      [noteLabel length]); 
        }
    }
}

#pragma mark - Touches

// create a new TouchDiamond and update pd with params from this point
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.monoTouch) {
		[self.monoTouch removeFromSuperview];
	}
	CGPoint point = [[touches anyObject] locationInView:self];
	self.monoTouch = [[[TouchDiamond alloc] init] autorelease];
	self.monoTouch.center = point;
	[self addSubview:self.monoTouch];
	[self.monoTouch displayAnimated];

	[self sendParamsWithPoint:point];
}

// if the point is within this view's bounds, update it's position and pd
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint point = [[touches anyObject] locationInView:self];
	if (![self pointIsWithinBounds:point]) {
		// could remove the monoTouch here, but I chose not to,
		// if it moves far enough out of the view the touchesCancelled
		// will be called
		return;
	}

	self.monoTouch.center = point;
	[self sendParamsWithPoint:point];
}

// remove TouchDiamond and turn off the sound for this voice in pd
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.monoTouch) {
		return;
	}
	[self.monoTouch removeFromSuperview];
	self.monoTouch = nil;
	[self sendParamsOff];
}

// forward to touchesEnded
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    RLog(@"************ touches cancelled ***************");
	[self touchesEnded:touches withEvent:event];
}

#pragma mark - Mapping functions

- (void)sendParamsWithPoint:(CGPoint)point {

	// pitch is related to the x location in view, scaled within min and max Pitch
    float pitch = self.minPitch + (self.maxPitch - self.minPitch) * point.x / CGRectGetWidth(self.frame);

	// mag is related to the inverted y location in view, so loudest (1.0) is on top
    float mag = (CGRectGetHeight(self.frame) - point.y) / CGRectGetHeight(self.frame);
	
    [PdBase sendFloat:mag toReceiver:RECEIVER_MAG];
    [PdBase sendFloat:pitch toReceiver:RECEIVER_FREQ];
}

- (void)sendParamsOff{
	[PdBase sendFloat:0 toReceiver:RECEIVER_MAG];
}

- (CGFloat)mapXToPitch:(CGFloat)x {
    float w = CGRectGetWidth(self.frame);

    float sx = self.minPitch + (self.maxPitch - self.minPitch) * x / w;
    return sx;
}

- (CGFloat)mapYToMag:(CGFloat)y {
    float h = CGRectGetHeight(self.frame);
    return (h - y) / h; 
}

#pragma mark - Private

- (BOOL)pointIsWithinBounds:(CGPoint)point {
	if (point.x < -kThresholdForTouchRelease || point.x > self.bounds.size.width + kThresholdForTouchRelease || 
		point.y < -kThresholdForTouchRelease || point.y > self.bounds.size.height + kThresholdForTouchRelease) {
		return NO;
	} else {
		return YES;
	}
}

@end
