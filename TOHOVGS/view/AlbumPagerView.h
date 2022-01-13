//
//  AlbumPagerView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import <UIKit/UIKit.h>
#import "../ControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlbumPagerView : UIView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate;
@end

NS_ASSUME_NONNULL_END
