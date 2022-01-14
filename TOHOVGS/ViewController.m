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
            nextPage = [[SongListView alloc] initWithControlDelegate:self songs:_musicManager.allUnlockedSongs];
            nextPageIndex = 1;
            break;
        case FooterButtonTypeShuffle:
            nextPage = [[SongListView alloc] initWithControlDelegate:self songs:_musicManager.allUnlockedSongs];
            nextPageIndex = 2;
            break;
        case FooterButtonTypeRetro:
            nextPage = [[RetroView alloc] init];
            nextPageIndex = 3;
            break;
    }
    [self.view addSubview:nextPage];
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

- (void)musicManager:(MusicManager*)manager didChangeProgress:(NSInteger)progress
{
    _seekBar.progress = progress;
}

- (void)seekBarView:(SeekBarView*)seek didRequestSeekTo:(NSInteger)progress
{
    [_musicManager seekTo:progress];
}

@end
