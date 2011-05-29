//
//  WaveTableView.h
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PdArray;

@interface WaveTableView : UIView {
    PdArray *wavetable_;
    UIColor *borderColor_;
    UIColor *arrayColor_;
    
	CGPoint lastPoint_;
    BOOL dragging_;
    
    CGFloat minY_;
    CGFloat maxY_;
}

@property (nonatomic, retain, readonly) PdArray *wavetable;
@property (nonatomic, assign) CGFloat minY; // minimum magnitude to draw in the wavetable (default: -1.0)
@property (nonatomic, assign) CGFloat maxY; // minimum magnitude to draw in the wavetable (default: 1.0)

- (id)initWithWavetable:(PdArray *)pdArray;

@end
