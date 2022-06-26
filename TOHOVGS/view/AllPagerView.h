//
//  AllPagerView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/06/26.
//

#import <UIKit/UIKit.h>
#import "../ControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AllPagerView : UIView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate;
- (void)requireNextSong:(Song*)song infinity:(BOOL)infinity;
@end

NS_ASSUME_NONNULL_END
