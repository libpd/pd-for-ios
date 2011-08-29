//
//  SampleListener.h
//  DispatcherSample
//
//  Created by Peter Brinkmann on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdDispatcher.h"

@interface SampleListener : NSObject<PdListener> {
    NSString *label;
}

- (id)initWithLabel:(NSString *)label;
@end
