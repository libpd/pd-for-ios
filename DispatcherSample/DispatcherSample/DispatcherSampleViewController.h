//
//  DispatcherSampleViewController.h
//  DispatcherSample
//
//  Copyright (c) 2011 Peter Brinkmann (peter.brinkmann@gmail.com)
//
//  For information on usage and redistribution, and for a DISCLAIMER OF ALL
//  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
//

#import <UIKit/UIKit.h>
#import "PdDispatcher.h"

@interface DispatcherSampleViewController : UIViewController {
    UILabel *fooLabel;
    UILabel *barLabel;
}

@property(nonatomic, retain) IBOutlet UILabel *fooLabel;
@property(nonatomic, retain) IBOutlet UILabel *barLabel;

-(void)pdSetup;

@end
