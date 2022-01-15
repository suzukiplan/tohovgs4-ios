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
@property (nonatomic) UILabel* label;
@end

@implementation FooterButton

- (instancetype)initWithType:(FooterButtonType)type
                    delegate:(nonnull id<FooterButtonDelegate>)delegate
{
    if (self = [super initWithDelegate:self]) {
        _type = type;
        _footerDelegate = delegate;
        self.touchAlphaAnimation = YES;
        self.tapBoundAnimation = YES;
        _image = [[UIImageView alloc] init];
        [self addSubview:_image];
        _label = [[UILabel alloc] init];
        _label.font = [UIFont boldSystemFontOfSize:12];
        switch (type) {
            case FooterButtonTypeHome:
                _image.image = [UIImage imageNamed:@"ic_home_white_18pt"];
                _label.text = NSLocalizedString(@"home", nil);
                break;
            case FooterButtonTypeAll:
                _image.image = [UIImage imageNamed:@"ic_view_list_white_18pt"];
                _label.text = NSLocalizedString(@"all", nil);
                break;
            case FooterButtonTypeShuffle:
                _image.image = [UIImage imageNamed:@"ic_shuffle_white_18pt"];
                _label.text = NSLocalizedString(@"shuffle", nil);
                break;
            case FooterButtonTypeRetro:
                _image.image = [UIImage imageNamed:@"ic_apps_white_18pt"];
                _label.text = NSLocalizedString(@"retro", nil);
                break;
        }
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor colorWithWhite:1 alpha:1];
        [self addSubview:_label];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    const CGFloat w = _label.intrinsicContentSize.width;
    const CGFloat h = _label.intrinsicContentSize.height;
    CGFloat y = (frame.size.height - h - 4 - 18) / 2;
    _image.frame = CGRectMake((frame.size.width - 18) / 2, y, 18, 18);
    y += 18 + 4;
    _label.frame = CGRectMake((frame.size.width - w) / 2, y, w, h);
}

- (void)didPushPushableView:(PushableView*)pushableView
{
    [_footerDelegate footerButton:self didTapWithType:_type];
}

@end
