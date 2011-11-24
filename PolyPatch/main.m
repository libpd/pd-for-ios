//
//  main.m
//  PolyPatch
//

#import <UIKit/UIKit.h>
#import "PolyPatchAppDelegate.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([PolyPatchAppDelegate class]));
    [pool release];
    return retVal;
}
