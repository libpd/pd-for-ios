/*
 *  For information on usage and redistribution, and for a DISCLAIMER OF ALL
 *  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 */

#import <UIKit/UIKit.h>
#import "PdAudioController.h"
#include "ABLLink.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PdAudioController *pd;

- (ABLLinkRef)getLinkRef;

@end

