//
//  DispatcherSampleAppDelegate.h
//  DispatcherSample
//
//  Created by Peter Brinkmann on 8/28/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdAudio.h"

@class DispatcherSampleViewController;

@interface DispatcherSampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    DispatcherSampleViewController *viewController;
	PdAudio *pdAudio;
    void *patch;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DispatcherSampleViewController *viewController;

@end


