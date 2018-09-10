/*
 *  For information on usage and redistribution, and for a DISCLAIMER OF ALL
 *  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 */

#import "PdLinkAudioUnit.h"
#import "PdBase.h"
#include <AVFoundation/AVFoundation.h>
#include <mach/mach_time.h>

#include "abl_link.c"  // Yes, we want to include the .c file here.

static int kPdBlockSize;

@interface PdLinkAudioUnit () {
@private
    Float64 sampleRate_;
    int numChannels_;
    BOOL usesInput_;
    UInt32 outputLatency_;
    UInt32 tickTime_;
    ABLLinkRef linkRef_;
}

- (void)handleRouteChange:(NSNotification *)notification;
@end

@implementation PdLinkAudioUnit

#pragma mark - Init / Dealloc

+ (void)initialize {
    // Make sure to initialize PdBase before we do anything else.
    kPdBlockSize = [PdBase getBlockSize];
    abl_link_tilde_setup();
}

- (void)handleRouteChange:(NSNotification *)notification {
    NSLog(@"Route changed.");
    // Redoing the configuration will update output latency and related parameters.
    if ([self configureWithSampleRate:sampleRate_ numberChannels:numChannels_ inputEnabled:usesInput_] != 0) {
        NSLog(@"Failed to recreate audio unit on audio route change.");
    }
}

- (id)initWithLinkRef:(ABLLinkRef)linkRef {
    self = [super init];
    linkRef_ = linkRef;
    abl_link_set_link_ref(linkRef);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    return self;
}

#pragma mark - Public Methods

- (void)setActive:(BOOL)active {
    ABLLinkSetActive(linkRef_, active);
    [super setActive:active];
}

- (int)configureWithSampleRate:(Float64)sampleRate numberChannels:(int)numChannels inputEnabled:(BOOL)inputEnabled {
    sampleRate_ = sampleRate;
    numChannels_ = numChannels;
    usesInput_ = inputEnabled;
    mach_timebase_info_data_t timeInfo;
    mach_timebase_info(&timeInfo);
    float secondsToHostTime = (1.0e9 * timeInfo.denom) / (Float64)timeInfo.numer;
    outputLatency_ = (UInt32)(secondsToHostTime * [AVAudioSession sharedInstance].outputLatency);
    tickTime_ = (UInt32)(secondsToHostTime * kPdBlockSize / sampleRate);
    return [super configureWithSampleRate:sampleRate numberChannels:numChannels inputEnabled:inputEnabled];
}

#pragma mark - AURenderCallback

static const AudioUnitElement kInputElement = 1;

static OSStatus AudioRenderCallback(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData) {
    PdLinkAudioUnit *pdAudioUnit = (__bridge PdLinkAudioUnit *)inRefCon;
    Float32 *auBuffer = (Float32 *)ioData->mBuffers[0].mData;
    if (pdAudioUnit->usesInput_) {
        AudioUnitRender([pdAudioUnit audioUnit], ioActionFlags, inTimeStamp, kInputElement, inNumberFrames, ioData);
    }
    
    ABLLinkSessionStateRef session_state = ABLLinkCaptureAudioSessionState(pdAudioUnit->linkRef_);
    abl_link_set_session_state(session_state);
    int ticks = inNumberFrames / kPdBlockSize;
    UInt64 hostTimeAfterTick = inTimeStamp->mHostTime + pdAudioUnit->outputLatency_;
    int bufSizePerTick = kPdBlockSize * pdAudioUnit->numChannels_;
    for (int i = 0; i < ticks; i++) {
        hostTimeAfterTick += pdAudioUnit->tickTime_;
        abl_link_set_time(hostTimeAfterTick);
        [PdBase processFloatWithInputBuffer:auBuffer outputBuffer:auBuffer ticks:1];
        auBuffer += bufSizePerTick;
    }
    ABLLinkCommitAudioSessionState(pdAudioUnit->linkRef_, session_state);

    return noErr;
}

- (AURenderCallback)renderCallback {
    return AudioRenderCallback;
}

@end
