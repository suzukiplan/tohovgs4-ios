//
//  AllPagerView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/06/26.
//

#import "AllPagerView.h"
#import "TextTabView.h"
#import "SongListView.h"
#import "PushableView.h"

@interface AllPagerView() <UIScrollViewDelegate, TextTabViewDelegate, PushableViewDelegate>
@property (nonatomic, weak) id<ControlDelegate> controlDelegate;
@property (nonatomic) TextTabView* tabView;
@property (nonatomic) UIScrollView* pager;
@property (nonatomic) NSArray<SongListView*>* pages;
@property (nonatomic) NSInteger currentPosition;
@property (nonatomic) BOOL forceScrolling;
@end

@implementation AllPagerView

- (instancetype)initWithControlDelegate:(id<ControlDelegate>)controlDelegate
{
    if (self = [super init]) {
        _controlDelegate = controlDelegate;
        _tabView = [[TextTabView alloc] initWithTexts:@[NSLocalizedString(@"all_songs", nil),
                                                        NSLocalizedString(@"favorites", nil)]
                                             delegate:self];
        [self addSubview:_tabView];
        _pager = [[UIScrollView alloc] init];
        _pager.pagingEnabled = YES;
        _pager.delegate = self;
        _pager.showsHorizontalScrollIndicator = NO;
        [self addSubview:_pager];
        MusicManager* manager = [_controlDelegate getViewController].musicManager;
        SongListView* allSongs = [[SongListView alloc] initWithControlDelegate:_controlDelegate
                                                                         songs:manager.allUnlockedSongs
                                                                  splitByAlbum:YES
                                                                       shuffle:NO
                                                                  favoriteOnly:NO];
        SongListView* favorites = [[SongListView alloc] initWithControlDelegate:_controlDelegate
                                                                          songs:manager.allUnlockedSongs
                                                                   splitByAlbum:NO
                                                                        shuffle:NO
                                                                   favoriteOnly:YES];
        _pages = @[allSongs, favorites];
        [_pager addSubview:allSongs];
        [_pager addSubview:favorites];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _tabView.frame = CGRectMake(0, 0, frame.size.width, _tabView.height);
    _pager.frame = CGRectMake(0, _tabView.height, frame.size.width, frame.size.height - _tabView.height);
    for (NSInteger i = 0; i < _pages.count; i++) {
        _pages[i].frame = CGRectMake(i * frame.size.width, 0, frame.size.width, _pager.frame.size.height);
    }
    _pager.contentSize = CGSizeMake(frame.size.width * _pages.count, _pager.frame.size.height);
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
    if (_pages.count <= position) position = _pages.count - 1;
    if (position < 0) position = 0;
    _tabView.position = position;
    if (_currentPosition != position) {
        _currentPosition = position;
        [[_controlDelegate getViewController].musicManager purgeKeepInfo];
        for (SongListView* page in _pages) [page reload];
    }
}

- (void)textTabViewDidMoveEnd:(TextTabView*)view
{
}

- (void)textTabView:(TextTabView*)tabView didChangePosition:(NSInteger)position
{
    _forceScrolling = YES;
    [_pager scrollRectToVisible:_pages[position].frame animated:YES];
    [[_controlDelegate getViewController].musicManager purgeKeepInfo];
    for (SongListView* page in _pages) [page reload];
}

- (void)didPushPushableView:(PushableView*)pushableView
{
}

- (void)requireNextSong:(Song*)song infinity:(BOOL)infinity
{
    [_pages[_currentPosition] requireNextSong:song infinity:infinity];
}

@end
