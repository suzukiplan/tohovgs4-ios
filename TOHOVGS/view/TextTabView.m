//
//  TextTabView.m
//  TOHOVGS
//
//  Created by Yoji Suzuki on 2022/06/26.
//

#import "TextTabView.h"
#import "PushableView.h"
#define HEIGHT 44

@interface TextTabView() <PushableViewDelegate>
@property (nonatomic, weak) id<TextTabViewDelegate> delegate;
@property (nonatomic, readwrite) CGFloat height;
@property (nonatomic) UIView* cursor;
@property (nonatomic) NSMutableArray<PushableView*>* pushables;
@property (nonatomic) NSMutableArray<UILabel*>* labels;
@property (nonatomic) UIFont* selectedFont;
@property (nonatomic) UIFont* notSelectedFont;
@property (nonatomic) NSInteger initialPosition;
@end

@implementation TextTabView

- (instancetype)initWithTexts:(NSArray<NSString*>*)texts
                     delegate:(id<TextTabViewDelegate>)delegate
{
    if (self = [super init]) {
        _pushables = [NSMutableArray arrayWithCapacity:texts.count];
        _labels = [NSMutableArray arrayWithCapacity:texts.count];
        _selectedFont = [UIFont boldSystemFontOfSize:12];
        _notSelectedFont = [UIFont systemFontOfSize:12];
        _delegate = delegate;
        BOOL isFirst = YES;
        _cursor = [[UIView alloc] init];
        _cursor.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        _cursor.layer.cornerRadius = 2;
        [self addSubview:_cursor];
        for (NSString* text in texts) {
            PushableView* pushable = [[PushableView alloc] initWithDelegate:self];
            pushable.touchAlphaAnimation = YES;
            pushable.tapBoundAnimation = YES;
            [self addSubview:pushable];
            [_pushables addObject:pushable];
            UILabel* label = [[UILabel alloc] init];
            label.text = text;
            label.font = isFirst ? _selectedFont : _notSelectedFont;
            label.textColor = [UIColor colorWithWhite:1 alpha:1];
            label.textAlignment = NSTextAlignmentCenter;
            [_labels addObject:label];
            [pushable addSubview:label];
            isFirst = NO;
        }
    }
    return self;
}

- (CGFloat)height
{
    return HEIGHT;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (!_pushables.count) return;
    CGFloat w = frame.size.width / _pushables.count;
    CGFloat x = 0;
    for (NSInteger i = 0; i < _pushables.count; i++) {
        _pushables[i].frame = CGRectMake(x, 0, w, HEIGHT);
        _labels[i].frame = CGRectMake(0, 0, w, HEIGHT);
        x += w;
    }
    _cursor.frame = CGRectMake(_position * w + 2, 2, w - 4, frame.size.height - 4);
}

- (void)setPosition:(NSInteger)position
{
    if (_position == position) return;
    NSInteger previousPosition = _position;
    _position = position;
    __weak TextTabView* weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.labels[previousPosition].font = weakSelf.notSelectedFont;
        weakSelf.labels[position].font = weakSelf.selectedFont;
        [weakSelf setFrame:weakSelf.frame];
        [weakSelf.delegate textTabViewDidMoveEnd:weakSelf];
    }];
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    NSInteger moveTo = [_pushables indexOfObject:pushableView];
    if (_position != moveTo) {
        [_delegate textTabView:self didChangePosition:moveTo];
        [self setPosition:moveTo];
    }
}

@end
