/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "SettingView.h"
#import "PushableView.h"
#import "SliderView.h"
#import "ToggleView.h"

@interface SettingView() <PushableViewDelegate, SliderViewDelegate, PurchaseDelegate, ToggleViewDelegate>
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
@property (nonatomic) UILabel* kobusiLabel;
@property (nonatomic) ToggleView* kobusiSwitch;
@property (nonatomic) UILabel* supportLabel;
@property (nonatomic) PushableView* twitter;
@property (nonatomic) UILabel* twitterLabel;
@property (nonatomic) PushableView* github;
@property (nonatomic) UILabel* githubLabel;
@property (nonatomic) UILabel* infoLabel;
@property (nonatomic) UILabel* appleMusicLabel;
@property (nonatomic) PushableView* appleMusic;
@property (nonatomic) UILabel* removeAdsLabel;
@property (nonatomic) UILabel* removeRewardAdsLabel;
@property (nonatomic) PushableView* removeRewardAds;
@property (nonatomic) UILabel* removeBannerAdsLabel;
@property (nonatomic) PushableView* removeBannerAds;
@property (nonatomic) UILabel* restorePurchasesLabel;
@property (nonatomic) PushableView* restorePurchases;
@property (nonatomic) BOOL initialized;
@property (nonatomic) BOOL alreadyChecked;
@property (nonatomic) NSString* purchaseProductId;
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
        _kobusiLabel = [self _makeHeader:NSLocalizedString(@"kobusi_mode", nil)];
        _kobusiLabel.textColor = [UIColor whiteColor];
        [self addSubview:_kobusiLabel];
        _kobusiSwitch = [[ToggleView alloc] initWithDelegate:self status:[[NSUserDefaults standardUserDefaults] integerForKey:@"compat_kobushi"] ? YES : NO];
        [self addSubview:_kobusiSwitch];
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
        _infoLabel = [self _makeHeader:NSLocalizedString(@"info", nil)];
        [self addSubview:_infoLabel];
        _appleMusic = [[PushableView alloc] initWithDelegate:self];
        _appleMusic.touchAlphaAnimation = YES;
        [self addSubview:_appleMusic];
        _appleMusicLabel = [self _makeButton:NSLocalizedString(@"check_apple_music", nil)];
        [_appleMusic addSubview:_appleMusicLabel];
        _removeAdsLabel = [self _makeHeader:NSLocalizedString(@"remove_ads", nil)];
        [self addSubview:_removeAdsLabel];
        _removeRewardAds = [[PushableView alloc] initWithDelegate:self];
        _removeRewardAds.touchAlphaAnimation = YES;
        [self addSubview:_removeRewardAds];
        _removeRewardAdsLabel = [self _makeButton:[NSString stringWithFormat:NSLocalizedString(@"remove_ads_reward", nil), [_controlDelegate priceWithProductId:PRODUCT_ID_REWARD]]];
        _removeRewardAdsLabel.numberOfLines = 2;
        [_removeRewardAds addSubview:_removeRewardAdsLabel];
        _removeBannerAds = [[PushableView alloc] initWithDelegate:self];
        _removeBannerAds.touchAlphaAnimation = YES;
        [self addSubview:_removeBannerAds];
        _removeBannerAdsLabel = [self _makeButton:[NSString stringWithFormat:NSLocalizedString(@"remove_ads_banner", nil), [_controlDelegate priceWithProductId:PRODUCT_ID_BANNER]]];
        _removeBannerAdsLabel.numberOfLines = 2;
        [_removeBannerAds addSubview:_removeBannerAdsLabel];
        _restorePurchases = [[PushableView alloc] initWithDelegate:self];
        _restorePurchases.touchAlphaAnimation = YES;
        [self addSubview:_restorePurchases];
        _restorePurchasesLabel = [self _makeButton:NSLocalizedString(@"restore_purchases", nil)];
        [_restorePurchases addSubview:_restorePurchasesLabel];
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
    y += 44 + 8;
    _kobusiLabel.frame = CGRectMake(16, y, _kobusiLabel.intrinsicContentSize.width, 44);
    _kobusiSwitch.frame = CGRectMake(frame.size.width - 60, y, 44, 44);
    y += 44 + 32;
    _supportLabel.frame = CGRectMake(8, y, frame.size.width - 16, th);
    y += th + 12;
    _twitter.frame = CGRectMake(8, y, frame.size.width - 16, 44);
    _twitterLabel.frame = CGRectMake(0, 0, frame.size.width - 16, 44);
    y += 44 + 8;
    _github.frame = CGRectMake(8, y, frame.size.width - 16, 44);
    _githubLabel.frame = CGRectMake(0, 0, frame.size.width - 16, 44);
    y += 44 + 32;
    _infoLabel.frame = CGRectMake(8, y, frame.size.width - 16, th);
    y += th + 12;
    _appleMusic.frame = CGRectMake(8, y, frame.size.width - 16, 44);
    _appleMusicLabel.frame = CGRectMake(0, 0, frame.size.width - 16, 44);
    y += 44 + 32;
    _removeAdsLabel.frame = CGRectMake(8, y, frame.size.width - 16, th);
    y += th + 12;
    _removeRewardAds.frame = CGRectMake(8, y, frame.size.width - 16, 52);
    _removeRewardAdsLabel.frame = CGRectMake(0, 0, frame.size.width - 16, 52);
    if ([_controlDelegate isPurchasedWithProductId:PRODUCT_ID_REWARD]) {
        _removeRewardAdsLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _removeRewardAdsLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    }
    y += 52 + 8;
    _removeBannerAds.frame = CGRectMake(8, y, frame.size.width - 16, 52);
    _removeBannerAdsLabel.frame = CGRectMake(0, 0, frame.size.width - 16, 52);
    if ([_controlDelegate isPurchasedWithProductId:PRODUCT_ID_BANNER]) {
        _removeBannerAdsLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _removeBannerAdsLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    }
    y += 52 + 8;
    _restorePurchases.frame = CGRectMake(8, y, frame.size.width - 16, 44);
    _restorePurchasesLabel.frame = CGRectMake(0, 0, frame.size.width - 16, 44);
    if ([_controlDelegate isPurchasedWithProductId:PRODUCT_ID_REWARD] &&
        [_controlDelegate isPurchasedWithProductId:PRODUCT_ID_BANNER]) {
        _restorePurchasesLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
        _restorePurchasesLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    }
    y += 44 + 32;
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
            [weakSelf.controlDelegate stopProgress];
            if (error) {
                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"communication_error", nil), error.code];
                [weakSelf.controlDelegate showErrorMessage:message];
                return;
            }
            weakSelf.alreadyChecked = YES; // ignore next check at the current SettingView
            [weakSelf.settingDelegate didChangeSongListFromSettingView:weakSelf];
            if (!updated || !downloaded) {
                [weakSelf.controlDelegate showInfoMessage:NSLocalizedString(@"list_is_latest", nil)];
                return;
            }
            if (downloaded.count < 1) {
                [weakSelf.controlDelegate showInfoMessage:NSLocalizedString(@"update_list_only", nil)];
                return;
            }
            weakSelf.downloadBadge.hidden = YES;
            [weakSelf.controlDelegate showUpdateSongs:downloaded];
        }];
        return;
    } else if (pushableView == _twitter) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/suzukiplan"]];
    } else if (pushableView == _github) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://suzukiplan.github.io/tohovgs4-ios/"]];
    } else if (pushableView == _appleMusic) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://music.apple.com/jp/artist/1190977068"]];
    } else if (pushableView == _removeRewardAds) {
        [self _confirmPurchase:PRODUCT_ID_REWARD];
        return;
    } else if (pushableView == _removeBannerAds) {
        [self _confirmPurchase:PRODUCT_ID_BANNER];
        return;
    } else if (pushableView == _restorePurchases) {
        if ([_controlDelegate isPurchasedWithProductId:PRODUCT_ID_REWARD] &&
            [_controlDelegate isPurchasedWithProductId:PRODUCT_ID_BANNER]) {
            [_controlDelegate showInfoMessage:NSLocalizedString(@"already_restored", nil)];
        } else {
            [_controlDelegate startProgressWithMessage:NSLocalizedString(@"connecting_appstore", nil)];
            [_controlDelegate restorePurchaseWithPurchaseDelegate:self];
        }
        return;
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

- (void)_confirmPurchase:(NSString*)productId
{
    if ([_controlDelegate isPurchasedWithProductId:productId]) {
        [_controlDelegate showInfoMessage:NSLocalizedString(@"already_purchased", nil)];
        return;
    }
    __weak SettingView* weakSelf = self;
    NSString* title;
    NSString* message;
    BOOL isReward = [productId isEqualToString:PRODUCT_ID_REWARD];
    if (isReward) {
        title = [NSString stringWithFormat:NSLocalizedString(@"remove_ads_reward", nil), [_controlDelegate priceWithProductId:PRODUCT_ID_REWARD]];
        message = NSLocalizedString(@"remove_ads_reward_about", nil);
    } else {
        title = [NSString stringWithFormat:NSLocalizedString(@"remove_ads_banner", nil), [_controlDelegate priceWithProductId:PRODUCT_ID_BANNER]];
        message = NSLocalizedString(@"remove_ads_banner_about", nil);
    }
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"purchase", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf _purchase:productId];
    }];
    [controller addAction:cancel];
    [controller addAction:ok];
    [_controlDelegate presentViewController:controller];
}

- (void)_purchase:(NSString*)productId
{
    NSLog(@"start purchase: %@", productId);
    _purchaseProductId = productId;
    [_controlDelegate startProgressWithMessage:NSLocalizedString(@"connecting_appstore", nil)];
    [_controlDelegate purchaseWithProductId:productId purchaseDelegate:self];
}

- (void)purchaseDidSucceed
{
    [_controlDelegate stopProgress];
}

- (void)purchaseDidFailedWithError:(NSError*)error
{
    [_controlDelegate stopProgress];
    if (error.localizedDescription) {
        [_controlDelegate showErrorMessage:error.localizedDescription];
    }
}

- (void)purchaseDidRestored
{
    [_controlDelegate stopProgress];
}

- (void)toggleView:(ToggleView *)toggleView didChangeStatus:(BOOL)status
{
    if (toggleView == _kobusiSwitch) {
        [[NSUserDefaults standardUserDefaults] setInteger:status? 1 : 0 forKey:@"compat_kobushi"];
    }
}

@end
