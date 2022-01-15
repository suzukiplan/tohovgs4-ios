//
//  RetroView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <UIKit/UIKit.h>
#import "../ControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface RetroView : UIView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate;
- (void)destroy;
@end

NS_ASSUME_NONNULL_END
