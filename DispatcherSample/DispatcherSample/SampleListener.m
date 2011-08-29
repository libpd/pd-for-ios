//
//  SampleListener.m
//  DispatcherSample
//
//  Created by Peter Brinkmann on 8/28/11.
//  Copyright 2011. All rights reserved.
//

#import "SampleListener.h"


@implementation SampleListener

- (id)initWithLabel:(NSString *)s {
    self = [super init];
    if (self) {
        label = s;
        [label retain];
    }
    return self;
}

- (void)dealloc {
    [label release];
    [super dealloc];
}

- (void)receiveBang {
    NSLog(@"Listener %@: bang\n", label);
}

- (void)receiveFloat:(float)val {
    NSLog(@"Listener %@: float %f\n", label, val);
}

- (void)receiveSymbol:(NSString *)s {
    NSLog(@"Listener %@: symbol %@\n", label, s);
}

- (void)receiveList:(NSArray *)v {
    NSLog(@"Listener %@: list %@\n", label, v);
}

- (void)receiveMessage:(NSString *)message withArguments:(NSArray *)arguments {
    NSLog(@"Listener %@: message %@,  %@\n", label, message, arguments);
}

@end
