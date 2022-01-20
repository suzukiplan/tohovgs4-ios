//
//  SettingView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/19.
//

#import "SettingView.h"
#import "PushableView.h"
#import "SliderView.h"

@interface SettingView() <PushableViewDelegate, SliderViewDelegate>
@property (nonatomic, weak) id<ControlDelegate> controlDelegate;
@property (nonatomic, weak) id<SettingViewDelegate> settingDelegate;
@property (nonatomic, weak) MusicManager* musicManager;
@property (nonatomic, readonly) NSString* masterVolumeText;
@property (nonatomic) UILabel* contentLabel;
@property (nonatomic) PushableView* download;
@property (nonatomic) UILabel* downloadLabel;
@property (nonatomic) UIImageView* downloadBadge;
@property (nonatomic) UILabel* soundLabel;
@property (nonatomic) NSInteger masterVolume;
@property (nonatomic) UILabel* masterVolumeLabel;
@property (nonatomic) SliderView* masterVolumeSlider;
@property (nonatomic) UILabel* supportLabel;
@property (nonatomic) PushableView* twitter;
@property (nonatomic) UILabel* twitterLabel;
@property (nonatomic) PushableView* github;
@property (nonatomic) UILabel* githubLabel;
@property (nonatomic) BOOL initialized;
@property (nonatomic) BOOL alreadyChecked;
@end

@implementation SettingView

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
                               delegate:(nonnull id<SettingViewDelegate>)delegate
{
    if (self = [super init]) {
        _controlDelegate = controlDelegate;
        _settingDelegate = delegate;
        _musicManager = [_controlDelegate getViewController].musicManager;
        self.backgroundColor = [UIColor blackColor];
        _contentLabel = [self _makeHeader:NSLocalizedString(@"contents", nil)];
        [self addSubview:_contentLabel];
        _download = [[PushableView alloc] initWithDelegate:self];
        _download.touchAlphaAnimation = YES;
        [self addSubview:_download];
        _downloadLabel = [self _makeButton:NSLocalizedString(@"download_latest_songs", nil)];
        [_download addSubview:_downloadLabel];
        _downloadBadge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_badge"]];
        _downloadBadge.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"badge"];
        [_download addSubview:_downloadBadge];
        _soundLabel = [self _makeHeader:NSLocalizedString(@"sound", nil)];
        [self addSubview:_soundLabel];
        _masterVolumeLabel = [self _makeHeader:self.masterVolumeText];
        _masterVolumeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_masterVolumeLabel];
        _masterVolumeSlider = [[SliderView alloc] initWithDelegate:self];
        _masterVolumeSlider.max = 100;
        _masterVolume = _musicManager.masterVolume;
        _masterVolumeSlider.progress = _masterVolume;
        _masterVolumeLabel.text = self.masterVolumeText;
        [self addSubview:_masterVolumeSlider];
        _supportLabel = [self _makeHeader:NSLocalizedString(@"support", nil)];
        [self addSubview:_supportLabel];
        _twitter = [[PushableView alloc] initWithDelegate:self];
        _twitter.touchAlphaAnimation = YES;
        [self addSubview:_twitter];
        _twitterLabel = [self _makeButton:NSLocalizedString(@"support_twitter", nil)];
        [_twitter addSubview:_twitterLabel];
        _github = [[PushableView alloc] initWithDelegate:self];
        _github.touchAlphaAnimation = YES;
        [self addSubview:_github];
        _githubLabel = [self _makeButton:NSLocalizedString(@"support_github", nil)];
        [_github addSubview:_githubLabel];
        _initialized = YES;
    }
    return self;
}

- (NSString*)masterVolumeText
{
    return [NSString stringWithFormat:NSLocalizedString(@"master_volume", nil), _masterVolume];
}

- (UILabel*)_makeHeader:(NSString*)text
{
    UILabel* label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor colorWithRed:0 green:0.6 blue:0.8 alpha:0.9];
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

