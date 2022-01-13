//
//  FooterView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <UIKit/UIKit.h>
#import "FooterButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface FooterView : UIView
- (instancetype)initWithDelegate:(id<FooterButtonDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
