/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "FooterView.h"

@interface FooterView() <FooterButtonDelegate>
@property (nonatomic, weak) id<FooterButtonDelegate> delegate;
@property (nonatomic) UIView* cursor;
@property (nonatomic) NSArray<FooterButton*>* buttons;
@property (nonatomic) NSInteger selection;
@property (nonatomic) BOOL isMoving;
@end

@implementation FooterView

- (instancetype)initWithDelegate:(id<FooterButtonDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:1]];
        _cursor = [[UIView alloc] init];
        _cursor.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        _cursor.layer.cornerRadius = 4.0;
        [self addSubview:_cursor];
        _buttons = @[[self _makeButton:FooterButtonTypeHome],
                     [self _makeButton:FooterButtonTypeAll],
                     [self _makeButton:FooterButtonTypeShuffle],
                     [self _makeButton:FooterButtonTypeRetro],
                     [self _makeButton:FooterButtonTypeSettings]];
        for (UIView* view in _buttons) {
            [self addSubview:view];
        }
    }
    return self;
}

- (FooterButton*)_makeButton:(FooterButtonType)type
{
    if (type == FooterButtonTypeSettings) {
        return [[FooterButton alloc] initWithType:type budge:YES delegate:self];
    } else {
        return [[FooterButton alloc] initWithType:type delegate:self];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat width = frame.size.width / _buttons.count;
    CGFloat x = 0;
    for (NSInteger i = 0; i < _buttons.count; i++, x += width) {
        _buttons[i].frame = CGRectMake(x, 0, width, frame.size.height);
        _buttons[i].enabled = i != _selection;
    }
    _buttons[2].enabled = YES; // support shuffle again
    _cursor.frame = CGRectMake(_selection * width + 4, 4, width - 8, frame.size.height - 8);
}

- (void)footerButton:(FooterButton*)button didTapWithType:(FooterButtonType)type
{
    if (_isMoving) return;
    NSInteger tappedIndex = [_buttons indexOfObject:button];
    _selection = tappedIndex;
    __weak FooterView* weakSelf = self;
    _isMoving = YES;
    [UIView animateWithDuration:0.2 animations:^{
        [weakSelf setFrame:weakSelf.frame];
    } completion:^(BOOL finished) {
        if (finished) {
            weakSelf.isMoving = NO;
        }
    }];
    [_delegate footerButton:button didTapWithType:type];
}

@end
