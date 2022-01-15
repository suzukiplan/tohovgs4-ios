/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "FooterButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface FooterView : UIView
- (instancetype)initWithDelegate:(id<FooterButtonDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
