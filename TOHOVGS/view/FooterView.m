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
                     [self _makeButton:FooterButtonTypeSettings],
                     [self _makeButton:FooterButtonTypeMyList]];
        for (UIView* view in _buttons) {
            [self addSubview:view];
        }
    }
    return self;
}

- (FooterButton*)_makeButton:(FooterButtonType)type
{
    if (type == FooterButtonTypeSettings) {
        _badge = [[NSUserDefaults standardUserDefaults] boolForKey:@"badge"];
        return [[FooterButton alloc] initWithType:type badge:_badge delegate:self];
    } else {
        return [[FooterButton alloc] initWithType:type delegate:self];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat width = frame.size.width / 5;
    CGFloat x = 0;
    for (NSInteger i = 0; i < 5; i++, x += width) {
        NSInteger buttonIndex = i;
        if (1 == i) {
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"mylist_mode"]) {
                buttonIndex = 5;
                _buttons[1].hidden = YES;
                _buttons[5].hidden = NO;
            } else {
                _buttons[1].hidden = NO;
                _buttons[5].hidden = YES;
            }
        }
        _buttons[buttonIndex].frame = CGRectMake(x, 0, width, frame.size.height);
        _buttons[buttonIndex].enabled = buttonIndex != _selection;
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

- (void)setBadge:(BOOL)badge
{
    if (badge != _badge) {
        _badge = badge;
        __weak FooterView* weakSelf = self;
        [[NSUserDefaults standardUserDefaults] setBool:badge forKey:@"badge"];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.buttons[4].badge = badge;
        });
    }
}

- (void)moveToType:(FooterButtonType)type
{
    [self footerButton:[self buttonWithType:type] didTapWithType:type];
}

- (FooterButton*)buttonWithType:(FooterButtonType)type
{
    switch (type) {
        case FooterButtonTypeHome: return _buttons[0];
        case FooterButtonTypeAll: return _buttons[1];
        case FooterButtonTypeShuffle: return _buttons[2];
        case FooterButtonTypeRetro: return _buttons[3];
        case FooterButtonTypeSettings: return _buttons[4];
        case FooterButtonTypeMyList: return _buttons[5];
    }
}

@end
