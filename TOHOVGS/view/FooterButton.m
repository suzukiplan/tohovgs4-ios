/**
 * ©2022, SUZUKI PLAN
 * License: https://github.com/suzukiplan/tohovgs4-ios/blob/master/LICENSE.txt
 */

#import "FooterButton.h"
#import "PushableView.h"

@interface FooterButton() <PushableViewDelegate>
@property (nonatomic) FooterButtonType type;
@property (nonatomic, weak) id<FooterButtonDelegate> footerDelegate;
@property (nonatomic) UIImageView* image;
@property (nonatomic, nullable) UIImageView* badgeView;
@end

@implementation FooterButton

- (instancetype)initWithType:(FooterButtonType)type
                    delegate:(id<FooterButtonDelegate>)delegate
{
    return [self initWithType:type badge:NO delegate:delegate];
}

- (instancetype)initWithType:(FooterButtonType)type
                       badge:(BOOL)badge
                    delegate:(nonnull id<FooterButtonDelegate>)delegate
{
    if (self = [super initWithDelegate:self]) {
        _type = type;
        _badge = badge;
        _footerDelegate = delegate;
        self.touchAlphaAnimation = YES;
        self.tapBoundAnimation = YES;
        _image = [[UIImageView alloc] init];
        [self addSubview:_image];
        switch (type) {
            case FooterButtonTypeHome:
                _image.image = [UIImage imageNamed:@"footer_home"];
                break;
            case FooterButtonTypeAll:
                _image.image = [UIImage imageNamed:@"footer_all"];
                break;
            case FooterButtonTypeMyList:
                _image.image = [UIImage imageNamed:@"footer_mylist"];
                break;
            case FooterButtonTypeShuffle:
                _image.image = [UIImage imageNamed:@"footer_shuffle"];
                break;
            case FooterButtonTypeRetro:
                _image.image = [UIImage imageNamed:@"footer_retro"];
                break;
            case FooterButtonTypeSettings:
                _image.image = [UIImage imageNamed:@"footer_settings"];
                _badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_badge"]];
                [self addSubview:_badgeView];
                break;
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _image.frame = CGRectMake((frame.size.width - 32) / 2, (frame.size.height - 44) / 2, 32, 44);
    _badgeView.frame = CGRectMake(_image.frame.origin.x + 22, _image.frame.origin.y + 2, 8, 8);
    _badgeView.hidden = !_badge;
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    [_footerDelegate footerButton:self didTapWithType:_type];
}

- (void)setBadge:(BOOL)badge
{
    _badge = badge;
    [self setFrame:self.frame];
}

@end
