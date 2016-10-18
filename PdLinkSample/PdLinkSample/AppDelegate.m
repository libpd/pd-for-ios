/*
 *  For information on usage and redistribution, and for a DISCLAIMER OF ALL
 *  WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 */

#import "AppDelegate.h"
#import "PdLinkAudioUnit.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    PdLinkAudioUnit *pd_au_;
    PdAudioController *pd_;
    ABLLinkRef linkRef_;
}

@synthesize pd = pd_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    linkRef_ = ABLLinkNew(120);
    pd_au_ = [[PdLinkAudioUnit alloc] initWithLinkRef:linkRef_];
    pd_ = [[PdAudioController alloc] initWithAudioUnit:pd_au_];
    PdAudioStatus status = [pd_ configureAmbientWithSampleRate:44100 numberChannels:2 mixingEnabled:YES];
    if (status == PdAudioOK) {
        NSLog(@"Configured PdAudioController instance.");
    } else {
        NSLog(@"Failed to configure PdAudioController instance.");
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    pd_.active = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    pd_.active = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    ABLLinkDelete(linkRef_);
}

- (ABLLinkRef)getLinkRef {
    return linkRef_;
}

@end
