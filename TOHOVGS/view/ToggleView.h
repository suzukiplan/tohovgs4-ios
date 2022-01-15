/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "PushableView.h"

NS_ASSUME_NONNULL_BEGIN

@class ToggleView;

@protocol ToggleViewDelegate <NSObject>
- (void)toggleView:(ToggleView*)toggleView didChangeStatus:(BOOL)status;
@end

@interface ToggleView : PushableView
- (instancetype)initWithDelegate:(id<ToggleViewDelegate>)delegate status:(BOOL)status;
@end

NS_ASSUME_NONNULL_END
