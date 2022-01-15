//
//  ViewController.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import "ViewController.h"
#import "view/SeekBarView.h"
#import "view/FooterView.h"
#import "view/AlbumPagerView.h"
#import "view/SongListView.h"
#import "view/RetroView.h"
#import "view/ProgressView.h"
#import "vgs/vgsplay-ios.h"
#import "ControlDelegate.h"

#define AD_HEIGHT 56
#define FOOTER_HEIGHT 56
#define SEEKBAR_HEIGHT 48

@interface ViewController () <FooterButtonDelegate, ControlDelegate, MusicManagerDelegate, SeekBarViewDelegate>
@property (nonatomic, readwrite) MusicManager* musicManager;
@property (nonatomic) UIView* adContainer;
@property (nonatomic) UIView* pageView;
@property (nonatomic) SeekBarView* seekBar;
@property (nonatomic) FooterView* footer;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic) BOOL pageMoving;
@property (nonatomic, nullable) ProgressView* progressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    _musicManager = [[MusicManager alloc] init];
    _musicManager.delegate = self;
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    _adContainer = [[UIView alloc] init];
    _adContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    [self.view addSubview:_adContainer];
    _pageView = [[AlbumPagerView alloc] initWithControlDelegate:self];
    [self.view addSubview:_pageView];
    _seekBar = [[SeekBarView alloc] init];
    _seekBar.delegate = self;
    [self.view addSubview:_seekBar];
    _footer = [[FooterView alloc] initWithDelegate:self];
    [self.view addSubview:_footer];
    _currentPageIndex = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _resizeAll:YES];
}

- (void)_resizeAll:(BOOL)all
{
    const CGFloat bh = self.view.window.windowScene.statusBarManager.statusBarFrame.size.height;
    const CGFloat sx = self.additionalSafeAreaInsets.left;
    const CGFloat sy = self.additionalSafeAreaInsets.top + bh;
    const CGFloat sw = self.view.frame.size.width - self.additionalSafeAreaInsets.left - self.additionalSafeAreaInsets.right;
    const CGFloat sh = self.view.frame.size.height - self.additionalSafeAreaInsets.top - self.additionalSafeAreaInsets.bottom - bh;
    if (_currentPageIndex == 3) {
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

- (void)footerButton:(FooterButton*)button didTapWithType:(FooterButtonType)type
{
    if (_pageMoving) return;
    [_musicManager stopPlaying];
    _pageMoving = YES;
    UIView* nextPage;
    NSInteger nextPageIndex;
    switch (type) {
        case FooterButtonTypeHome:
            nextPage = [[AlbumPagerView alloc] initWithControlDelegate:self];
            nextPageIndex = 0;
            break;
        case FooterButtonTypeAll:
            nextPage = [[SongListView alloc] initWithControlDelegate:self
                                                               songs:_musicManager.allUnlockedSongs
                                                        splitByAlbum:YES
                                                             shuffle:NO];
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
                                                             shuffle:YES];
            nextPageIndex = 2;
            break;
        case FooterButtonTypeRetro:
            nextPage = [[RetroView alloc] initWithControlDelegate:self];
            nextPageIndex = 3;
            break;
    }
    [self.view addSubview:nextPage];
    if (_progressView) {
        [self.view bringSubviewToFront:_progressView];
    }
    const CGFloat y = _pageView.frame.origin.y;
    const CGFloat w = _pageView.frame.size.width;
    const CGFloat h = _pageView.frame.size.height - (3 == _currentPageIndex ? SEEKBAR_HEIGHT : 0);
    const BOOL moveToRight = _currentPageIndex < nextPageIndex;
    nextPage.frame = CGRectMake(moveToRight ? w : -w, y, w, h + (3 == nextPageIndex ? SEEKBAR_HEIGHT : 0));
    __weak ViewController* weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.pageView.frame = CGRectMake(moveToRight ? -w : w, y, w, weakSelf.pageView.frame.size.height);
        nextPage.frame = CGRectMake(0, y, w, h + (3 == nextPageIndex ? SEEKBAR_HEIGHT : 0));
        weakSelf.currentPageIndex = nextPageIndex;
        [weakSelf _resizeAll:NO];
    } completion:^(BOOL finished) {
        if (finished) {
            if ([weakSelf.pageView isKindOfClass:[RetroView class]]) {
                [(RetroView*)weakSelf.pageView destroy];
            }
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

- (void)musicManager:(MusicManager*)manager didStartPlayingSong:(Song*)song
{
    _seekBar.max = vgsplay_getSongLength();
}

- (void)musicManager:(MusicManager*)manager didStopPlayingSong:(Song*)song
{
    _seekBar.max = 0;
}

- (void)musicManager:(MusicManager*)manager didEndPlayingSong:(Song*)song
{
    if ([_pageView isKindOfClass:[AlbumPagerView class]]) {
        [(AlbumPagerView*)_pageView requireNextSong:song
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
}

- (void)seekBarView:(SeekBarView*)seek didChangeInfinity:(BOOL)infinity
{
    _musicManager.infinity = infinity;
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

- (void)stopProgress:(void(^)(void))done
{
    if (_progressView) {
        __weak ViewController* weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.progressView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [weakSelf.progressView removeFromSuperview];
                weakSelf.progressView = nil;
                done();
            }
        }];
    }
}

- (void)askLockWithSong:(Song*)song locked:(void(^)(void))locked
{
    __weak ViewController* weakSelf = self;
    NSString* title = NSLocalizedString(@"confirm", nil);
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"ask_lock", nil), song.name];
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.musicManager lock:YES song:song];
        if ([weakSelf.pageView isKindOfClass:[AlbumPagerView class]]) {
            [(AlbumPagerView*)weakSelf.pageView refreshIsThereLockedSongWithAnimate:YES];
        }
        locked();
    }];
    [controller addAction:cancel];
    [controller addAction:ok];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)askUnlockWithAlbum:(Album*)album unlocked:(void(^)(void))unlocked
{
    __weak ViewController* weakSelf = self;
    NSString* title = NSLocalizedString(@"confirm", nil);
    NSString* message = [NSString stringWithFormat:NSLocalizedString(@"ask_unlock", nil), album.name];
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        for (Song* song in album.songs) {
            if ([weakSelf.musicManager isLockedSong:song]) {
                [weakSelf.musicManager lock:NO song:song];
            }
        }
        if ([weakSelf.pageView isKindOfClass:[AlbumPagerView class]]) {
            [(AlbumPagerView*)weakSelf.pageView refreshIsThereLockedSongWithAnimate:YES];
        }
        unlocked();
    }];
    [controller addAction:cancel];
    [controller addAction:ok];
    [self presentViewController:controller animated:YES completion:nil];

}

- (void)askUnlockAllWithCallback:(void(^)(void))unlocked
{
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
        for (Album* album in weakSelf.musicManager.albums) {
            for (Song* song in album.songs) {
                if ([weakSelf.musicManager isLockedSong:song]) {
                    [weakSelf.musicManager lock:NO song:song];
                }
            }
        }
        unlocked();
    }];
    [controller addAction:cancel];
    [controller addAction:ok];
    [self presentViewController:controller animated:YES completion:nil];

}

@end
