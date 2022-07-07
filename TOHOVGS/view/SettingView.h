/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "../ControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class SettingView;

@protocol SettingViewDelegate <NSObject>
- (void)didChangeSongListFromSettingView:(SettingView*)view;
- (void)settingView:(SettingView*)view didChangedSpeed:(NSInteger)speed;
@end

@interface SettingView : UIScrollView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                               delegate:(id<SettingViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
