//
//  SeekBarView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import "SeekBarView.h"
#import "SliderView.h"
#import "ToggleView.h"

@interface SeekBarView() <SliderViewDelegate, ToggleViewDelegate>
@property (nonatomic) UILabel* progressLabel;
@property (nonatomic) UILabel* leftLabel;
@property (nonatomic) SliderView* slider;
@property (nonatomic) UIView* border;
@property (nonatomic) UILabel* inifinityLabel;
@property (nonatomic) ToggleView* infinitySwitch;
@property (nonatomic) BOOL isDragging;
@end

@implementation SeekBarView

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.5];
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
        _progressLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.text = @"00:00";
        [self addSubview:_progressLabel];
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
        _leftLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        _leftLabel.textAlignment = NSTextAlignmentCenter;
        _leftLabel.text = @"00:00";
        [self addSubview:_leftLabel];
        _slider = [[SliderView alloc] initWithDelegate:self];
        [self addSubview:_slider];
        _border = [[UIView alloc] init];
        _border.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        [self addSubview:_border];
        _inifinityLabel = [[UILabel alloc] init];
        _inifinityLabel.font = [UIFont systemFontOfSize:12];
        _inifinityLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        _inifinityLabel.textAlignment = NSTextAlignmentCenter;
        _inifinityLabel.text = @"∞";
        [self addSubview:_inifinityLabel];
        _infinitySwitch = [[ToggleView alloc] initWithDelegate:self status:NO];
        [self addSubview:_infinitySwitch];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    const CGFloat timeLableWidth = 48;
    const CGFloat switchWidth = 44;
    const CGFloat switchLabelWidth = 16;
    const CGFloat margin = 4;
    const CGFloat sliderWidth = frame.size.width - timeLableWidth * 2 - 1 - switchLabelWidth - switchWidth - 1 - margin * 4;
    CGFloat x = margin;
    const CGFloat height = frame.size.height - margin * 2;
    _progressLabel.frame = CGRectMake(x, margin, timeLableWidth, height);
    x += timeLableWidth;
    _slider.frame = CGRectMake(x + margin, margin, sliderWidth - margin * 2, height);
    x += sliderWidth;
    _leftLabel.frame = CGRectMake(x, margin, timeLableWidth, height);
    x += timeLableWidth + margin;
    _border.frame = CGRectMake(x, 1, 1, frame.size.height - 1);
    x += 1 + margin;
    _inifinityLabel.frame = CGRectMake(x, margin, switchLabelWidth, height);
    x += switchLabelWidth;
    _infinitySwitch.frame = CGRectMake(x, margin, switchWidth, height);
}

- (void)didStartTouchWithSliderView:(SliderView*)sliderView
{
    _isDragging = YES;
}

- (void)didEndTouchWithSliderView:(SliderView*)sliderView
{
    _isDragging = NO;
    [_delegate seekBarView:self didRequestSeekTo:sliderView.progress];
}

- (void)sliderView:(SliderView*)sliderView didChangeProgress:(NSInteger)progress max:(NSInteger)max
{
    NSInteger sec = progress / 22050;
    _progressLabel.text = [self _timeFromValue:sec];
    _leftLabel.text = [self _timeFromValue:max / 22050 - sec];
}

- (NSString*)_timeFromValue:(NSInteger)sec
{
    return [NSString stringWithFormat:@"%02ld:%02ld", sec / 60, sec % 60];
}

- (void)toggleView:(ToggleView*)toggleView didChangeStatus:(BOOL)status
{
    [_delegate seekBarView:self didChangeInfinity:status];
}

- (void)setMax:(NSInteger)max
{
    _slider.max = max;
}

- (void)setProgress:(NSInteger)progress
{
    if (!_isDragging) {
        _slider.progress = progress;
    }
}

@end
