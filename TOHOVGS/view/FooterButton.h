//
//  FooterButton.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <UIKit/UIKit.h>
#import "PushableView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FooterButtonType) {
    FooterButtonTypeHome,
    FooterButtonTypeAll,
    FooterButtonTypeShuffle,
    FooterButtonTypeRetro
};

@class FooterButton;

@protocol FooterButtonDelegate <NSObject>
- (void)footerButton:(FooterButton*)button didTapWithType:(FooterButtonType)type;
@end

@interface FooterButton : PushableView
- (instancetype)initWithType:(FooterButtonType)type delegate:(id<FooterButtonDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
