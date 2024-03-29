/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "view/SeekBarView.h"
#import "view/FooterView.h"
#import "view/AlbumPagerView.h"
#import "view/AllPagerView.h"
#import "view/SongListView.h"
#import "view/RetroView.h"
#import "view/ProgressView.h"
#import "view/SettingView.h"
#import "vgs/vgsplay-ios.h"
#import "SongListViewController.h"
#import "PlaybackSettingViewController.h"
#import "ControlDelegate.h"
#include "AdSettings.h"
@import GoogleMobileAds;
@import AdSupport;
@import AppTrackingTransparency;

#define AD_HEIGHT 56
#define FOOTER_HEIGHT 56
#define SEEKBAR_HEIGHT 48

@interface ViewController () <FooterButtonDelegate, ControlDelegate, MusicManagerDelegate, SeekBarViewDelegate, GADFullScreenContentDelegate, GADBannerViewDelegate, SettingViewDelegate, SongListViewControllerDelegate, ProductManagerDelegate, PlaybackSettingViewControllerDelegate>
@property (nonatomic, readwrite) MusicManager* musicManager;
@property (nonatomic, readwrite) ProductManager* productManager;
@property (nonatomic) UIView* adContainer;
@property (nonatomic) UIImageView* tohovgsImage;
@property (nonatomic) UILabel* tohovgsLabel;
@property (nonatomic) UIView* pageView;
@property (nonatomic) SeekBarView* seekBar;
@property (nonatomic) FooterView* footer;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic) BOOL pageMoving;
@property (nonatomic, nullable) ProgressView* progressView;
@property (nonatomic) UIView* bannerBgView;
@property (nonatomic, strong) GADBannerView* bannerView;
@property (nonatomic, strong) GADRewardedAd* rewardedAd;
@property (nonatomic) BOOL bannerLoaded;
@property (nonatomic) NSString* idfa;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    _musicManager = [[MusicManager alloc] init];
    _musicManager.delegate = self;
    _productManager = [[ProductManager alloc] init];
    _productManager.delegate = self;
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    _adContainer = [[UIView alloc] init];
    _adContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    [self.view addSubview:_adContainer];
    _tohovgsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tohovgs"]];
    [_adContainer addSubview:_tohovgsImage];
    _tohovgsLabel = [[UILabel alloc] init];
    _tohovgsLabel.text = @"東方BGM on VGS";
    _tohovgsLabel.textColor = [UIColor colorWithWhite:1 alpha:0.3];
    _tohovgsLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:24];
    _tohovgsLabel.textAlignment = NSTextAlignmentCenter;
    [_adContainer addSubview:_tohovgsLabel];
    _pageView = [[AlbumPagerView alloc] initWithControlDelegate:self];
    [self.view addSubview:_pageView];
    _seekBar = [[SeekBarView alloc] init];
    _seekBar.delegate = self;
    [self.view addSubview:_seekBar];
    _footer = [[FooterView alloc] initWithDelegate:self];
    [self.view addSubview:_footer];
    if (![_productManager isPurchasedWithProductId:PRODUCT_ID_BANNER]) {
        _bannerBgView = [[UIView alloc] init];
        _bannerBgView.backgroundColor = [UIColor blackColor];
        _bannerBgView.hidden = YES;
        [_adContainer addSubview:_bannerBgView];
        _bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
        _bannerView.adUnitID = ADS_ID_BANNER;
        _bannerView.rootViewController = self;
        _bannerView.delegate = self;
        [_adContainer addSubview:_bannerView];
    }
    _currentPageIndex = 0;
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(viewWillEnterForeground)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(viewDidEnterBackground)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    _bannerLoaded = NO;
}

- (void)viewWillEnterForeground
{
    if ([_pageView isKindOfClass:[RetroView class]]) {
        [(RetroView*)_pageView enterForeground];
    } else if ([_pageView isKindOfClass:[AlbumPagerView class]]) {
        [(AlbumPagerView*)_pageView scrollToCurrentSong];
    } else if ([_pageView isKindOfClass:[SongListView class]]) {
        [(SongListView*)_pageView scrollToCurrentSong];
    }
}