- (UILabel*)_makeButton:(NSString*)text
{
    UILabel* label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.5];
    label.layer.borderColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.25].CGColor;
    label.layer.borderWidth = 2;
    label.layer.cornerRadius = 4.0;
    label.clipsToBounds = YES;
    return label;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat y = 16;
    CGFloat th = _contentLabel.intrinsicContentSize.height;
    _contentLabel.frame = CGRectMake(8, y, frame.size.width - 16, th);
    y += th + 12;
    _download.frame = CGRectMake(8, y, frame.size.width - 16, 44);
    _downloadLabel.frame = CGRectMake(0, 0, frame.size.width - 16, 44);
    {
        CGFloat dw = _downloadLabel.intrinsicContentSize.width;
        CGFloat dh = _downloadLabel.intrinsicContentSize.height;
        CGFloat dx = (_download.frame.size.width - dw) / 2;
        CGFloat dy = (_download.frame.size.height - dh) / 2;
        _downloadBadge.frame = CGRectMake(dx + dw, dy - 4, 8, 8);
    }
    y += 44 + 32;
    _soundLabel.frame = CGRectMake(8, y, frame.size.width - 16, th);
    y += th + 12;
    _masterVolumeLabel.frame = CGRectMake(16, y, frame.size.width - 32, th);
    y += th + 8;
    _masterVolumeSlider.frame = CGRectMake(24, y, frame.size.width - 48, 44);
    y += 44 + 32;
    _supportLabel.frame = CGRectMake(8, y, frame.size.width - 16, th);
    y += th + 12;
    _twitter.frame = CGRectMake(8, y, frame.size.width - 16, 44);
    _twitterLabel.frame = CGRectMake(0, 0, frame.size.width - 16, 44);
    y += 44 + 8;
    _github.frame = CGRectMake(8, y, frame.size.width - 16, 44);
    _githubLabel.frame = CGRectMake(0, 0, frame.size.width - 16, 44);
    y += 44 + 8;
    self.contentSize = CGSizeMake(frame.size.width, y);
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    NSURL* url = nil;
    if (pushableView == _download) {
        if (_alreadyChecked) {
            [_controlDelegate showInfoMessage:NSLocalizedString(@"list_is_latest", nil)];
            return;
        }
        [_controlDelegate startProgressWithMessage:NSLocalizedString(@"connecting_server", nil)];
        __weak SettingView* weakSelf = self;
        [_musicManager updateSongListWithCallback:^(NSError* error,
                                                    BOOL updated,
                                                    NSArray<Song*>* _Nullable downloaded) {
            [weakSelf.controlDelegate stopProgress:^{
                if (error) {
                    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"communication_error", nil), error.code];
                    [weakSelf.controlDelegate showErrorMessage:message];
                    return;
                }
                weakSelf.alreadyChecked = YES; // ignore next check at the current SettingView
                [weakSelf.settingDelegate didChangeSongListFromSettingView:weakSelf];
                if (!updated || !downloaded || downloaded.count < 1) {
                    [weakSelf.controlDelegate showInfoMessage:NSLocalizedString(@"list_is_latest", nil)];
                    return;
                }
                [weakSelf.controlDelegate showUpdateSongs:downloaded];
            }];
        }];
        return;
    } else if (pushableView == _twitter) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/suzukiplan"]];
    } else if (pushableView == _github) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://suzukiplan.github.io/tohovgs4-ios/"]];
    }
    if (url) {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success){
                                     // nothing to do
                                 }];
    }
}

- (void)sliderView:(SliderView*)sliderView didChangeProgress:(NSInteger)progress max:(NSInteger)max
{
    if (!_initialized) return;
    _masterVolume = progress;
    _masterVolumeLabel.text = self.masterVolumeText;
    _musicManager.masterVolume = _masterVolume;
}

- (void)didStartTouchWithSliderView:(SliderView*)sliderView
{
    [_musicManager playSong:_musicManager.albums[0].songs[0]];
}

- (void)didEndTouchWithSliderView:(SliderView*)sliderView
{
    [_musicManager stopPlaying];
}

@end
