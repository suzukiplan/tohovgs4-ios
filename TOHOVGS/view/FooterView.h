/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "FooterButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface FooterView : UIView
@property (nonatomic) BOOL badge;
- (instancetype)initWithDelegate:(id<FooterButtonDelegate>)delegate;
- (void)moveToType:(FooterButtonType)type;
@end

NS_ASSUME_NONNULL_END
