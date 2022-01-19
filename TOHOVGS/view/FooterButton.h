/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "PushableView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FooterButtonType) {
    FooterButtonTypeHome,
    FooterButtonTypeAll,
    FooterButtonTypeShuffle,
    FooterButtonTypeRetro,
    FooterButtonTypeSettings,
};

@class FooterButton;

@protocol FooterButtonDelegate <NSObject>
- (void)footerButton:(FooterButton*)button didTapWithType:(FooterButtonType)type;
@end

@interface FooterButton : PushableView
@property (nonatomic) BOOL budge;
- (instancetype)initWithType:(FooterButtonType)type
                       budge:(BOOL)budge
                    delegate:(id<FooterButtonDelegate>)delegate;
- (instancetype)initWithType:(FooterButtonType)type
                    delegate:(id<FooterButtonDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
