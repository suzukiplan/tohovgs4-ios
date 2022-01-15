/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "AlbumPagerView.h"
#import "AlbumTabView.h"
#import "SongListView.h"
#import "PushableView.h"
#import "../api/MusicManager.h"

@interface AlbumPagerView() <UIScrollViewDelegate, AlbumTabViewDelegate, PushableViewDelegate>
@property (nonatomic, weak) id<ControlDelegate> controlDelegate;
@property (nonatomic, weak) MusicManager* musicManager;
@property (nonatomic, weak) NSArray<Album*>* albums;
@property (nonatomic, weak) NSUserDefaults* userDefaults;
@property (nonatomic) AlbumTabView* tabView;
@property (nonatomic) UIScrollView* pager;
@property (nonatomic) NSArray<SongListView*>* pages;
@property (nonatomic) BOOL forceScrolling;
@property (nonatomic) NSInteger initialPageIndex;
@property (nonatomic) PushableView* unlockAllPushable;
@property (nonatomic) UILabel* unlockAllLabel;
@property (nonatomic) BOOL isThereLockedSong;
@end

@implementation AlbumPagerView

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
{
    if (self = [super init]) {
        self.clipsToBounds = YES;
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _controlDelegate = controlDelegate;
        _musicManager = [controlDelegate getViewController].musicManager;
        _albums = _musicManager.albums;
        _pager = [[UIScrollView alloc] init];
        _pager.pagingEnabled = YES;
        _pager.delegate = self;
        _pager.showsHorizontalScrollIndicator = NO;
        [self addSubview:_pager];
        NSMutableArray<SongListView*>* pages = [NSMutableArray arrayWithCapacity:_albums.count];
        NSString* initialAlbumId = [_userDefaults stringForKey:@"initial_album_id"];
        if (!initialAlbumId) {
            initialAlbumId = @"th06";
        } else {
            NSLog(@"initial page: %@", initialAlbumId);
        }
        for (Album* album in _albums) {
            SongListView* page = [[SongListView alloc] initWithControlDelegate:controlDelegate
                                                                         songs:album.songs
                                                                  splitByAlbum:NO
                                                                       shuffle:NO];
            [_pager addSubview:page];
            [pages addObject:page];
            if ([album.albumId isEqualToString:initialAlbumId]) {
                _initialPageIndex = [pages indexOfObject:page];
            }
            _tabView = [[AlbumTabView alloc] initWithAlbums:_albums
                                            initialPosition:_initialPageIndex
                                                   delegate:self];
            [self addSubview:_tabView];
        }
        _pages = pages;
        _unlockAllPushable = [[PushableView alloc] initWithDelegate:self];
        _unlockAllPushable.tapBoundAnimation = NO;
        _unlockAllPushable.touchAlphaAnimation = YES;
        [self addSubview:_unlockAllPushable];
        _unlockAllLabel = [[UILabel alloc] init];
        _unlockAllLabel.text = NSLocalizedString(@"unlock_all_songs", nil);
        _unlockAllLabel.font = [UIFont boldSystemFontOfSize:12];
        _unlockAllLabel.textColor = [UIColor whiteColor];
        _unlockAllLabel.textAlignment = NSTextAlignmentCenter;
        _unlockAllLabel.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.5];
        _unlockAllLabel.layer.borderColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.5 alpha:0.25].CGColor;
        _unlockAllLabel.layer.borderWidth = 2;
        _unlockAllLabel.layer.cornerRadius = 4.0;
        _unlockAllLabel.clipsToBounds = YES;
        [_unlockAllPushable addSubview:_unlockAllLabel];
        [self refreshIsThereLockedSongWithAnimate:NO];
    }
    return self;
}

- (void)refreshIsThereLockedSongWithAnimate:(BOOL)animate
{
    BOOL previousStatus = _isThereLockedSong;
    _isThereLockedSong = NO;
    for (Album* album in _albums) {
        for (Song* song in album.songs) {
            if ([_musicManager isLockedSong:song]) {
                _isThereLockedSong = YES;
                break;
            }
        }
    }
    if (animate && previousStatus != _isThereLockedSong) {
        __weak AlbumPagerView* weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf setFrame:weakSelf.frame];
        }];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat y = _isThereLockedSong ? 0 : -44;
    _unlockAllPushable.frame = CGRectMake(0, y, frame.size.width, 44);
    _unlockAllLabel.frame = CGRectMake(4, 4, frame.size.width - 8, 36);
    y += 44;
    _tabView.frame = CGRectMake(0, y, frame.size.width, _tabView.height);
    y += _tabView.height;
    _pager.frame = CGRectMake(0, y, frame.size.width, frame.size.height - y);
    CGFloat x = 0;
    for (SongListView* page in _pages) {
        page.frame = CGRectMake(x, 0, _pager.frame.size.width, _pager.frame.size.height);
        x += _pager.frame.size.width;
    }
    _pager.contentSize = CGSizeMake(x, _pager.frame.size.height);
    if (0 < _initialPageIndex) {
        NSLog(@"initial page index: %ld %f", _initialPageIndex, _pages[_initialPageIndex].frame.origin.x);
        [_pager scrollRectToVisible:_pages[_initialPageIndex].frame animated:NO];
        _initialPageIndex = -1;
    }
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if (_forceScrolling) {
        if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            _forceScrolling = NO;
        } else {
            return;
        }
    }
    NSInteger position = (scrollView.contentOffset.x + _pager.frame.size.width / 2) / _pager.frame.size.width;
    if (_albums.count <= position) position = _albums.count - 1;
    if (position < 0) position = 0;
    if (_tabView.position != position) {
        NSLog(@"position changed by swipe: %@", _albums[position].albumId);
        [_userDefaults setObject:_albums[position].albumId forKey:@"initial_album_id"];
    }
    _tabView.position = position;
}

- (void)albumTabView:(AlbumTabView*)tabView didChangePosition:(NSInteger)position
{
    _forceScrolling = YES;
    [_pager scrollRectToVisible:_pages[position].frame animated:YES];
    NSLog(@"position changed by tab: %@", _albums[position].albumId);
    [_userDefaults setObject:_albums[position].albumId forKey:@"initial_album_id"];
}

- (void)albumTabViewDidMoveEnd
{
    [self _stopSong];
}

- (void)_stopSong
{
    for (SongListView* page in _pages) {
        [page stopSong];
    }
}

- (void)requireNextSong:(Song*)song
               infinity:(BOOL)infinity
{
    NSInteger index = [_albums indexOfObject:song.parentAlbum];
    [_pages[index] requireNextSong:song infinity:infinity];
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    __weak AlbumPagerView* weakSelf = self;
    [self _stopSong];
    [_controlDelegate askUnlockAllWithCallback:^{
        [weakSelf refreshIsThereLockedSongWithAnimate:YES];
        for (SongListView* page in weakSelf.pages) {
            [page reload];
        }
    }];
}

- (void)scrollToCurrentSong
{
    Song* target = _musicManager.playingSong;
    if (target) {
        NSInteger albumIndex = [_albums indexOfObject:target.parentAlbum];
        if (albumIndex != NSNotFound) {
            [_pages[albumIndex] scrollToCurrentSong];
        }
    }
}

@end
