/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <AVFoundation/AVFoundation.h>
#import "AdSettings.h"
#import "AppDelegate.h"
#import "vgs/vgsplay-ios.h"
@import Firebase;
@import GoogleMobileAds;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ ADS_TEST_DEVICE_IDENTIFIERS,
                                                                                GADSimulatorID];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    NSError* error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                            mode:AVAudioSessionModeMoviePlayback
                                         options:AVAudioSessionCategoryOptionMixWithOthers
                                           error:&error];
    if (error) {
        NSLog(@"cannot set audio session category: %@", error);
    }
    return YES;
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    vgsplay_stop();
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
