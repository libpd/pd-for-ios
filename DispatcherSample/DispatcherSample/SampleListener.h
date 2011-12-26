//
//  SampleListener.h
//  DispatcherSample
//
//  Copyright (c) 2011 Peter Brinkmann (peter.brinkmann@gmail.com)
//
//  For information on usage and redistribution, and for a DISCLAIMER OF ALL
//  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
//

#import <Foundation/Foundation.h>
#import "PdBase.h"
#import "PdDispatcher.h"

@interface SampleListener : NSObject<PdListener> {
    UILabel *label;
}

- (id)initWithLabel:(UILabel *)label;
@end
