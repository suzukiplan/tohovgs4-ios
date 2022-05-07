/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "../ControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RetroView : UIView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate;
- (void)enterForeground;
- (void)enterBackground;
- (void)destroy;
- (void)savePreferences;
@end

NS_ASSUME_NONNULL_END
