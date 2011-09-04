//
//  SampleListener.m
//  DispatcherSample
//
//  Copyright (c) 2011 Peter Brinkmann (peter.brinkmann@gmail.com)
//
//  For information on usage and redistribution, and for a DISCLAIMER OF ALL
//  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
//

#import "SampleListener.h"


@implementation SampleListener

- (id)initWithLabel:(UILabel *)s {
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
    NSString *s = [NSString stringWithFormat:@"%f", val];
    [label performSelectorOnMainThread:@selector(setText:) withObject:s waitUntilDone:NO];
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