- (void)viewDidEnterBackground
{
    if ([_pageView isKindOfClass:[RetroView class]]) {
        [(RetroView*)_pageView enterBackground];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _resizeAll:YES];

    __weak ViewController* weakSelf = self;
    switch ([ATTrackingManager trackingAuthorizationStatus]) {
        case ATTrackingManagerAuthorizationStatusRestricted:
            NSLog(@"IDFA Restricted");
            break;
        case ATTrackingManagerAuthorizationStatusDenied:
            NSLog(@"IDFA Denied");
            break;
        case ATTrackingManagerAuthorizationStatusAuthorized: {
            NSUUID* idfa = [ASIdentifierManager sharedManager].advertisingIdentifier;
            NSLog(@"IDFA Authorized: %@", idfa);
            _idfa = idfa.UUIDString;
            break;
        }
        case ATTrackingManagerAuthorizationStatusNotDetermined:
            NSLog(@"IDFA Determined");
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                if (ATTrackingManagerAuthorizationStatusAuthorized == status) {
                    NSUUID* idfa = [ASIdentifierManager sharedManager].advertisingIdentifier;
                    NSLog(@"IDFA Authorized: %@", idfa);
                    weakSelf.idfa = idfa.UUIDString;
                } else {
                    NSLog(@"IDFA not authorized");
                }
            }];
    }
    [_musicManager checkUpdateWithCallback:^(BOOL updateExist) {
        weakSelf.footer.badge = updateExist;
    }];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    [self _resizeAll:YES];
}

- (void)_resizeAll:(BOOL)all
{
    UIEdgeInsets safe = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets;
    const CGFloat bh = safe.top ? 0 : self.view.window.windowScene.statusBarManager.statusBarFrame.size.height;
    const CGFloat sx = safe.left;
    const CGFloat sy = safe.top + bh;
    const CGFloat sw = self.view.frame.size.width - safe.left - safe.right;
    const CGFloat sh = self.view.frame.size.height - safe.top - safe.bottom - bh;
    _adContainer.frame = CGRectMake(sx, sy, sw, AD_HEIGHT);
    if (_bannerView) {
        _bannerView.frame = CGRectMake(0, 0, sw, AD_HEIGHT);
        _bannerBgView.frame = _bannerView.frame;
    }
    _tohovgsImage.frame = CGRectMake(0, 0, sw, AD_HEIGHT);
    _tohovgsLabel.frame = CGRectMake(0, 0, sw, AD_HEIGHT);
    if (_bannerView && !_bannerLoaded) {
        _bannerLoaded = YES;
        [_bannerView loadRequest:[GADRequest request]];
    }
    if (3 <= _currentPageIndex) {
        CGFloat pageHeight = sh - AD_HEIGHT - FOOTER_HEIGHT;
        _adContainer.frame = CGRectMake(sx, sy, sw, AD_HEIGHT);
        if (all) _pageView.frame = CGRectMake(sx, sy + AD_HEIGHT, sw, pageHeight);
        _seekBar.frame = CGRectMake(sx, sy + sh - FOOTER_HEIGHT, sw, SEEKBAR_HEIGHT);
        _footer.frame = CGRectMake(sx, sy + sh - FOOTER_HEIGHT, sw, FOOTER_HEIGHT);
    } else {
        CGFloat pageHeight = sh - AD_HEIGHT - FOOTER_HEIGHT - SEEKBAR_HEIGHT;
        _adContainer.frame = CGRectMake(sx, sy, sw, AD_HEIGHT);
        if (all) _pageView.frame = CGRectMake(sx, sy + AD_HEIGHT, sw, pageHeight);
        _seekBar.frame = CGRectMake(sx, sy + sh - FOOTER_HEIGHT - SEEKBAR_HEIGHT, sw, SEEKBAR_HEIGHT);
        _footer.frame = CGRectMake(sx, sy + sh - FOOTER_HEIGHT, sw, FOOTER_HEIGHT);
    }
    _progressView.frame = CGRectMake(sx, sy, sw, sh);
}

- (void)_moveTo:(FooterButtonType)type
{
    __weak ViewController* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.footer moveToType:FooterButtonTypeSettings];
    });
}

