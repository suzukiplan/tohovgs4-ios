//
//  SliderView.h
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import <UIKit/UIKit.h>
#import "PushableView.h"

NS_ASSUME_NONNULL_BEGIN

@class SliderView;

@protocol SliderViewDelegate <NSObject>
- (void)didStartTouchWithSliderView:(SliderView*)sliderView;
- (void)didEndTouchWithSliderView:(SliderView*)sliderView;
- (void)sliderView:(SliderView*)sliderView didChangeProgress:(NSInteger)progress;
@end

@interface SliderView : PushableView
@property (nonatomic) NSInteger progress;
@property (nonatomic) NSInteger max;
- (instancetype)initWithDelegate:(id<SliderViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
