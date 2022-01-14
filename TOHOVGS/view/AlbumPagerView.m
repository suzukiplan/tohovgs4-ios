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
@property (nonatomic) AlbumTabView* tabView;
@property (nonatomic) UIScrollView* pager;
@property (nonatomic) NSArray<SongListView*>* pages;
@property (nonatomic) BOOL forceScrolling;
@end

@implementation AlbumPagerView

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
{
    if (self = [super init]) {
        _musicManager = [controlDelegate getViewController].musicManager;
        _albums = _musicManager.albums;
        _tabView = [[AlbumTabView alloc] initWithAlbums:_albums delegate:self];
        [self addSubview:_tabView];
        _pager = [[UIScrollView alloc] init];
        _pager.pagingEnabled = YES;
        _pager.delegate = self;
        _pager.showsHorizontalScrollIndicator = NO;
        [self addSubview:_pager];
        NSMutableArray<SongListView*>* pages = [NSMutableArray arrayWithCapacity:_albums.count];
        for (Album* album in _albums) {
            SongListView* page = [[SongListView alloc] initWithControlDelegate:controlDelegate
                                                                         songs:album.songs
                                                                  splitByAlbum:NO
                                                                       shuffle:NO];
            [_pager addSubview:page];
            [pages addObject:page];
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
    _tabView.position = position;
}

- (void)albumTabView:(AlbumTabView*)tabView didChangePosition:(NSInteger)position
{
    _forceScrolling = YES;
    [_pager scrollRectToVisible:_pages[position].frame animated:YES];
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