- (void)footerButton:(FooterButton*)button didTapWithType:(FooterButtonType)type
{
    if (_pageMoving) return;
    [_musicManager stopPlaying];
    _pageMoving = YES;
    BOOL currentPageIsRetro = [_pageView isKindOfClass:[RetroView class]];
    if (currentPageIsRetro) {
        [(RetroView*)_pageView savePreferences];
    }
    UIView* nextPage;
    NSInteger nextPageIndex;
    switch (type) {
        case FooterButtonTypeHome:
            nextPage = [[AlbumPagerView alloc] initWithControlDelegate:self];
            nextPageIndex = 0;
            break;
        case FooterButtonTypeAll:
            nextPage = [[AllPagerView alloc] initWithControlDelegate:self];
            nextPageIndex = 1;
            break;
        case FooterButtonTypeShuffle:
            if (2 == _currentPageIndex) {
                [(SongListView*)_pageView shuffleWithControlDelegate:self];
                _pageMoving = NO;
                return;
            }
            nextPage = [[SongListView alloc] initWithControlDelegate:self
                                                               songs:_musicManager.allUnlockedSongs
                                                        splitByAlbum:NO
                                                             shuffle:YES
                                                        favoriteOnly:NO];
            nextPageIndex = 2;
            break;
        case FooterButtonTypeRetro:
            nextPage = [[RetroView alloc] initWithControlDelegate:self];
            nextPageIndex = 3;
            break;
        case FooterButtonTypeSettings:
            nextPage = [[SettingView alloc] initWithControlDelegate:self delegate:self];
            nextPageIndex = 4;
            break;
    }
    [self.view addSubview:nextPage];
    if (_progressView) {
        [self.view bringSubviewToFront:_progressView];
    }
    const CGFloat y = _pageView.frame.origin.y;
    const CGFloat w = _pageView.frame.size.width;
    const CGFloat h = _pageView.frame.size.height - (3 <= _currentPageIndex ? SEEKBAR_HEIGHT : 0);
    const BOOL moveToRight = _currentPageIndex < nextPageIndex;
    nextPage.frame = CGRectMake(moveToRight ? w : -w, y, w, h + (3 <= nextPageIndex ? SEEKBAR_HEIGHT : 0));
    __weak ViewController* weakSelf = self;
    _bannerView.hidden = NO;
    BOOL nextPageIsRetro = [nextPage isKindOfClass:[RetroView class]];
    _bannerView.alpha = currentPageIsRetro ? 0 : 1;
    _bannerBgView.alpha = _bannerView.alpha;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.pageView.frame = CGRectMake(moveToRight ? -w : w, y, w, weakSelf.pageView.frame.size.height);
        nextPage.frame = CGRectMake(0, y, w, h + (3 <= nextPageIndex ? SEEKBAR_HEIGHT : 0));
        weakSelf.bannerView.alpha = nextPageIsRetro ? 0 : 1;
        weakSelf.bannerBgView.alpha = weakSelf.bannerView.alpha;
        weakSelf.currentPageIndex = nextPageIndex;
        [weakSelf _resizeAll:NO];
    } completion:^(BOOL finished) {
        if (finished) {
            if (currentPageIsRetro) {
                [(RetroView*)weakSelf.pageView destroy];
            }
            weakSelf.bannerView.hidden = nextPageIsRetro;
            [weakSelf.pageView removeFromSuperview];
            weakSelf.pageView = nextPage;
            weakSelf.pageMoving = NO;
        }
    }];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (ViewController*)getViewController
{
    return self;
}

- (void)bannerViewDidReceiveAd:(GADBannerView*)bannerView
{
    _bannerBgView.hidden = NO;
}

- (void)musicManager:(MusicManager*)manager didStartPlayingSong:(Song*)song
{
    _seekBar.max = vgsplay_getSongLength();
}

- (void)musicManager:(MusicManager*)manager didStopPlayingSong:(Song*)song
{
}

- (void)resetSeekBar
{
    _seekBar.max = 0;
}

- (void)musicManager:(MusicManager*)manager didEndPlayingSong:(Song*)song
{
    if ([_pageView isKindOfClass:[AlbumPagerView class]]) {
        [(AlbumPagerView*)_pageView requireNextSong:song
                                           infinity:_musicManager.infinity];
    } else if ([_pageView isKindOfClass:[AllPagerView class]]) {
        [(AllPagerView*)_pageView requireNextSong:song
                                         infinity:_musicManager.infinity];
    } else if ([_pageView isKindOfClass:[SongListView class]]) {
        [(SongListView*)_pageView requireNextSong:song
                                         infinity:_musicManager.infinity];
    } else if ([_pageView isKindOfClass:[RetroView class]]) {
    }
}

