//
//  SettingView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/19.
//

#import <UIKit/UIKit.h>
#import "../ControlDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class SettingView;

@protocol SettingViewDelegate <NSObject>
- (void)didChangeSongListFromSettingView:(SettingView*)view;
@end

@interface SettingView : UIScrollView
- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                               delegate:(id<SettingViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
