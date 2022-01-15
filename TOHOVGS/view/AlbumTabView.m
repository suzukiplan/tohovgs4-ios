//
//  AlbumTabView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/01/13.
//

#import "AlbumTabView.h"
#import "PushableView.h"

#define MARGIN 8
#define HEIGHT 44

@interface AlbumTabView() <PushableViewDelegate>
@property (nonatomic, weak) id<AlbumTabViewDelegate> tabDelegate;
@property (nonatomic, weak) NSArray<Album*>* albums;
@property (nonatomic, readwrite) CGFloat height;
@property (nonatomic) UIView* cursor;
@property (nonatomic) NSMutableArray<PushableView*>* pushables;
@property (nonatomic) NSMutableArray<UILabel*>* labels;
@property (nonatomic) UIFont* selectedFont;
@property (nonatomic) UIFont* notSelectedFont;
@property (nonatomic) NSInteger initialPosition;
@end

@implementation AlbumTabView

- (instancetype)initWithAlbums:(NSArray<Album*>*)albums
               initialPosition:(NSInteger)initialPosition
                      delegate:(nonnull id<AlbumTabViewDelegate>)delegate
{
    if (self = [super init]) {
        self.showsHorizontalScrollIndicator = NO;
        _albums = albums;
        _initialPosition = initialPosition;
        _tabDelegate = delegate;
        _height = HEIGHT;
        _cursor = [[UIView alloc] init];
        _cursor.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        _cursor.layer.cornerRadius = 2;
        [self addSubview:_cursor];
        _pushables = [NSMutableArray arrayWithCapacity:_albums.count];
        _labels = [NSMutableArray arrayWithCapacity:_albums.count];
        _selectedFont = [UIFont boldSystemFontOfSize:12];
        _notSelectedFont = [UIFont systemFontOfSize:12];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        NSInteger x = 0;
        for (Album* album in _albums) {
            PushableView* pushable = [[PushableView alloc] initWithDelegate:self];
            pushable.touchAlphaAnimation = YES;
            pushable.tapBoundAnimation = YES;
            [self addSubview:pushable];
            [_pushables addObject:pushable];
            UILabel* label = [[UILabel alloc] init];
            label.text = album.name;
            label.font = x ? _notSelectedFont : _selectedFont;
            label.textColor = [UIColor colorWithWhite:1 alpha:1];
            label.textAlignment = NSTextAlignmentCenter;
            label.frame = CGRectMake(MARGIN, 0, label.intrinsicContentSize.width, HEIGHT);
            [_labels addObject:label];
            [pushable addSubview:label];
            CGFloat w = label.frame.size.width + MARGIN * 2;
            pushable.frame = CGRectMake(x, 0, w, HEIGHT);
            x += w;
        }
        self.contentSize = CGSizeMake(x, HEIGHT);
    }
    return self;
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    [self setPosition:[_pushables indexOfObject:pushableView]];
    [_tabDelegate albumTabView:self didChangePosition:_position];
}

- (void)setPosition:(NSInteger)position
{
    if (_position == position) return;
    NSInteger previousPosition = _position;
    _position = position;
    __weak AlbumTabView* weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.labels[previousPosition].font = weakSelf.notSelectedFont;
        weakSelf.labels[position].font = weakSelf.selectedFont;
        [weakSelf setFrame:weakSelf.frame];
        [weakSelf scrollRectToVisible:weakSelf.cursor.frame animated:YES];
        [weakSelf.tabDelegate albumTabViewDidMoveEnd];
    }];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _cursor.frame = CGRectMake(_pushables[_position].frame.origin.x + 4,
                               _pushables[_position].frame.origin.y + 4,
                               _pushables[_position].frame.size.width - 8,
                               _pushables[_position].frame.size.height - 8);
    for (PushableView* view in _pushables) {
        view.enabled = YES;
    }
    _pushables[_position].enabled = NO;
    if (0 < _initialPosition) {
        NSInteger initialPosition = _initialPosition;
        _initialPosition = -1;
        CGFloat x = _pushables[initialPosition].frame.origin.x;
        x -= (frame.size.width - _pushables[initialPosition].frame.size.width) / 2;
        if (self.contentSize.width < x + frame.size.width) {
            x = self.contentSize.width - frame.size.width;
        } else if (x < 0) {
            x = 0;
        }
        self.contentOffset = CGPointMake(x, 0);
        _labels[_position].font = _notSelectedFont;
        _labels[initialPosition].font = _selectedFont;
        _cursor.frame = CGRectMake(_pushables[initialPosition].frame.origin.x + 4,
                                   _pushables[initialPosition].frame.origin.y + 4,
                                   _pushables[initialPosition].frame.size.width - 8,
                                   _pushables[initialPosition].frame.size.height - 8);
        [self scrollRectToVisible:_cursor.frame animated:NO];
        _position = initialPosition;
    }
}

@end