- (void)musicManager:(MusicManager*)manager didChangeProgress:(NSInteger)progress
{
    _seekBar.progress = progress;
}

- (void)seekBarView:(SeekBarView*)seek didRequestSeekTo:(NSInteger)progress
{
    [_musicManager seekTo:progress];
    if ([_pageView isKindOfClass:[AlbumPagerView class]]) {
        [(AlbumPagerView*)_pageView reloadCurrentPage];
    } else if ([_pageView isKindOfClass:[SongListView class]]) {
        [(SongListView*)_pageView reload];
    }
}

- (void)seekBarView:(SeekBarView*)seek didChangeInfinity:(BOOL)infinity
{
    _musicManager.infinity = infinity;
}

- (void)seekBarview:(SeekBarView*)seek didRequestChangeSpeedFrom:(NSInteger)speed
{
    [_musicManager stopPlaying];
    PlaybackSettingViewController* vc = [[PlaybackSettingViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.delegate = self;
    vc.musicManager = _musicManager;
    [self presentViewController:vc animated:YES completion:^{
        ;
    }];
}

- (void)playbackSettingViewController:(PlaybackSettingViewController*)viewController
                   didCloseWithVolume:(NSInteger)volume
                                speed:(NSInteger)speed
{
    [_seekBar updateSpeed:speed];
}

- (void)settingView:(SettingView*)view didChangedSpeed:(NSInteger)speed
{
    [_seekBar updateSpeed:speed];
}

- (void)startProgressWithMessage:(NSString *)message
{
    _progressView = [[ProgressView alloc] initWithMessage:message];
    _progressView.alpha = 0;
    [self.view addSubview:_progressView];
    [self _resizeAll:NO];
    __weak ViewController* weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.progressView.alpha = 1;
    }];
}

- (void)stopProgress
{
    if (_progressView) {
        __weak ViewController* weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.progressView.alpha = 0;
            } completion:^(BOOL finished) {
                if (finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.progressView removeFromSuperview];
                        weakSelf.progressView = nil;
                    });
                }
            }];
        });
    }
}

- (void)askLockWithSong:(Song*)song locked:(void(^)(void))locked
{
    NSString* title = song.name;
    NSString* message = NSLocalizedString(@"choose_operation", nil);
    __weak ViewController* weakSelf = self;
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction* lockSong = [UIAlertAction actionWithTitle:NSLocalizedString(@"lock_song", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.musicManager lock:YES song:song];
        if ([weakSelf.pageView isKindOfClass:[AlbumPagerView class]]) {
            [(AlbumPagerView*)weakSelf.pageView refreshIsThereLockedSongWithAnimate:YES];
        }
        locked();
    }];
    UIAlertAction* appleMusic = [UIAlertAction actionWithTitle:NSLocalizedString(@"check_apple_music", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        if (song.appleMusicURL) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:song.appleMusicURL]
                                               options:@{}
                                     completionHandler:^(BOOL success){
                                         // nothing to do
                                     }];
        } else {
            [self showErrorMessage:NSLocalizedString(@"apple_music_not_found", nil)];
        }
    }];
    [controller addAction:cancel];
    [controller addAction:lockSong];
    [controller addAction:appleMusic];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)askUnlockAllWithCallback:(void(^)(void))unlocked
{
    if ([_productManager isPurchasedWithProductId:PRODUCT_ID_REWARD]) {
        [self doUnlockWithCallback:unlocked];
        return;
    }
    __weak ViewController* weakSelf = self;
    NSString* title = NSLocalizedString(@"confirm", nil);
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"ask_unlock_all", nil)];
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.footer.badge) {
            [weakSelf confirmDownloadBeforeUnlockWithCallback:unlocked];
        } else {
            [weakSelf doUnlockWithCallback:unlocked];
        }
    }];
    [controller addAction:cancel];
    [controller addAction:ok];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)confirmDownloadBeforeUnlockWithCallback:(void(^)(void))unlocked
{
    __weak ViewController* weakSelf = self;
    NSString* title = NSLocalizedString(@"confirm", nil);
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"ask_download_before_unlock", nil)];
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"unlock_soon", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf doUnlockWithCallback:unlocked];
    }];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"download_ahead", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf _moveTo:FooterButtonTypeSettings];
    }];
    [controller addAction:cancel];
    [controller addAction:ok];
    [self presentViewController:controller animated:YES completion:nil];

}

