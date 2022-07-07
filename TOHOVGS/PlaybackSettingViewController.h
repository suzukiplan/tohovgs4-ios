/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import <UIKit/UIKit.h>
#import "api/MusicManager.h"

NS_ASSUME_NONNULL_BEGIN

@class PlaybackSettingViewController;

@protocol PlaybackSettingViewControllerDelegate <NSObject>
- (void)playbackSettingViewController:(PlaybackSettingViewController*)viewController
                   didCloseWithVolume:(NSInteger)volume
                                speed:(NSInteger)speed;
@end

@interface PlaybackSettingViewController : UIViewController
@property (nonatomic, weak) id<PlaybackSettingViewControllerDelegate> delegate;
@property (nonatomic, weak) MusicManager* musicManager;
@end

NS_ASSUME_NONNULL_END
