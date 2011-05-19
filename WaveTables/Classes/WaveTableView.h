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
    
    int lastX_;
    float lastY_;
    BOOL dragging_;
}

- (id)initWithWavetable:(PdArray *)pdArray;

@end
