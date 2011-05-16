//
//  AppDelegate.h
//  WaveTables
//
//  Created by Rich E on 16/05/11.
//  Copyright 2011 Richard T. Eakin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdAudio.h"

@class RootViewController;

@interface WaveTablesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window_;
    RootViewController *viewController_;
    PdAudio *pdAudio_;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;

@end

