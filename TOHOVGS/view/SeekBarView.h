/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SeekBarView;

@protocol SeekBarViewDelegate <NSObject>
- (void)seekBarView:(SeekBarView*)seek didRequestSeekTo:(NSInteger)progress;
- (void)seekBarView:(SeekBarView*)seek didChangeInfinity:(BOOL)infinity;
- (void)seekBarview:(SeekBarView*)seek didRequestChangeSpeedFrom:(NSInteger)speed;
@end

@interface SeekBarView : UIView
@property (nonatomic, weak) id<SeekBarViewDelegate> delegate;
@property (nonatomic) NSInteger max;
@property (nonatomic) NSInteger progress;
- (void)updateSpeed:(NSInteger)speed;
@end

NS_ASSUME_NONNULL_END
