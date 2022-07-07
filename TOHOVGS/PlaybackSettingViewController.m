/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */
#import "PlaybackSettingViewController.h"
#import "view/PushableView.h"
#import "view/SliderView.h"
#import "view/ToggleView.h"

@interface PlaybackSettingViewController () <SliderViewDelegate, PushableViewDelegate, ToggleViewDelegate>
@property (nonatomic) BOOL initialized;
@property (nonatomic) NSInteger volume;
@property (nonatomic) NSInteger speed;
@property (nonatomic) UIView* container;
@property (nonatomic) UILabel* titleLabel;
@property (nonatomic) UILabel* volumeLabel;
@property (nonatomic) SliderView* volumeSlider;
@property (nonatomic) UILabel* speedLabel;
@property (nonatomic) SliderView* speedSlider;
@property (nonatomic) UILabel* kobusiLabel;
@property (nonatomic) ToggleView* kobusiSwitch;
@property (nonatomic) PushableView* reset;
@property (nonatomic) UILabel* resetLabel;
@property (nonatomic) PushableView* close;
@property (nonatomic) UILabel* closeLabel;
@end

@implementation PlaybackSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _volume = _musicManager.masterVolume;
    _speed = _musicManager.playbackSpeed;
    _container = [[UIView alloc] init];
    _container.clipsToBounds = YES;
    _container.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    _container.layer.borderColor = [UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:1].CGColor;
    _container.layer.borderWidth = 1;
    _container.layer.cornerRadius = 4.0;
    [self.view addSubview:_container];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = NSLocalizedString(@"sound", nil);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:_titleLabel];
    _volumeLabel = [[UILabel alloc] init];
    _volumeLabel.font = [UIFont systemFontOfSize:12];
    _volumeLabel.textColor = [UIColor whiteColor];
    [self _updateVolumeLabel];
    [_container addSubview:_volumeLabel];
    _volumeSlider = [[SliderView alloc] initWithDelegate:self];
    _volumeSlider.max = 100;
    _volumeSlider.progress = _volume;
    [_container addSubview:_volumeSlider];
    _speedLabel = [[UILabel alloc] init];
    _speedLabel.font = [UIFont systemFontOfSize:12];
    _speedLabel.textColor = [UIColor whiteColor];
    [self _updateSpeedLabel];
    [_container addSubview:_speedLabel];
    _speedSlider = [[SliderView alloc] initWithDelegate:self];
    _speedSlider.max = (200 - 25) / 5;
    _speedSlider.progress = (_speed - 25) / 5;
    [_container addSubview:_speedSlider];
    _kobusiLabel = [[UILabel alloc] init];
    _kobusiLabel.font = [UIFont systemFontOfSize:12];
    _kobusiLabel.textColor = [UIColor whiteColor];
    _kobusiLabel.text = NSLocalizedString(@"kobusi_mode", nil);
    [_container addSubview:_kobusiLabel];
    _kobusiSwitch = [[ToggleView alloc] initWithDelegate:self status:([[NSUserDefaults standardUserDefaults] integerForKey:@"compat_kobushi"] ? YES : NO)];
    [_container addSubview:_kobusiSwitch];
    _reset = [[PushableView alloc] initWithDelegate:self];
    [_container addSubview:_reset];
    _resetLabel = [[UILabel alloc] init];
    _resetLabel.text = NSLocalizedString(@"reset", nil);
    _resetLabel.font = [UIFont boldSystemFontOfSize:12];
    _resetLabel.textColor = [UIColor whiteColor];
    _resetLabel.textAlignment = NSTextAlignmentCenter;
    _resetLabel.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.5];
    _resetLabel.layer.borderColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.25].CGColor;
    _resetLabel.layer.borderWidth = 2;
    _resetLabel.layer.cornerRadius = 4;
    _resetLabel.clipsToBounds = YES;
    [_reset addSubview:_resetLabel];
    _close = [[PushableView alloc] initWithDelegate:self];
    [_container addSubview:_close];
    _closeLabel = [[UILabel alloc] init];
    _closeLabel.text = NSLocalizedString(@"close", nil);
    _closeLabel.font = [UIFont boldSystemFontOfSize:12];
    _closeLabel.textColor = [UIColor whiteColor];
    _closeLabel.textAlignment = NSTextAlignmentCenter;
    _closeLabel.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.5];
    _closeLabel.layer.borderColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.25].CGColor;
    _closeLabel.layer.borderWidth = 2;
    _closeLabel.layer.cornerRadius = 4;
    _closeLabel.clipsToBounds = YES;
    [_close addSubview:_closeLabel];
    [self _resize];
    _initialized = YES;
}

- (void)_updateVolumeLabel
{
    _volumeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"master_volume", nil), _volume];
}

- (void)_updateSpeedLabel
{
    _speedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"playback_speed", nil), _speed / 100, _speed % 100];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.musicManager.masterVolume = _volume;
    self.musicManager.playbackSpeed = _speed;
    [self.delegate playbackSettingViewController:self didCloseWithVolume:_volume speed:_speed];
}

- (void)_resize
{
    CGFloat width = self.view.frame.size.width * 0.8;
    CGFloat height = 348;
    CGFloat x = (self.view.frame.size.width - width) / 2;
    CGFloat y = (self.view.frame.size.height - height) / 2;
    _container.frame = CGRectMake(x, y, width, height);
    _titleLabel.frame = CGRectMake(8, 8, width - 16, 44);
    _volumeLabel.frame = CGRectMake(8, 60, width - 16, 44);
    _volumeSlider.frame = CGRectMake(8, 104, width - 16, 44);
    _speedLabel.frame = CGRectMake(8, 148, width - 16, 44);
    _speedSlider.frame = CGRectMake(8, 192, width - 16, 44);
    _kobusiLabel.frame = CGRectMake(8, 244, width - 60, 44);
    _kobusiSwitch.frame = CGRectMake(width - 52, 244, 44, 44);
    CGFloat w = (width - 24) / 2;
    _reset.frame = CGRectMake(8, 296, w, 44);
    _resetLabel.frame = CGRectMake(0, 0, w, 44);
    _close.frame = CGRectMake(16 + w, 296, w, 44);
    _closeLabel.frame = CGRectMake(0, 0, w, 44);
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    if (pushableView == _close) {
        [self dismissViewControllerAnimated:YES completion:^{
            ;
        }];
    } else if (pushableView == _reset) {
        _volumeSlider.progress = 100;
        _speedSlider.progress = (100 - 25) / 5;
        [_kobusiSwitch changeStatus:NO];
    }
}

- (void)didStartTouchWithSliderView:(SliderView*)sliderView
{
    
}

- (void)didEndTouchWithSliderView:(SliderView*)sliderView
{
}

- (void)sliderView:(SliderView*)sliderView didChangeProgress:(NSInteger)progress max:(NSInteger)max
{
    if (!_initialized) return;
    if (sliderView == _volumeSlider) {
        self.volume = progress;
        [self _updateVolumeLabel];
    } else if (sliderView == _speedSlider) {
        self.speed = progress * 5 + 25;
        [self _updateSpeedLabel];
    }
}

- (void)toggleView:(ToggleView*)toggleView didChangeStatus:(BOOL)status
{
    if (toggleView == _kobusiSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:status forKey:@"compat_kobushi"];
    }
}

@end
