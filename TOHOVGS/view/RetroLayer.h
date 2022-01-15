/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <QuartzCore/QuartzCore.h>
#import "RetroView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RetroLayer : CALayer
@property (nonatomic, weak) RetroView* retroView;
- (void)drawFrame;
@end

NS_ASSUME_NONNULL_END
