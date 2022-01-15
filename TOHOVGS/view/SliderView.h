/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>
#import "PushableView.h"

NS_ASSUME_NONNULL_BEGIN

@class SliderView;

@protocol SliderViewDelegate <NSObject>
- (void)didStartTouchWithSliderView:(SliderView*)sliderView;
- (void)didEndTouchWithSliderView:(SliderView*)sliderView;
- (void)sliderView:(SliderView*)sliderView didChangeProgress:(NSInteger)progress max:(NSInteger)max;
@end

@interface SliderView : PushableView
@property (nonatomic) NSInteger progress;
@property (nonatomic) NSInteger max;
- (instancetype)initWithDelegate:(id<SliderViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
