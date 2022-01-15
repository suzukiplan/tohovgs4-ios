//
//  AlbumPagerView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/11.
//

#import "AlbumPagerView.h"
#import "AlbumTabView.h"
#import "SongListView.h"
#import "../api/MusicManager.h"

@interface AlbumPagerView() <UIScrollViewDelegate, AlbumTabViewDelegate>
@property (nonatomic, weak) MusicManager* musicManager;
@property (nonatomic, weak) NSArray<Album*>* albums;
@property (nonatomic, weak) NSUserDefaults* userDefaults;
@property (nonatomic) AlbumTabView* tabView;
@property (nonatomic) UIScrollView* pager;
@property (nonatomic) NSArray<SongListView*>* pages;
@property (nonatomic) BOOL forceScrolling;
@property (nonatomic) NSInteger initialPageIndex;
@end

@implementation AlbumPagerView

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
{
    if (self = [super init]) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
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
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _tabView.frame = CGRectMake(0, 0, frame.size.width, _tabView.height);
    _pager.frame = CGRectMake(0, _tabView.height, frame.size.width, frame.size.height - _tabView.height);
    CGFloat x = 0;
    for (SongListView* page in _pages) {
        page.frame = CGRectMake(x, 0, _pager.frame.size.width, _pager.frame.size.height);
        x += _pager.frame.size.width;
    }
    _pager.contentSize = CGSizeMake(x, _pager.frame.size.height);
    if (0 < _initialPageIndex) {
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

@end
