/*
 *  For information on usage and redistribution, and for a DISCLAIMER OF ALL
 *  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 */

#import "PdAudioUnit.h"

#include "ABLLink.h"

@interface PdLinkAudioUnit : PdAudioUnit

+ (void)initialize;
- (id)initWithLinkRef:(ABLLinkRef)linkRef;

@end