- (void)doUnlockWithCallback:(void(^)(void))unlocked
{
    __weak ViewController* weakSelf = self;
    [self requestReward:^{
        for (Album* album in weakSelf.musicManager.albums) {
            for (Song* song in album.songs) {
                if ([weakSelf.musicManager isLockedSong:song]) {
                    [weakSelf.musicManager lock:NO song:song];
                }
            }
        }
        if ([weakSelf.pageView isKindOfClass:[AlbumPagerView class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [(AlbumPagerView*)weakSelf.pageView refreshIsThereLockedSongWithAnimate:YES];
            });
        }
        unlocked();
    }];
}

- (void)showErrorMessage:(NSString*)message
{
    NSString* title = NSLocalizedString(@"error", nil);
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    [controller addAction:ok];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showInfoMessage:(NSString*)message
{
    NSString* title = NSLocalizedString(@"information", nil);
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    [controller addAction:ok];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)requestReward:(void(^)(void))earnReward
{
    if ([_productManager isPurchasedWithProductId:PRODUCT_ID_REWARD]) {
        earnReward();
        return;
    }
    __weak ViewController* weakSelf = self;
    [self startProgressWithMessage:NSLocalizedString(@"please_wait", nil)];
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:ADS_ID_REWARD
                            request:request
                  completionHandler:^(GADRewardedAd* ad, NSError* error) {
        if (error) {
            NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
            [weakSelf stopProgress];
            // 外的要因（広告在庫が無い or 広告配信制限中など）も考えられるので無条件でアンロック
            NSString* message = [NSString stringWithFormat:NSLocalizedString(@"unlock_without_ads", nil), error.localizedDescription];
            [weakSelf showErrorMessage:message];
            earnReward();
            return;
        }
        weakSelf.rewardedAd = ad;
        weakSelf.rewardedAd.fullScreenContentDelegate = self;
        [weakSelf.rewardedAd presentFromRootViewController:weakSelf userDidEarnRewardHandler:^{
            earnReward();
        }];
    }];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError*)error
{
    NSLog(@"Ad did fail to present full screen content.");
    [self stopProgress];
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"error_ads", nil), error.localizedDescription];
    [self showErrorMessage:message];
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad
{
    NSLog(@"Ad did dismiss full screen content.");
    [self stopProgress];
}

- (void)didChangeSongListFromSettingView:(SettingView*)view
{
    _footer.badge = NO;
}

- (void)showUpdateSongs:(NSArray<Song*>*)songs
{
    SongListViewController* vc = [[SongListViewController alloc] init];
    vc.songs = songs;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{
        ;
    }];
}

- (void)didDissmissSongListViewController:(SongListViewController*)viewController
{
    __weak ViewController* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf askUnlockAllWithCallback:^{
            NSLog(@"unlocked");
        }];
    });
}

- (NSString*)priceWithProductId:(NSString*)productId
{
    return [_productManager priceWithProductId:productId];
}

- (BOOL)isPurchasedWithProductId:(NSString*)productId
{
    return [_productManager isPurchasedWithProductId:productId];
}

- (void)purchaseWithProductId:(NSString*)productId
             purchaseDelegate:(id<PurchaseDelegate>)purchaseDelegate
{
    [_productManager purchaseWithProductId:productId purchaseDelegate:purchaseDelegate];
}

- (void)restorePurchaseWithPurchaseDelegate:(id<PurchaseDelegate>)purchaseDelegate
{
    [_productManager restoreWithPurchaseDelegate:purchaseDelegate];
}

- (void)presentViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)productManagerDidRequestRemoveBannerAds:(ProductManager*)manager
{
    if (_bannerView && [_productManager isPurchasedWithProductId:PRODUCT_ID_BANNER]) {
        [_bannerView removeFromSuperview];
        _bannerView = nil;
        [_bannerBgView removeFromSuperview];
        _bannerBgView = nil;
        [self _resizeAll:YES];
    }
}

@end
