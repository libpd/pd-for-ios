//
//  RootViewController.h
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdBase.h"

@class PdFile;
@class WaveTableView;

@interface RootViewController : UIViewController <PdReceiverDelegate> {
    PdFile *patch_;
    WaveTableView *waveTableView_;
	UIToolbar *toolBar_;
}

@end

