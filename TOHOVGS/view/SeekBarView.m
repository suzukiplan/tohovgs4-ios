/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "SeekBarView.h"
#import "SliderView.h"
#import "ToggleView.h"

@interface SeekBarView() <SliderViewDelegate, ToggleViewDelegate, PushableViewDelegate>
@property (nonatomic) UILabel* progressLabel;
@property (nonatomic) PushableView* speedButton;
@property (nonatomic) UILabel* speedLabel;
@property (nonatomic) NSInteger speed;
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
        _speed = [[NSUserDefaults standardUserDefaults] integerForKey:@"playback_speed"];
        if (_speed < 1) _speed = 100;
        _speedButton = [[PushableView alloc] initWithDelegate:self];
        _speedButton.tapBoundAnimation = YES;
        [self addSubview:_speedButton];
        _speedLabel = [[UILabel alloc] init];
        _speedLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
        _speedLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
        _speedLabel.textAlignment = NSTextAlignmentCenter;
        [self _updateSpeedText];
        [_speedButton addSubview:_speedLabel];
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

- (void)_updateSpeedText
{
    _speedLabel.text = [NSString stringWithFormat:@"x%ld.%02ld", _speed / 100, _speed % 100];
}

- (void)updateSpeed:(NSInteger)speed
{
    _speed = speed;
    [self _updateSpeedText];
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
    _speedButton.frame = CGRectMake(x, margin, timeLableWidth, height);
    _speedLabel.frame = CGRectMake(0, 0, timeLableWidth, height);
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

- (void)didPushPushableView:(PushableView*)pushableView
{
    if (pushableView == _speedButton) {
        [_delegate seekBarview:self didRequestChangeSpeedFrom:_speed];
    }
}

@end
